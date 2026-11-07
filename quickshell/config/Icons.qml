pragma Singleton
import QtQuick

QtObject {
    function get(id, looseMatch) {
        const upper = id.toUpperCase();
        const exact = iconsMap.get(upper);
        if (exact !== undefined)
            return exact;
        if (!looseMatch)
            return undefined;
        for (const [pattern, icon] of iconsMap) {
            if (upper.includes(pattern)) {
                return icon;
            }
        }
        return undefined;
    }
    readonly property var iconsMap: new Map([
        //apps
        ["FIREFOX", "󰈹"], ["MD.OBSIDIAN.OBSIDIAN", ""], ["SPOTATUI", ""], ["SPOTIFY", ""], ["WARP-TASKBAR", ""], ["SATTY", "󱇣"], ["DRIVEDECK", "󰏊"], ["COM.OBSPROJECT.STUDIO", "󰄄"], ["MPV", ""], ["BITWARDEN", "󰞀"], ["ORG.KDE.KDENLIVE", "󱄢"], ["ORG.INKSCAPE.INKSCAPE", ""],
        //coding
        ["KITTY", ""], ["COM.VISUALSTUDIO.CODEOSS", ""], ["SUN-TOOLS-JCONSOLE-JCONSOLE", ""], ["NVIM", ""], ["STM32CUBEIDE", "󰆦"], ["STM32CUBEMX", "󰻟"], ["KICAD", ""], ["GLSLVIEWER", "󰋁"], ["ARDUINO IDE", ""], ["MMS", "󱇷"], ["TOUCHDESIGNER", ""],
        // email
        ["NET.THUNDERBIRD.THUNDERBIRD", ""], ["ZOHO MAIL - DESKTOP", ""],
        // messaging
        ["ZAPFAST", ""], ["ORG.KDE.KDECONNECT.SMS", "󰵅"], ["DISCORD", ""], ["SLACK", ""],
        //tui
        ["BTOP", ""], ["WIFITUI", ""], ["BLUETUI", "󰂯"], ["YAZI", ""], ["CLAUDE", ""], ["CLIPSE", ""], ["HYPRMONCFG", "󰍺"],
        //games
        ["ALEPHONE", gameIcon], ["HADES", gameIcon], ["CLASSIC MARATHON", gameIcon], ["WATCH_DOGS", gameIcon], ["GAMESCOPE", gameIcon], ["BATMAN ARKHAM ASYLUM GOTY EDITION", gameIcon], ["COM.MOJANG.MINECRAFT", "󰍳"], ["ORG.PRISMLAUNCHER.PRISMLAUNCHER", ""], ["STEAM", "󰓓"], ["THESEUS", ""],
        //system apps
        ["WL-KBPTR", ""], ["QUICKSHELL-WALLPAPER-PICKER", "󰸉"], ["ZOOM", ""], ["ORG.FEDORAPROJECT.MEDIAWRITER", "󱊟"], ["HYPRPOLKITAGENT", "󰈷"], ["ORG.KDE.KDECONNECT.APP", ""]])
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
        else if (temp <= 85)
            return tempIcons[3];
        return tempIcons[4];
    }
    readonly property string sleepIcon: ""
    readonly property string wakeIcon: "󰛐"
}
