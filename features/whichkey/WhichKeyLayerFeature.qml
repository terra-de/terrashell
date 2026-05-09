import QtQuick
import Quickshell
import Quickshell.Io

import "../../config" as Config
import "../../services" as Services
import "./components" as WhichKeyComponents
import "./vm" as WhichKeyVm

/*
  WhichKeyLayerFeature
  Per-screen which-key overlay host and state registration.
  Required properties: panelScreen.

  Which-key binds are loaded from two sources, in priority order:
    1. ~/.config/terra/keys.json (user override, hot-reloaded)
    2. /usr/share/terrashell/keys-defaults.json (shipped defaults)
  If neither exists, the tree remains empty.
 */
Scope {
    id: root

    required property ShellScreen panelScreen

    WhichKeyVm.WhichKeyState {
        id: whichKeyState

        config: Config.Config.whichKey ?? ({})
    }

    readonly property string _defaultsPath: "file:///usr/share/terrashell/keys-defaults.json"
    readonly property string _userKeysPath: "file://" + Quickshell.env("HOME") + "/.config/terra/keys.json"

    // Shipped defaults — loads first
    FileView {
        id: defaultsFile

        path: root._defaultsPath
        blockLoading: true

        onLoaded: {
            try {
                const rawText = defaultsFile.text();
                const parsed = rawText ? JSON.parse(rawText) : null;
                if (Array.isArray(parsed)) {
                    whichKeyState.rebuildBinds(parsed);
                }
            } catch (e) {
                console.warn("WhichKeyLayerFeature: failed to parse keys-defaults.json", e);
            }
            // After defaults are loaded, try the user override
            userKeysFile.reload();
        }

        onLoadFailed: {
            // Shipped defaults missing — try user override directly
            userKeysFile.reload();
        }
    }

    // User override — hot-reloaded
    FileView {
        id: userKeysFile

        path: root._userKeysPath
        watchChanges: true
        blockLoading: true

        function loadBinds() {
            try {
                const rawText = userKeysFile.text();
                const parsed = rawText ? JSON.parse(rawText) : null;
                if (Array.isArray(parsed)) {
                    whichKeyState.rebuildBinds(parsed);
                }
            } catch (e) {
                console.warn("WhichKeyLayerFeature: failed to parse keys.json", e);
            }
        }

        onLoaded: loadBinds()
        onFileChanged: reload()
    }

    Component.onCompleted: {
        Services.WhichKeyService.registerScreenState(root.panelScreen, whichKeyState);
        defaultsFile.reload();
    }
    Component.onDestruction: Services.WhichKeyService.unregisterScreenState(whichKeyState)

    Connections {
        target: whichKeyState

        function onCommandRequested(command) {
            Services.WhichKeyService.executeCommand(command);
        }
    }

    WhichKeyComponents.WhichKeyPopup {
        panelScreen: root.panelScreen
        active: whichKeyState.open && whichKeyState.enabled
        viewModel: whichKeyState
        style: Config.Config.whichKey?.panel ?? ({})
    }
}
