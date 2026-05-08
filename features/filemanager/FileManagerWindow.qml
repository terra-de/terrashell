import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../services" as Services
import "./" as FileManagerComponents

/*
  FileManagerWindow
  Main TFiles composition: resizable sidebar + path bar + content view.
*/
Rectangle {
    id: root

    color: TTheme.Palette.color("base")

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        FileManagerComponents.FileManagerPathBar {
            Layout.fillWidth: true
        }

        SplitView {
            Layout.fillWidth: true
            Layout.fillHeight: true

            FileManagerComponents.FileManagerSidebar {
                SplitView.minimumWidth: 160
                SplitView.preferredWidth: Config.Config.fileManager?.sidebarWidth ?? 220
                SplitView.maximumWidth: 400
            }

            FileManagerComponents.FileManagerContentView {
                SplitView.fillWidth: true
            }
        }
    }
}
