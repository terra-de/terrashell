import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel

import "../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../services" as Services
import "./" as FileManagerComponents

/*
  FileManagerContentView
  Main directory listing using FolderListModel backed by FileManagerService.
*/
Rectangle {
    id: root

    color: TTheme.Palette.color("front")
    radius: Config.Appearance.radiusMedium

    FolderListModel {
        id: folderModel

        folder: Services.FileManagerService.currentFolder
        showDirsFirst: true
        showHidden: Config.Config.fileManager?.showHidden ?? false
        sortField: FolderListModel.Name
    }

    ListView {
        id: listView

        anchors.fill: parent
        anchors.margins: 6
        clip: true
        model: folderModel
        spacing: 2
        boundsBehavior: Flickable.StopAtBounds
        reuseItems: true
        cacheBuffer: 40 * 8

        delegate: FileManagerComponents.FileManagerListItem {
            // required properties are auto-bound from delegate context:
            // index, fileName, fileIsDir, fileSuffix, filePath
        }

        Text {
            anchors.centerIn: parent
            visible: folderModel.count === 0
            text: "This folder is empty"
            color: TTheme.Palette.color("muted")
            font.family: Config.Appearance.fontFamily
            font.weight: Config.Appearance.fontWeight
            font.pixelSize: Config.Appearance.fontSizeMedium
        }
    }
}
