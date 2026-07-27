pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris as Mpris
import Quickshell.Services.Pipewire
import Quickshell.Hyprland

import "./" as Services

Scope {
    id: root

    readonly property string panelId: "mediaplayer"
    property var entries: []
    property var players: []

    property Mpris.MprisPlayer activePlayer: null
    property string trackTitle: root.activePlayer?.trackTitle ?? ""
    property string trackArtist: root.activePlayer?.trackArtist ?? ""
    property string trackAlbum: root.activePlayer?.trackAlbum ?? ""
    property string trackArtUrl: root.activePlayer?.trackArtUrl ?? ""
    property double position: root.activePlayer?.position ?? 0
    property double length: root.activePlayer?.length ?? 0
    property double volume: root.activePlayer?.volume ?? 0
    property bool canGoNext: root.activePlayer?.canGoNext ?? false
    property bool canGoPrevious: root.activePlayer?.canGoPrevious ?? false
    property bool canSeek: root.activePlayer?.canSeek ?? false
    property bool canPlay: root.activePlayer?.canPlay ?? false
    property bool canPause: root.activePlayer?.canPause ?? false
    property int playbackState: root.activePlayer?.playbackState ?? Mpris.MprisPlaybackState.Stopped
    readonly property bool isPlaying: root.playbackState === Mpris.MprisPlaybackState.Playing
    readonly property bool hasActivePlayer: root.activePlayer !== null
    readonly property double volumeLevel: Pipewire?.defaultAudioSink?.audio?.volume ?? 0

    function monitorKey(monitor) {
        if (!monitor) {
            return "";
        }

        return monitor.name
            || monitor.connector
            || monitor.id
            || monitor.lastIpcObject?.name
            || "";
    }

    function focusedMonitorKey() {
        return root.monitorKey(Hyprland.focusedMonitor);
    }

    function stateEntryForFocusedMonitor() {
        const key = root.focusedMonitorKey();
        if (key === "") {
            return null;
        }

        for (const entry of root.entries) {
            if (!entry || !entry.screen || !entry.state) {
                continue;
            }

            const monitor = Hyprland.monitorFor(entry.screen);
            if (root.monitorKey(monitor) === key) {
                return entry;
            }
        }

        return null;
    }

    function fallbackEntry() {
        for (const entry of root.entries) {
            if (entry && entry.state) {
                return entry;
            }
        }

        return null;
    }

    function withTargetState(callback) {
        const entry = root.stateEntryForFocusedMonitor() || root.fallbackEntry();
        if (!entry || !entry.state) {
            return;
        }

        callback(entry.state);
    }

    function targetState() {
        const entry = root.stateEntryForFocusedMonitor() || root.fallbackEntry();
        if (!entry || !entry.state) {
            return null;
        }

        return entry.state;
    }

    function registerScreenState(screen, state) {
        if (!screen || !state) {
            return;
        }

        const filtered = root.entries.filter(entry => entry && entry.state && entry.state !== state);
        filtered.push({
            screen: screen,
            state: state
        });
        root.entries = filtered;
    }

    function unregisterScreenState(state) {
        if (!state) {
            return;
        }

        root.entries = root.entries.filter(entry => entry && entry.state && entry.state !== state);
    }

    function toggle() {
        if (root.isTargetOpen()) {
            root.close();
            return;
        }

        root.open();
    }

    function open() {
        const state = root.targetState();
        if (!state) {
            return;
        }

        Services.PanelExclusivityService.requestOpen(root.panelId);
        root.closeAll();
        state.openPanel();
    }

    function close() {
        root.withTargetState(state => state.close());
    }

    function closeAll() {
        for (const entry of root.entries) {
            if (entry?.state) {
                entry.state.close();
            }
        }
    }

    function isOpen() {
        for (const entry of root.entries) {
            if (entry?.state?.open) {
                return true;
            }
        }

        return false;
    }

    function isTargetOpen() {
        const state = root.targetState();
        return state ? state.open : false;
    }

    function togglePlaying() {
        if (root.activePlayer?.canTogglePlaying) {
            root.activePlayer.togglePlaying();
        } else if (root.activePlayer?.canPlay && !root.isPlaying) {
            root.activePlayer.play();
        } else if (root.activePlayer?.canPause && root.isPlaying) {
            root.activePlayer.pause();
        }
    }

    function play() {
        if (root.activePlayer?.canPlay) {
            root.activePlayer.play();
        }
    }

    function pause() {
        if (root.activePlayer?.canPause) {
            root.activePlayer.pause();
        }
    }

    function next() {
        if (root.activePlayer?.canGoNext) {
            root.activePlayer.next();
        }
    }

    function previous() {
        if (root.activePlayer?.canGoPrevious) {
            root.activePlayer.previous();
        }
    }

    function seek(offsetMs) {
        if (root.activePlayer?.canSeek) {
            root.activePlayer.seek(offsetMs / 1000);
        }
    }

    function setPosition(pos) {
        if (root.activePlayer?.canSeek && root.activePlayer?.positionSupported) {
            root.activePlayer.position = pos;
        }
    }

    function setVolume(vol) {
        if (root.activePlayer?.volumeSupported) {
            root.activePlayer.volume = Math.max(0, Math.min(1, vol));
        }
    }

    function connectToPlayer(player) {
        if (!player) {
            return;
        }

        player.trackTitleChanged.connect(() => {
            root.trackTitle = player.trackTitle;
        });
        player.trackArtistChanged.connect(() => {
            root.trackArtist = player.trackArtist;
        });
        player.trackAlbumChanged.connect(() => {
            root.trackAlbum = player.trackAlbum;
        });
        player.trackArtUrlChanged.connect(() => {
            root.trackArtUrl = player.trackArtUrl;
        });
        player.positionChanged.connect(() => {
            root.position = player.position;
        });
        player.lengthChanged.connect(() => {
            root.length = player.length;
        });
        player.volumeChanged.connect(() => {
            root.volume = player.volume;
        });
        player.canGoNextChanged.connect(() => {
            root.canGoNext = player.canGoNext;
        });
        player.canGoPreviousChanged.connect(() => {
            root.canGoPrevious = player.canGoPrevious;
        });
        player.canSeekChanged.connect(() => {
            root.canSeek = player.canSeek;
        });
        player.canPlayChanged.connect(() => {
            root.canPlay = player.canPlay;
        });
        player.canPauseChanged.connect(() => {
            root.canPause = player.canPause;
        });
        player.playbackStateChanged.connect(() => {
            root.playbackState = player.playbackState;
        });
    }

    function onPlayersChanged() {
        const newPlayers = Mpris.Mpris.players;

        for (const player of newPlayers) {
            if (Array.isArray(players) && players.includes(player)) {
                continue;
            }

            root.connectToPlayer(player);
        }

        root.players = newPlayers.slice();

        if (!root.activePlayer && newPlayers.length > 0) {
            root.activePlayer = newPlayers[0];
            root.trackTitle = root.activePlayer.trackTitle;
            root.trackArtist = root.activePlayer.trackArtist;
            root.trackAlbum = root.activePlayer.trackAlbum;
            root.trackArtUrl = root.activePlayer.trackArtUrl;
            root.position = root.activePlayer.position;
            root.length = root.activePlayer.length;
            root.volume = root.activePlayer.volume;
            root.canGoNext = root.activePlayer.canGoNext;
            root.canGoPrevious = root.activePlayer.canGoPrevious;
            root.canSeek = root.activePlayer.canSeek;
            root.canPlay = root.activePlayer.canPlay;
            root.canPause = root.activePlayer.canPause;
            root.playbackState = root.activePlayer.playbackState;
        }
    }

    property bool _volumeTracked: false
    property double _previousVolume: 0
    property bool _brightnessTracked: false
    property double _previousBrightness: 0

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    function openSlidersOnFocused() {
        root.withTargetState(state => state.openSlidersOnly());
    }

    onVolumeLevelChanged: {
        const level = Pipewire.defaultAudioSink?.audio?.volume ?? 0;
        if (!root._volumeTracked) {
            root._previousVolume = level;
            root._volumeTracked = true;
            return;
        }
        if (Math.abs(level - root._previousVolume) > 0.005) {
            root._previousVolume = level;
            root.openSlidersOnFocused();
        }
    }

    property Connections brightnessConnection: Connections {
        target: Services.BrightnessService
        function onLevelChanged() {
            const level = Services.BrightnessService.level;
            if (!root._brightnessTracked) {
                root._previousBrightness = level;
                root._brightnessTracked = true;
                return;
            }
            if (Math.abs(level - root._previousBrightness) > 0.005) {
                root._previousBrightness = level;
                root.openSlidersOnFocused();
            }
        }
    }

    property Connections playersConnection: Connections {
        target: Mpris.Mpris
        function onPlayersChanged() {
            root.onPlayersChanged();
        }
    }

    Component.onCompleted: {
        root.onPlayersChanged();
        Services.PanelExclusivityService.registerPanel(root.panelId, root);
    }

    Component.onDestruction: {
        Services.PanelExclusivityService.unregisterPanel(root.panelId, root);
    }

    IpcHandler {
        target: "mediaplayer"

        function toggle(): void {
            root.toggle();
        }

        function open(): void {
            root.open();
        }

        function close(): void {
            root.close();
        }

        function togglePlaying(): void {
            root.togglePlaying();
        }

        function next(): void {
            root.next();
        }

        function previous(): void {
            root.previous();
        }

        function play(): void {
            root.play();
        }

        function pause(): void {
            root.pause();
        }

        function setPosition(value: double): void {
            root.setPosition(value);
        }

        function setVolume(value: double): void {
            root.setVolume(value);
        }
    }
}
