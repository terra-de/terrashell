pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/*!
  PowerService
  Executes power actions (lock, suspend, hibernate, logout, reboot, shutdown).
  All actions are routed through tctl power.
*/
Scope {
    id: root

    function trigger(actionId) {
        if (actionId === "lock") {
            lock();
            return;
        }
        if (actionId === "suspend") {
            suspend();
            return;
        }
        if (actionId === "hibernate") {
            hibernate();
            return;
        }
        if (actionId === "logout") {
            logout();
            return;
        }
        if (actionId === "reboot") {
            reboot();
            return;
        }
        if (actionId === "poweroff" || actionId === "shutdown") {
            shutdown();
        }
    }

    function lock() {
        commandProcess.exec(["/bin/sh", "-lc", "tctl power lock"]);
    }

    function suspend() {
        commandProcess.exec(["/bin/sh", "-lc", "tctl power suspend"]);
    }

    function hibernate() {
        commandProcess.exec(["/bin/sh", "-lc", "tctl power hibernate"]);
    }

    function logout() {
        commandProcess.exec(["/bin/sh", "-lc", "tctl power logout"]);
    }

    function reboot() {
        commandProcess.exec(["/bin/sh", "-lc", "tctl power reboot"]);
    }

    function shutdown() {
        commandProcess.exec(["/bin/sh", "-lc", "tctl power shutdown"]);
    }

    Process {
        id: commandProcess
    }
}
