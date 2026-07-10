import Quickshell
import Quickshell.Wayland
import QtQuick
import qs.config.fonts

ShellRoot {
	//--Color#--
	property color textColor: "#ffffff"

	//--Size--
	property int sizeTop:  90
	property int sizeCenter: 20
	property int sizeDown:  18

    //--Spacing--
	property int spaceWith: 4

	//--Spacing between text--
	property int spaceBetweenTopText: 10
	property int spaceBetweenDownText: 0
	
    PanelWindow {
        // ┌─────────────────────────────────────┐
        // │           Widget position           │
        // ├─────────────────────────────────────┤
        // │  Active side (true/false)           │
            anchors.top: false                  
            anchors.right: true                
            anchors.left: true                 
            anchors.bottom: true               
        //    Position     
            margins.top: 0                   
            margins.right: 0              
            margins.left: 1300                   
            margins.bottom: 50                   
        // └─────────────────────────────────────┘
 
 //─────────────────────────────────────────────────────────────────────────

        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "clock-widget"
        WlrLayershell.exclusiveZone: -1
        color: "transparent"

        // --- Time ---
 		SystemClock { id: clock; precision: SystemClock.Seconds }

        // --- Content ---
        Column {
            id: container
            anchors.centerIn: parent
            spacing: spaceWith

// ── Days of the week ──────────────────────────
            Item {
                implicitWidth: clock_day.implicitWidth
                implicitHeight: clock_day.implicitHeight
                anchors.horizontalCenter: parent.horizontalCenter

                // shadow
                Text {
                    x: 2; y: 2
                    text: clock_day.text
                    font: clock_day.font
                    color: "#550000"
                }
                // Main text
                Text {
                    id: clock_day
                    text: Qt.formatDate(clock.date, "dddd").toUpperCase()
                    font.family: Fonts.activeTopFont
                    font.pixelSize: sizeTop
                    color: textColor
                    font.letterSpacing: spaceBetweenTopText
                    
                }
            }

            // ── Date ────────────────────────────────
            Item {
                implicitWidth: clock_date.implicitWidth
                implicitHeight: clock_date.implicitHeight
                anchors.horizontalCenter: parent.horizontalCenter

                // shadow
                Text {
                    x: 1; y: 1
                    text: clock_date.text
                    font: clock_date.font
                    color: "#550000"
                }
                // Main text
                Text {
                    id: clock_date
                    text: Qt.formatDate(clock.date, "dd MMM yyyy").toUpperCase()
                    font.family: Fonts.activeDownFont
                    font.pixelSize: sizeCenter
                    color: textColor
                    font.letterSpacing: spaceBetweenDownText
                }
            }

            // ── Time  ─────────────────────────────────
            Item {
                implicitWidth: clock_time.implicitWidth
                implicitHeight: clock_time.implicitHeight
                anchors.horizontalCenter: parent.horizontalCenter

                // shadow
                Text {
                    x: 1; y: 1
                    text: clock_time.text
                    font: clock_time.font
                    color: "#550000"
                }
                // Main text
                Text {
                    id: clock_time
                    text: "- " + Qt.formatTime(clock.date, "hh:mm") + " -"
                    font.family: Fonts.activeDownFont
                    font.pixelSize: sizeDown
                    color: textColor
                    font.letterSpacing: spaceBetweenDownText
                }
            }
        }
    }
}
