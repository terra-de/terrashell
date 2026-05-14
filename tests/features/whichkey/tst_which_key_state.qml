import QtQuick
import QtTest

import "../../../features/whichkey/vm" as WhichKeyVm

TestCase {
    name: "WhichKeyState"

    WhichKeyVm.WhichKeyState {
        id: state

        config: ({
            enabled: true,
            title: "Leader",
        })
    }

    function init() {
        state.close();
        state.enabled = true;
    }

    function test_initialState() {
        compare(state.open, false);
        compare(state.enabled, true);
        compare(state.title, "Leader");
        compare(state.entries.length, 0);
    }

    function test_rebuildBinds() {
        state.rebuildBinds([
            { key: "y", label: "Y", description: "Toggle quickterm", icon: "terminal", hasChildren: false },
            { key: "r", label: "R", description: "Reload config", icon: "refresh", hasChildren: false },
        ]);
        compare(state.entries.length, 2);
        compare(state.entries[0].key, "y");
        compare(state.entries[1].key, "r");
    }

    function test_rebuildBinds_emptyDoesNothing() {
        state.rebuildBinds([]);
        compare(state.entries.length, 0);
    }

    function test_close() {
        state.open = true;
        compare(state.open, true);
        state.close();
        compare(state.open, false);
    }

    function test_configDisabled() {
        const original = state.config;
        state.config = { enabled: false, title: "Disabled" };
        compare(state.enabled, false);
        state.config = original;
    }
}
