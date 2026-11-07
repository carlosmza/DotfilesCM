import QtQuick

// Shared animation presets. Use, for example:
// AnimateReveal { preset: AnimateReveal.SlideUp; open: panelVisible }
Item {
    id: root

    enum Preset {
        SlideLeft,
        ScaleCenter,
        SlideUp,
        SlideDown,
        SpringPop,
        SlideRight,
        FadeOnly,
        BounceUp,
        ZoomOut,
        FlipY
    }

    property bool open: false
    property int preset: AnimateReveal.SlideLeft
    signal hidden()
    default property alias contentData: contentArea.data

    readonly property real closedX: root.preset === AnimateReveal.SlideLeft ? -48
        : (root.preset === AnimateReveal.SlideRight ? 48 : 0)
    readonly property real closedY: root.preset === AnimateReveal.SlideUp
        || root.preset === AnimateReveal.BounceUp ? 32
        : (root.preset === AnimateReveal.SlideDown ? -32
        : (root.preset === AnimateReveal.SpringPop ? 10 : 0))
    readonly property real closedScale: root.preset === AnimateReveal.ScaleCenter ? 0.95
        : (root.preset === AnimateReveal.SpringPop ? 0.88
        : (root.preset === AnimateReveal.ZoomOut ? 1.08
        : (root.preset === AnimateReveal.FlipY ? 0.96 : 1)))
    readonly property real closedRotation: root.preset === AnimateReveal.FlipY ? 8 : 0
    readonly property int enterDuration: {
        switch (root.preset) {
        case AnimateReveal.SlideLeft: return 280
        case AnimateReveal.ScaleCenter: return 220
        case AnimateReveal.SlideUp: return 300
        case AnimateReveal.SlideDown: return 260
        case AnimateReveal.SpringPop: return 340
        case AnimateReveal.SlideRight: return 280
        case AnimateReveal.FadeOnly: return 180
        case AnimateReveal.BounceUp: return 360
        case AnimateReveal.ZoomOut: return 220
        case AnimateReveal.FlipY: return 260
        default: return 220
        }
    }
    readonly property int exitDuration: {
        switch (root.preset) {
        case AnimateReveal.SlideLeft:
        case AnimateReveal.SlideRight: return 180
        case AnimateReveal.ScaleCenter:
        case AnimateReveal.ZoomOut:
        case AnimateReveal.FlipY: return 160
        case AnimateReveal.SlideUp:
        case AnimateReveal.SlideDown: return 200
        case AnimateReveal.SpringPop:
        case AnimateReveal.BounceUp: return 180
        case AnimateReveal.FadeOnly: return 130
        default: return 160
        }
    }

    Item {
        id: container
        anchors.fill: parent
        x: root.closedX
        y: root.closedY
        scale: root.closedScale
        rotation: root.closedRotation
        opacity: 0

        Item {
            id: contentArea
            anchors.fill: parent
        }
    }

    states: State {
        name: "visible"
        when: root.open
        PropertyChanges {
            container.x: 0
            container.y: 0
            container.scale: 1
            container.rotation: 0
            container.opacity: 1
        }
    }

    transitions: [
        Transition {
            id: enterTransition
            from: ""
            to: "visible"
            ParallelAnimation {
                PropertyAnimation {
                    target: container
                    property: "x"
                    from: root.closedX
                    to: 0
                    duration: root.enterDuration
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    target: container
                    property: "y"
                    from: root.closedY
                    to: 0
                    duration: root.enterDuration
                    easing.type: root.preset === AnimateReveal.BounceUp
                        ? Easing.OutBounce
                        : (root.preset === AnimateReveal.SpringPop
                        ? Easing.OutBack : Easing.OutCubic)
                }
                PropertyAnimation {
                    target: container
                    property: "scale"
                    from: root.closedScale
                    to: 1
                    duration: root.enterDuration
                    easing.type: root.preset === AnimateReveal.SpringPop
                        || root.preset === AnimateReveal.FlipY
                        ? Easing.OutBack : Easing.OutCubic
                }
                PropertyAnimation {
                    target: container
                    property: "rotation"
                    from: root.closedRotation
                    to: 0
                    duration: root.enterDuration
                    easing.type: Easing.OutCubic
                }
                PropertyAnimation {
                    target: container
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: root.preset === AnimateReveal.FadeOnly ? 180 : 200
                    easing.type: Easing.OutQuad
                }
            }
        },
        Transition {
            id: exitTransition
            from: "visible"
            to: ""
            onRunningChanged: {
                if (!running && !root.open)
                    root.hidden()
            }
            ParallelAnimation {
                PropertyAnimation {
                    target: container
                    property: "x"
                    from: 0
                    to: root.closedX
                    duration: root.exitDuration
                    easing.type: Easing.InCubic
                }
                PropertyAnimation {
                    target: container
                    property: "y"
                    from: 0
                    to: root.closedY
                    duration: root.exitDuration
                    easing.type: root.preset === AnimateReveal.BounceUp
                        ? Easing.InBounce : Easing.InCubic
                }
                PropertyAnimation {
                    target: container
                    property: "scale"
                    from: 1
                    to: root.closedScale
                    duration: root.exitDuration
                    easing.type: Easing.InCubic
                }
                PropertyAnimation {
                    target: container
                    property: "rotation"
                    from: 0
                    to: root.closedRotation
                    duration: root.exitDuration
                    easing.type: Easing.InCubic
                }
                PropertyAnimation {
                    target: container
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: root.preset === AnimateReveal.FadeOnly ? 130 : 140
                    easing.type: Easing.InQuad
                }
            }
        }
    ]
}
