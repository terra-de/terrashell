import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import "../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../services" as Services

/*
  FileManagerPathBar
  Breadcrumb path bar with click-to-navigate segments and a manual-edit mode.
*/
Rectangle {
    id: root

    color: TTheme.Palette.color("high")
    radius: Config.Appearance.radiusSmall
    height: 42

    readonly property var segments: Services.FileManagerService.pathSegments()

    RowLayout {
        id: breadcrumbRow

        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 0

        Repeater {
            model: root.segments

            RowLayout {
                spacing: 0

                Text {
                    visible: index > 0
                    text: "/"
                    color: TTheme.Palette.color("muted")
                    font.family: Config.Appearance.fontFamily
                    font.weight: Config.Appearance.fontWeight
                    font.pixelSize: Config.Appearance.fontSizeMedium
                    Layout.alignment: Qt.AlignVCenter
                }

                Text {
                    text: modelData.name
                    color: breadcrumbMouseArea.containsMouse ? TTheme.Palette.color("c4") : TTheme.Palette.color("muted")
                    font.family: Config.Appearance.fontFamily
                    font.weight: Config.Appearance.fontWeight
                    font.pixelSize: Config.Appearance.fontSizeMedium
                    Layout.alignment: Qt.AlignVCenter

                    MouseArea {
                        id: breadcrumbMouseArea

                        anchors.fill: parent
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton
                        onClicked: Services.FileManagerService.navigateTo(modelData.path)
                    }
                }
            }
        }

        // Spacer that captures clicks to enter edit mode
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onClicked: root.enterEditMode()
            }
        }
    }

    TextField {
        id: editField

        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        visible: false
        text: Services.FileManagerService.currentFolder.slice(7)
        color: TTheme.Palette.color("muted")
        selectedTextColor: TTheme.Palette.color("on_c4")
        selectionColor: TTheme.Palette.color("c4")
        font.family: Config.Appearance.fontFamily
        font.weight: Config.Appearance.fontWeight
        font.pixelSize: Config.Appearance.fontSizeMedium
        background: Rectangle {
            color: "transparent"
        }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape) {
                root.exitEditMode();
                event.accepted = true;
                return;
            }
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                const path = editField.text.trim();
                if (path) {
                    Services.FileManagerService.navigateTo(path);
                }
                root.exitEditMode();
                event.accepted = true;
            }
        }

        onActiveFocusChanged: {
            if (!activeFocus) {
                root.exitEditMode();
            }
        }
    }

    function enterEditMode() {
        editField.text = Services.FileManagerService.currentFolder.slice(7);
        breadcrumbRow.visible = false;
        editField.visible = true;
        editField.forceActiveFocus();
        editField.selectAll();
    }

    function exitEditMode() {
        editField.visible = false;
        breadcrumbRow.visible = true;
    }
}
