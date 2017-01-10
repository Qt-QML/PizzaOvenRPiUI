import QtQuick 2.0

Item {
    id: dialogWithCheckbox
    implicitWidth: parent.width
    implicitHeight: parent.height
    visible: false
    property alias dialogMessage: msg.text
    property alias pointSize: msg.font.pointSize
    signal clicked()

    Rectangle {
        width: parent.width
        height: parent.height
        color: appBackgroundColor
        opacity: 0.75
        MouseArea {
            anchors.fill: parent
        }
    }

    Item {
        x: (parent.width - width) / 2
        y: 96
        height: 206
        width: 206

        Rectangle {
            id: messageCircle
            height: parent.height
            width: parent.width
            radius: width/2
            color: appBackgroundColor
            border.width: 1
            border.color: appForegroundColor
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    autoShutoff.reset();
                    sounds.select.play();
                    dialogWithCheckbox.visible = false;
                    dialogWithCheckbox.clicked();
                }
            }
        }

        Text {
            id: msg
            text: "Dialog Message"
            wrapMode: Text.Wrap
            font.family: localFont.name
            font.pointSize: 18
            color: appForegroundColor
            width: 165
            height: parent.height * 0.6
            anchors.centerIn: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            id: okLabel
            text: "OK"
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            anchors.rightMargin: 5
            anchors.right: parent.horizontalCenter
            font.family: localFont.name
            font.pointSize: 18
            color: appForegroundColor
        }

        Rectangle {
            width: 28
            height: width
            color: appBackgroundColor
            border.color: appForegroundColor
            border.width: 3
            anchors.verticalCenter: okLabel.verticalCenter
            anchors.leftMargin: 5
            anchors.left: parent.horizontalCenter
        }
    }
}
