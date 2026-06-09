pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "parsers/KeyboardParsers.js" as KeyboardParsers

/*
  KeyboardService
  Manages wvkbd-deskintl on-screen keyboard state.
  Signals: SIGUSR2 = show, SIGUSR1 = hide

  Convergence logic: after a local toggle, `localToggleInFlight` stays true
  until the actual layer state matches `intendedVisible`. This prevents the
  polling timer from overwriting `visible` back to the stale pre-transition
  state before Hyprland's layer tracking has updated.
*/
Scope {
    id: root

    property bool visible: false
    property bool localToggleInFlight: false
    property bool intendedVisible: false
    readonly property int localToggleSettleMs: 2000

    function refresh() {
        detectProcess.exec(["hyprctl", "-j", "layers"]);
    }

    function show() {
        root.visible = true;
        root.intendedVisible = true;
        root.localToggleInFlight = true;
        settleTimer.restart();
        sigProcess.exec(["/bin/sh", "-lc", "tctl osk show"]);
        refreshDelay.restart();
    }

    function hide() {
        root.visible = false;
        root.intendedVisible = false;
        root.localToggleInFlight = true;
        settleTimer.restart();
        sigProcess.exec(["/bin/sh", "-lc", "tctl osk hide"]);
        refreshDelay.restart();
    }

    function toggle() {
        sigProcess.exec(["/bin/sh", "-lc", "tctl osk toggle"]);
        refreshDelay.restart();
    }

    IpcHandler {
        target: "keyboard"

        function toggle(): void {
            root.toggle();
        }

        function show(): void {
            root.show();
        }

        function hide(): void {
            root.hide();
        }

        function isVisible(): bool {
            return root.visible;
        }
    }

    Process {
        id: sigProcess

        stdout: StdioCollector {
            onStreamFinished: refreshDelay.restart()
        }

        stderr: StdioCollector {
            onStreamFinished: refreshDelay.restart()
        }
    }

    Process {
        id: detectProcess

        stdout: StdioCollector {
            onStreamFinished: {
                const actualVisible = KeyboardParsers.parseLayerState(text, "wvkbd");
                if (root.localToggleInFlight) {
                    // Wait for actual state to converge with intended state
                    if (actualVisible === root.intendedVisible) {
                        root.localToggleInFlight = false;
                        root.visible = actualVisible;
                    }
                    // else: still waiting for transition — don't update visible
                } else {
                    root.visible = actualVisible;
                }
            }
        }

        stderr: StdioCollector {
            onStreamFinished: {}
        }
    }

    Timer {
        id: refreshDelay

        interval: 120
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: pollingTimer

        interval: 300
        repeat: true
        running: true
        onTriggered: root.refresh()
    }

    Timer {
        id: settleTimer

        // Failsafe: if convergence doesn't happen within this window
        // (e.g. signal lost, wvkbd crashed), force the intended state.
        interval: root.localToggleSettleMs
        repeat: false
        onTriggered: {
            root.localToggleInFlight = false;
            root.visible = root.intendedVisible;
        }
    }

    Component.onCompleted: {
        sigProcess.exec(["/bin/sh", "-lc", "tctl osk show"]);
        refreshDelay.restart();
    }
}
