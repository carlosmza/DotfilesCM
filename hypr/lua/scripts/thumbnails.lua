-- Configuración de rutas
local WALLPAPERS_DIR = "/home/carlosm/Pictures/Wallpapers"
local THUMBS_DIR     = "/home/carlosm/Pictures/wallpaper_thumbs"  -- cambia esto
local THUMB_SIZE     = 300  -- ancho de thumbnail
-- local CONVERT_CMD    = "magick convert -thumbnail %d '%s' '%s'"
local THUMB_CMD = "magick -thumbnail %dx%d '%s' '%s'"


-- Listar archivos de un directorio (solo nombres) usando io.popen(ls)
local function list_files(dir)
    local files = {}
    local ls_cmd = string.format("ls -A -- '%s'", dir)
    for line in io.popen(ls_cmd):lines() do
        table.insert(files, line)
    end
    return files
end

-- Quitar extensión de nombre de archivo
local function remove_ext(fname)
    return (fname:gsub("%.[^%.]*$", ""))
end

-- Obtener el nombre base sin extensión
local function basename_with_ext(fname)
    return fname:match("([^/\\]+)$")
end


-- 1) Leer wallpapers y thumbnails
print("Scanning wallpapers and thumbnails...")

local wallpapers = list_files(WALLPAPERS_DIR)
local thumbs     = list_files(THUMBS_DIR)

-- 2) Crear conjuntos de nombres base (sin extensión)
local thumbs_base = {}
for _, t in ipairs(thumbs) do
    local base = remove_ext(t)
    base = base:gsub("^thumb%-", "")
    thumbs_base[base] = true
end
-- 3) Crear thumbnails faltantes
for _, w in ipairs(wallpapers) do
    local w_path = WALLPAPERS_DIR .. "/" .. w
    local w_base = remove_ext(w)
    local t_path = THUMBS_DIR .. "/thumb-" .. w
		local THUMB_WIDTH  = 300
		local THUMB_HEIGHT = 200

		local CONVERT_CMD =
				"/usr/bin/magick '%s' " ..
				"-thumbnail '%dx%d^' " ..
				"-gravity center " ..
				"-extent %dx%d " ..
				"'%s'"
    if not thumbs_base[w_base] then
        print("Generating thumbnail for: " .. w_path)
        -- local cmd = string.format(THUMB_CMD, w_path, THUMB_SIZE, THUMB_SIZE, w_path, t_path)
				local cmd = string.format(
					CONVERT_CMD,
					w_path,
					THUMB_WIDTH,
					THUMB_HEIGHT,
					THUMB_WIDTH,
					THUMB_HEIGHT,
					t_path
			)
				-- print(cmd)
        local rc = os.execute(cmd)
				if not rc then
						print("Error generating thumbnail for: " .. w_path)
				end
				    if rc ~= 0 then
				        print("Error generating thumbnail for: " .. w_path)
				    end
    end
end

print("Thumbnail generation complete.")
