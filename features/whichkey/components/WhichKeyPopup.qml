import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../design/primitives" as Primitives

/*
  WhichKeyPopup
  Display-only which-key overlay driven by Hyprland submap IPC.
  All navigation is handled by Hyprland submaps — this popup
  just shows the available keys for the current submap.
  Required properties: panelScreen, active, viewModel, style.
*/
Primitives.SlideOutPanelWindow {
    id: root

    required property bool active
    required property var viewModel
    required property var style

    readonly property int contentPadding: Config.Config.appDrawer?.size?.padding ?? 18
    readonly property int contentSpacing: Config.Config.appDrawer?.size?.spacing ?? 14
    readonly property int headerHeight: Config.Config.appDrawer?.size?.searchHeight ?? 44
    readonly property int headerHorizontalPadding: Config.Config.appDrawer?.size?.searchHorizontalPadding ?? 18
    readonly property int drawerRows: Math.max(1, Config.Config.appDrawer?.size?.rows ?? 3)
    readonly property int drawerTileHeight: Config.Config.appDrawer?.size?.tileHeight ?? 104
    readonly property int drawerTileSpacing: Config.Config.appDrawer?.size?.tileSpacing ?? 10
    readonly property int footerHeight: 36
    readonly property int overshootBottomPadding: Config.Config.appDrawer?.size?.overshootPadding
        ?? Math.max(72, Math.round(root.panelHeight * 0.22))
    readonly property int drawerOpenDelay: Config.Config.appDrawer?.behavior?.drawerOpenDelay ?? 0
    readonly property int panelOpenDurationMs: Config.Motion.shellDuration
    readonly property int panelCloseDurationMs: Config.Motion.shortDuration
    readonly property color surfaceColor: TTheme.Palette.color("base")
    readonly property color sectionColor: TTheme.Palette.color("high")
    readonly property int sectionHeight: drawerRows * drawerTileHeight
        + Math.max(0, drawerRows - 1) * drawerTileSpacing
    readonly property int panelHeight: contentPadding
        + headerHeight
        + contentSpacing
        + sectionHeight
        + contentSpacing
        + footerHeight
        + contentPadding

    readonly property int columns: Math.max(1, style?.columns ?? 2)
    readonly property int columnSpacing: style?.columnSpacing ?? 12
    readonly property int rowSpacing: style?.rowSpacing ?? 8
    readonly property int itemHeight: style?.itemHeight ?? 44
    readonly property int iconSize: style?.iconSize ?? 18
    readonly property int keySize: style?.keySize ?? 13

    open: root.active
    closeDurationMs: root.panelCloseDurationMs
    WlrLayershell.namespace: "quickshell-whichkey"
    WlrLayershell.layer: WlrLayer.Overlay

    Primitives.SlideOutPanelSurface {
        id: mainPanel

        anchors.fill: parent
        attachedEdge: "bottom"
        primaryExtent: root.panelHeight
        overshootPadding: root.overshootBottomPadding
        openDelay: root.drawerOpenDelay
        active: root.presentationOpen
        open: root.open
        surfaceColor: root.surfaceColor
        shadowOffsetY: -Config.Appearance.shadowOffsetY

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.contentPadding
            spacing: root.contentSpacing

            // Header: title only (crumb removed — navigation is submap-driven)
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.headerHeight
                Layout.leftMargin: root.headerHorizontalPadding
                Layout.rightMargin: root.headerHorizontalPadding

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.viewModel.title || "Leader"
                    color: TTheme.Palette.color("standard")
                    font.family: Config.Appearance.fontFamily
                    font.pixelSize: Config.Appearance.fontSizeLarge
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
            }

            // Main key grid
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Config.Appearance.radiusLarge
                color: root.sectionColor
                clip: true

                Item {
                    anchors.fill: parent
                    anchors.margins: root.contentPadding

                    Flickable {
                        id: listFlick

                        anchors.fill: parent
                        contentWidth: width
                        contentHeight: contentGrid.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        GridLayout {
                            id: contentGrid

                            width: listFlick.width
                            columns: root.columns
                            rowSpacing: root.rowSpacing
                            columnSpacing: root.columnSpacing

                            Repeater {
                                model: root.viewModel.entries

                                delegate: Rectangle {
                                    id: delegateRoot

                                    required property var modelData

                                    readonly property string bindKey: modelData.key || ""
                                    readonly property string bindLabel: modelData.label || ""
                                    readonly property string bindDescription: modelData.description || ""
                                    readonly property string bindIcon: modelData.icon || "bolt"
                                    readonly property bool bindHasChildren: modelData.hasChildren ?? false

                                    Layout.fillWidth: true
                                    Layout.preferredHeight: root.itemHeight
                                    radius: Config.Appearance.radiusMedium
                                    color: TTheme.Palette.color("top")

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.leftMargin: 10
                                        anchors.rightMargin: 10
                                        spacing: 8

                                        Text {
                                            text: delegateRoot.bindIcon
                                            color: TTheme.Palette.color("muted")
                                            font.family: Config.Appearance.iconFontFamily
                                            font.pixelSize: root.iconSize
                                            font.weight: Font.Medium
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        Rectangle {
                                            Layout.preferredWidth: 28
                                            Layout.preferredHeight: 22
                                            radius: 6
                                            color: TTheme.Palette.color("high")
                                            border.width: 1
                                            border.color: TTheme.Palette.color("outline")

                                            Text {
                                                anchors.centerIn: parent
                                                text: delegateRoot.bindLabel
                                                color: TTheme.Palette.color("standard")
                                                font.family: Config.Appearance.fontFamily
                                                font.pixelSize: root.keySize
                                                font.weight: Font.DemiBold
                                            }
                                        }

                                        Text {
                                            text: delegateRoot.bindDescription
                                            color: TTheme.Palette.color("standard")
                                            font.family: Config.Appearance.fontFamily
                                            font.pixelSize: Config.Appearance.fontSizeMedium
                                            font.weight: Config.Appearance.fontWeight
                                            Layout.fillWidth: true
                                            elide: Text.ElideRight
                                            verticalAlignment: Text.AlignVCenter
                                        }

                                        Text {
                                            visible: delegateRoot.bindHasChildren
                                            text: "chevron_right"
                                            color: TTheme.Palette.color("muted")
                                            font.family: Config.Appearance.iconFontFamily
                                            font.pixelSize: root.iconSize
                                            font.weight: Font.Medium
                                            Layout.alignment: Qt.AlignVCenter
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Footer: special keys always shown
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: root.footerHeight

                Text {
                    anchors.centerIn: parent
                    text: "Esc Close    Backspace Back"
                    color: TTheme.Palette.color("muted")
                    font.family: Config.Appearance.fontFamily
                    font.pixelSize: Config.Appearance.fontSizeSmall
                    font.weight: Font.Medium
                }
            }
        }
    }
}
