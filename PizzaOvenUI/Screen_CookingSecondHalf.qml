import QtQuick 2.3

Item {
    id: thisScreen
    implicitWidth: parent.width
    implicitHeight: parent.height

    property bool screenSwitchInProgress: false

    function screenEntry() {
        screenSwitchInProgress = false;
    }

    CircleScreenTemplate {
        id: dataCircle
        circleValue: rootWindow.cookTimer.value
        titleText: "COOKING"
        onCircleValueChanged: {
            doExitCheck();
        }
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

    CircleContent {
        id: circleContent
        topString: utility.tempToString(upperFront.setTemp)
        middleString: utility.tempToString(lowerFront.setTemp)
        bottomString: utility.timeToString(cookTime * dataCircle.circleValue / 100)
        needsAnimation: false
    }

    PauseButton {
        id: pauseButton
        needsAnimation: false
    }

    function doExitCheck() {
        if (screenSwitchInProgress) return;
        if (cookTime * dataCircle.circleValue / 100 >= finalCheckTime) {
            screenSwitchInProgress = true;
            screenExitAnimator.start();
        }
    }

    SequentialAnimation {
        id: screenExitAnimator
        ScriptAction {
            script: {
                stackView.push({item:Qt.resolvedUrl("Screen_CookingFinalCheck.qml"), immediate:immediateTransitions});
            }
        }
    }
}
