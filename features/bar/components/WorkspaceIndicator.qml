import QtQuick
import QtQuick.Layouts

import "../../../config" as Config
import "file:/usr/lib/qt6/qml/TTheme" as TTheme
import "../../../utils"

Rectangle {
    id: root

    required property int workspaceId
    required property bool active
    required property bool occupied
    required property bool urgent
    required property bool vertical

    property real contentWidth: 0
    property real contentHeight: 0
    property bool hovered: false

    readonly property real horizontalPadding: active ? 20 : 8
    readonly property real verticalPadding: active ? 20 : 8

    readonly property real layoutHorizontalPadding: vertical ? 6 : horizontalPadding
    readonly property real layoutVerticalPadding: vertical ? verticalPadding : 4

    readonly property real baseSize: 14

    radius: active ? Config.Appearance.radiusMedium : Math.min(implicitWidth, implicitHeight) / 2

    implicitWidth: Math.max(baseSize, contentWidth)
    implicitHeight: Math.max(baseSize, contentHeight)

    Layout.preferredWidth: implicitWidth
    Layout.preferredHeight: implicitHeight
    Layout.alignment: Qt.AlignVCenter

    color: urgent
        ? TTheme.Palette.color("error")
        : (active
            ? TTheme.Palette.color("c4")
            : (hovered
                ? TTheme.Palette.color("c1")
                : (occupied
                    ? TTheme.Palette.color("high")
                    : TTheme.Palette.color("base"))))

    Behavior on implicitWidth {
        Anim {
            durationMs: Config.Motion.longDuration
            curve: Config.Motion.emphasizedCurve

        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Config.Motion.mediumDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: Config.Motion.standardCurve
        }
    }
}
