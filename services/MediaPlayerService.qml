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
    readonly property bool volumeMuted: Pipewire?.defaultAudioSink?.audio?.muted ?? false

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

    function _initPlayers() {
        const players = Mpris.Mpris.players.values;
        for (const player of players) {
            console.warn("MediaPlayerService: Connecting to", player.identity || player.dbusName);
            root.connectToPlayer(player);
        }
        root.players = players;
        if (players.length > 0) {
            root._switchActivePlayer(players[0]);
        }
    }

    function _onPlayerConnected(player) {
        console.warn("MediaPlayerService: Player connected", player.identity || player.dbusName);
        root.connectToPlayer(player);
        root.players = Mpris.Mpris.players.values;
        if (!root.activePlayer) {
            root._switchActivePlayer(player);
        } else if (root.playbackState === Mpris.MprisPlaybackState.Stopped
                   && player.playbackState === Mpris.MprisPlaybackState.Playing) {
            root._switchActivePlayer(player);
        }
    }

    function _onPlayerDisconnected(player) {
        console.warn("MediaPlayerService: Player disconnected", player.identity || player.dbusName);
        root.players = Mpris.Mpris.players.values;
        if (root.activePlayer === player) {
            const remaining = root.players;
            if (remaining.length > 0) {
                root._switchActivePlayer(remaining[0]);
            } else {
                root.activePlayer = null;
                root._clearActivePlayerProps();
            }
        }
    }

    function _switchActivePlayer(player) {
        root.activePlayer = player;
        root.trackTitle = player?.trackTitle ?? "";
        root.trackArtist = player?.trackArtist ?? "";
        root.trackAlbum = player?.trackAlbum ?? "";
        root.trackArtUrl = player?.trackArtUrl ?? "";
        root.position = player?.position ?? 0;
        root.length = player?.length ?? 0;
        root.volume = player?.volume ?? 0;
        root.canGoNext = player?.canGoNext ?? false;
        root.canGoPrevious = player?.canGoPrevious ?? false;
        root.canSeek = player?.canSeek ?? false;
        root.canPlay = player?.canPlay ?? false;
        root.canPause = player?.canPause ?? false;
        root.playbackState = player?.playbackState ?? Mpris.MprisPlaybackState.Stopped;
    }

    function _clearActivePlayerProps() {
        root.trackTitle = "";
        root.trackArtist = "";
        root.trackAlbum = "";
        root.trackArtUrl = "";
        root.position = 0;
        root.length = 0;
        root.volume = 0;
        root.canGoNext = false;
        root.canGoPrevious = false;
        root.canSeek = false;
        root.canPlay = false;
        root.canPause = false;
        root.playbackState = Mpris.MprisPlaybackState.Stopped;
    }

    property bool _volumeTracked: false
    property double _previousVolume: 0
    property bool _mutedTracked: false
    property bool _previousMuted: false
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

    onVolumeMutedChanged: {
        const muted = Pipewire.defaultAudioSink?.audio?.muted ?? false;
        if (!root._mutedTracked) {
            root._previousMuted = muted;
            root._mutedTracked = true;
            return;
        }
        if (muted !== root._previousMuted) {
            root._previousMuted = muted;
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

    property Connections playerModelConnection: Connections {
        target: Mpris.Mpris.players
        function onObjectInsertedPost() {
            root._onPlayerConnected(arguments[0]);
        }
        function onObjectRemovedPost() {
            root._onPlayerDisconnected(arguments[0]);
        }
    }

    FrameAnimation {
        running: root.activePlayer?.playbackState === Mpris.MprisPlaybackState.Playing
        onTriggered: {
            if (root.activePlayer) {
                root.activePlayer.positionChanged();
            }
        }
    }

    Component.onCompleted: {
        root._initPlayers();
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
