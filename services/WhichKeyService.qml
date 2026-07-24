pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import "./" as Services
import "../features/whichkey/vm/WhichKeyTree.js" as WhichKeyTree

/*
  WhichKeyService
  Tracks per-screen which-key state, exposes IPC entrypoints, and executes bind commands.
 */
Scope {
    id: root

    readonly property string panelId: "whichkey"
    property var entries: []
    property string currentSubmap: ""

    // Cache of all hyprctl binds (loaded once, invalidated on config reload).
    // Avoids async races from running hyprctl binds -j on every submap change.
    property var bindsCache: null
    property bool bindsLoading: false
    property var bindsPending: []

    // Derive a display title from a submap slug like "leader_window" -> "Window"
    function titleForSubmap(slug) {
        if (!slug) return "Leader";
        var parts = slug.split("_");
        var name = parts[parts.length - 1];
        return name.charAt(0).toUpperCase() + name.slice(1);
    }

    function monitorKey(monitor) {
        if (!monitor) {
            return "";
        }

        return monitor.name
            || monitor.connector
            || monitor.id
            || monitor.lastIpcObject?.name
            || "";
    }

    function focusedMonitorKey() {
        return root.monitorKey(Hyprland.focusedMonitor);
    }

    function stateEntryForFocusedMonitor() {
        const key = root.focusedMonitorKey();
        if (key === "") {
            return null;
        }

        for (const entry of root.entries) {
            if (!entry || !entry.screen || !entry.state) {
                continue;
            }

            const monitor = Hyprland.monitorFor(entry.screen);
            if (root.monitorKey(monitor) === key) {
                return entry;
            }
        }

        return null;
    }

    function fallbackEntry() {
        for (const entry of root.entries) {
            if (entry && entry.state) {
                return entry;
            }
        }

        return null;
    }

    function withTargetState(callback) {
        const entry = root.stateEntryForFocusedMonitor() || root.fallbackEntry();
        if (!entry || !entry.state) {
            return;
        }

        callback(entry.state);
    }

    function targetState() {
        const entry = root.stateEntryForFocusedMonitor() || root.fallbackEntry();
        if (!entry || !entry.state) {
            return null;
        }

        return entry.state;
    }

    function registerScreenState(screen, state) {
        if (!screen || !state) {
            return;
        }

        const filtered = root.entries.filter(entry => entry && entry.state && entry.state !== state);
        filtered.push({
            screen: screen,
            state: state
        });
        root.entries = filtered;
    }

    function unregisterScreenState(state) {
        if (!state) {
            return;
        }

        root.entries = root.entries.filter(entry => entry && entry.state && entry.state !== state);
    }

    function openLeader() {
        root.show("leader");
    }

    function toggleLeader() {
        if (root.isTargetOpen()) {
            root.close();
            return;
        }

        root.openLeader();
    }

    function close() {
        root.withTargetState(state => state.close());
    }

    function closeAll() {
        for (const entry of root.entries) {
            if (entry?.state) {
                entry.state.close();
            }
        }
    }

    function isOpen() {
        for (const entry of root.entries) {
            if (entry?.state?.open) {
                return true;
            }
        }

        return false;
    }

    function isTargetOpen() {
        const state = root.targetState();
        return state ? state.open : false;
    }

    function executeCommand(command) {
        const normalized = typeof command === "string" ? command.trim() : "";
        if (!normalized) {
            return;
        }
        commandProcess.exec(["/bin/sh", "-lc", normalized]);
    }

    function applyBindsToState(submapName) {
        const state = root.targetState();
        if (!state || !root.bindsCache) return;

        const filtered = root.bindsCache.filter(function(b) {
            return (b.submap || "") === submapName;
        });
        const entries = filtered.map(function(b) {
            return {
                key: b.key,
                description: b.description || b.dispatcher || "",
                dispatcher: b.dispatcher || "",
                icon: "",
            };
        });

        const title = root.titleForSubmap(submapName);
        state.rebuildBinds(WhichKeyTree.normalizeBinds(entries), title);
        state.open = true;
        Services.PanelExclusivityService.requestOpen(root.panelId);
    }

    function flushPending() {
        while (root.bindsPending.length > 0) {
            const pending = root.bindsPending.shift();
            root.applyBindsToState(pending);
        }
    }

    function show(submap) {
        root.currentSubmap = submap;

        if (root.bindsCache) {
            root.applyBindsToState(submap);
            return;
        }

        // Queue this submap for when the cache is ready
        root.bindsPending.push(submap);

        if (root.bindsLoading) return;
        root.bindsLoading = true;
        fetchBindsProcess.exec(["/bin/sh", "-lc", "tctl binds list"]);
    }

    IpcHandler {
        target: "whichkey"

        function toggleLeader(): void {
            root.toggleLeader();
        }

        function close(): void {
            root.close();
        }

        function isOpen(): bool {
            return root.isOpen();
        }

        function show(submap: string): void {
            root.show(submap);
        }

        function dismiss(): void {
            root.currentSubmap = "";
            root.closeAll();
        }

        function reloadBinds(): void {
            root.bindsCache = null;
        }
    }

    // Fetches hyprctl binds -j once, then caches the result for all subsequent
    // show() calls.  Eliminates the async race where multiple rapid submap
    // changes trigger overlapping process completions with stale submap state.
    Process {
        id: fetchBindsProcess

        stdout: StdioCollector {
            onStreamFinished: {
                root.bindsLoading = false;
                try {
                    const raw = this.text.trim();
                    if (!raw) return;

                    root.bindsCache = JSON.parse(raw);
                    root.flushPending();
                } catch (e) {
                    console.warn("WhichKeyService: failed to parse binds", e);
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {
                const err = this.text.trim();
                if (err) {
                    console.warn("WhichKeyService: hyprctl binds error", err);
                }
            }
        }
    }

    Process {
        id: commandProcess

        stderr: StdioCollector {
            onStreamFinished: {
                const output = text.trim();
                if (output) {
                    console.warn("WhichKeyService command failed", output);
                }
            }
        }
    }

    Component.onCompleted: Services.PanelExclusivityService.registerPanel(root.panelId, root)
    Component.onDestruction: Services.PanelExclusivityService.unregisterPanel(root.panelId, root)
}
