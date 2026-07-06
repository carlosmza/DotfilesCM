import Quickshell
import QtQuick
import Quickshell.Io
import qs.config.theme
import qs.config.fonts

PanelWindow {
  id: root
  anchors { top: true; right: true }
  implicitWidth: 300; implicitHeight: 300
  color: "transparent"
  focusable: true
	exclusiveZone: -1
	visible: false
  
	property var themes: []
  property real cx: root.implicitWidth / 2 + 50
  property real cy: root.implicitHeight / 2 - 200
	property real orbitX: 110
	property real orbitY: -60
  property int currentIndex: 0

	property real firstAngle: 180
	property real lastAngle: 270
	property real radius: 140
	property bool applying: false

	onVisibleChanged: {
		if (visible) {
			root.applying = false
			if (themes.length === 0) loadThemes()
			mainCircle.forceActiveFocus()
		}
	}

	Component.onCompleted: loadThemes()

	// Generar angulos
	function angleFor(index) {
		if (themes.length < 2) return 90
		return index * (lastAngle - firstAngle) / (themes.length -1) + 90
	}
	// Generar positions
	function orbitPosition (angleDeg, radius) {
		    const a = angleDeg * Math.PI / 180;
		return {
			x: orbitX + mainCircle.width/2 + Math.cos(a) * radius,
			y: orbitY + mainCircle.height/2 + Math.sin(a) * radius
		}
	}

	function loadThemes() {
			procList.command = ["bash", "-c",
			"for f in /home/carlosm/.config/system-themes/themes/*.json; do
					name=$(basename \"$f\" .json);
					[ \"$name\" = \"current\" ] && continue;
					c0=$(jq -r '.palette.base00' \"$f\");
					cD=$(jq -r '.palette.base0D' \"$f\");
					cF=$(jq -r '.palette.base0F' \"$f\");
					echo \"$name|$c0|$cD|$cF\";
			done"]
			procList.running = true
	}

	function parseThemes(output) {
			var lines = output.trim().split("\n")
			var items = []
			for (var i = 0; i < lines.length; i++) {
					var parts = lines[i].trim().split("|")
					if (parts.length >= 4) {
							items.push({
									name: parts[0],
									base00: parts[1],
									base0D: parts[2],
									base0F: parts[3]
							})
					}
			}
			items.sort(function(a, b) { return a.name < b.name ? -1 : 1 })
			themes = items
	}

	Process {
			id: procList
			command: ["bash"]
			stdout: StdioCollector {
					onStreamFinished: {
							root.parseThemes(this.text)
					}
			}
	}

	function applyTheme(name) {
			if (root.applying) return
			root.applying = true
			proc.command = [
					"bash", "-c",
					`/home/carlosm/.config/scripts/themes/apply-theme.sh "${name}" >> /tmp/apply-theme.log 2>&1`
			]
			proc.running = true
	}
// themeLabel("nombre-de-tema", false)   // "Nombre De\nTema"
	function themeLabel(text, reverse) {
    if (!text || text.length === 0)
        return ""

    if (reverse) {
        return text
            .replace(/\n/g, "-")
            .replace(/\s+/g, "-")
            .replace(/-+/g, "-")
            .replace(/^-|-$/g, "")
            .toLowerCase()
    }

    const parts = text.split("-").filter(p => p.length > 0)
    if (parts.length === 0)
        return ""

    const words = parts.map(p => p.charAt(0).toUpperCase() + p.slice(1).toLowerCase())

    if (words.length <= 2)
        return words.join(" ")

    return words.slice(0, 2).join(" ") + "\n" + words.slice(2).join(" ")
	}
	Process {
			id: proc
			command: ["bash"]
			onRunningChanged: {
					if (!running && root.applying) {
							root.applying = false
							root.visible = false
					}
			}
	}
  Rectangle {
    id: mainCircle
		color: themes.length > 0 ? themes[currentIndex].base0F : Colors.palette.base00
		implicitWidth: 140
		implicitHeight: 140
		radius: 100
		focus: true
		Keys.onPressed: (event) => {
			if (event.key === Qt.Key_Escape) {
				root.visible = false
				event.accepted = true
			} else if (event.key === Qt.Key_Left || event.key === Qt.Key_Up) {
				if (themes.length > 0)
					currentIndex = (currentIndex + 1) % themes.length
				event.accepted = true
			} else if (event.key === Qt.Key_Right || event.key === Qt.Key_Down) {
				if (themes.length > 0)
					currentIndex = (currentIndex - 1 + themes.length) % themes.length
				event.accepted = true
			} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
				if (!root.applying && themes.length > 0)
					root.applyTheme(themes[currentIndex].name)
				event.accepted = true
			} else if (event.key === Qt.Key_F5) {
				loadThemes()
				event.accepted = true
			}
		}
		x: root.cx
		y: root.cy
		z: 0

  }
	Repeater {
		id: repeater
		model: themes
		delegate: Rectangle {
			id: themeItem
			width: 150; height: 60; radius: 8
			opacity: root.applying ? 0.4 : 1.0
			color: {
					// if (mouseArea.containsMouse)
					// 		return Colors.palette.base03
					if (index === root.currentIndex)
							return modelData.base00
					return Colors.palette.base02
			}
			border.width: index === root.currentIndex ? 2 : 1

			property var pos: root.orbitPosition(
							root.angleFor(index),
							root.radius
			)
			x: index == root.currentIndex ? pos.x - 20 : pos.x
			y: index == root.currentIndex ? pos.y + 20 : pos.y
			z: index === root.currentIndex ? 2.0 : 1
			rotation: root.angleFor(index)
			scale: index === root.currentIndex ? 1.05 : 1.0

			Text {
				anchors.centerIn: parent
				text: themeLabel(modelData.name, false)
        rotation: 180
				color: {
						if (mouseArea.containsMouse || index === root.currentIndex)
								// return Colors.palette.base00
								return modelData.base0D
						return Colors.palette.base05
				}
				font { pixelSize: 16; bold: true }
				opacity: parent.opacity
			}
			Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
			Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
			Behavior on x { SmoothedAnimation { duration: 300; easing.type: Easing.OutCubic } }
			Behavior on y { SmoothedAnimation { duration: 300; easing.type: Easing.OutCubic } }

			MouseArea {
					id: mouseArea
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					enabled: !root.applying
					onClicked: {
							if (root.applying) return
							root.currentIndex = index; mainCircle.forceActiveFocus()
							root.applyTheme(modelData.name)
					}
			}
		}
	}

	Rectangle {
		anchors.fill: parent
		color: Qt.rgba(0, 0, 0, 0.5)
		radius: 20
		visible: root.applying
		z: 100

		Text {
			anchors.centerIn: parent
			text: "Applying\u2026"
			color: Colors.palette.base05
			font { pixelSize: 16; bold: true }
		}
	}

	Text {
		anchors.centerIn: parent
		text: "No themes found\nPress F5 to reload"
		color: Colors.palette.base03
		horizontalAlignment: Text.AlignHCenter
		visible: themes.length === 0 && !root.applying
		font { pixelSize: 14; bold: true }
	}
}
