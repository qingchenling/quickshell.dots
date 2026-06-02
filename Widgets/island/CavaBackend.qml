import QtQuick
import Quickshell.Io

// ═══════════════════════════════════════════════════════════
// CavaBackend — drives the audio visualizer with real-time
// peak data from cava.
//
// Uses cava's "ascii" data format: each frame is a line of
// semicolon-separated values (0..12), e.g. "0;3;7;2;...\n".
// SplitParser delivers each line to _parseLine().
//
// Exports:
//   levels      — float array [0..1], 32 values
//   audioActive — bool, hysteresis-debounced
//   running     — bool, whether cava is alive
// ═══════════════════════════════════════════════════════════

Item {
    id: root

    // ── Public output ──
    // Use a plain property (not readonly with binding) so
    // consumers can bind directly and QML sees the change.
    property var levels: _zeroLevels()
    property bool audioActive: false
    readonly property bool running: cavaProc.running

    // ── Internal ──
    property var _recentPeaks: []
    // At cava's 30 fps, 30 frames ≈ 1 second of history
    readonly property int _historySize: 30
    readonly property real _threshold: 0.02
    readonly property real _asciiMax: 12.0   // matches cava.conf ascii_max_range

    function _zeroLevels() {
        var a = []
        for (var i = 0; i < 32; i++) a.push(0)
        return a
    }

    // ── Config path (relative to this file) ──
    readonly property string _configPath: {
        var u = Qt.resolvedUrl("cava.conf")
        return u.toString().replace(/^file:\/\//, "")
    }

    // ── Stdout parser ──
    SplitParser {
        id: cavaParser
        splitMarker: "\n"
        onRead: function (data) { root._parseLine(data) }
    }

    // ── Process — cava directly, no Python needed ──
    Process {
        id: cavaProc
        command: ["/usr/bin/cava", "-p", root._configPath]
        stdout: cavaParser

        onStarted: {
            console.log("CavaBackend: started (pid=" + cavaProc.processId + ")")
        }

        onExited: function (exitCode, exitStatus) {
            if (exitCode !== 0) {
                console.warn("CavaBackend: exited code=" + exitCode +
                    " — retrying in 2s")
                retryTimer.restart()
            }
        }

        function onErrorOccurred(error) {
            console.warn("CavaBackend: error", error, "— retrying in 2s")
            retryTimer.restart()
        }
    }

    // ── Auto-restart ──
    Timer {
        id: retryTimer
        interval: 2000
        onTriggered: {
            console.log("CavaBackend: restarting...")
            cavaProc.running = true
        }
    }

    // ── Startup / shutdown ──
    Component.onCompleted: {
        cavaProc.running = true
    }

    Component.onDestruction: {
        cavaProc.running = false
    }

    // ── Diagnostic ──
    property int _frameCount: 0
    Timer {
        id: diagTimer
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            var peak = 0, sum = 0
            var lvls = root.levels
            for (var i = 0; i < lvls.length; i++) {
                sum += lvls[i]
                if (lvls[i] > peak) peak = lvls[i]
            }
            console.log("CavaBackend: frames=" + root._frameCount +
                " peak=" + peak.toFixed(3) +
                " avg=" + (sum / lvls.length).toFixed(3) +
                " active=" + root.audioActive +
                " #history=" + root._recentPeaks.length)
        }
    }

    // ═══════════════════════════════════════════════════
    // Parse one line → 32 floats
    // Input format: "0;3;7;2;..." (semicolon-separated)
    // ═══════════════════════════════════════════════════
    function _parseLine(line) {
        if (!line || line.trim() === "") return
        root._frameCount++

        var parts = line.trim().split(";")
        var len = Math.min(parts.length, 32)
        var maxVal = 0

        // Build new array and assign directly (new reference = QML detects change)
        var newLevels = []
        for (var i = 0; i < 32; i++) {
            var v = 0
            if (i < len) {
                v = Number(parts[i])
                if (!isFinite(v)) v = 0
                v = Math.max(0, Math.min(1, v / root._asciiMax))
            }
            newLevels.push(v)
            if (v > maxVal) maxVal = v
        }

        // Assign new array reference — QML bindings detect this change
        root.levels = newLevels

        // ── Audio detection with hysteresis ──
        root._recentPeaks.push(maxVal)
        if (root._recentPeaks.length > root._historySize)
            root._recentPeaks.shift()

        var above = 0, below = 0
        for (var j = 0; j < root._recentPeaks.length; j++) {
            if (root._recentPeaks[j] > root._threshold) above++
            else below++
        }

        // 30-frame window (~1s at 30fps):
        //   activate  → 10/30 above (~330ms of signal)
        //   deactivate → 25/30 below (~830ms of silence)
        if (!root.audioActive && above >= 10)
            root.audioActive = true
        else if (root.audioActive && below >= 24)
            root.audioActive = false
    }
}
