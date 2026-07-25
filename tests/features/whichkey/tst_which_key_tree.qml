import QtQuick
import QtTest

import "../../../features/whichkey/vm/WhichKeyTree.js" as WhichKeyTree

TestCase {
    name: "WhichKeyTree"

    function test_normalizeBinds_empty() {
        const result = WhichKeyTree.normalizeBinds([]);
        compare(result.length, 0);
    }

    function test_normalizeBinds_filtersEscapeBackspace() {
        const result = WhichKeyTree.normalizeBinds([
            { key: "escape", description: "Close" },
            { key: "backspace", description: "Back" },
            { key: "y", description: "Toggle quickterm" },
        ]);
        compare(result.length, 1);
        compare(result[0].key, "y");
        compare(result[0].keyIcon, "");
    }

    function test_normalizeBinds_detectsSubmap() {
        const result = WhichKeyTree.normalizeBinds([
            { key: "u", description: "@submap@Utilities", dispatcher: "__lua" },
            { key: "y", description: "Toggle quickterm", dispatcher: "__lua" },
        ]);
        compare(result.length, 2);
        compare(result[0].key, "u");
        compare(result[0].hasChildren, true);
        compare(result[0].description, "Utilities");
        compare(result[1].key, "y");
        compare(result[1].hasChildren, false);
    }

    function test_normalizeBinds_submapWithIconFallback() {
        const result = WhichKeyTree.normalizeBinds([
            { key: "w", description: "@submap@Window", dispatcher: "__lua" },
            { key: "r", description: "<refresh>Reload config", dispatcher: "__lua" },
        ]);
        compare(result.length, 2);
        // Submap has no icon in description, should fall back to "folder"
        compare(result[0].icon, "folder");
        compare(result[0].hasChildren, true);
        compare(result[0].description, "Window");
        // Leaf with icon prefix
        compare(result[1].icon, "refresh");
        compare(result[1].hasChildren, false);
        compare(result[1].description, "Reload config");
    }

    function test_normalizeBinds_parsesIconPrefix() {
        const result = WhichKeyTree.normalizeBinds([
            { key: "y", description: "<terminal>Toggle quickterm", dispatcher: "exec_cmd" },
        ]);
        compare(result.length, 1);
        compare(result[0].icon, "terminal");
        compare(result[0].description, "Toggle quickterm");
    }

    function test_normalizeBinds_deduplicates() {
        const result = WhichKeyTree.normalizeBinds([
            { key: "y", description: "First", dispatcher: "exec_cmd" },
            { key: "Y", description: "Duplicate", dispatcher: "exec_cmd" },
        ]);
        compare(result.length, 1);
        compare(result[0].description, "First"); // first wins lowercase key
    }

    function test_normalizeBinds_keyIconMappings() {
        const result = WhichKeyTree.normalizeBinds([
            { key: "return", description: "Confirm" },
            { key: "space", description: "Toggle" },
            { key: "tab", description: "Switch" },
            { key: "f", description: "Fullscreen" },
            { key: "up", description: "Move up" },
            { key: "page_up", description: "Scroll up" },
            { key: "delete", description: "Delete" },
        ]);
        compare(result.length, 7);
        compare(result[0].keyIcon, "keyboard_return");
        compare(result[1].keyIcon, "space_bar");
        compare(result[2].keyIcon, "keyboard_tab");
        compare(result[3].keyIcon, ""); // "f" — no icon mapping
        compare(result[4].keyIcon, "keyboard_arrow_up");
        compare(result[5].keyIcon, "keyboard_page_up");
        compare(result[6].keyIcon, "delete");
        // Regular label still set for fallback
        compare(result[0].label, "RETURN");
        compare(result[3].label, "F");
    }
}
