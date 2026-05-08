import QtQuick
import QtQuick.Layouts
import Qt.labs.platform as Platform

import "../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../services" as Services
import "../../services/parsers/FileManagerIconMap.js" as IconMap

/*
  FileManagerSidebar
  Left shortcuts panel with static XDG directory bookmarks.
*/
Rectangle {
    id: root

    color: TTheme.Palette.color("front")
    radius: Config.Appearance.radiusMedium

    readonly property var shortcuts: [
        {
            name: "Home",
            path: "file://" + Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation),
            icon: IconMap.iconForShortcut("Home")
        },
        {
            name: "Desktop",
            path: "file://" + Platform.StandardPaths.writableLocation(Platform.StandardPaths.DesktopLocation),
            icon: IconMap.iconForShortcut("Desktop")
        },
        {
            name: "Documents",
            path: "file://" + Platform.StandardPaths.writableLocation(Platform.StandardPaths.DocumentsLocation),
            icon: IconMap.iconForShortcut("Documents")
        },
        {
            name: "Downloads",
            path: "file://" + Platform.StandardPaths.writableLocation(Platform.StandardPaths.DownloadLocation),
            icon: IconMap.iconForShortcut("Downloads")
        },
        {
            name: "Pictures",
            path: "file://" + Platform.StandardPaths.writableLocation(Platform.StandardPaths.PicturesLocation),
            icon: IconMap.iconForShortcut("Pictures")
        },
        {
            name: "Music",
            path: "file://" + Platform.StandardPaths.writableLocation(Platform.StandardPaths.MusicLocation),
            icon: IconMap.iconForShortcut("Music")
        },
        {
            name: "Videos",
            path: "file://" + Platform.StandardPaths.writableLocation(Platform.StandardPaths.MoviesLocation),
            icon: IconMap.iconForShortcut("Videos")
        }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        anchors.topMargin: 12
        spacing: 2

        Repeater {
            model: root.shortcuts

            Rectangle {
                required property var modelData

                readonly property bool active: Services.FileManagerService.currentFolder === modelData.path

                Layout.fillWidth: true
                height: 36
                radius: Config.Appearance.radiusSmall
                color: active ? TTheme.Palette.color("c0") : (shortcutMouseArea.containsMouse ? TTheme.Palette.color("top") : "transparent")

                Behavior on color {
                    ColorAnimation {
                        duration: Config.Motion.shortDuration
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Text {
                        text: modelData.icon
                        color: active ? TTheme.Palette.color("on_c0") : TTheme.Palette.color("muted")
                        font.family: Config.Appearance.iconFontFamily
                        font.pixelSize: 20
                        font.weight: Font.Medium
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: modelData.name
                        color: active ? TTheme.Palette.color("on_c0") : TTheme.Palette.color("muted")
                        font.family: Config.Appearance.fontFamily
                        font.weight: Config.Appearance.fontWeight
                        font.pixelSize: Config.Appearance.fontSizeMedium
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                }

                MouseArea {
                    id: shortcutMouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton
                    onClicked: Services.FileManagerService.navigateTo(modelData.path)
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
