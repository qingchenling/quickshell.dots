import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.Themes
import "island"

// ═══════════════════════════════════════════════════════════
// DyIsland — Dynamic Island pill + app launcher.
// PanelWindow anchored top, full-width transparent, mask-
// clipped to the pill.  Modules: AudioVisualizer, Launcher.
//
// States:  HIDDEN (transparent)  /  COLLAPSED (120×34 viz)
//          LAUNCHER  (400×450 search+apps)
//
// IpcHandler target:  "DyIsland"  →  Alt+Space
// ═══════════════════════════════════════════════════════════

PanelWindow {
    id: win
    anchors.top: true; anchors.left: true; anchors.right: true
    margins.top: 5
    implicitHeight: pill.launcherH
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: pill }

    // ── Focus ──
    focusable: true

    // ═══════════════════════════════  State  ═══════════════
    enum State { HIDDEN, COLLAPSED, LAUNCHER }
    property int state: DyIsland.HIDDEN

    CavaBackend { id: cava }

    // ── MPRIS: detect active multimedia playback ──
    // Mpris.players is ObjectModel — use .values to get list
    readonly property bool mediaActive: {
        var players = Mpris.players.values
        for (var i = 0; i < players.length; i++) {
            if (players[i].playbackState === MprisPlaybackState.Playing)
                return true
        }
        return false
    }

    // ── Delayed hide (fade-out then unmap) ──
    property bool _hiding: false
    visible: win.state !== DyIsland.HIDDEN || _hiding
    onStateChanged: {
        if (win.state === DyIsland.HIDDEN) { _hiding = true; hideTimer.start() }
        else { _hiding = false; hideTimer.stop() }
    }
    Timer { id: hideTimer; interval: 300; onTriggered: _hiding = false }

    // ── Delayed content reveal (after size morph) ──
    property bool _contentReady: false
    Timer {
        id: revealTimer; interval: 320
        onTriggered: {
            _contentReady = true
            focusTimer.start()  // retry until searchInput gets focus
        }
    }
    Timer {
        id: focusTimer; interval: 30; repeat: true
        property int _n: 0
        onTriggered: {
            _n++
            launcherMod.searchInput.forceActiveFocus()
            if (launcherMod.searchInput.activeFocus || _n > 10) { stop(); _n = 0 }
        }
    }

    // ═══════════════════════════════  I/O  ══════════════════
    IpcHandler {
        target: "DyIsland"
        function toggle() {
            if (win.state === DyIsland.LAUNCHER)
                _setState(mediaActive ? DyIsland.COLLAPSED : DyIsland.HIDDEN)
            else
                _setState(DyIsland.LAUNCHER)
        }
    }
    Shortcut {
        sequence: "Escape"
        enabled: win.state === DyIsland.LAUNCHER
        onActivated: _setState(mediaActive ? DyIsland.COLLAPSED : DyIsland.HIDDEN)
    }

    // ── Audio poll + level push ──
    Timer {
        id: audioPoll; interval: 50; running: true; repeat: true
        onTriggered: {
            if (audioViz.visible) audioViz.levels = cava.levels
            if (win.state === DyIsland.LAUNCHER) return
            var tgt = mediaActive ? DyIsland.COLLAPSED : DyIsland.HIDDEN
            if (win.state !== tgt) _setState(tgt)
        }
    }

    function _setState(s) {
        if (win.state === s) return
        var names = ["HIDDEN","COLLAPSED","LAUNCHER"]
        console.log("DyIsland:", names[win.state], "→", names[s],
            "audio=" + mediaActive)
        win.state = s
        if (s === DyIsland.LAUNCHER) {
            _contentReady = false
            revealTimer.start()
        } else {
            _contentReady = false
            revealTimer.stop()
            focusTimer.stop()
        }
    }

    // ═══════════════════════════════  Pill  ═════════════════
    Rectangle {
        id: pill
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        readonly property real collapsedW: 120
        readonly property real collapsedH: 34
        readonly property real launcherW: 400
        readonly property real launcherH: 450

        width:  win.state === DyIsland.LAUNCHER ? launcherW : collapsedW
        height: win.state === DyIsland.LAUNCHER ? launcherH : collapsedH
        radius: win.state === DyIsland.LAUNCHER ? 36 : height / 2

        color: Colors.surface_container_high
        border.width: 1; border.color: Colors.outline_variant

        // ── Visibility ──
        scale:  win.state === DyIsland.HIDDEN ? 0.7 : 1.0
        opacity: win.state === DyIsland.HIDDEN ? 0.0 : 1.0

        Behavior on width   { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on height  { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on radius  { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on scale   { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

        // ── Module A: Audio Visualizer ──
        AudioVisualizer {
            id: audioViz
            anchors.centerIn: parent
            opacity: (win.state === DyIsland.COLLAPSED
                      && pill.height <= pill.collapsedH + 10) ? 1.0 : 0.0
            levels: cava.levels
            barCount: 32; barWidth: 2; barSpacing: 1
            minBarHeight: 2; maxBarHeight: pill.collapsedH - 6
            barColor: Colors.primary
            Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        // ── Module B: Launcher ──
        LauncherModule {
            id: launcherMod
            anchors.fill: parent
            opacity: (win.state === DyIsland.LAUNCHER && _contentReady) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
            onAppLaunched: _setState(mediaActive ? DyIsland.COLLAPSED : DyIsland.HIDDEN)
        }
    }
}
