import QtQuick 2.0

Rectangle {
    id: homeButton
    signal clicked()
    implicitWidth: 40
    implicitHeight: 40
    color: appBackgroundColor

    property int segmentThickness: 2
    property color segmentColor: appForegroundColor
    x: 37
    y: 37

    Rectangle {
        id: buttonBox
        width: 30
        height: 30
        anchors.centerIn: parent

        color: appBackgroundColor

//        border.color: "orange"
//        border.width: 1

        Canvas {
            id: drawing
            width: parent.width
            height: parent.height
            antialiasing: true
            anchors.centerIn: parent

            onPaint: {
                var ctx = getContext("2d");
                ctx.save();

                ctx.clearRect(0, 0, width, height);

                // floor and walls
                ctx.beginPath();
                ctx.lineWidth = segmentThickness;
                ctx.strokeStyle = segmentColor;
                ctx.moveTo(width / 6, height / 3);
                ctx.lineTo(width / 6, height-1);
                ctx.lineTo(width * 5 / 6, height-1);
                ctx.lineTo(width * 5 / 6, height / 3);
                ctx.stroke();

                // roof
                ctx.beginPath();
                ctx.lineWidth = segmentThickness;
                ctx.strokeStyle = segmentColor;
                ctx.moveTo(0, height / 2 + 1);
                ctx.lineTo(width/2, 1);
                ctx.lineTo(width, height/2+1);
                ctx.stroke();

                ctx.restore();
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: buttonBox
        onClicked: {
            console.log("Home clicked");
            sounds.touch.play();
            homeButton.clicked();
        }
        onPressed: {
            segmentColor = appBackgroundColor;
            buttonBox.color = appForegroundColor;
            drawing.requestPaint();
        }
        onReleased: {
            segmentColor = appForegroundColor;
            buttonBox.color = appBackgroundColor;
            drawing.requestPaint();
        }
    }
}
