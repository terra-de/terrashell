import QtQuick
import Quickshell.Services.SystemTray

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../vm" as QuickSettingsVm

/*
  TrayList
  Virtualized list view for system tray entries.
*/
Item {
    id: root

    required property int itemHeight
    required property int iconSize
    required property int spacing
    required property Item tooltipLayer
    required property Timer tooltipTimer
    required property QuickSettingsVm.PopoverState state

    readonly property int itemCount: SystemTray.items.values?.length ?? 0

    Item {
        id: trayContainer

        anchors.fill: parent
        visible: root.itemCount > 0
        clip: true

        Column {
            id: trayColumn

            width: trayContainer.width
            spacing: root.spacing

            Repeater {
                model: SystemTray.items

                delegate: TrayEntry {
                    required property var modelData

                    width: trayColumn.width
                    trayItem: modelData
                    itemHeight: root.itemHeight
                    iconSize: root.iconSize
                    tooltipLayer: root.tooltipLayer
                    tooltipTimer: root.tooltipTimer
                    state: root.state
                }
            }
        }
    }

    Text {
        visible: root.itemCount === 0
        text: "No tray items"
        font.family: Config.Appearance.fontFamily
        font.weight: Config.Appearance.fontWeight
        font.pixelSize: Config.Appearance.fontSizeMedium
        color: TTheme.Palette.color("muted")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        anchors.centerIn: parent
        width: parent.width
    }
}
