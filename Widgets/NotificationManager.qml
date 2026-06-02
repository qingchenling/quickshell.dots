import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications

import qs.Services
import "notify"

// ═══════════════════════════════════════════════════════════
// MD3 notification panel — right-side popup with animated
// notification cards that slide in from the right, auto-dismiss
// after 5 s, and collapse + fade on dismiss.
//
// Each NotifyCard manages its own lifecycle: slide-in →
// visible → auto-dismiss timer → collapse animation →
// notification.tracked = false (removes from model).
// ═══════════════════════════════════════════════════════════

PanelWindow {
    id: panel
    anchors.right: true
    anchors.top: true
    margins.top: 20
    margins.right: 30
    width: 400
    height: notificationLayout.implicitHeight
    mask: Region { item: notificationLayout }
    color: "transparent"

    // ═════════════════════════════════════════
    // Notification server
    // ═════════════════════════════════════════
    NotificationServer {
        id: notificationServer
        onNotification: function (event) {
            // Drop silently when Do Not Disturb is active
            if (NotificationService.dnd) return
            event.tracked = true
        }
    }

    // ═════════════════════════════════════════
    // Card column — height follows content
    // ═════════════════════════════════════════
    Column {
        id: notificationLayout
        width: parent.width
        spacing: 12

        Repeater {
            id: repeater
            model: notificationServer.trackedNotifications

            delegate: NotifyCard {
                width: notificationLayout.width
                notification: modelData
            }
        }
    }
}
