pragma Singleton
import QtQuick

// ═══════════════════════════════════════════════════════════
// NotificationService — cross-cutting notification state.
//
// Shared by NotificationManager (popup panel) and StartMenu
// (DnD toggle).  When dnd is true the manager silently drops
// incoming notifications instead of showing them on screen.
// ═══════════════════════════════════════════════════════════

QtObject {
    id: root

    // Do Not Disturb — set by StartMenu toggle
    property bool dnd: false
}
