pragma Singleton
import QtQuick

QtObject {
    function get(id) {
        return iconsMap.get(id.toUpperCase());
    }
    readonly property var iconsMap: new Map([
        // email
        ["FFPWA-01KVW3DHW51HBQCX9WTGWBFPX5", "󰴢"], ["FFPWA-01KWDA5RWGQGKY90K5ASC92HKS", "󰴢"], ["FFPWA-01KWJ7TA62N89YFTVMET811XTV", "󰴢"], ["FFPWA-01KWJ5SF3PJ0MSX3FGMTF1NQ2R", "󰊫"], ["FFPWA-01M0HDS63PJCZX3RZKN552N8TR", ""],
        // messaging
        ["FFPWA-01KVW3KKWDT26QR2XQX414AM5Z", ""], ["FFPWA-01KWTPJ0SZWBKKY4X7BSV5RWRN", "󰵅"], ["DISCORD", ""], ["SLACK", ""],
        //coding
        ["KITTY", ""], ["VSCODIUM", ""], ["SUN-TOOLS-JCONSOLE-JCONSOLE", ""], ["NVIM", ""], ["STM32CUBEIDE", "󰆦"], ["STM32CUBEIDE-2.2.0", "󰆦"], ["COM-ST-MICROXPLORER-MAINGUI-STM32CUBEMX", "󰻟"], ["COM.ST.STM32CUBEMX", "󰻟"], ["KICAD", ""], ["GERBVIEW", "󱤓"], ["PCB_CALCULATOR", ""], ["PCBNEW", ""], ["EESCHEMA", "󱢒"], ["BITMAP2COMPONENT", "󱔽"], ["OPENCASCADE-DRAW", "󰮄"], ["DRAW", "󰮄"], ["GLSLVIEWER", "󰋁"],
        //apps
        ["FIREFOX", "󰈹"], ["MD.OBSIDIAN.OBSIDIAN", ""], ["SPOTIFY", ""], ["WARP-TASKBAR", ""], ["LOCALSEND", "󱒃"], ["SATTY", "󱇣"], ["ONEDRIVEGUI", "󰏊"], ["COM.OBSPROJECT.STUDIO", "󰄄"], ["MPV", ""], ["BITWARDEN", "󰞀"],
        //tui
        ["BTOP", ""], ["WIFITUI", ""], ["BLUETUI", "󰂯"], ["YAZI", ""], ["CLAUDE", ""], ["CLIPSE", ""], ["HYPRMONCFG", "󰍺"],
        //games
        ["ALEPHONE", gameIcon], ["HADES", gameIcon], ["CLASSIC MARATHON", gameIcon], ["WATCH_DOGS", gameIcon], ["COM.MOJANG.MINECRAFT", "󰍳"], ["ORG.PRISMLAUNCHER.PRISMLAUNCHER", ""], ["STEAM", "󰓓"], ["THESEUS", ""],
        //system apps
        ["WL-KBPTR", ""], ["QDIRSTAT", ""], ["PROBLEM REPORTING", "󰞏"], ["QUICKSHELL-WALLPAPER-PICKER", "󰸉"], ["ZOOM", ""], ["ORG.FEDORAPROJECT.MEDIAWRITER", "󱊟"], ["HYPRPOLKITAGENT", "󰈷"]])
    readonly property var brightnessIcons: ["󰹐", "󱩎", "󱩏", "󱩐", "󱩑", "󱩒", "󱩓", "󱩔", "󱩕", "󱩖", "󰛨"]
    readonly property string volumeOff: "󰖁"
    readonly property string volumeLow: "󰕿"
    readonly property string volumeMedium: "󰖀"
    readonly property string volumeHigh: "󰕾"
    readonly property string gameIcon: "󰊴"
    function getVolumeIcon(volume, muted) {
        if (muted || volume === 0)
            return volumeOff;
        if (volume >= 70)
            return volumeHigh;
        if (volume >= 30)
            return volumeMedium;
        return volumeLow;
    }
    readonly property string micIcon: "󰍬"
    readonly property var powerProfileIcons: new Map([["Performance", ""], ["Balanced", ""], ["PowerSaver", ""]])
    readonly property var batteryIcons: ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
    readonly property var batteryChargingIcons: ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"]
    readonly property var wifiIcons: ["󰤟", "󰤢", "󰤥", "󰤨"]
    readonly property string ethernetIcon: ""
    readonly property string wifiDisconnectedIcon: "󰤭"
    readonly property string wifiLoadingIcon: ""
    readonly property string bluetoothDisconnected: "󰂲"
    readonly property string bluetoothConnected: "󰂱"
    readonly property string cpuIcon: ""
    readonly property string ramIcon: ""
    readonly property var tempIcons: ["", "", "", "", ""]
    function getTempIcon(temp) {
        if (temp <= 30)
            return tempIcons[0];
        else if (temp <= 50)
            return tempIcons[1];
        else if (temp <= 70)
            return tempIcons[2];
        else if (volume <= 85)
            return tempIcons[3];
        return tempIcons[4];
    }
    readonly property string sleepIcon: ""
    readonly property string wakeIcon: "󰛐"
}
