import QtQuick 2.3
import QtWebSockets 1.0

Item {

    // The reset line is active high on the Pi and active low on the control board.
    property bool resetLineState: false

    function start() {
        webSocketConnectionTimer.start();
    }

    function sendMessage(msg) {
        if (socket.status == WebSocket.Open) {
            socket.sendTextMessage(msg);
        }
    }


    WebSocket {
        id: socket
        url: "ws://localhost:8080"
        onTextMessageReceived: {
            //            console.log("Received message: " + message);
            handleWebSocketMessage(message);
        }
        onStatusChanged: if (socket.status == WebSocket.Error) {
                             //                             console.log("Error: " + socket.errorString)
                             webSocketConnectionTimer.start();
                         } else if (socket.status == WebSocket.Open) {
                             socket.sendTextMessage("Hello World")
                             sendMessage("Get UF");
                             sendMessage("Get UR");
                             sendMessage("Get LF");
                             sendMessage("Get LR");
                         } else if (socket.status == WebSocket.Closed) {
                             //                             console.log("Socket closed");
                             webSocketConnectionTimer.start();
                         }
        active: false
    }

    WebSocket {
        id: secureWebSocket
        url: "wss://localhost"
        onTextMessageReceived: {
            console.log("Received secure message: " + message);
        }
        onStatusChanged: if (secureWebSocket.status == WebSocket.Error) {
                             //                             console.log("Error: " + secureWebSocket.errorString)
                         } else if (secureWebSocket.status == WebSocket.Open) {
                             secureWebSocket.sendTextMessage("Hello Secure World")
                         } else if (secureWebSocket.status == WebSocket.Closed) {
                             console.log("Secure socket closed");
                         }
        active: false
    }

    Timer {
        id: webSocketConnectionTimer
        interval: 1000; running: false; repeat: true
        onTriggered: {
            switch(socket.status) {
            case WebSocket.Closed:
                console.log("Web socket is closed.");
                socket.active = false;
                socket.active = true;
                break;
            case WebSocket.Connecting:
                console.log("Web socket is connecting.");
                break;
            case WebSocket.Open:
                webSocketConnectionTimer.stop();
                break;
            case WebSocket.Closing:
                console.log("Web socket is closing.");
                break;
            case WebSocket.Error:
                //                console.log("Web socket is error.");
                socket.active = false;
                socket.active = true;
                break;
            }
        }
    }

    function handleWebSocketMessage(_msg) {
        var  msg = JSON.parse(_msg);
        switch (msg.id){
        case "Temp":
            if (msg.data.LF && msg.data.LR){
                upperFront.currentTemp = msg.data.UF;
                upperRear.currentTemp = msg.data.UR;
                lowerFront.currentTemp = msg.data.LF;
                lowerRear.currentTemp = msg.data.LR;
            } else {
                console.log("Temp data missing.");
            }
            break;
        case "Reset":
            if (msg.data.pin) {
                if (msg.data.pin == 1) {
                    resetLineState = true;
                } else {
                    resetLineState = true;
                }
            }
            break;
        case "SetTemp":
            console.log("Got a set temp message: " + _msg);
            break;
        case "CookTime":
            console.log("Got a cook time message: " + _msg);
            break;
        case "Power":
            console.log("Power message: " + JSON.stringify(msg));
            if (msg.data.powerSwitch && msg.data.l2DLB) {
                dlb = msg.data.l2DLB*1;
                powerSwitch = msg.data.powerSwitch*1;
            }
            if (msg.data.tco) {
                tco = msg.data.tco*1;
            }

            var oldState = oldPowerSwitch + (oldDlb * 10);
            var newState = powerSwitch + (dlb * 10);

            if (oldDlb != dlb) {
                console.log("DLB state is now " + dlb);
            }
            if (oldPowerSwitch != powerSwitch) {
                console.log("Power switch state is now " + powerSwitch);
                console.log("Old state: " + oldState + ", new state: " + newState);
                if (powerSwitch == 1) {
                    sounds.powerOn.play();
                } else {
                    sounds.powerOff.play();
                }
            }

            oldDlb = dlb;
            oldPowerSwitch = powerSwitch;

            if (developmentModeIsActive) {
                forceScreenTransition(Qt.resolvedUrl("Screen_Development.qml"));
                return;
            }


            switch(oldState) {
            case 00: // off
                switch(newState) {
                case 00:
                    if (ovenState == "Standby") {
                        console.log("Transitioning to off. 194");
                        forceScreenTransition(Qt.resolvedUrl("Screen_Off.qml"));
                    }
                    if (ovenState == "Cooldown") {
                        console.log("Transitioning to cooldown.");
                        forceScreenTransition(Qt.resolvedUrl("Screen_Cooldown.qml"));
                    }
                    break;
                case 01:
                    console.log("Transitioning to main menu.");
                    forceScreenTransition(Qt.resolvedUrl("Screen_MainMenu.qml"));
                    break;
                case 10:
                    console.log("Transitioning to cooldown.");
                    forceScreenTransition(Qt.resolvedUrl("Screen_Cooldown.qml"));
                    break;
                case 11:
                    console.log("Transitioning to main menu.");
                    forceScreenTransition(Qt.resolvedUrl("Screen_MainMenu.qml"));
                    break;
                }
                break;
            case 01: // powered on
                switch(newState) {
                case 00:
                    if (ovenState == "Cooldown") {
                        console.log("Transitioning to cooldown.");
                        forceScreenTransition(Qt.resolvedUrl("Screen_Cooldown.qml"));
                    } else {
                        console.log("Transitioning to off. 223");
                        forceScreenTransition(Qt.resolvedUrl("Screen_Off.qml"));
                    }
                    break;
                case 10:
                    console.log("Transitioning to cooldown.");
                    forceScreenTransition(Qt.resolvedUrl("Screen_Cooldown.qml"));
                    break;
                }
                break;
            case 10: // cooling
                switch(newState) {
                case 00:
                    if (ovenState == "Cooldown") {
                        console.log("Transitioning to cooldown.");
                        forceScreenTransition(Qt.resolvedUrl("Screen_Cooldown.qml"));
                    } else {
                        console.log("Transitioning to off. 240");
                        forceScreenTransition(Qt.resolvedUrl("Screen_Off.qml"));
                    }
                    break;
                case 01:
                    console.log("Transitioning to main menu.");
                    forceScreenTransition(Qt.resolvedUrl("Screen_MainMenu.qml"));
                    break;
                case 11:
                    console.log("Transitioning to main menu.");
                    forceScreenTransition(Qt.resolvedUrl("Screen_MainMenu.qml"));
                    break;
                }
                break;
            case 11: // cooking or other
                switch(newState) {
                case 00:
                    if (ovenState == "Cooldown") {
                        console.log("Transitioning to cooldown.");
                        forceScreenTransition(Qt.resolvedUrl("Screen_Cooldown.qml"));
                    } else {
                        console.log("Transitioning to off. 261");
                        forceScreenTransition(Qt.resolvedUrl("Screen_Off.qml"));
                    }
                    break;
                case 01:
                    console.log("Transitioning to main menu.");
                    forceScreenTransition(Qt.resolvedUrl("Screen_MainMenu.qml"));
                    break;
                case 10:
                    console.log("Transitioning to cooldown.");
                    forceScreenTransition(Qt.resolvedUrl("Screen_Cooldown.qml"));
                    break;
                }
                break;
            }
            break;
        case "RelayParameters":
            console.log("Received relay parameters: " + _msg);
            if (msg.data) {
                if (msg.data.relay && msg.data.onTemp && msg.data.offTemp && msg.data.onPercent && msg.data.offPercent) {
                    switch(msg.data.relay) {
                    case "UF":
                        console.log("Setting the data for UF.");
                        upperFront.setTemp = (parseInt(msg.data.onTemp) + parseInt(msg.data.offTemp)) / 2;
                        upperFront.onPercent = parseInt(msg.data.onPercent);
                        upperFront.offPercent = parseInt(msg.data.offPercent);
                        break;
                    case "UR":
                        console.log("Setting the data for UR.");
                        upperRear.setTemp = (parseInt(msg.data.onTemp) + parseInt(msg.data.offTemp)) / 2;
                        upperRear.onPercent = parseInt(msg.data.onPercent);
                        upperRear.offPercent = parseInt(msg.data.offPercent);
                        break;
                    case "LF":
                        console.log("Setting the data for LF.");
                        lowerFront.setTemp = (parseInt(msg.data.onTemp) + parseInt(msg.data.offTemp)) / 2;
                        lowerFront.onPercent = parseInt(msg.data.onPercent);
                        lowerFront.offPercent = parseInt(msg.data.offPercent);
                        lowerFront.setTemp = lowerFront.setTemp;
                        break;
                    case "LR":
                        console.log("Setting the data for LR.");
                        lowerRear.setTemp = (parseInt(msg.data.onTemp) + parseInt(msg.data.offTemp)) / 2;
                        lowerRear.onPercent = parseInt(msg.data.onPercent);
                        lowerRear.offPercent = parseInt(msg.data.offPercent);
                        break;
                    }
                }
            }
            break;
        case "OvenState":
            ovenState = msg.data;
            break;
        case "PidDutyCycles":
            upperFront.elementDutyCycle = msg.data.UF;
            upperRear.elementDutyCycle = msg.data.UR;
            lowerFront.elementDutyCycle = msg.data.LF;
            lowerRear.elementDutyCycle = msg.data.LR;
            break;
        case "RelayStates":
            upperFront.elementRelay = msg.data.UF;
            upperRear.elementRelay = msg.data.UR;
            lowerFront.elementRelay = msg.data.LF;
            lowerRear.elementRelay = msg.data.LR;
            break;
        case "Door":
            doorStatus = msg.data.Status;
            doorCount = msg.data.Count;
            //console.log("Got a door message: " + JSON.stringify(msg));
            break;
        case "ControlVersion":
            console.log("Version: " + msg.data.ovenFirmwareVersion);
            controlVersion = msg.data.ovenFirmwareVersion + "." + msg.data.ovenFirmwareBugfixVersion;
            break;
        case "BackendVersion":
            console.log("Backend Version: " + msg.data.backendVersion);
            backendVersion = msg.data.backendVersion;
            break;
        default:
            console.log("Unknown message received: " + _msg);
            break
        }
    }
}
