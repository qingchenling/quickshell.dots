import QtQuick

import qs.Components

// Material You fade-tip — shows an icon+label notification that fades in,
// pauses, then fades out.  Unifies KeyTips_card + TipCard patterns.
//
// Properties (inherited from Button):
//   text / activeText, icon / activeIcon, bgColor / fgColor / activeBgColor / activeFgColor
//
// Additional properties:
//   active: bool       — rising edge triggers the show→pause→hide sequence
//   displayDuration: int — pause duration in ms (default 1000)
Button {
    id: root
    anchors.centerIn: parent
    height: 70
    width: 120
    visible: false

    property int displayDuration: 1000

    onActiveChanged: {
        if (!active) return
        visible = true
        anim.stop()
        anim.start()
    }

    SequentialAnimation {
        id: anim
        NumberAnimation {
            target: root
            property: "opacity"
            from: 0
            to: 1
            duration: 100
            easing.type: Easing.OutCubic
        }

        PauseAnimation { duration: root.displayDuration }

        NumberAnimation {
            target: root
            property: "opacity"
            from: 1
            to: 0
            duration: 500
            easing.type: Easing.InCubic
            onFinished: root.visible = false
        }
    }
}
