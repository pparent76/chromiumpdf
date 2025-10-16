// Toast.qml
import QtQuick 2.9
import QtQuick.Controls 2.9

Rectangle {
    id: root
    radius: 8
    color: "#ff8a8a"
    z: 100
    opacity: 0
    visible: true

    // Ces anchors dépendront du parent (définis dans le parent si besoin)
    anchors.bottom: parent ? parent.bottom : undefined
    anchors.left: parent ? parent.left : undefined
    anchors.bottomMargin: 14
    anchors.leftMargin: 100

    implicitWidth: toastRow.width + 24
    implicitHeight: toastRow.height + 3

    Row {
        id: toastRow
        anchors.centerIn: parent
        spacing: 7
        padding: 12


        Text {
            id: toastText
            color: "black"
            font.pixelSize: 14
            font.bold: true
        }
    }

    Behavior on opacity {
        NumberAnimation { duration: 500 }
    }

    Timer {
        id: timer
        repeat: false
        interval: 3500
        onTriggered: {
            root.opacity = 0
            Qt.callLater(() => root.visible = false)
        }
    }

    // === Méthode publique ===
    function show(msg) {
        toastText.text = msg
        root.visible = true
        root.opacity = 1
        timer.restart()
    }
}
