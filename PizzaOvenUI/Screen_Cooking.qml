import QtQuick 2.3

Item {
    id: thisScreen
    implicitWidth: parent.width
    implicitHeight: parent.height
    state: "start"

    property bool screenSwitchInProgress: false
    property string targetScreen: ""
    property real cookTimeValueShadow: rootWindow.cookTimer.value
    property real cookTimerRunningShadow: rootWindow.cookTimer.running
    property int ovenStateCount: 3
    property bool topPreheated: true
    property real oldTimeRemaining: 0

    function screenEntry() {
        console.log("Entering cooking screen");
        screenSwitchInProgress = false;
        if (opacity < 1.0) screenEntryAnimation.start();
        if (!rootWindow.cookTimer.running) thisScreen.state = "start";
        ovenStateCount = 3;
        autoShutoff.start();
    }

    function startExitToScreen(screen) {
        targetScreen = screen;
        singleSettingOnly = true;
        bookmarkCurrentScreen();
        screenFadeOut.start();
    }

    function handleOvenStateMsg(state) {
        if (demoModeIsActive || (acPowerIsPresent == 0)) return;
        if (ovenStateCount > 0) {
            ovenStateCount--;
            return;
        }
        switch(state) {
        case "Standby":
            forceScreenTransition(Qt.resolvedUrl("Screen_MainMenu.qml"));
            break;
        case "Cooldown":
            forceScreenTransition(Qt.resolvedUrl("Screen_MainMenu.qml"));
            break;
        }
    }

    function handlePowerSwitchStateChanged() {
        if (powerSwitch == 1) {
            // restart cooking, if needed
            handleControlBoardCommsChanged();
        }
    }

    function handleControlBoardCommsChanged() {
        if (controlBoardCommsFailed) {
            console.log("In cooking and comms failed.");
            ovenStateCount = 5
        } else {
            console.log("In cooking and comms restored.");
            if (powerSwitch == 1) {
                console.log("Power switch is on.");
                ovenStateCount = 5
                if (!demoModeIsActive) {
                    console.log("We are not in demo mode so restarting oven.");
                    backEnd.sendMessage("StartOven ");
                }
            }
        }
    }

    OpacityAnimator {id: screenEntryAnimation; target: thisScreen; from: 0.0; to: 1.0; easing.type: Easing.InCubic; running: false}

    OpacityAnimator {id: screenFadeOut; target: thisScreen; from: 1.0; to: 0.0;  easing.type: Easing.OutCubic;
        onStopped: {
            stackView.push({item:Qt.resolvedUrl(targetScreen), immediate:immediateTransitions});
        }
        running: false
    }

    states: [
        State {
            name: "start"
            PropertyChanges {target: dataCircle; showNotice: false; showTitle: true; newTitleText: "READY"}
            PropertyChanges {target: circleContent; bottomString: utility.timeToString(cookTime)}
//            PropertyChanges {target: startButton; visible: true}
//            PropertyChanges {target: pauseButton; visible: false}
        },
        State {
            name: "first-half"
            PropertyChanges {target: dataCircle; showNotice: false; showTitle: true; newTitleText: "COOKING"}
            PropertyChanges {target: circleContent; bottomString: utility.timeToString(rootWindow.cookTimer.timeRemaining)}
//            PropertyChanges {target: startButton; visible: false}
//            PropertyChanges {target: pauseButton; visible: true}
        },
        State {
            name: "rotate-pizza"
            PropertyChanges {target: dataCircle; noticeText: "ROTATE PIZZA"; showTitle: false; showNotice: true}
        },
        State {
            name: "second-half"
            PropertyChanges {target: dataCircle; showNotice: false; showTitle: true}
        },
        State {
            name: "final-check"
            PropertyChanges {target: dataCircle; noticeText: "FINAL CHECK"; showTitle: false; showNotice: true}
        },
        State {
            name: "final"
            PropertyChanges {target: dataCircle; showNotice: false; showTitle: true}
        },
        State {
            name: "done"
            PropertyChanges {target: dataCircle; showNotice: false; showTitle: true}
            PropertyChanges {target: circleContent; bottomString: "DONE"}
//            PropertyChanges {target: pauseButton; visible: false}
//            PropertyChanges {target: startButton; visible: true}
        }
    ]

    onStateChanged: {
        console.log("State is now " + state);
        switch(state) {
        case "start":
        case "first-half":
            halfTimeRotateAlertOccurred = false;
            finalCheckAlertOccurred = false;
            pizzaDoneAlertOccurred = false;
            break;
        case "rotate-pizza":
            halfTimeRotateAlertOccurred = true;
            if (halfTimeRotateAlertEnabled) {
                sounds.alarmMid.play();
            }
            break;
        case "final-check":
            if(finalCheckAlertEnabled) {
                finalCheckAlertOccurred = true;
                sounds.alarmUrgent.play()
            }
            break;
        case "done":
            pizzaDoneAlertOccurred = true;
            if (pizzaDoneAlertEnabled) {
                sounds.cycleComplete.play();
            }
            break;
        }
    }

    onCookTimeValueShadowChanged: {
        if ((cookTimer.timeRemaining == 0) || (Math.abs(cookTimer.timeRemaining - oldTimeRemaining) >= 1)) {
            backEnd.sendMessage("TimeRemaining " + cookTimer.timeRemaining);
            oldTimeRemaining = cookTimer.timeRemaining
        }

        switch (thisScreen.state) {
        case "start":
            break;
        case "first-half":
            if (dataCircle.circleValue >= 50) {
                if (halfTimeRotateAlertEnabled) {
                    thisScreen.state = "rotate-pizza";
                } else {
                    thisScreen.state = "second-half";
                }
            }
            break;
        case "rotate-pizza":
            if (dataCircle.circleValue >= 60) {
                thisScreen.state = "second-half";
            }
            break;
        case "second-half":
            if (dataCircle.circleValue >= 85) {
                if (finalCheckAlertEnabled) {
                    thisScreen.state = "final-check";
                } else {
                    thisScreen.state = "final";
                }
            }
            break;
        case "final-check":
            if (dataCircle.circleValue >= 95) {
                thisScreen.state = "final";
            }
            break;
        case "final":
            if (dataCircle.circleValue >= 100) {
//                if (domeToggle.state) {
                if (domeToggle.state) {
                    if (topPreheated) {
                        thisScreen.state = "done";
                    } else {
                        // go to preheating
                        rootWindow.maxPreheatTimer.restart();
                        stackView.clear();
                        stackView.push({item:Qt.resolvedUrl("Screen_Preheating2Temp.qml"), immediate:immediateTransitions});
                    }
                } else {
                    // go to stone hold
                    stackView.clear();
                    stackView.push({item:Qt.resolvedUrl("Screen_Idle.qml"), immediate:immediateTransitions});
                }
            }
            break;
        case "done":
            break;
        }
    }

    CircleScreenTemplate {
        id: dataCircle
        circleValue: rootWindow.cookTimer.value
        titleText: "PREHEATING"
        newTitleText: "COOKING"
        noticeText: ""
        needsAnimation: false
    }

    HomeButton {
        id: homeButton
        needsAnimation: false
    }

    EditButton {
        id: editButton
        needsAnimation: false
    }

    property real upperTemp: upperFront.setTemp

    Timer {
        id: displayUpdateTimer
        interval: 1000
        repeat: true
        running: !demoModeIsActive
        onTriggered: {
            if (topPreheated) {
                upperTemp = upperFront.setTemp;
            } else {
                if (domeToggle.state == false) {
                    if (upperFront.currentTemp < upperFront.setTemp) {
                        upperTemp = upperFront.currentTemp;
                    }
                }
                else {
                    var currentDisplayTemp = upperTemp;
                    if (upperFront.currentTemp < upperFront.setTemp) {
                        if (upperFront.currentTemp > upperTemp) {
                            upperTemp = upperFront.currentTemp;
                        } else {
                            upperTemp = currentDisplayTemp;
                        }
                    } else {
                        upperTemp = upperFront.setTemp;
                        topPreheated = true;
                    }
                }
            }
            rootWindow.displayedDomeTemp = upperTemp;
            rootWindow.displayedStoneTemp = lowerFront.setTemp;
        }
    }
    CircleContent {
        id: circleContent
        needsAnimation: true
        topString: domeToggle.state ? utility.tempToString(upperTemp) : "OFF"
        middleString: utility.tempToString(lowerFront.setTemp)
        bottomString: utility.timeToString(rootWindow.cookTimer.timeRemaining)
        onTopStringClicked: {
            startExitToScreen("Screen_EnterDomeTemp.qml");
        }
        onMiddleStringClicked: {
            startExitToScreen("Screen_EnterStoneTemp.qml");
        }
        onBottomStringClicked: SequentialAnimation {
            OpacityAnimator {target: thisScreen; from: 1.0; to: 0.0;  easing.type: Easing.OutCubic;}
            ScriptAction {
                script: {
                    rootWindow.cookTimer.stop();
                }
            }
            ScriptAction {
                script: {
                    rootWindow.cookTimer.reset();
                    singleSettingOnly = true;
                    bookmarkCurrentScreen();
                    stackView.push({item:Qt.resolvedUrl("Screen_EnterTime.qml"), immediate:immediateTransitions});
                }
            }
        }
    }

    PauseButton {
        id: pauseButton
        needsAnimation: false
        visible: cookTimer.running || cookTimer.paused
        enabled: visible
    }

    ButtonRight {
        id: startButton
        text: "START"
        visible: !cookTimer.running && !cookTimer.paused
        enabled: visible
        onClicked: {
            console.log("Starting cook timer.");
            rootWindow.cookTimer.start();
            thisScreen.state = "first-half"
        }
        needsAnimation: false
    }

    onCookTimerRunningShadowChanged: {
        if (cookTimer.running) {
            if (thisScreen.state == "start" || thisScreen.state == "done") {
                thisScreen.state = "first-half"
            }
        } else {
            if (!cookTimer.paused) {
                thisScreen.state = "start"
                rootWindow.cookTimer.reset();
            }
        }
    }

    DomeToggle {
        id: domeToggle;
        text: "DOME"
        needsAnimation: false
        onStateChanged: domeToggle.clicked()
        onClicked: {
            console.log("Dome toggle clicked.");
            if (!demoModeIsActive) {
                topPreheated = false;
            }
            if (domeToggle.state == false) {
                switch (thisScreen.state) {
                case "start":
                case "done":
                    stackView.clear();
                    stackView.push({item:Qt.resolvedUrl("Screen_Idle.qml"), immediate:immediateTransitions});
                    break;
                }
            }
        }
    }
}

