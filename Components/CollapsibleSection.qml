import QtQuick

// Height-animated visibility wrapper — expands/collapses content with a
// smooth NumberAnimation. Use this for conditional messages and cards
// instead of manually wiring `Behavior on height` + `clip: true`.
//
// Usage:
//   CollapsibleSection {
//       visible: someCondition
//       heightWhenVisible: 64
//       // children go here
//       Rectangle { ... }
//   }

Item {
    id: root

    /// Whether the section is expanded (content shown at full height).
    property bool expanded: true
    /// The target height when expanded (in pixels).
    property real heightWhenVisible: 64

    width: parent ? parent.width : 100
    height: expanded ? heightWhenVisible : 0
    clip: true

    // Drive opacity so children inherit it
    opacity: expanded ? 1 : 0

    Behavior on height {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }
    Behavior on opacity {
        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
}
