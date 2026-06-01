import QtQuick

import qs.Themes

// A group of selectable pill buttons, rendered in a Flow layout.
// Provide a `model` (ListModel or JS array of {label, value}) and the
// currently selected `currentValue`. Emits `selected(value)` on tap.
//
// Usage:
//   PillGroup {
//       model: [{label: "30s", value: 30}, {label: "1 min", value: 60}]
//       currentValue: SettingsService.wallpaperInterval
//       onSelected: SettingsService.wallpaperInterval = value
//   }

Item {
    id: root

    /// Model: array of {label: string, value: var}.
    property var model: []
    /// The currently selected value.
    property var currentValue

    /// Emitted when the user taps a pill.
    signal selected(var value)

    implicitWidth: parent ? parent.width - 8 : 200
    implicitHeight: flow.implicitHeight

    Flow {
        id: flow
        width: parent.width
        spacing: 6

        Repeater {
            model: root.model

            delegate: Rectangle {
                readonly property var item: modelData
                readonly property bool isSelected: {
                    // Deep compare only for simple types (numbers, strings)
                    root.currentValue === item.value
                }

                width: (flow.width - (flow.spacing * (count - 1))) / count
                height: 36
                radius: 12
                color: isSelected ? Colors.primary_container : Colors.surface_container

                readonly property int count: {
                    let m = root.model
                    if (m instanceof Array) return Math.max(1, m.length)
                    if (m && m.count !== undefined) return Math.max(1, m.count)
                    return 1
                }

                Text {
                    anchors.centerIn: parent
                    text: item.label
                    font.family: "XiaoLai"; font.pixelSize: 11; font.bold: true
                    color: isSelected ? Colors.on_primary_container : Colors.on_surface_variant
                }

                TapHandler { onTapped: root.selected(item.value) }

                Behavior on color {
                    ColorAnimation { duration: 250; easing.type: Easing.OutCubic }
                }

                scale: pillTap.pressed ? 0.95 : 1.0
                Behavior on scale {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }
                TapHandler { id: pillTap }
            }
        }
    }
}
