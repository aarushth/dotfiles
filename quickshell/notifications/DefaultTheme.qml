import QtQuick

QtObject {
  readonly property color bgBase: '#141414'
  readonly property color bgButtonHover: '#2d2c2c'
  readonly property color bgButton: '#4C4F5C'
  readonly property color bgOverlay: "#88000000"
//   readonly property color bgHover: "#1e2235"
//   readonly property color bgSelected: "#283457"
//   readonly property color bgBorder: '#343434'

  readonly property color textPrimary: "#000000"
  readonly property color textSecondary: "#ffffff"
  readonly property color textMuted: '#929191'

  readonly property color accentPrimary: "#7aa2f7"
  readonly property color accentCyan: "#7dcfff"
  readonly property color accentGreen: "#02C939"
  readonly property color accentOrange: "#FFE910"
  readonly property color accentRed: "#E22E29"

  readonly property color urgencyLow: accentOrange
  readonly property color urgencyNormal: accentGreen
  readonly property color urgencyCritical: accentRed
  readonly property color batteryGood: accentGreen
  readonly property color batteryWarning: accentOrange
  readonly property color batteryCritical: accentRed

}
