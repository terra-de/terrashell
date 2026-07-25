import QtQuick

import "../../config" as Config
import "../../design/controls" as Controls
import "../../services" as Services
import "../../utils/PickerActivator.js" as PickerActivator
import "../symbolpicker/vm" as SymbolPickerVm

/*
  NerdFontPanelFeature
  Searchable Nerd Font grid picker backed by symbol data and MRU sorting.
  Required properties: panelScreen, state.
 */
Controls.SlideOutGridPanel {
    id: root

    readonly property var gridConfig: Config.Config.nerdFontPicker && Config.Config.nerdFontPicker.grid
        ? Config.Config.nerdFontPicker.grid
        : ({})

    panelNamespace: "quickshell-nerdfont"
    items: gridModel.filteredEntries
    columns: root.gridConfig.columns || 6
    tileHeight: root.gridConfig.tileHeight || 76
    tileSpacing: root.gridConfig.tileSpacing || 12
    glyphSize: root.gridConfig.glyphSize || 30
    glyphFontFamily: root.gridConfig.fontFamily || "Hack Nerd Font Mono"
    emptyText: Services.SymbolPickerService.isKindLoading("nerdfont")
        ? "Loading Nerd Font icons..."
        : (state.query ? "No matching icons" : "No Nerd Font data loaded")

    SymbolPickerVm.SymbolGridModel {
        id: gridModel

        state: root.state
        presentationOpen: root.presentationOpen
        sourceEntries: Services.SymbolPickerService.nerdFontEntries
    }

    onActivateRequested: (item, ctrl) => {
        const text = item && item.glyph ? item.glyph : "";
        if (!text) {
            return;
        }

        if (ctrl) {
            PickerActivator.activateCopy(root, () => Services.SymbolPickerService.copyGlyph(text));
        } else {
            PickerActivator.activateType(root,
                () => Services.SymbolPickerService.copyGlyph(text),
                () => Services.SymbolPickerService.typeGlyph("nerdfont", text)
            );
        }
    }
}
