pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

import "./" as Services

/*
  WhichKeyService
  Tracks per-screen which-key state, exposes IPC entrypoints, and executes bind commands.
 */
Scope {
    id: root

    readonly property string panelId: "whichkey"
    property var entries: []
    property string currentSubmap: ""

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
        const state = root.targetState();
        if (!state) {
            return;
        }

        Services.PanelExclusivityService.requestOpen(root.panelId);
        root.closeAll();
        state.openLeader();
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
            root.currentSubmap = submap;
            fetchBindsProcess.exec(["/usr/bin/hyprctl", "binds", "-j"]);
        }

        function dismiss(): void {
            root.currentSubmap = "";
            root.closeAll();
        }
    }

    // Fetches hyprctl binds -j, filters by current submap, feeds to which-key state
    Process {
        id: fetchBindsProcess

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const raw = this.text.trim();
                    if (!raw) {
                        return;
                    }

                    const allBinds = JSON.parse(raw);
                    const submapName = root.currentSubmap;
                    if (!submapName) {
                        return;
                    }

                    const filtered = allBinds.filter(b => (b.submap || "") === submapName);
                    const entries = filtered.map(b => {
                        const keys = b.key.toLowerCase();
                        let icon = "";
                        let description = b.description || b.dispatcher || "";

                        // Parse <icon> prefix from description
                        // Format: "<icon_name>Description text"
                        const iconMatch = description.match(/^<([^>]+)>(.*)/);
                        if (iconMatch) {
                            icon = iconMatch[1];
                            description = iconMatch[2].trim();
                        }

                        return {
                            keys: keys,
                            description: description,
                            command: "",
                            icon: icon,
                        };
                    });

                    const state = root.targetState();
                    if (state) {
                        state.rebuildBinds(entries);
                        state.open = true;
                        state.path = [];
                        state.refreshView();
                        Services.PanelExclusivityService.requestOpen(root.panelId);
                    }
                } catch (e) {
                    console.warn("WhichKeyService: failed to process binds", e);
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
