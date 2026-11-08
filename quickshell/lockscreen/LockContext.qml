import QtQuick
import Quickshell
import Quickshell.Services.Pam
import "../config"

Scope {
    id: root

    signal failure
    // True from password submit until PAM either succeeds (unlock screen takes over),
    // fails, errors, asks a new question, or is restarted.
    property bool verifying: false
    property alias message: pam.message
    property alias messageIsError: pam.messageIsError
    property alias responseRequired: pam.responseRequired
    property alias responseVisible: pam.responseVisible
    onMessageChanged: console.warn(message)
    PamContext {
        id: pam
        config: "login"
        onResponseRequiredChanged: if (responseRequired) root.verifying = false
        onCompleted: result => {
            if (result !== PamResult.Success)
                root.verifying = false;
            switch (result) {
            case PamResult.Success:
                Lockevents.unlocked();
                break;
            case PamResult.Failed:
                root.failure();
                console.warn("failed");
                break;
            case PamResult.Error:
                pam.restart();
                break;
            case PamResult.MaxTries:
                pam.restart();
                break;
            }
        }
    }
    function submit(password) {
        if (pam.responseRequired) {
            root.verifying = true;
            pam.respond(password);
        }
    }
    function abort() {
        root.verifying = false;
        pam.abort();
    }
    function restart() {
        root.verifying = false;
        pam.abort();
        pam.start();
    }
}
