import QtQuick
import QtQuick.Layouts

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme

Item {
    id: root

    property bool canGoPrevious: false
    property bool canGoNext: false
    property bool isPlaying: false

    signal previousClicked()
    signal rewindClicked()
    signal playPauseClicked()
    signal fastForwardClicked()
    signal nextClicked()

    readonly property int buttonSize: Math.max(36, Math.round(root.height * 0.55))
    readonly property int iconSize: Math.round(root.buttonSize * 0.5)

    implicitHeight: root.buttonSize + 8

    RowLayout {
        anchors.centerIn: parent
        spacing: Math.max(8, Math.round(root.buttonSize * 0.3))

        TransportButton {
            icon_: "skip_previous"
            enabled_: root.canGoPrevious
            buttonSize: root.buttonSize
            iconSize: root.iconSize
            onClicked: root.previousClicked()
        }

        TransportButton {
            icon_: "fast_rewind"
            enabled_: true
            buttonSize: root.buttonSize
            iconSize: root.iconSize
            onClicked: root.rewindClicked()
        }

        Rectangle {
            width: root.buttonSize * 1.5
            height: root.buttonSize * 1.5
            radius: width / 2
            color: TTheme.Palette.color("c4")
            Layout.alignment: Qt.AlignVCenter

            Text {
                anchors.centerIn: parent
                text: root.isPlaying ? "pause" : "play_arrow"
                font.family: Config.Appearance.iconFontFamily
                font.pixelSize: Math.round(parent.width * 0.5)
                color: TTheme.Palette.color("on_c4")
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.playPauseClicked()
            }

            Behavior on color {
                ColorAnimation {
                    duration: Config.Motion.shortDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Config.Motion.standardCurve
                }
            }
        }

        TransportButton {
            icon_: "fast_forward"
            enabled_: true
            buttonSize: root.buttonSize
            iconSize: root.iconSize
            onClicked: root.fastForwardClicked()
        }

        TransportButton {
            icon_: "skip_next"
            enabled_: root.canGoNext
            buttonSize: root.buttonSize
            iconSize: root.iconSize
            onClicked: root.nextClicked()
        }
    }

    component TransportButton: Item {
        id: transportButton

        property string icon_: ""
        property bool enabled_: true
        property int buttonSize: 36
        property int iconSize: 18

        signal clicked()

        width: transportButton.buttonSize
        height: transportButton.buttonSize
        opacity: transportButton.enabled_ ? 1 : 0.4
        Layout.alignment: Qt.AlignVCenter

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: TTheme.Palette.color("high")

            Text {
                anchors.centerIn: parent
                text: transportButton.icon_
                font.family: Config.Appearance.iconFontFamily
                font.pixelSize: transportButton.iconSize
                color: TTheme.Palette.color("standard")
            }

            MouseArea {
                anchors.fill: parent
                enabled: transportButton.enabled_
                onClicked: transportButton.clicked()
            }

            Behavior on color {
                ColorAnimation {
                    duration: Config.Motion.shortDuration
                    easing.type: Easing.BezierSpline
                    easing.bezierCurve: Config.Motion.standardCurve
                }
            }
        }
    }
}
