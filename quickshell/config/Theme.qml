pragma Singleton
import QtQuick

QtObject {
	readonly property color bgBase: '#141414'
	readonly property color bgButtonHover: '#2d2c2c'
	readonly property color bgButton: '#4C4F5C'
	readonly property color bgOverlay: '#171717'

	readonly property color textPrimary: "#000000"
	readonly property color textSecondary: "#ffffff"
	readonly property color textMuted: '#929191'

	readonly property color accentPurple: '#4c09f5'
	readonly property color accentPurpleHover: '#3b06c0'
	readonly property color accentGreen: "#02C939"
	readonly property color accentYellow: "#FFE910"
	readonly property color accentOrange: "#FF4B00"
	readonly property color accentRed: "#E22E29"

	readonly property color urgencyLow: accentOrange
	readonly property color urgencyNormal: accentGreen
	readonly property color urgencyCritical: accentRed
	readonly property color batteryGood: accentGreen
	readonly property color batteryWarning: accentOrange
	readonly property color batteryCritical: accentRed

	readonly property string fontNormal: "PP Fraktion Mono"
	readonly property string fontTitle: "Specify PERSONAL Extraexpanded"
	readonly property string fontFancy: "KH Interference TRIAL"
}
