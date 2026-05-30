import Quickshell.Services.UPower
import QtQuick

import qs.Components

Button {
    height: parent.height
    width: 130
    visible: UPower.onBattery
    opacity: visible ? 1 : 0
    text: Math.floor(UPower.displayDevice.percentage * 100) + "% | " +
            Math.floor(UPower.displayDevice.timeToEmpty / 60) + " mins"

    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
}
