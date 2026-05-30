import Quickshell.Services.UPower
import QtQuick

import qs.Themes

Rectangle {
    property bool charged: UPower.displayDevice.state === UPowerDeviceState.Charging

    anchors.verticalCenter: parent.verticalCenter
    height: 30
    color: "transparent"

    Rectangle {
        id: fuckingHead
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: 2
        height: 6
        radius: 1
        color: Colors.outline
    }
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: fuckingHead.left
        width: 30
        height: 15
        radius: 3
        color: "transparent"
        border.width: 2
        border.color: Colors.outline

        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: 3
            anchors.verticalCenter: parent.verticalCenter
            width: (parent.width - 6) * UPower.displayDevice.percentage
            height: parent.height - 6
            radius: 2
            color: charged ? Colors.primary : Colors.secondary

            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            Behavior on color { ColorAnimation { duration: 200 } }
        }
    }
}
