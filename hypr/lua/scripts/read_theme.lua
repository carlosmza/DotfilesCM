#!/usr/bin/env lua
local cjson = require("cjson")

local HOME = os.getenv("HOME")
local THEME_JSON = HOME .. "/.config/system-themes/themes/current.json"

local file, err = io.open(THEME_JSON, "r")
if not file then
    error("No se pudo abrir el archivo: " .. err)
end

local content = file:read("*a")
file:close()

local data = cjson.decode(content)

local handle = io.popen("readlink -f " .. THEME_JSON .. " 2>/dev/null || echo " .. THEME_JSON)
local resolved = handle:read("*l")
handle:close()

local slug = resolved:match("/([^/]+)%.json$") or "unknown"

local palette = {}
for k, v in pairs(data.palette) do
    palette[k] = v:gsub("^#", "")
end

local theme = {
    name = data.name,
    slug = slug,
    variant = data.variant,
    palette = palette,
}

if select("#", ...) == 0 then
    print("Tema cargado: " .. theme.name .. " (" .. theme.variant .. ")")
end

return theme
