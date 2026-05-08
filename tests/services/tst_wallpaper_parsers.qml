import QtQuick
import QtTest

import "../../services/parsers/WallpaperParsers.js" as WallpaperParsers

TestCase {
    name: "WallpaperParsers"

    function test_buildTerrathemeArgs() {
        const dark = WallpaperParsers.buildTerrathemeArgs("/tmp/a.png", true);
        compare(dark.length, 5);
        compare(dark[0], "terratheme");
        compare(dark[1], "set");
        compare(dark[2], "/tmp/a.png");
        compare(dark[3], "--mode");
        compare(dark[4], "dark");

        const light = WallpaperParsers.buildTerrathemeArgs("/tmp/a.png", false);
        compare(light[4], "light");
    }

    function test_parseAndSortDiscoveryOutput() {
        const parsed = WallpaperParsers.parseDiscoveryOutput('["/x/b.png", "/x/A.jpg", "/y/a.jpg"]');
        compare(parsed.length, 3);

        const sorted = WallpaperParsers.sortedImagePaths(parsed);
        compare(sorted[0], "/x/A.jpg");
        compare(sorted[1], "/y/a.jpg");
        compare(sorted[2], "/x/b.png");
    }

    function test_indexAndClamp() {
        const paths = ["/a.png", "/b.png"];
        compare(WallpaperParsers.indexForPath(paths, "/b.png"), 1);
        compare(WallpaperParsers.indexForPath(paths, "/c.png"), -1);

        compare(WallpaperParsers.clampIndex(-3, 2), 0);
        compare(WallpaperParsers.clampIndex(9, 2), 1);
        compare(WallpaperParsers.clampIndex(1, 2), 1);
        compare(WallpaperParsers.clampIndex(0, 0), -1);
    }
}
