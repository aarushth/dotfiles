import QtQuick
import Quickshell
import Quickshell.Services.Pam
import "../config"

Scope {
    id: root

	signal failure()
    property alias message: pam.message
    property alias messageIsError: pam.messageIsError
    property alias responseRequired: pam.responseRequired
    property alias responseVisible: pam.responseVisible
    PamContext {
        id: pam 
        onCompleted: (result) => {
            switch (result) {
				case PamResult.Success:
					Lockevents.unlocked()
					break
				case PamResult.Failed:
					root.failure()
					break
				case PamResult.Error:
					pam.restart()
					break
				case PamResult.MaxTries:
					pam.restart()
					break
            }
        }
		
    }
    function submit(password) {
        if (pam.responseRequired){
            pam.respond(password)
		}
    }
	function abort(){
		pam.abort()
	}
    function restart() {
        pam.abort()
        pam.start()
    }
}