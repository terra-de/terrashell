import QtQuick
import QtQuick.Layouts

import "../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../design/primitives" as Primitives
import "../../services" as Services
import "./components" as MediaComponents
import "./vm" as MediaPlayerVm

Primitives.SlideOutPanelWindow {
    id: root

    required property MediaPlayerVm.MediaPlayerState state

    readonly property int panelHeight: Config.Config.mediaplayer?.size?.height ?? 420
    readonly property int sliderSectionHeight: Config.Config.mediaplayer?.size?.sliderSectionHeight ?? 56
    readonly property int contentPadding: Config.Config.mediaplayer?.size?.padding ?? 16
    readonly property int contentSpacing: Config.Config.mediaplayer?.size?.spacing ?? 12
    readonly property int overshootTopPadding: Config.Config.mediaplayer?.size?.overshootPadding
        ?? Math.max(48, Math.round(panelHeight * 0.16))
    readonly property int drawerOpenDelay: Config.Config.mediaplayer?.transition?.drawerOpenDelay ?? 0
    readonly property int panelOpenDurationMs: Config.Motion.shellDuration
    readonly property int panelCloseDurationMs: Config.Motion.shortDuration
    readonly property color surfaceColor: TTheme.Palette.color("base")
    readonly property color sectionColor: TTheme.Palette.color("high")

    open: root.state.open
    closeDurationMs: root.panelCloseDurationMs
    focusable: true

    Timer {
        id: hideTimer

        interval: Config.Config.mediaplayer?.sliderHideDelay ?? 2000
        repeat: false
        onTriggered: {
            if (root.state.sliderOnly) {
                root.state.close();
            }
        }
    }

    function restartHideTimer() {
        if (root.state.sliderOnly) {
            hideTimer.restart();
        }
    }

    onOpenChanged: {
        if (root.open) {
            keyRouter.forceActiveFocus();
        } else {
            hideTimer.stop();
        }
    }

    property int _watchTriggerCount: root.state?.sliderTriggerCount ?? 0
    on_WatchTriggerCountChanged: {
        if (root.state?.sliderOnly) {
            hideTimer.restart();
        } else {
            hideTimer.stop();
        }
    }

    onCloseCompleted: {
        root.state.sliderOnly = false;
        root.state.sliderTriggerCount = 0;
    }

    Item {
        id: keyRouter

        anchors.fill: parent
        focus: root.state.open

        Keys.onPressed: event => {
            if (!root.state.open) {
                return;
            }

            if (event.key === Qt.Key_Escape) {
                root.state.close();
                event.accepted = true;
            }
        }
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: Math.max(0, Math.round(mainPanel.visibleSurfaceY + mainPanel.primaryExtent))
        anchors.bottom: parent.bottom
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        enabled: root.state.open
        onClicked: root.state.close()
    }

    Primitives.SlideOutPanelSurface {
        id: mainPanel

        anchors.fill: parent
        attachedEdge: "top"
        primaryExtent: root.state.sliderOnly
            ? root.sliderSectionHeight + root.contentPadding
            : root.panelHeight
        overshootPadding: root.overshootTopPadding
        openDelay: root.drawerOpenDelay
        active: root.presentationOpen
        open: root.open
        surfaceColor: root.surfaceColor
        closeDurationMs: root.state.sliderOnly ? Config.Motion.shortDuration : root.panelCloseDurationMs

        onEdgeInsetChanged: root.state.edgeInset = edgeInset

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: root.contentPadding
            spacing: root.contentSpacing

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: !root.state.sliderOnly

                ColumnLayout {
                    id: contentArea

                    anchors.fill: parent
                    spacing: root.contentSpacing

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: root.contentSpacing * 2

                            MediaComponents.AlbumArt {
                                id: albumArt

                                artUrl: Services.MediaPlayerService.trackArtUrl
                                artworkSize: Math.min(200, Math.round(parent.height * 0.85))
                                Layout.alignment: Qt.AlignVCenter
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignCenter
                        spacing: 2

                        Text {
                            text: Services.MediaPlayerService.trackTitle || "No track"
                            font.family: Config.Appearance.fontFamily
                            font.weight: Font.DemiBold
                            font.pixelSize: Math.max(14, Math.round(Config.Appearance.fontSizeLarge))
                            color: TTheme.Palette.color("standard")
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }

                        Text {
                            text: Services.MediaPlayerService.trackArtist
                                ? `${Services.MediaPlayerService.trackArtist}`
                                : ""
                            font.family: Config.Appearance.fontFamily
                            font.pixelSize: Math.max(12, Math.round(Config.Appearance.fontSizeMedium))
                            color: TTheme.Palette.color("muted")
                            elide: Text.ElideRight
                            horizontalAlignment: Text.AlignHCenter
                            Layout.fillWidth: true
                        }
                    }

                    MediaComponents.ProgressSlider {
                        position: Services.MediaPlayerService.position
                        length: Services.MediaPlayerService.length
                        canSeek: Services.MediaPlayerService.canSeek
                        Layout.fillWidth: true
                        onSeekRequested: pos => Services.MediaPlayerService.setPosition(pos)
                    }

                    MediaComponents.TransportControls {
                        canGoPrevious: Services.MediaPlayerService.canGoPrevious
                        canGoNext: Services.MediaPlayerService.canGoNext
                        isPlaying: Services.MediaPlayerService.isPlaying
                        Layout.fillWidth: true
                        Layout.preferredHeight: Math.max(48, Math.round(root.panelHeight * 0.12))

                        onPreviousClicked: Services.MediaPlayerService.previous()
                        onRewindClicked: Services.MediaPlayerService.seek(-10000)
                        onPlayPauseClicked: Services.MediaPlayerService.togglePlaying()
                        onFastForwardClicked: Services.MediaPlayerService.seek(10000)
                        onNextClicked: Services.MediaPlayerService.next()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: TTheme.Palette.color("outline")
                visible: !root.state.sliderOnly
            }

            MediaComponents.SliderSection {
                id: sliderSection

                Layout.fillWidth: true
                Layout.preferredHeight: root.sliderSectionHeight - root.contentPadding
                onUserInteraction: root.restartHideTimer()
            }
        }
    }
}
