import QtQuick

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../vm" as QuickSettingsVm

/*
  TrayTooltip
  Tooltip bubble for system tray item metadata.
*/
Item {
    id: root

    required property QuickSettingsVm.PopoverState state
    required property int maxWidth

    readonly property int padding: 8

    visible: root.state.trayTooltipVisible

    Item {
        id: bubble

        width: root.maxWidth
        height: Math.max(24, Math.round(content.implicitHeight + root.padding * 2))
        x: Math.min(Math.max(0, root.state.trayTooltipX), Math.max(0, root.width - width))
        y: Math.min(
            Math.max(0, Math.round(root.state.trayTooltipY - height - 6)),
            Math.max(0, root.height - height)
        )

        Rectangle {
            anchors.fill: parent
            radius: Config.Appearance.radiusSmall
            color: TTheme.Palette.color("top")
        }

        Column {
            id: content

            anchors.fill: parent
            anchors.margins: root.padding
            spacing: 4
            width: bubble.width - root.padding * 2

            Text {
                text: root.state.trayTooltipTitle
                font.family: Config.Appearance.fontFamily
                font.weight: Config.Appearance.fontWeight
                font.pixelSize: Config.Appearance.fontSizeMedium
                color: TTheme.Palette.color("standard")
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                width: content.width
                visible: text !== ""
            }

            Text {
                visible: root.state.trayTooltipDescription !== ""
                text: root.state.trayTooltipDescription
                font.family: Config.Appearance.fontFamily
                font.weight: Config.Appearance.fontWeight
                font.pixelSize: Math.max(10, Math.round(Config.Appearance.fontSizeSmall))
                color: TTheme.Palette.color("muted")
                wrapMode: Text.Wrap
                textFormat: Text.PlainText
                width: content.width
            }
        }
    }
}
