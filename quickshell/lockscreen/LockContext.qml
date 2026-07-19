import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root

    signal unlocked()
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
					root.unlocked()
					break
				case PamResult.Failed:
					console.warn("Failure")
					root.failure()
					break
				case PamResult.Error:
					console.warn("error")
					pam.restart()
					break
				case PamResult.MaxTries:
					console.warn("max tries")
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

    function restart() {
        pam.abort()
        pam.start()
    }
}