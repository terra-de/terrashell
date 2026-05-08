//@ pragma UseQApplication
import QtQuick
import Quickshell

import "config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "features/filemanager" as FileManager

FloatingWindow {
    id: root

    visible: true
    title: "TFiles"
    implicitWidth: Config.Config.fileManager?.window?.width ?? 900
    implicitHeight: Config.Config.fileManager?.window?.height ?? 600
    color: TTheme.Palette.color("base")

    onClosed: Qt.quit()

    FileManager.FileManagerWindow {
        anchors.fill: parent
    }
}
