import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../services" as Services
import "../../../utils" as Utils

Item {
    id: root

    signal userInteraction()

    readonly property real volumeLevel: Pipewire?.defaultAudioSink?.audio?.volume ?? 0
    readonly property bool volumeMuted: Pipewire?.defaultAudioSink?.audio?.muted ?? false
    readonly property real brightnessLevel: Services.BrightnessService.level
    readonly property real micLevel: Services.MicVolumeService.level
    readonly property bool micMuted: Services.MicVolumeService.muted

    readonly property int sliderHeight: Math.max(36, Math.round(root.height * 0.22))
    readonly property int trackHeight: Math.max(4, Math.round(sliderHeight * 0.15))
    readonly property int iconSize: Math.max(16, Math.round(sliderHeight * 0.45))

    implicitHeight: sliderHeight * 3 + spacing * 2

    readonly property int spacing: Math.max(4, Math.round(sliderHeight * 0.15))

    function formatPercent(value) {
        return `${Math.round(value * 100)}%`;
    }

    function volumeIconName() {
        if (root.volumeMuted || root.volumeLevel <= 0) {
            return "volume_off";
        }
        if (root.volumeLevel < 0.3) {
            return "volume_mute";
        }
        if (root.volumeLevel < 0.7) {
            return "volume_down";
        }
        return "volume_up";
    }

    function micIconName() {
        if (root.micMuted || root.micLevel <= 0) {
            return "mic_off";
        }
        return "mic";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: root.spacing

        SliderRow {
            icon_: "brightness_6"
            level: root.brightnessLevel
            onLevelSet: value => Services.BrightnessService.setLevel(value)
            Layout.fillWidth: true
            Layout.preferredHeight: root.sliderHeight
        }

        SliderRow {
            icon_: root.volumeIconName()
            level: root.volumeMuted ? 0 : root.volumeLevel
            onLevelSet: value => {
                const audio = Pipewire?.defaultAudioSink?.audio;
                if (!audio) {
                    return;
                }
                audio.volume = value;
                if (value > 0 && audio.muted) {
                    audio.muted = false;
                }
            }
            Layout.fillWidth: true
            Layout.preferredHeight: root.sliderHeight
        }

        SliderRow {
            icon_: root.micIconName()
            level: root.micMuted ? 0 : root.micLevel
            secondaryIcon: root.micMuted ? "mic_off" : ""
            onLevelSet: value => Services.MicVolumeService.setLevel(value)
            Layout.fillWidth: true
            Layout.preferredHeight: root.sliderHeight
        }
    }

    component SliderRow: Item {
        property string icon_: ""
        property string secondaryIcon: ""
        property real level: 0
        signal levelSet(real value)

        id: sliderRow

        readonly property int trackH: root.trackHeight
        readonly property int thumbSize: Math.max(10, Math.round(root.trackHeight * 2.5))

        implicitHeight: root.sliderHeight

        RowLayout {
            anchors.fill: parent
            spacing: 8

            Text {
                text: sliderRow.icon_
                font.family: Config.Appearance.iconFontFamily
                font.pixelSize: root.iconSize
                color: TTheme.Palette.color("standard")
                Layout.preferredWidth: implicitWidth
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: sliderRow.trackH + sliderRow.thumbSize

                Rectangle {
                    id: sliderTrack

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    height: sliderRow.trackH
                    radius: height / 2
                    color: TTheme.Palette.color("high")

                    Rectangle {
                        id: sliderFill

                        width: Math.max(0, Math.min(parent.width, parent.width * sliderRow.level))
                        height: parent.height
                        radius: height / 2
                        color: TTheme.Palette.color("c4")
                    }

                    Rectangle {
                        id: sliderThumb

                        x: Math.max(0, Math.min(parent.width - width,
                            parent.width * sliderRow.level - width / 2))
                        y: (parent.height - sliderRow.thumbSize) / 2
                        width: sliderRow.thumbSize
                        height: sliderRow.thumbSize
                        radius: width / 2
                        color: TTheme.Palette.color("c4")
                        visible: sliderMouse.pressed || sliderMouse.containsMouse
                    }

                    MouseArea {
                        id: sliderMouse

                        anchors.fill: parent
                        hoverEnabled: true

                        function posToValue(mouse) {
                            return Math.max(0, Math.min(1, mouse.x / width));
                        }

                        onPressed: mouse => {
                            root.userInteraction();
                            sliderRow.levelSet(posToValue(mouse));
                        }

                        onPositionChanged: mouse => {
                            if (pressed) {
                                root.userInteraction();
                                sliderRow.levelSet(posToValue(mouse));
                            }
                        }

                        onClicked: mouse => {
                            root.userInteraction();
                            sliderRow.levelSet(posToValue(mouse));
                        }
                    }
                }
            }

            Text {
                text: `${Math.round(sliderRow.level * 100)}%`
                font.family: Config.Appearance.fontFamily
                font.pixelSize: Math.max(10, Math.round(Config.Appearance.fontSizeSmall * 0.9))
                color: TTheme.Palette.color("muted")
                Layout.preferredWidth: implicitWidth
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
