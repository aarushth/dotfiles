import QtQuick
import QtQuick.Layouts
import Quickshell
import Qt5Compat.GraphicalEffects
import "../../config"
	
Rectangle{
	id: root
	required property int boxSize
	Layout.preferredHeight: parent.height
	SystemClock {
		id: clock
		precision: SystemClock.Minutes
	}
	color: Theme.accentPurple
	width: root.boxSize * 5
	ColumnLayout{
		id: column
		anchors.fill: parent
		spacing: 0
		Text {
			Layout.preferredWidth: parent.width
			color: Theme.bgBase
			text: Qt.formatTime(clock.date, "hh:mm")
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: 20
			font.family: Theme.fontNormal
			font.bold: true
		}
		Text {
			Layout.preferredWidth: parent.width
			color: Theme.bgBase
			text: Qt.formatDate(clock.date, "MMM dd yyyy")
			horizontalAlignment: Text.AlignHCenter
			font.pixelSize: 10
			font.family: Theme.fontFancy
		}
	}
}
