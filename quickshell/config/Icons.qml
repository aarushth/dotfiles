pragma Singleton
import QtQuick

QtObject {
	function get(id) {
        return iconsMap.get(id)
    }
    property var iconsMap: new Map([
		["org.mozilla.firefox", "󰈹"], 
		["kitty", ""],
        // outlook
        ["FFPWA-01KVW3DHW51HBQCX9WTGWBFPX5", "󰴢"], 
		["FFPWA-01KWDA5RWGQGKY90K5ASC92HKS", "󰴢"],
		["FFPWA-01KWJ7TA62N89YFTVMET811XTV", "󰴢"],
		//gmail
		["FFPWA-01KWJ5SF3PJ0MSX3FGMTF1NQ2R", "󰊫"],
		// whatsapp
		["FFPWA-01KVW3KKWDT26QR2XQX414AM5Z", ""], 
		["code", ""],
		["obsidian", ""],
		["proton.vpn.app.gtk", "󰌘"],
		["spotify", ""],
		["com.discordapp.Discord", ""],
		["steam", "󰓓"],
		["qdirstat", ""],
		["localsend", "󱒃"],
		["btop", ""],
		["quickshell-wallpaper-picker", "󰸉"],
		["OneDriveGUI", "󰏊"]
		])
}
