pragma ComponentBehavior: Bound

import QtQuick

/*
  NotificationPanelState
  Shared per-screen state for notification panel visibility and animated edge inset.
*/
QtObject {
    id: root

    property bool open: false
    property int edgeInset: 0

    function toggle() {
        root.open = !root.open;
    }

    function close() {
        root.open = false;
    }

    function openPanel() {
        root.open = true;
    }
}
