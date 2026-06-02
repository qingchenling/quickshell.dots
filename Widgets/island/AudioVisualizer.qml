import QtQuick

import qs.Themes

// ═══════════════════════════════════════════════════════════
// AudioVisualizer — pill-shaped rhythm bars for the Dynamic
// Island.  A pure UI component: receives float level data
// through the `levels` property and renders animated bars.
//
// Properties:
//   levels        — float array (0.0–1.0), one value per bar
//   barCount      — number of bars (default 8)
//   barWidth      — bar width in px (default 4)
//   barSpacing    — gap between bars (default 3)
//   minBarHeight  — idle bar height (default 3)
//   maxBarHeight  — peak bar height (default 22)
//   barColor      — fill colour (default Colors.primary)
// ═══════════════════════════════════════════════════════════

Item {
    id: root

    // ── Input data ──
    property var levels: []
    // ── Visual config ──
    property int barCount: 32
    property real barWidth: 2
    property real barSpacing: 1
    property real minBarHeight: 2
    property real maxBarHeight: 22
    property color barColor: Colors.primary

    // ── Calculated size ──
    implicitWidth: barCount * barWidth + Math.max(0, barCount - 1) * barSpacing
    implicitHeight: maxBarHeight
    width: implicitWidth
    height: implicitHeight

    // ── Helper: safe level at index ──
    function _levelAt(index) {
        if (!levels || index < 0 || index >= levels.length) return 0
        var v = Number(levels[index])
        return isFinite(v) ? Math.max(0, Math.min(1, v)) : 0
    }

    // ── Bar row ──
    Row {
        anchors.centerIn: parent
        spacing: root.barSpacing

        Repeater {
            model: root.barCount

            delegate: Rectangle {
                id: bar
                readonly property real _level: root._levelAt(index)

                width: root.barWidth
                height: root.minBarHeight
                    + (root.maxBarHeight - root.minBarHeight) * _level
                radius: width / 2
                color: root.barColor

                anchors.verticalCenter: parent.verticalCenter

                Behavior on height {
                    NumberAnimation {
                        duration: 90
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }
}
