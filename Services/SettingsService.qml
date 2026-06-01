pragma Singleton
import Quickshell.Io
import Quickshell
import QtQuick

QtObject {
    id: root

    // ═══════════════════════════════════════════════════════════
    // Persistent settings stored as JSON in the quickshell config folder
    // Uses FileView for reactive reading + Process for writing
    // Config file: settings.json alongside shell.qml
    // ═══════════════════════════════════════════════════════════

    property string wallpaper: ""       // "" means random
    property string shader: "random"    // "random" or shader filename
    property int wallpaperInterval: 0   // seconds, 0 = disabled

    // ═══════════════════════════════════════════════════════════
    // Helpful derived values
    // ═══════════════════════════════════════════════════════════

    readonly property bool useRandomWallpaper: wallpaper === ""
    readonly property bool useRandomShader: shader === "random"

    signal settingsChanged()

    property bool _loading: false

    onWallpaperChanged:     { if (!_loading) scheduleSave(); settingsChanged() }
    onShaderChanged:        { if (!_loading) scheduleSave(); settingsChanged() }
    onWallpaperIntervalChanged: { if (!_loading) scheduleSave(); updateAutoTimer() }

    // ═══════════════════════════════════════════════════════════
    // Shader list — all compiled .qsb files in assets/shaders/
    // ═══════════════════════════════════════════════════════════

    property var shaderList: [
        { name: "Random",        value: "random" },
        { name: "Particle",      value: "particle.frag.qsb" },
        { name: "Dissolve",      value: "dissolve.frag.qsb" },
        { name: "Zoom Blur",     value: "zoomBlur.frag.qsb" },
        { name: "Cave Story",    value: "caveStory.frag.qsb" }
    ]

    function shaderPath(value) {
        if (!value || value === "random") return ""
        return Qt.resolvedUrl("../assets/shaders/" + value)
    }

    // ═══════════════════════════════════════════════════════════
    // Auto-switch interval options
    // ═══════════════════════════════════════════════════════════
    property var intervalOptions: [
        { label: "Off",   value: 0 },
        { label: "30s",   value: 30 },
        { label: "1 min", value: 60 },
        { label: "5 min", value: 300 },
        { label: "10 min", value: 600 },
        { label: "30 min", value: 1800 },
        { label: "1 h",   value: 3600 }
    ]

    // ═══════════════════════════════════════════════════════════
    // Auto-switch timer — fires at the configured interval
    // ═══════════════════════════════════════════════════════════
    property Timer _autoTimer: Timer {
        id: autoTimer
        interval: root.wallpaperInterval > 0 ? root.wallpaperInterval * 1000 : 60000
        repeat: true
        running: root.wallpaperInterval > 0
        onTriggered: {
            if (root.wallpaperInterval > 0) {
                BackgroundService.changeImage("")
            }
        }
        onRunningChanged: {
            if (running && root.wallpaperInterval > 0) {
                interval = root.wallpaperInterval * 1000
            }
        }
    }

    function updateAutoTimer() {
        if (root.wallpaperInterval > 0) {
            autoTimer.interval = root.wallpaperInterval * 1000
            autoTimer.restart()
        } else {
            autoTimer.stop()
        }
    }

    // ═══════════════════════════════════════════════════════════
    // JSON file loading (reactive via FileView)
    // ═══════════════════════════════════════════════════════════

    property string _settingsPath: Qt.resolvedUrl("../settings.json")

    property FileView _file: FileView {
        id: settingsFile
        path: root._settingsPath
        onLoaded: root._loadFromJson(text())
        onFileChanged: root._loadFromJson(text())
    }

    function _loadFromJson(text) {
        if (!text || text.trim() === "") return
        try {
            let data = JSON.parse(text)
            root._loading = true
            if (data.wallpaper !== undefined)         root.wallpaper         = data.wallpaper
            if (data.shader !== undefined)            root.shader            = data.shader
            if (data.wallpaperInterval !== undefined) root.wallpaperInterval = data.wallpaperInterval
            root._loading = false
        } catch (e) {
            root._loading = false
            console.warn("SettingsService: failed to parse settings.json:", e.message)
        }
    }

    // ═══════════════════════════════════════════════════════════
    // JSON file writing (debounced via Timer)
    // ═══════════════════════════════════════════════════════════

    property Timer _saveTimer: Timer {
        interval: 300   // debounce multiple rapid changes
        repeat: false
        onTriggered: root._writeSettings()
    }

    function scheduleSave() { _saveTimer.restart() }

    function _writeSettings() {
        let data = {
            wallpaper: root.wallpaper,
            shader: root.shader,
            wallpaperInterval: root.wallpaperInterval
        }
        let json = JSON.stringify(data, null, 2)
        // Escape for shell: wrap in single quotes, escape any internal single quotes
        let safe = json.replace(/'/g, "'\\''")
        writeProc.exec({ command: ["/bin/sh", "-c", "echo '" + safe + "' > " + root._settingsPath.toString().replace("file://", "")] })
    }

    property Process writeProc: Process {
        id: writeProc
    }
}
