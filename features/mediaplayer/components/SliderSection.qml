import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../services" as Services

Item {
    id: root

    signal userInteraction()

    readonly property real volumeLevel: Pipewire?.defaultAudioSink?.audio?.volume ?? 0
    readonly property bool volumeMuted: Pipewire?.defaultAudioSink?.audio?.muted ?? false
    readonly property real brightnessLevel: Services.BrightnessService.level
    readonly property real micLevel: Services.MicVolumeService.level
    readonly property bool micMuted: Services.MicVolumeService.muted

    readonly property int barHeight: 32
    readonly property int iconSize: Math.round(barHeight * 0.5)

    implicitHeight: barHeight + 4

    function volumeIconName() {
        if (root.volumeMuted || root.volumeLevel <= 0) return "volume_off";
        if (root.volumeLevel < 0.3) return "volume_mute";
        if (root.volumeLevel < 0.7) return "volume_down";
        return "volume_up";
    }

    function micIconName() {
        if (root.micMuted || root.micLevel <= 0) return "mic_off";
        return "mic";
    }

    RowLayout {
        anchors.centerIn: parent
        width: Math.round(parent.width / 3)
        spacing: Math.round(barHeight * 0.5)

        SliderBar {
            icon_: "brightness_6"
            level: root.brightnessLevel
            onLevelSet: v => Services.BrightnessService.setLevel(v)
        }

        SliderBar {
            icon_: root.volumeIconName()
            level: root.volumeMuted ? 0 : root.volumeLevel
            onLevelSet: v => {
                const audio = Pipewire?.defaultAudioSink?.audio;
                if (!audio) return;
                audio.volume = v;
                if (v > 0 && audio.muted) audio.muted = false;
            }
        }

        SliderBar {
            icon_: root.micIconName()
            level: root.micMuted ? 0 : root.micLevel
            onLevelSet: v => Services.MicVolumeService.setLevel(v)
        }
    }

    component SliderBar: Item {
        id: sliderBar

        property string icon_: ""
        property real level: 0
        signal levelSet(real value)

        implicitHeight: root.barHeight
        implicitWidth: Math.max(40, Math.round(root.barHeight * 1.5))
        Layout.fillWidth: true
        Layout.preferredHeight: root.barHeight

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: TTheme.Palette.color("high")

            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                width: parent.width * sliderBar.level
                radius: height / 2
                color: TTheme.Palette.color("c4")
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Math.round(parent.height * 0.25)
                anchors.verticalCenter: parent.verticalCenter
                text: sliderBar.icon_
                font.family: Config.Appearance.iconFontFamily
                font.pixelSize: root.iconSize
                color: TTheme.Palette.color("standard")
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true

                function posToValue(mouse) {
                    return Math.max(0, Math.min(1, mouse.x / width));
                }

                onPressed: mouse => {
                    root.userInteraction();
                    sliderBar.levelSet(posToValue(mouse));
                }

                onPositionChanged: mouse => {
                    if (pressed) {
                        root.userInteraction();
                        sliderBar.levelSet(posToValue(mouse));
                    }
                }

                onClicked: mouse => {
                    root.userInteraction();
                    sliderBar.levelSet(posToValue(mouse));
                }
            }
        }
    }
}
