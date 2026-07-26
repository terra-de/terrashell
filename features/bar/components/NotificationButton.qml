import QtQuick

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../services" as Services
import "../../../utils" as Utils

/*
  NotificationButton
  Compact action button that toggles the right-edge notification panel.
  Shows a numbered red badge for unread notifications.
  Required properties: barHeight, iconFont, active.
*/
Rectangle {
    id: root

    required property int barHeight
    required property string iconFont
    required property bool active

    signal clicked()

    readonly property int horizontalPadding: Math.max(8, Math.round(root.barHeight * 0.25))
    readonly property int verticalPadding: Math.max(5, Math.round(root.barHeight * 0.16))
    readonly property int iconSize: Math.max(16, Math.round(root.barHeight * 0.5))
    readonly property int unreadCount: Services.NotificationService.unreadCount

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
        text: "notifications"
        font.family: root.iconFont
        font.pixelSize: root.iconSize
        font.weight: Font.Medium
        color: root.active ? TTheme.Palette.color("on_c4") : TTheme.Palette.color("standard")
    }

    Rectangle {
        visible: root.unreadCount > 0
        width: Math.max(16, Math.round(root.barHeight * 0.4))
        height: Math.max(16, Math.round(root.barHeight * 0.4))
        radius: width / 2
        color: TTheme.Palette.color("error")
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Math.max(1, Math.round(root.verticalPadding * 0.2))
        anchors.rightMargin: Math.max(1, Math.round(root.horizontalPadding * 0.15))
        z: 2

        Text {
            anchors.centerIn: parent
            text: root.unreadCount > 99 ? "99+" : root.unreadCount.toString()
            font.pixelSize: Math.max(8, Math.round(parent.height * 0.55))
            font.weight: Font.Bold
            color: TTheme.Palette.color("on_error")
            fontSizeMode: Text.Fit
            minimumPixelSize: 6
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
