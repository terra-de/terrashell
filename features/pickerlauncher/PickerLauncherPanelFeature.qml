import QtQuick

import "../../config" as Config
import "../../design/controls" as Controls
import "../../services" as Services

Controls.SlideOutListPanel {
    id: root

    panelNamespace: "quickshell-pickerlauncher"
    items: root.filteredItems
    itemHeight: 56
    itemSpacing: 6
    itemIconSize: 20
    emptyText: "No pickers match your search"

    readonly property var availablePickers: [
        { label: "Clipboard history", icon: "content_paste", actionId: "clipboard" },
        { label: "Emoji",             icon: "emoji_emotions", actionId: "emoji" },
        { label: "Nerd Font",         icon: "font_download",  actionId: "nerdfont" },
        { label: "Passwords",         icon: "password",       actionId: "password" },
        { label: "Usernames",         icon: "person",         actionId: "username" },
        { label: "TOTP codes",        icon: "pin",            actionId: "totp" }
    ]

    readonly property var filteredItems: {
        const query = (root.state?.query || "").toLowerCase();
        if (!query) {
            return root.availablePickers;
        }

        return root.availablePickers.filter(item => item.label.toLowerCase().includes(query));
    }

    function dispatchAction(actionId) {
        if (actionId === "emoji") {
            Services.SymbolPickerService.toggleKind("emoji");
            return;
        }
        if (actionId === "nerdfont") {
            Services.SymbolPickerService.toggleKind("nerdfont");
            return;
        }
        if (actionId === "clipboard") {
            Services.ClipboardHistoryService.toggle();
            return;
        }
        if (actionId === "password") {
            Services.BitwardenService.toggleMode("password");
            return;
        }
        if (actionId === "username") {
            Services.BitwardenService.toggleMode("username");
            return;
        }
        if (actionId === "totp") {
            Services.BitwardenService.toggleMode("totp");
            return;
        }
    }

    onActivateRequested: (item, ctrl) => {
        root.dispatchAction(item.actionId);
        root.state.close();
    }
}
