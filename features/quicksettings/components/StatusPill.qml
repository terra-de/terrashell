import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../utils" as Utils

/*
  StatusPill
  Compact status row used as quick settings trigger.
*/
Rectangle {
    id: root

    required property int barHeight
    required property int spacing
    required property string materialFont
    required property int iconSize
    required property int horizontalPadding
    required property var viewModel

    radius: Config.Appearance.radiusMedium
    color: TTheme.Palette.color("front")

    PwObjectTracker {
        objects: [root.viewModel.defaultSink]
    }

    implicitWidth: contentRow.implicitWidth + root.horizontalPadding * 2
    implicitHeight: root.barHeight

    RowLayout {
        id: contentRow

        anchors.fill: parent
        anchors.leftMargin: root.horizontalPadding
        anchors.rightMargin: root.horizontalPadding
        spacing: root.spacing

        Text {
            text: root.viewModel.wifiIconName
            color: TTheme.Palette.color("standard")
            font.family: root.materialFont
            font.pixelSize: root.iconSize
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.viewModel.volumeIconName
            color: TTheme.Palette.color("standard")
            font.family: root.materialFont
            font.pixelSize: root.iconSize
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.viewModel.batteryIconName
            visible: root.viewModel.hasBattery
            color: root.viewModel.batteryTextColor
            font.family: root.materialFont
            font.pixelSize: root.iconSize
            font.weight: Font.Medium
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.viewModel.batteryPercentLabel
            visible: root.viewModel.hasBattery
            color: root.viewModel.batteryTextColor
            font.family: Config.Appearance.fontFamily
            font.weight: Config.Appearance.fontWeight
            font.pixelSize: Config.Appearance.fontSizeSmall
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.viewModel.dateText
            color: TTheme.Palette.color("standard")
            font.family: Config.Appearance.fontFamily
            font.weight: Config.Appearance.fontWeight
            font.pixelSize: Config.Appearance.fontSizeSmall
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.viewModel.timeText
            color: TTheme.Palette.color("standard")
            font.family: Config.Appearance.fontFamily
            font.weight: Config.Appearance.fontWeight
            font.pixelSize: Config.Appearance.fontSizeSmall
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
