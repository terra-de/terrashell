pragma ComponentBehavior: Bound

import QtQuick
import Qt.labs.platform as Platform
import Quickshell.Io

// Reads ~/.config/terra/palette.json via Quickshell-native file I/O and pushes the
// data into TTheme.Palette. TTheme itself cannot use this mechanism because it is a
// standalone module (not Quickshell-specific) and must rely on XMLHttpRequest for
// file loading in generic Qt QML runtimes. That XHR does not work in Quickshell's
// runtime, so this bridge provides the Quickshell-specific file-reading path.
//
// paletteSource must be set from the parent scope where TTheme is importable.
Item {
    id: root

    required property var paletteSource

    readonly property string palettePath:
        Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation)
        + "/.config/terra/palette.json"

    FileView {
        id: paletteFile

        path: root.palettePath
        watchChanges: true
        blockLoading: true

        onFileChanged: paletteFile.reload()

        onLoaded: {
            try {
                const rawText = paletteFile.text();
                if (rawText) {
                    const parsed = JSON.parse(rawText);
                    root.paletteSource.applyPaletteData(parsed);
                }
            } catch (error) {
                console.warn("PaletteBridge: failed to parse palette:", error);
            }
        }

        onLoadFailed: {
            console.warn("PaletteBridge: failed to load palette:", errorString);
        }
    }
}
