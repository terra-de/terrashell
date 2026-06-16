import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../services" as Services
import "../../../utils"

/*
  NotificationToast
  Compact popup for one notification entry.
  Required properties: entry, widthValue.
*/
Item {
    id: root

    required property var entry
    required property int widthValue

    readonly property bool critical: String(root.entry?.urgency || "").toLowerCase().indexOf("critical") >= 0
    readonly property bool persistent: (root.entry?.notification?.expireTimeout ?? -1) === 0
    readonly property bool hasBody: (root.entry?.body || "") !== ""
    property int _tick: 0

    readonly property string ageText: {
        root._tick;
        const received = root.entry?.receivedAtMs;
        if (!received) return "";
        const delta = Math.max(0, Math.floor((Date.now() - received) / 1000));
        if (delta < 60) return `${delta}s`;
        if (delta < 3600) return `${Math.floor(delta / 60)}m`;
        if (delta < 86400) return `${Math.floor(delta / 3600)}h`;
        return `${Math.floor(delta / 86400)}d`;
    }
    readonly property bool hovered: hoverHandler.hovered
    readonly property int contentPadding: Math.max(8, Config.Config.notifications?.popup?.itemPadding ?? 12)
    readonly property int iconSize: Math.max(16, Config.Config.notifications?.popup?.iconSize ?? 22)
    readonly property int timeoutMs: Services.NotificationService.timeoutMsFor(root.entry)
    readonly property bool pauseOnHover: Config.Config.notifications?.popup?.pauseOnHover ?? true
    readonly property color surfaceColor: root.critical
        ? TTheme.Palette.color("error")
        : TTheme.Palette.color("high")
    readonly property color onSurfaceColor: root.critical
        ? TTheme.Palette.color("on_error")
        : TTheme.Palette.color("standard")
    readonly property color metaColor: root.critical
        ? TTheme.Palette.color("on_error")
        : TTheme.Palette.color("muted")

    function iconSource(iconName) {
        const raw = typeof iconName === "string" ? iconName.trim() : "";
        if (!raw) {
            return Quickshell.iconPath("notifications", true);
        }
        if (raw.startsWith("/") || raw.startsWith("file:/")) {
            return raw;
        }
        return Quickshell.iconPath(raw, true);
    }

    function restartTimeout() {
        if (root.timeoutMs <= 0) {
            expireTimer.stop();
            return;
        }
        expireTimer.interval = root.timeoutMs;
        expireTimer.restart();
    }

    width: root.widthValue
    implicitWidth: root.widthValue
    implicitHeight: toastBody.implicitHeight

    Component.onCompleted: restartTimeout()
    onTimeoutMsChanged: restartTimeout()

    Timer {
        id: expireTimer
        repeat: false
        onTriggered: {
            if (root.entry) {
                Services.NotificationService.hidePopup(root.entry);
            }
        }
    }

    Timer {
        id: clockTimer
        interval: 1000
        repeat: true
        running: true
        onTriggered: root._tick++
    }

    Rectangle {
        id: toastBody

        width: root.widthValue
        radius: Config.Appearance.radiusMedium
        color: root.surfaceColor
        implicitHeight: contentColumn.implicitHeight + root.contentPadding * 2

        Behavior on color {
            ColorAnimation {
                duration: Config.Motion.shortDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: Config.Motion.standardCurve
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: Services.NotificationService.navigateToNotificationApp(root.entry)
        }

        ColumnLayout {
            id: contentColumn

            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: root.contentPadding
            spacing: Math.max(6, Math.round(root.contentPadding * 0.6))

            RowLayout {
                Layout.fillWidth: true
                spacing: Math.max(8, Math.round(root.contentPadding * 0.6))

                IconImage {
                    source: root.iconSource(root.entry?.notification?.appIcon)
                    asynchronous: true
                    mipmap: true
                    implicitSize: root.iconSize
                    Layout.preferredWidth: root.iconSize
                    Layout.preferredHeight: root.iconSize
                    Layout.alignment: Qt.AlignTop
                }

                Text {
                    visible: root.persistent
                    text: "push_pin"
                    font.family: Config.Appearance.iconFontFamily
                    font.pixelSize: Math.max(12, Math.round(Config.Appearance.fontSizeSmall * 0.85))
                    color: root.metaColor
                    verticalAlignment: Text.AlignTop
                }

                ColumnLayout {
                    spacing: 2
                    Layout.fillWidth: true

                    Text {
                        text: root.entry?.appName || "Notification"
                        font.family: Config.Appearance.fontFamily
                        font.weight: Font.DemiBold
                        font.pixelSize: Config.Appearance.fontSizeSmall
                        color: root.metaColor
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        textFormat: Text.PlainText
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.entry?.summary || "Notification"
                        font.family: Config.Appearance.fontFamily
                        font.weight: Font.DemiBold
                        font.pixelSize: Config.Appearance.fontSizeMedium
                        color: root.critical
                            ? TTheme.Palette.color("on_error")
                            : TTheme.Palette.color("muted")
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        textFormat: Text.PlainText
                        Layout.fillWidth: true
                    }
                }

                Text {
                    id: ageLabelText
                    visible: root.ageText !== ""
                    text: root.ageText
                    font.family: Config.Appearance.fontFamily
                    font.pixelSize: Math.max(10, Math.round(Config.Appearance.fontSizeSmall * 0.8))
                    color: root.metaColor
                    verticalAlignment: Text.AlignTop
                }

                Text {
                    text: "expand_more"
                    font.family: Config.Appearance.iconFontFamily
                    font.pixelSize: Config.Appearance.fontSizeLarge
                    color: root.metaColor
                    verticalAlignment: Text.AlignTop

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Services.NotificationService.hideNotification(root.entry)
                    }
                }

                Text {
                    text: "close"
                    font.family: Config.Appearance.iconFontFamily
                    font.pixelSize: Config.Appearance.fontSizeLarge
                    color: root.metaColor
                    verticalAlignment: Text.AlignTop

                    MouseArea {
                        anchors.fill: parent
                        onClicked: Services.NotificationService.dismiss(root.entry)
                    }
                }
            }

            Text {
                visible: root.hasBody
                text: root.entry?.body || ""
                font.family: Config.Appearance.fontFamily
                font.weight: Config.Appearance.fontWeight
                font.pixelSize: Config.Appearance.fontSizeMedium
                color: root.metaColor
                wrapMode: Text.Wrap
                maximumLineCount: 5
                elide: Text.ElideRight
                textFormat: Text.PlainText
                Layout.fillWidth: true
            }

            RowLayout {
                visible: (root.entry?.notification?.actions?.length ?? 0) > 0
                Layout.fillWidth: true
                spacing: Math.max(6, Math.round(root.contentPadding * 0.5))

                Repeater {
                    model: root.entry?.notification?.actions ?? []

                    delegate: Rectangle {
                        required property var modelData

                        radius: Config.Appearance.radiusSmall
                        color: TTheme.Palette.color("base")
                        implicitHeight: Math.max(28, Math.round(Config.Appearance.fontSizeMedium * 2.1))
                        implicitWidth: actionText.implicitWidth + 14

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: modelData.text || "Action"
                            font.family: Config.Appearance.fontFamily
                            font.weight: Font.Medium
                            font.pixelSize: Config.Appearance.fontSizeSmall
                            color: TTheme.Palette.color("standard")
                            textFormat: Text.PlainText
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Services.NotificationService.invokeAction(root.entry, modelData)
                        }
                    }
                }
            }
        }

        HoverHandler {
            id: hoverHandler
            target: toastBody
            onHoveredChanged: {
                if (!root.pauseOnHover) {
                    return;
                }
                if (hovered) {
                    expireTimer.stop();
                } else {
                    root.restartTimeout();
                }
            }
        }
    }
}
