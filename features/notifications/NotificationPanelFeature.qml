import QtQuick
import QtQuick.Layouts

import "../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../design/primitives" as Primitives
import "../../services" as Services
import "./components" as NotificationComponents
import "./vm" as NotificationPanelVm

/*
  NotificationPanelFeature
  Full-height right-edge notification history drawer.
  Required properties: panelScreen, state.
*/
Primitives.SlideOutPanelWindow {
    id: root

    required property NotificationPanelVm.NotificationPanelState state

    readonly property int panelWidth: Config.Config.notifications?.panel?.width ?? 420
    readonly property int contentPadding: Config.Config.controlCenter?.size?.padding ?? 16
    readonly property int contentSpacing: Config.Config.controlCenter?.size?.spacing ?? 12
    readonly property int overshootRightPadding: Config.Config.controlCenter?.size?.overshootPadding
        ?? Math.max(96, Math.round(panelWidth * 0.24))
    readonly property int drawerOpenDelay: Config.Config.controlCenter?.transition?.drawerOpenDelay ?? 0
    readonly property int panelOpenDurationMs: Config.Motion.shellDuration
    readonly property int panelCloseDurationMs: Config.Motion.shortDuration
    readonly property color surfaceColor: TTheme.Palette.color("base")
    readonly property color sectionColor: TTheme.Palette.color("high")

    open: root.state.open
    closeDurationMs: root.panelCloseDurationMs
    focusable: true

    onOpenChanged: {
        if (root.open) {
            keyRouter.forceActiveFocus();
        }
    }

    Item {
        id: keyRouter

        anchors.fill: parent
        focus: root.state.open

        Keys.onPressed: event => {
            if (!root.state.open) {
                return;
            }

            if (event.key === Qt.Key_Escape) {
                root.state.close();
                event.accepted = true;
            }
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: Math.max(0, Math.round(mainPanel.visibleSurfaceX))
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        enabled: root.state.open
        onClicked: root.state.close()
    }

    Primitives.SlideOutPanelSurface {
        id: mainPanel

        anchors.fill: parent
        attachedEdge: "right"
        primaryExtent: root.panelWidth
        overshootPadding: root.overshootRightPadding
        openDelay: root.drawerOpenDelay
        active: root.presentationOpen
        open: root.open
        surfaceColor: root.surfaceColor

        onEdgeInsetChanged: root.state.edgeInset = edgeInset

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.contentPadding
            spacing: root.contentSpacing

            Text {
                text: "Notifications"
                font.family: Config.Appearance.fontFamily
                font.weight: Font.DemiBold
                font.pixelSize: Math.max(16, Math.round(Config.Appearance.fontSizeLarge * 1.1))
                color: TTheme.Palette.color("standard")
                Layout.fillWidth: true
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true

                NotificationComponents.NotificationsPanel {
                    anchors.fill: parent
                    panelWidth: root.panelWidth
                    open: root.presentationOpen
                }
            }
        }
    }
}
