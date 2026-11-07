.pragma library

var mexicoCityOffsetMinutes = -360

function mexicoCityDate(now) {
    return new Date(now.getTime() + (now.getTimezoneOffset() + mexicoCityOffsetMinutes) * 60000)
}
