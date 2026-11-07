.pragma library

var queryCommand = ["bash", "-c", "nmcli -t -f ACTIVE,SSID,SIGNAL dev wifi | grep '^yes' || true"]

var icons = ["󰤭", "󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]

function parse(text) {
    var out = (text || "").trim()
    if (out === "")
        return { connected: false, ssid: "", strength: 0 }

    var parts = out.split(":")
    if (parts.length >= 3 && (parts[0] === "yes" || parts[0] === "*"))
        return { connected: true, ssid: parts[1] || "", strength: parseInt(parts[2]) || 0 }

    return { connected: false, ssid: "", strength: 0 }
}

function iconFor(connected, strength) {
    if (!connected)
        return icons[0]

    var p = Math.max(0, Math.min(100, parseInt(strength)))
    if (p <= 10)
        return icons[1]
    if (p <= 30)
        return icons[2]
    if (p <= 60)
        return icons[3]
    if (p <= 85)
        return icons[4]
    return icons[5]
}
