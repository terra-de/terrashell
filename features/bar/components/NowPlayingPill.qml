import QtQuick

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../services" as Services
import "../../../utils" as Utils

Rectangle {
    id: root

    required property int barHeight
    required property string iconFont
    required property bool active

    signal clicked()

    readonly property int horizontalPadding: Math.max(8, Math.round(root.barHeight * 0.25))
    readonly property int verticalPadding: Math.max(5, Math.round(root.barHeight * 0.16))
    readonly property int iconSize: Math.max(16, Math.round(root.barHeight * 0.5))
    readonly property string trackTitle: Services.MediaPlayerService.trackTitle
    readonly property string trackArtist: Services.MediaPlayerService.trackArtist
    readonly property string displayText: root.trackTitle
        ? root.trackArtist
            ? `${root.trackArtist} - ${root.trackTitle}`
            : root.trackTitle
        : ""
    readonly property bool hasMedia: Services.MediaPlayerService.isPlaying && root.displayText !== ""

    visible: root.hasMedia

    color: root.active ? TTheme.Palette.color("c4") : TTheme.Palette.color("high")
    radius: Config.Appearance.radiusMedium

    implicitWidth: visible ? Math.min(300, root.displayText.length * 8 + root.horizontalPadding * 2) : 0
    implicitHeight: Utils.Bar.widgetHeight(root.barHeight, iconLabel.implicitHeight + root.verticalPadding * 2)

    Behavior on color {
        ColorAnimation {
            duration: Config.Motion.shortDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.Motion.standardCurve
        }
    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Config.Motion.shortDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.Motion.standardCurve
        }
    }

    Item {
        anchors.fill: parent
        clip: true

        Text {
            id: iconLabel

            anchors.left: parent.left
            anchors.leftMargin: root.horizontalPadding
            anchors.verticalCenter: parent.verticalCenter
            text: "music_note"
            font.family: Config.Appearance.iconFontFamily
            font.pixelSize: root.iconSize
            color: root.active ? TTheme.Palette.color("on_c4") : TTheme.Palette.color("standard")
        }

        Text {
            anchors.left: iconLabel.right
            anchors.leftMargin: Math.max(4, Math.round(root.horizontalPadding * 0.4))
            anchors.right: parent.right
            anchors.rightMargin: root.horizontalPadding
            anchors.verticalCenter: parent.verticalCenter
            text: root.displayText
            font.family: Config.Appearance.fontFamily
            font.pixelSize: Math.max(11, Math.round(Config.Appearance.fontSizeSmall))
            font.weight: Font.Medium
            color: root.active ? TTheme.Palette.color("on_c4") : TTheme.Palette.color("standard")
            elide: Text.ElideRight
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.visible
        onClicked: root.clicked()
    }
}
