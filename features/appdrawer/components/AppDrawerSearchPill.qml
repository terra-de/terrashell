import QtQuick
import QtQuick.Layouts

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme

/*
  AppDrawerSearchPill
  Search input pill for filtering app drawer entries.
  Required properties: query.
*/
Rectangle {
    id: root

    required property string query
    required property int iconSize

    signal queryEdited(string value)
    signal escapePressed()
    signal leftPressed()
    signal rightPressed()
    signal upPressed()
    signal downPressed()
    signal enterPressed()

    radius: height / 2
    color: TTheme.Palette.color("high")

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Math.max(12, Math.round(height * 0.42))
        anchors.rightMargin: Math.max(12, Math.round(height * 0.42))
        spacing: Math.max(8, Math.round(height * 0.18))

        Text {
            text: "search"
            font.family: Config.Appearance.iconFontFamily
            font.pixelSize: root.iconSize
            font.weight: Font.Medium
            color: TTheme.Palette.color("muted")
            Layout.alignment: Qt.AlignVCenter
        }

        TextInput {
            id: input

            text: root.query
            clip: true
            color: TTheme.Palette.color("standard")
            selectedTextColor: TTheme.Palette.color("on_c0")
            selectionColor: TTheme.Palette.color("c4")
            font.family: Config.Appearance.fontFamily
            font.weight: Config.Appearance.fontWeight
            font.pixelSize: Config.Appearance.fontSizeMedium
            verticalAlignment: TextInput.AlignVCenter
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            onTextEdited: root.queryEdited(text)

            Keys.onPressed: event => {
                if (event.key === Qt.Key_Escape) {
                    root.escapePressed();
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Left) {
                    root.leftPressed();
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Right) {
                    root.rightPressed();
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Up) {
                    root.upPressed();
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Down) {
                    root.downPressed();
                    event.accepted = true;
                    return;
                }

                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    root.enterPressed();
                    event.accepted = true;
                }
            }
        }
    }

    function forceInputFocus() {
        input.forceActiveFocus();
    }

    function cursorAtEnd() {
        input.cursorPosition = input.text.length;
    }
}
