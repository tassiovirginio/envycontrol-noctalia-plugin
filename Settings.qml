import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Commons
import qs.Services.UI
import qs.Widgets

ColumnLayout {
    id: root

    property var pluginApi: null

    property bool showLabel: pluginApi.pluginSettings.showLabel ?? pluginApi.manifest.metadata.defaultSettings.showLabel
    property bool toast: pluginApi.pluginSettings.toast ?? pluginApi.manifest.metadata.defaultSettings.toast
    property bool confirmReboot: pluginApi.pluginSettings.confirmReboot ?? pluginApi.manifest.metadata.defaultSettings.confirmReboot
    property bool showGpuInfo: pluginApi.pluginSettings.showGpuInfo ?? pluginApi.manifest.metadata.defaultSettings.showGpuInfo
    property bool boldText: pluginApi.pluginSettings.boldText ?? pluginApi.manifest.metadata.defaultSettings.boldText

    spacing: Style.marginM

    Component.onCompleted: {
        Logger.i("EnvyControl", "Settings UI loaded")
    }

    NText {
        text: pluginApi.tr("settings.title")
        pointSize: Style.fontSizeXL
        font.weight: Font.Bold
        color: Color.mOnSurface
    }

    NLabel {
        description: pluginApi.tr("settings.desc")
    }

    NDivider {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
    }

    // Show Label Toggle
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: showLabelToggle.implicitHeight
        NToggle {
            id: showLabelToggle
            anchors.fill: parent
            label: pluginApi.tr("settings.showLabel.text")
            description: pluginApi.tr("settings.showLabel.desc")
            checked: root.showLabel
            onToggled: checked => root.showLabel = checked
        }
    }

    // Bold Text Toggle
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: boldTextToggle.implicitHeight
        NToggle {
            id: boldTextToggle
            anchors.fill: parent
            label: pluginApi.tr("settings.boldText.text")
            description: pluginApi.tr("settings.boldText.desc")
            checked: root.boldText
            onToggled: checked => root.boldText = checked
        }
    }

    NDivider {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
    }

    // Toast Toggle
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: toastToggle.implicitHeight
        NToggle {
            id: toastToggle
            anchors.fill: parent
            label: pluginApi.tr("settings.toast.text")
            description: pluginApi.tr("settings.toast.desc")
            checked: root.toast
            onToggled: checked => root.toast = checked
        }
    }

    // Confirm Reboot Toggle
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: confirmRebootToggle.implicitHeight
        NToggle {
            id: confirmRebootToggle
            anchors.fill: parent
            label: pluginApi.tr("settings.confirmReboot.text")
            description: pluginApi.tr("settings.confirmReboot.desc")
            checked: root.confirmReboot
            onToggled: checked => root.confirmReboot = checked
        }
    }

    // Show GPU Info Toggle
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: showGpuInfoToggle.implicitHeight
        NToggle {
            id: showGpuInfoToggle
            anchors.fill: parent
            label: pluginApi.tr("settings.showGpuInfo.text")
            description: pluginApi.tr("settings.showGpuInfo.desc")
            checked: root.showGpuInfo
            onToggled: checked => root.showGpuInfo = checked
        }
    }

    NDivider {
        Layout.fillWidth: true
        Layout.topMargin: Style.marginS
        Layout.bottomMargin: Style.marginS
    }

    // Current Status
    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: statusRow.implicitHeight + Style.marginM * 2
        color: Color.mSurfaceVariant
        radius: Style.radiusM

        RowLayout {
            id: statusRow
            anchors {
                fill: parent
                margins: Style.marginM
            }
            spacing: Style.marginM

            NIcon {
                icon: pluginApi?.mainInstance?.getModeIcon(pluginApi?.mainInstance?.currentMode || "unknown") || "question-mark"
                color: pluginApi?.mainInstance?.getModeColor(pluginApi?.mainInstance?.currentMode || "unknown") || Color.mOnSurfaceVariant
                pointSize: Style.fontSizeXL
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Style.marginXS

                NText {
                    text: pluginApi.tr("settings.status.currentMode")
                    pointSize: Style.fontSizeS
                    color: Color.mOnSurfaceVariant
                }

                NText {
                    text: pluginApi?.mainInstance?.getModeLabel(pluginApi?.mainInstance?.currentMode || "unknown") || ""
                    pointSize: Style.fontSizeL
                    font.weight: Font.Bold
                    color: Color.mOnSurface
                }
            }

            NIconButton {
                icon: "refresh"
                onClicked: {
                    pluginApi?.mainInstance?.refreshMode()
                }
            }
        }
    }

    function saveSettings() {
        if (!pluginApi) {
            Logger.e("EnvyControl", "Cannot save: pluginApi is null")
            return
        }

        pluginApi.pluginSettings.showLabel = root.showLabel
        pluginApi.pluginSettings.toast = root.toast
        pluginApi.pluginSettings.confirmReboot = root.confirmReboot
        pluginApi.pluginSettings.showGpuInfo = root.showGpuInfo
        pluginApi.pluginSettings.boldText = root.boldText

        pluginApi.saveSettings()

        Logger.i("EnvyControl", "Settings saved successfully")
    }
}
