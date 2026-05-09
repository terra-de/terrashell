import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import "../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../design/primitives" as Primitives
import "../../services" as Services

/*
  WorkspaceRenamePanelFeature
  Top slide-out panel for renaming the current Hyprland workspace.
  Required properties: panelScreen.
 */
Primitives.SlideOutPanelWindow {
    id: root

    readonly property int contentPadding: 16
    readonly property int inputHeight: Math.max(28, Math.round(Config.Appearance.fontSizeMedium * 1.5 + 10))
    readonly property int inputWidth: Math.max(180, Math.round(parent?.width ?? 800 * 0.28))
    readonly property int panelHeight: contentPadding + inputHeight + contentPadding
    readonly property int overshootPadding: 24
    readonly property color surfaceColor: TTheme.Palette.color("base")

    open: false
    closeDurationMs: Config.Motion.shortDuration
    focusable: true
    WlrLayershell.namespace: "quickshell-workspacerename"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    onOpenChanged: {
        if (open) {
            focusTimer.restart();
            renameInput.text = Services.WorkspaceService.currentWorkspaceName || "";
            renameInput.selectAll();
        } else {
            focusRetryTimer.stop();
            renameInput.text = "";
        }
    }

    HyprlandFocusGrab {
        windows: [root]
        active: root.open

        onCleared: {
            if (root.open) {
                root.open = false;
            }
        }
    }

    Timer {
        id: focusTimer

        interval: 0
        repeat: false
        onTriggered: {
            renameInput.forceActiveFocus();
            renameInput.selectAll();
        }
    }

    Timer {
        id: focusRetryTimer

        interval: 70
        repeat: false
        onTriggered: {
            if (root.open) {
                renameInput.forceActiveFocus();
                renameInput.selectAll();
            }
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        y: Math.max(0, Math.round(mainPanel.visibleSurfaceY + root.panelHeight))
        height: Math.max(0, Math.round(parent.height - y))
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        enabled: root.open
        onClicked: root.open = false
    }

    Primitives.SlideOutPanelSurface {
        id: mainPanel

        anchors.fill: parent
        attachedEdge: "top"
        primaryExtent: root.panelHeight
        overshootPadding: root.overshootPadding
        openDelay: 0
        active: root.presentationOpen
        open: root.open
        surfaceColor: root.surfaceColor
        shadowOffsetY: Config.Appearance.shadowOffsetY

        Rectangle {
            anchors.fill: parent
            radius: Config.Appearance.radiusLarge
            color: root.surfaceColor

            Item {
                anchors.fill: parent
                anchors.leftMargin: root.contentPadding

                Text {
                    id: label

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Rename workspace:"
                    color: TTheme.Palette.color("standard")
                    font.family: Config.Appearance.fontFamily
                    font.pixelSize: Config.Appearance.fontSizeMedium
                    font.weight: Font.Medium
                    verticalAlignment: Text.AlignVCenter
                }

                Rectangle {
                    anchors.left: label.right
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: root.inputWidth
                    height: root.inputHeight
                    radius: Config.Appearance.radiusMedium
                    color: TTheme.Palette.color("high")
                    border.width: 1
                    border.color: TTheme.Palette.color("outline")

                    TextInput {
                        id: renameInput

                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        clip: true
                        color: TTheme.Palette.color("standard")
                        selectedTextColor: TTheme.Palette.color("on_c0")
                        selectionColor: TTheme.Palette.color("c0")
                        font.family: Config.Appearance.fontFamily
                        font.pixelSize: Config.Appearance.fontSizeMedium
                        font.weight: Font.Normal
                        verticalAlignment: TextInput.AlignVCenter
                        echoMode: TextInput.Normal

                        Text {
                            id: placeholderText

                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            text: Services.WorkspaceService.currentWorkspaceName || ""
                            color: TTheme.Palette.color("muted")
                            font.family: Config.Appearance.fontFamily
                            font.pixelSize: Config.Appearance.fontSizeMedium
                            font.weight: Font.Normal
                            verticalAlignment: TextInput.AlignVCenter
                            elide: Text.ElideRight
                            visible: renameInput.text.length === 0 && !renameInput.activeFocus
                        }

                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.open = false;
                                event.accepted = true;
                                return;
                            }

                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                Services.WorkspaceService.renameWorkspace(
                                    Services.WorkspaceService.currentWorkspaceId,
                                    renameInput.text.trim()
                                );
                                root.open = false;
                                event.accepted = true;
                                return;
                            }
                        }
                    }
                }
            }
        }
    }
}
