//@ pragma UseQApplication
import Quickshell.Wayland
import Quickshell.Io
import Quickshell

ShellRoot {
    Panel {}
    AppLauncher {}
    NotificationManager {}

    IdleMonitor {
        timeout: 180
        onIsIdleChanged: {
            if(isIdle) lockScreen.running = true
        }
    }
    Process {
        id: lockScreen
        command: ["bash", "/home/lingchen/.local/share/quickshell-lockscreen/lock.sh"]
    }
}
