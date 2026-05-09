import QtQuick
import QtQuick.Layouts

import "../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../services" as Services
import "../../services/parsers/FileManagerIconMap.js" as IconMap

/*
  FileManagerListItem
  Delegate row for a single file or folder in the content view.
  Required context: model.fileName, model.fileIsDir, model.fileSuffix, model.filePath
*/
Rectangle {
    id: root

    required property int index
    required property string fileName
    required property bool fileIsDir
    required property string fileSuffix
    required property string filePath

    readonly property string iconName: IconMap.iconForEntry(root.fileName, root.fileIsDir, root.fileSuffix)
    readonly property bool selected: ListView.view?.currentIndex === root.index

    width: ListView.view?.width ?? parent?.width ?? 200
    height: 40
    radius: Config.Appearance.radiusSmall
    color: root.selected
        ? TTheme.Palette.color("c4")
        : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: Config.Motion.shortDuration
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 12

        Text {
            text: root.iconName
            color: root.selected ? TTheme.Palette.color("on_c0") : TTheme.Palette.color("muted")
            font.family: Config.Appearance.iconFontFamily
            font.pixelSize: 22
            font.weight: Font.Medium
            Layout.alignment: Qt.AlignVCenter
        }

        Text {
            text: root.fileName
            color: root.selected ? TTheme.Palette.color("on_c0") : TTheme.Palette.color("muted")
            font.family: Config.Appearance.fontFamily
            font.weight: Config.Appearance.fontWeight
            font.pixelSize: Config.Appearance.fontSizeMedium
            Layout.fillWidth: true
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
    }

    MouseArea {
        id: hoverMouseArea

        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton

        onClicked: {
            if (ListView.view) {
                ListView.view.currentIndex = root.index;
            }
        }

        onDoubleClicked: {
            if (root.fileIsDir) {
                Services.FileManagerService.navigateTo(root.filePath);
            } else {
                Services.FileManagerService.openFile(root.filePath);
            }
        }
    }
}
