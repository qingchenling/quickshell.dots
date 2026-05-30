import Quickshell.Services.UPower
import QtQuick

import qs.Components

Button {
    height: panel.height
    width: 130
    visible: UPower.onBattery
    text: Math.floor(UPower.displayDevice.percentage*100) + "% | " +
            Math.floor(UPower.displayDevice.timeToEmpty/60) + " mins"
}
