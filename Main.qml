import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI

Item {
    id: root

    property var pluginApi: null

    property string currentMode: "unknown"
    property bool switching: false
    property bool envycontrolInstalled: false
    property string gpuName: ""
    property string gpuTemp: ""
    property string gpuMemory: ""

    Component.onCompleted: {
        checkEnvycontrolInstalled()
    }

    function checkEnvycontrolInstalled() {
        checkInstalledProcess.command = ["which", "envycontrol"]
        checkInstalledProcess.running = true
    }

    function refreshMode() {
        if (!root.envycontrolInstalled) {
            root.currentMode = "not_installed"
            return
        }
        queryModeProcess.command = ["envycontrol", "--query"]
        queryModeProcess.running = true
    }

    function refreshGpuInfo() {
        queryGpuProcess.command = ["nvidia-smi", "--query-gpu=name,temperature.gpu,memory.used,memory.total", "--format=csv,noheader,nounits"]
        queryGpuProcess.running = true
    }

    function switchMode(mode, options) {
        if (!root.envycontrolInstalled || root.switching) return

        root.switching = true
        var args = ["-s", mode]

        if (options) {
            if (options.rtd3 !== undefined && mode === "hybrid") {
                args.push("--rtd3")
                args.push(options.rtd3.toString())
            }
            if (options.forceComp && mode === "nvidia") {
                args.push("--force-comp")
            }
            if (options.coolbits !== undefined && mode === "nvidia") {
                args.push("--coolbits")
                args.push(options.coolbits.toString())
            }
        }

        args.push("--verbose")

        var cmd = "yes | envycontrol " + args.join(" ")
        switchProcess.command = ["pkexec", "sh", "-c", cmd]
        switchProcess.running = true
    }

    function resetEnvycontrol() {
        if (!root.envycontrolInstalled || root.switching) return

        root.switching = true
        var cmd = "yes | envycontrol --reset --verbose"
        resetProcess.command = ["pkexec", "sh", "-c", cmd]
        resetProcess.running = true
    }

    function reboot() {
        rebootProcess.command = ["systemctl", "reboot"]
        rebootProcess.running = true
    }

    function getModeIcon(mode) {
        switch(mode) {
            case "integrated": return "cpu"
            case "hybrid": return "device-desktop"
            case "nvidia": return "gpu"
            default: return "question-mark"
        }
    }

    function getModeColor(mode) {
        switch(mode) {
            case "integrated": return "#2196F3"
            case "hybrid": return "#9C27B0"
            case "nvidia": return "#76B900"
            default: return Color.mOnSurfaceVariant
        }
    }

    function getModeLabel(mode) {
        switch(mode) {
            case "integrated": return pluginApi?.tr("mode.integrated") || "Integrated"
            case "hybrid": return pluginApi?.tr("mode.hybrid") || "Hybrid"
            case "nvidia": return pluginApi?.tr("mode.nvidia") || "NVIDIA"
            case "not_installed": return pluginApi?.tr("mode.notInstalled") || "Not Installed"
            default: return pluginApi?.tr("mode.unknown") || "Unknown"
        }
    }

    Process {
        id: checkInstalledProcess
        onExited: (exitCode) => {
            root.envycontrolInstalled = exitCode === 0
            if (root.envycontrolInstalled) {
                refreshMode()
            } else {
                root.currentMode = "not_installed"
            }
        }
    }

    Process {
        id: queryModeProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim().toLowerCase()
                if (output.includes("integrated")) {
                    root.currentMode = "integrated"
                } else if (output.includes("hybrid")) {
                    root.currentMode = "hybrid"
                } else if (output.includes("nvidia")) {
                    root.currentMode = "nvidia"
                } else {
                    root.currentMode = "unknown"
                }
                Logger.i("EnvyControl", "Current mode:", root.currentMode)
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                Logger.w("EnvyControl", "Query failed with code:", exitCode)
                root.currentMode = "unknown"
            }
        }
    }

    Process {
        id: queryGpuProcess
        stdout: StdioCollector {
            onStreamFinished: {
                var output = this.text.trim()
                var parts = output.split(",").map(function(s) { return s.trim() })
                if (parts.length >= 4) {
                    root.gpuName = parts[0]
                    root.gpuTemp = parts[1] + " C"
                    root.gpuMemory = parts[2] + " / " + parts[3] + " MiB"
                }
            }
        }
    }

    Process {
        id: switchProcess
        stdout: StdioCollector {
            onStreamFinished: {
                Logger.i("EnvyControl", "Switch output:", this.text)
            }
        }
        onExited: (exitCode) => {
            root.switching = false
            if (exitCode === 0) {
                Logger.i("EnvyControl", "Mode switched successfully")
                if (pluginApi?.pluginSettings?.toast ?? pluginApi?.manifest?.metadata?.defaultSettings?.toast ?? true) {
                    ToastService.showNotice(pluginApi?.tr("toast.switched") || "GPU mode switched. Reboot required.")
                }
                refreshMode()
            } else {
                Logger.e("EnvyControl", "Switch failed with code:", exitCode)
                ToastService.showError(pluginApi?.tr("toast.switchFailed") || "Failed to switch GPU mode")
            }
        }
    }

    Process {
        id: resetProcess
        stdout: StdioCollector {
            onStreamFinished: {
                Logger.i("EnvyControl", "Reset output:", this.text)
            }
        }
        onExited: (exitCode) => {
            root.switching = false
            if (exitCode === 0) {
                Logger.i("EnvyControl", "Reset successful")
                if (pluginApi?.pluginSettings?.toast ?? pluginApi?.manifest?.metadata?.defaultSettings?.toast ?? true) {
                    ToastService.showNotice(pluginApi?.tr("toast.reset") || "EnvyControl reset. Reboot required.")
                }
                refreshMode()
            } else {
                Logger.e("EnvyControl", "Reset failed with code:", exitCode)
                ToastService.showError(pluginApi?.tr("toast.resetFailed") || "Failed to reset EnvyControl")
            }
        }
    }

    Process {
        id: rebootProcess
    }

    IpcHandler {
        target: "plugin:envy-control"

        function query() {
            Logger.d("EnvyControl", "IPC: query mode")
            root.pluginApi.mainInstance.refreshMode()
        }

        function switchToIntegrated() {
            Logger.d("EnvyControl", "IPC: switch to integrated")
            root.pluginApi.mainInstance.switchMode("integrated", null)
        }

        function switchToHybrid() {
            Logger.d("EnvyControl", "IPC: switch to hybrid")
            root.pluginApi.mainInstance.switchMode("hybrid", null)
        }

        function switchToNvidia() {
            Logger.d("EnvyControl", "IPC: switch to nvidia")
            root.pluginApi.mainInstance.switchMode("nvidia", null)
        }

        function reset() {
            Logger.d("EnvyControl", "IPC: reset")
            root.pluginApi.mainInstance.resetEnvycontrol()
        }
    }
}
