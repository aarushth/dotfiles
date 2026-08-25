pragma Singleton
import QtQuick

QtObject{
	signal lockCancelled()
	signal cancelCompleted()
	signal introCompleted()
	signal resetTimer()
	signal unlocked()
	signal unlockScreenUp()
}