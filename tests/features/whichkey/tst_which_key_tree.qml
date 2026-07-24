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
}
