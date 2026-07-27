pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    property bool open: false
    property int edgeInset: 0
    property bool sliderOnly: false
    property int sliderTriggerCount: 0

    function toggle() {
        root.open = !root.open;
        if (root.open) {
            root.sliderOnly = false;
        }
    }

    function close() {
        root.open = false;
        root.sliderOnly = false;
        root.sliderTriggerCount = 0;
    }

    function openPanel() {
        root.open = true;
        root.sliderOnly = false;
    }

    function openSlidersOnly() {
        root.open = true;
        root.sliderOnly = true;
        root.sliderTriggerCount++;
    }
}
