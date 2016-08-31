import QtQuick 2.0
import QtQuick 2.3
import QtQuick.Window 2.2
import QtQuick.Extras 1.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: rightButton

    width: 125
    height: 64
//    x: screenWidth-26-width
    x: (screenWidth-width)/2
    y: 165
    property string text: "LABEL"
    signal clicked()

    opacity: 0.0

    PropertyAnimation on x { to: screenWidth-26-width}
    OpacityAnimator on opacity {from: 0; to: 1.0; easing.type: Easing.InCubic}

    SideButton {
        id: theButton
        width: parent.width
        height: parent.height
        buttonText: parent.text
        onClicked: {
            parent.clicked();
        }
    }
}