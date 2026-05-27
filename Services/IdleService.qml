import Quickshell.Wayland
import QtQuick

QtObject {
    property bool idleInhibitor: false

    IdleMonitor {
        timeout: 30
        onIsIdleChanged: {
            if(isIdle&&!startButtom_idleInhibitor.active) lockScreen.running = true
        }
    }
    Process {
        id: lockScreen
        command: ["bash", "/home/lingchen/.local/share/quickshell-lockscreen/lock.sh"]
    }
}
