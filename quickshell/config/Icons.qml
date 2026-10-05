pragma Singleton
import QtQuick

QtObject {
    function get(id) {
        return iconsMap.get(id);
    }
    readonly property var iconsMap: new Map([["firefox", "󰈹"], ["kitty", ""],
        // outlook
        ["FFPWA-01KVW3DHW51HBQCX9WTGWBFPX5", "󰴢"], ["FFPWA-01KWDA5RWGQGKY90K5ASC92HKS", "󰴢"], ["FFPWA-01KWJ7TA62N89YFTVMET811XTV", "󰴢"],
        //gmail
        ["FFPWA-01KWJ5SF3PJ0MSX3FGMTF1NQ2R", "󰊫"],
        //ZOHO mail
        ["FFPWA-01M0HDS63PJCZX3RZKN552N8TR", ""],
        // whatsapp
        ["FFPWA-01KVW3KKWDT26QR2XQX414AM5Z", ""],
        //messages
        ["FFPWA-01KWTPJ0SZWBKKY4X7BSV5RWRN", "󰵅"], ["codium", ""], ["md.obsidian.Obsidian", ""], ["proton.vpn.app.gtk", "󰌘"], ["spotify", ""], ["discord", ""], ["steam", "󰓓"], ["warp-taskbar", ""], ["Claude", ""],
        //games
        ["alephone", gameIcon], ["Hades", gameIcon], ["Classic Marathon", gameIcon], ["Watch_Dogs", gameIcon],
        //other
        ["wl-kbptr", ""], ["qdirstat", ""], ["Problem Reporting", "󰞏"], ["sun-tools-jconsole-JConsole", ""], ["LocalSend", "󱒃"], ["btop", ""], ["quickshell-wallpaper-picker", "󰸉"], ["satty", "󱇣"], ["OneDriveGUI", "󰏊"], ["com.obsproject.Studio", "󰄄"], ["wifitui", ""], ["bluetui", "󰂯"], ["Yazi", ""], ["mpv", ""], ["zoom", ""], ["theseus", ""], ["Bitwarden", "󰞀"], ["org.fedoraproject.MediaWriter", "󱊟"], ["GlslViewer", "󰋁"], ["glslViewer", "󰋁"], ["slack", ""], ["nvim", ""], ["clipse", ""], ["hyprmoncfg", "󰍺"],])
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
