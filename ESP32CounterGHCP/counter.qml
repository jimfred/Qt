// Copyright (C) 2025 Jim Frangione
// ESP32 Dual Counter Application
import QtQuick 2.15

Rectangle {
    id: root
    width: 320
    height: 240
    color: "#2C3E50"

    Column {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // Title
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "ESP32 Dual Counter"
            font.pixelSize: 24
            font.bold: true
            color: "#ECF0F1"
        }

        // Counter 1 Section
        Rectangle {
            width: parent.width
            height: 80
            color: "#34495E"
            radius: 5

            Column {
                anchors.centerIn: parent
                spacing: 5

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Text {
                        text: "Counter 1:"
                        font.pixelSize: 18
                        color: "#ECF0F1"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        id: counter1Switch
                        width: 60
                        height: 30
                        radius: 15
                        color: checked ? "#2ECC71" : "#7F8C8D"
                        
                        property bool checked: false
                        
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: "#ECF0F1"
                            x: counter1Switch.checked ? 32 : 2
                            y: 2
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                counter1Switch.checked = !counter1Switch.checked;
                                CounterControl.setCounter1Running(counter1Switch.checked);
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: CounterControl.counter1Value
                    font.pixelSize: 32
                    font.bold: true
                    color: counter1Switch.checked ? "#2ECC71" : "#95A5A6"
                }
            }
        }

        // Counter 2 Section
        Rectangle {
            width: parent.width
            height: 80
            color: "#34495E"
            radius: 5

            Column {
                anchors.centerIn: parent
                spacing: 5

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Text {
                        text: "Counter 2:"
                        font.pixelSize: 18
                        color: "#ECF0F1"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Rectangle {
                        id: counter2Switch
                        width: 60
                        height: 30
                        radius: 15
                        color: checked ? "#3498DB" : "#7F8C8D"
                        
                        property bool checked: false
                        
                        Rectangle {
                            width: 26
                            height: 26
                            radius: 13
                            color: "#ECF0F1"
                            x: counter2Switch.checked ? 32 : 2
                            y: 2
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                counter2Switch.checked = !counter2Switch.checked;
                                CounterControl.setCounter2Running(counter2Switch.checked);
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: CounterControl.counter2Value
                    font.pixelSize: 32
                    font.bold: true
                    color: counter2Switch.checked ? "#3498DB" : "#95A5A6"
                }
            }
        }

        // Status text
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Toggle switches to start/stop counters"
            font.pixelSize: 12
            color: "#BDC3C7"
        }
    }
}
