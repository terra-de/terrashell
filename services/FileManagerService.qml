pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.platform as Platform

import "../config" as Config

/*
  FileManagerService
  Holds current directory state and provides navigation helpers for TFiles.
*/
Scope {
    id: root

    property string currentFolder: {
        const start = Config.Config.fileManager?.startPath ?? "~";
        if (start.startsWith("file://")) {
            return start;
        }
        const home = Platform.StandardPaths.writableLocation(Platform.StandardPaths.HomeLocation);
        if (start.startsWith("~")) {
            return "file://" + home + start.slice(1);
        }
        return "file://" + start;
    }

    function navigateTo(folderUrl) {
        if (!folderUrl) {
            return;
        }
        if (!folderUrl.startsWith("file://")) {
            folderUrl = "file://" + folderUrl;
        }
        root.currentFolder = folderUrl;
    }

    function navigateUp() {
        const current = root.currentFolder;
        if (!current || current === "file:///") {
            return;
        }
        let path = current.slice(7);
        // Remove trailing slash for consistency
        if (path.endsWith("/")) {
            path = path.slice(0, -1);
        }
        const lastSlash = path.lastIndexOf("/");
        if (lastSlash <= 0) {
            root.currentFolder = "file:///";
            return;
        }
        const parent = path.slice(0, lastSlash);
        root.currentFolder = "file://" + (parent || "/");
    }

    function openFile(filePath) {
        if (!filePath) {
            return;
        }
        openProcess.exec(["xdg-open", filePath]);
    }

    function pathSegments() {
        let path = root.currentFolder;
        if (path.startsWith("file://")) {
            path = path.slice(7);
        }
        if (!path || path === "/") {
            return [{ name: "/", path: "file:///" }];
        }
        const parts = path.split("/").filter(function (p) {
            return p !== "";
        });
        const segments = [];
        let build = "";
        for (let i = 0; i < parts.length; i++) {
            build += "/" + parts[i];
            segments.push({
                name: parts[i],
                path: "file://" + build
            });
        }
        return segments;
    }

    Process {
        id: openProcess
    }
}
