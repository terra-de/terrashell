import QtQuick
import QtQuick.Layouts

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme

Item {
    id: root

    property string artUrl: ""
    property int artworkSize: 200

    implicitWidth: root.artworkSize
    implicitHeight: root.artworkSize

    Rectangle {
        anchors.fill: parent
        radius: Config.Appearance.radiusMedium
        color: TTheme.Palette.color("high")
        visible: !artImage.visible

        Text {
            anchors.centerIn: parent
            text: "music_note"
            font.family: Config.Appearance.iconFontFamily
            font.pixelSize: Math.round(root.artworkSize * 0.35)
            color: TTheme.Palette.color("muted")
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Config.Appearance.radiusMedium
        clip: true
        color: "transparent"
        visible: artImage.status === Image.Ready

        Image {
            id: artImage

            anchors.fill: parent
            source: root.artUrl
            sourceSize.width: root.artworkSize
            sourceSize.height: root.artworkSize
            fillMode: Image.PreserveAspectCrop
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Config.Appearance.radiusMedium
        color: "transparent"
        border.color: TTheme.Palette.color("outline")
        border.width: 1
        visible: artImage.visible
    }
}
