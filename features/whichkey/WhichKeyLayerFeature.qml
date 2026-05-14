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

  Which-key displays are driven dynamically by Hyprland submaps.
  When a submap is entered, WhichKeyService calls show(submap),
  which reads hyprctl binds -j, filters by submap, and populates
  the display via rebuildBinds().
*/
Scope {
    id: root

    required property ShellScreen panelScreen

    WhichKeyVm.WhichKeyState {
        id: whichKeyState

        config: Config.Config.whichKey ?? ({})
    }

    Component.onCompleted: {
        Services.WhichKeyService.registerScreenState(root.panelScreen, whichKeyState);
    }
    Component.onDestruction: Services.WhichKeyService.unregisterScreenState(whichKeyState)

    WhichKeyComponents.WhichKeyPopup {
        panelScreen: root.panelScreen
        active: whichKeyState.open && whichKeyState.enabled
        viewModel: whichKeyState
        style: Config.Config.whichKey?.panel ?? ({})
    }
}
