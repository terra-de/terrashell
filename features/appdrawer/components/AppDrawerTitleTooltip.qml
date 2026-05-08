import QtQuick

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../design/primitives" as Primitives

/*
  AppDrawerTitleTooltip
  Shell-styled tooltip for full app names in the app drawer grid.
*/
Item {
    id: root

    property bool open: false
    property string title: ""
    property real tooltipX: 0
    property real tooltipY: 0
    property int maxWidth: 280

    readonly property int padding: 8
    readonly property real bubbleWidth: Math.min(root.maxWidth, Math.max(80, label.implicitWidth))
    readonly property real bubbleHeight: Math.max(24, label.implicitHeight)

    visible: root.open && root.title !== ""
    z: 25

    Primitives.SurfaceShadow {
        source: bubble
        offsetX: 0
        offsetY: 6
    }

    Rectangle {
        id: bubble

        x: root.tooltipX
        y: root.tooltipY
        width: root.bubbleWidth
        height: root.bubbleHeight
        radius: Config.Appearance.radiusSmall
        color: TTheme.Palette.color("top")
        border.width: 1
        border.color: TTheme.Palette.color("outline")

        Text {
            id: label

            anchors.centerIn: parent
            anchors.leftMargin: root.padding
            anchors.rightMargin: root.padding
            text: root.title
            font.family: Config.Appearance.fontFamily
            font.weight: Config.Appearance.fontWeight
            font.pixelSize: Config.Appearance.fontSizeMedium
            color: TTheme.Palette.color("standard")
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
            maximumLineCount: 4
        }
    }
}
