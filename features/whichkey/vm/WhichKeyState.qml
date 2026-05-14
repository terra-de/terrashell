pragma ComponentBehavior: Bound

import QtQuick

/*
  WhichKeyState
  Stores which-key display state for a screen.
  Entries come from IPC show() via rebuildBinds(), not local config navigation.
  The popup is display-only — Hyprland submaps drive all navigation.
*/
QtObject {
    id: root

    required property var config

    property bool enabled: true
    property bool open: false
    property string title: "Leader"
    property var entries: []

    function rebuildBinds(binds) {
        if (!Array.isArray(binds) || binds.length === 0) {
            return;
        }
        root.entries = binds;
    }

    function close() {
        root.open = false;
    }

    onConfigChanged: {
        const c = config && typeof config === "object" ? config : ({});
        root.enabled = c.enabled !== false;
        root.title = typeof c.title === "string" && c.title.trim() ? c.title.trim() : "Leader";
        if (!root.enabled) {
            root.open = false;
        }
    }

    Component.onCompleted: root.configChanged(config)
}
