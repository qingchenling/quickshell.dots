import Quickshell.Widgets
import QtQuick.Effects
import QtQuick

Item {
    id: slide
    property real minn: 0
    property real maxn: 100
    property real value: 50
    property real delta: 0
    property string icon: ""
    
    IconImage {
        id: slideIcon
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 25
        width: 24
        height: 24
        source: Qt.resolvedUrl(parent.icon)
        //MultiEffect {
        //    anchors.fill: parent
        //    source: parent
        //    colorization: 1.0
        //    colorizationColor: "white"
        //}
    }

    Rectangle {
        HoverHandler { id: slideHover }

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: slideIcon.right
        anchors.leftMargin: 10
        width: 220
        height: slideHover.hovered ? 20 : 3
        radius: 30
        color: Colors.secondary_container

        Rectangle {
            anchors.left: parent.left
            height: parent.height
            width: 220 * (slide.value-slide.minn) / (slide.maxn-slide.minn)
            radius: 30
            color: Colors.primary

            Behavior on width {
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutQuart
                }
            }
        }

        Text {
            id: valueText
            anchors.centerIn: parent
            text: slide.value
            opacity: 0
            color: "white"

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuart
                }
            }

            Timer {
                id: hideTimer
                interval: 500
                running: false
                repeat: false
                onTriggered: { parent.opacity=0 }
            }
        }

        Behavior on height {
            NumberAnimation {
                duration: 100
            }
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (event) => {
                if(event.angleDelta.y>0) slide.delta=1
                else slide.delta=-1
            }
        }

        TapHandler {
            onTapped: (event) => {
                let ratio=event.position.x/parent.width
                slide.delta=Math.round(ratio*(slide.maxn-slide.minn))-slide.value
            }
        }
    }

    onValueChanged: {
        valueText.opacity = 1
        hideTimer.restart()
    }
}
