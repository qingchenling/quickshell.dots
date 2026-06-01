import QtQuick

import qs.Themes

// Material You toggle switch — extracted from NetworkApplet
// Properties:
//   checked: bool   — current toggle state
// Signals:
//   toggled()       — emitted when the user taps the switch
Rectangle {
    id: root

    property bool checked: false
    signal toggled()

    implicitWidth: 52
    implicitHeight: 32
    radius: height / 2

    color: checked ? Colors.primary : Colors.surface_container_highest
    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }

    // Thumb knob
    Rectangle {
        id: knob
        width: parent.height - 8
        height: width
        radius: width / 2
        color: checked ? Colors.on_primary : Colors.outline_variant
        anchors.verticalCenter: parent.verticalCenter
        x: checked ? parent.width - width - 4 : 4

        Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }
    }

    // Press feedback
    scale: tapHandler.pressed ? 0.92 : 1.0
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

    TapHandler {
        id: tapHandler
        onTapped: root.toggled()
    }
}
