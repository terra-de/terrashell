import QtQuick
import QtQuick.Layouts

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme

Item {
    id: root

    property double position: 0
    property double length: 0
    property bool canSeek: false
    readonly property double progress: root.length > 0 ? root.position / root.length : 0

    signal seekRequested(double position)

    readonly property int trackHeight: Math.max(4, Math.round(root.height * 0.15))
    readonly property int thumbSize: Math.max(12, Math.round(trackHeight * 3))

    function formatTime(seconds) {
        if (!seconds || seconds <= 0) {
            return "0:00";
        }

        const totalSec = Math.floor(seconds);
        const mins = Math.floor(totalSec / 60);
        const secs = totalSec % 60;
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }

    implicitHeight: Math.max(36, trackHeight + 24)

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: root.formatTime(root.position)
                font.family: Config.Appearance.fontFamily
                font.pixelSize: Math.max(10, Math.round(Config.Appearance.fontSizeSmall * 0.9))
                color: TTheme.Palette.color("muted")
            }

            Item {
                Layout.fillWidth: true
                Layout.minimumHeight: root.trackHeight + root.thumbSize

                Rectangle {
                    id: track

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: root.trackHeight
                    radius: height / 2
                    color: TTheme.Palette.color("high")

                    Rectangle {
                        id: fill

                        width: Math.max(0, Math.min(parent.width, parent.width * root.progress))
                        height: parent.height
                        radius: height / 2
                        color: TTheme.Palette.color("c4")
                    }

                    Rectangle {
                        id: thumb

                        x: Math.max(0, Math.min(parent.width - width, parent.width * root.progress - width / 2))
                        y: (parent.height - root.thumbSize) / 2
                        width: root.thumbSize
                        height: root.thumbSize
                        radius: width / 2
                        color: TTheme.Palette.color("c4")
                        visible: sliderArea.pressed || sliderArea.containsMouse
                    }

                    MouseArea {
                        id: sliderArea

                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: root.canSeek

                        function posToValue(mouse) {
                            return Math.max(0, Math.min(1, mouse.x / width));
                        }

                        onClicked: mouse => {
                            if (!root.canSeek || root.length <= 0) {
                                return;
                            }
                            root.seekRequested(posToValue(mouse) * root.length);
                        }

                        onPositionChanged: mouse => {
                            if (pressed && root.canSeek && root.length > 0) {
                                root.seekRequested(posToValue(mouse) * root.length);
                            }
                        }

                        onPressed: mouse => {
                            if (root.canSeek && root.length > 0) {
                                root.seekRequested(posToValue(mouse) * root.length);
                            }
                        }
                    }
                }
            }

            Text {
                text: root.formatTime(root.length)
                font.family: Config.Appearance.fontFamily
                font.pixelSize: Math.max(10, Math.round(Config.Appearance.fontSizeSmall * 0.9))
                color: TTheme.Palette.color("muted")
            }
        }
    }
}
