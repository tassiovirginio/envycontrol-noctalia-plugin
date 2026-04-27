# EnvyControl - Noctalia Plugin

A GPU mode switcher plugin for [Noctalia](https://github.com/noctalia-dev/noctalia) that allows switching between Integrated, Hybrid, and NVIDIA graphics modes using [EnvyControl](https://github.com/bayasdev/envycontrol).

## Features

- **GPU Mode Switching** - Switch between Integrated, Hybrid, and NVIDIA modes
- **Bar Widget** - Displays current GPU mode with icon and optional label
- **Panel Interface** - Full panel with mode selection cards and descriptions
- **Context Menu** - Right-click quick access to switch modes
- **Reboot Confirmation** - Optional dialog before rebooting after mode switch
- **Toast Notifications** - Feedback on mode switch operations
- **GPU Info** - Optional display of GPU temperature and memory usage
- **Internationalization** - English and Portuguese translations included

## Prerequisites

- [Noctalia](https://github.com/noctalia-dev/noctalia) >= 3.6.0
- [EnvyControl](https://github.com/bayasdev/envycontrol) installed on the system
- NVIDIA GPU with proprietary drivers

## Installation

1. Clone or download this plugin into your Noctalia plugins directory:
   ```bash
   cd ~/.config/noctalia/plugins/
   git clone https://github.com/noctalia-dev/noctalia-plugins.git envy-control
   ```

2. Enable the plugin in Noctalia settings.

## Configuration

Access plugin settings through Noctalia or right-click the bar widget and select "Settings".

| Setting | Default | Description |
|---------|---------|-------------|
| Show Label | `true` | Display mode name next to the icon |
| Bold Text | `true` | Use bold font for the mode label |
| Toast Notifications | `true` | Show notifications on mode switch |
| Confirm Reboot | `true` | Show reboot confirmation dialog |
| Show GPU Info | `false` | Display GPU temp and memory in tooltip |

## Usage

### Bar Widget

- **Left Click**: Opens the GPU mode panel
- **Right Click**: Opens context menu with quick actions
- **Hover**: Shows tooltip with current mode

### Panel

The panel displays three mode cards:

| Mode | Icon | Description |
|------|------|-------------|
| Integrated | `cpu` | Intel/AMD only, best battery life |
| Hybrid | `device-desktop` | On-demand GPU, balanced power |
| NVIDIA | `gpu` | NVIDIA only, maximum performance |

### IPC Commands

The plugin exposes IPC commands for external control:

```bash
# Query current mode
quickshell ipc call plugin:envy-control query

# Switch modes
quickshell ipc call plugin:envy-control switchToIntegrated
quickshell ipc call plugin:envy-control switchToHybrid
quickshell ipc call plugin:envy-control switchToNvidia

# Reset EnvyControl
quickshell ipc call plugin:envy-control reset
```

## File Structure

```
envy-noctalia/
├── Main.qml          # Core logic and IPC handler
├── BarWidget.qml     # Bar widget component
├── Panel.qml         # Mode selection panel
├── Settings.qml      # Plugin settings UI
├── manifest.json     # Plugin metadata
├── i18n/
│   ├── en.json       # English translations
│   └── pt.json       # Portuguese translations
└── README.md
```

## License

MIT
