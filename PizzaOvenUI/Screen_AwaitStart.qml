import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Extras 1.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: thisScreen
    width: parent.width
    height: parent.height

    CircleScreenTemplate {
        id: theCircle
        circleValue: 0
        titleText: foodNameString
    }

    opacity: 0.0

    function screenEntry() {
        editButton.animate();
        preheatButton.animate();
        theCircle.animate();
        circleContent.animate();
        screenEntryAnimation.start();
        homeButton.animate();
    }

    OpacityAnimator {id: screenEntryAnimation; target: thisScreen; from: 0.0; to: 1.0; easing.type: Easing.InCubic; }

    property string targetScreen: ""

    OpacityAnimator {id: screenFadeOut; target: thisScreen; from: 1.0; to: 0.0;  easing.type: Easing.OutCubic;
        onStopped: {
            stackView.push({item:Qt.resolvedUrl(targetScreen), immediate:immediateTransitions});
        }
        running: false
    }

    function startExitToScreen(screen) {
        targetScreen = screen;
        screenFadeOut.start();
    }

    HomeButton {
        id: homeButton
    }

    EditButton {
        id: editButton
    }

    ButtonRight {
        id: preheatButton
        text: "PREHEAT"
        onClicked: {
            if (!demoModeIsActive) {
                backEnd.sendMessage("StartOven ");
            } else {
                lowerFront.currentTemp = 75;
            }

            if (appSettings.twoTempMode) {
                startExitToScreen("Screen_Preheating2Temp.qml");
            } else {
                startExitToScreen("Screen_Preheating.qml");
            }
        }
    }

    CircleContent {
        id: circleContent
        topString: utility.tempToString(upperFront.setTemp)
        middleString: utility.tempToString(lowerFront.setTemp)
        bottomString: utility.timeToString(cookTime)
        onTopStringClicked: {
            startExitToScreen("Screen_EnterDomeTemp.qml");
        }
        onMiddleStringClicked: {
            startExitToScreen("Screen_EnterStoneTemp.qml");
        }
        onBottomStringClicked: {
            startExitToScreen("Screen_EnterTime.qml");
        }
    }
}

