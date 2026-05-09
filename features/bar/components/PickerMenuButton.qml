import QtQuick

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../utils" as Utils

/*
  PickerMenuButton
  Compact action button that opens the mouse-first picker menu.
  Required properties: barHeight, iconFont, active.
 */
Rectangle {
    id: root

    required property int barHeight
    required property string iconFont
    required property bool active

    signal clicked(var mouse)

    readonly property int horizontalPadding: Math.max(8, Math.round(root.barHeight * 0.25))
    readonly property int verticalPadding: Math.max(5, Math.round(root.barHeight * 0.16))
    readonly property int iconSize: Math.max(16, Math.round(root.barHeight * 0.5))

    color: root.active ? TTheme.Palette.color("c4") : TTheme.Palette.color("high")
    radius: Config.Appearance.radiusMedium

    implicitWidth: iconLabel.implicitWidth + root.horizontalPadding * 2
    implicitHeight: Utils.Bar.widgetHeight(root.barHeight, iconLabel.implicitHeight + root.verticalPadding * 2)

    Behavior on color {
        ColorAnimation {
            duration: Config.Motion.shortDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.Motion.standardCurve
        }
    }

    Text {
        id: iconLabel

        anchors.centerIn: parent
        text: "search"
        font.family: root.iconFont
        font.pixelSize: root.iconSize
        font.weight: Font.Medium
        color: root.active ? TTheme.Palette.color("on_c0") : TTheme.Palette.color("standard")
    }

    MouseArea {
        anchors.fill: parent
        onClicked: mouse => root.clicked(mouse)
    }
}
