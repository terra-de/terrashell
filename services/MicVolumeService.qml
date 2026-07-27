pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Scope {
    id: root

    property real level: Pipewire.defaultAudioSource?.volume ?? 0
    property bool muted: Pipewire.defaultAudioSource?.muted ?? false
    property bool ready: false

    readonly property var audioSource: Pipewire.defaultAudioSource

    function setLevel(value) {
        const clamped = Math.max(0, Math.min(1, value));
        const source = root.audioSource;
        if (!source) {
            return;
        }

        source.volume = clamped;
        if (clamped > 0 && source.muted) {
            source.muted = false;
        }
    }

    function toggleMuted() {
        const source = root.audioSource;
        if (!source) {
            return;
        }

        source.muted = !source.muted;
    }

    function setMuted(value) {
        const source = root.audioSource;
        if (!source) {
            return;
        }

        source.muted = value;
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSource]
    }

    onAudioSourceChanged: {
        const source = root.audioSource;
        if (source) {
            root.level = source.volume;
            root.muted = source.muted;
            root.ready = true;
        }
    }

    property Connections sourceConnections: Connections {
        target: root.audioSource
        function onVolumesChanged() {
            root.level = root.audioSource?.volume ?? 0;
        }

        function onMutedChanged() {
            root.muted = root.audioSource?.muted ?? false;
        }
    }

    IpcHandler {
        target: "micvolume"

        function setLevel(value: int): void {
            root.setLevel(value / 100);
        }

        function toggleMute(): void {
            root.toggleMuted();
        }

        function setMuted(value: bool): void {
            root.setMuted(value);
        }
    }
}
