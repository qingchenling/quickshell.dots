import QtQuick

import qs.Components

Button {
    id: root
    anchors.centerIn: parent
    height: 70
    width: 120
    visible: false

    onActiveChanged: {
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
            easing.type: Easing.OutQuard
        }

        PauseAnimation { duration: 1000 }

        NumberAnimation {
            target: root
            property: "opacity"
            from: 1
            to: 0
            duration: 500
            easing.type: Easing.InQuard
            onFinished: root.visible = false
        }
    }
}
