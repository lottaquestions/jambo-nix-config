-- from https://gist.github.com/sans-serif/be3ef716d0c6a16d16bf
-- heavily simplified to just return one random wallpaper

local path_landscape = os.getenv("HOME") .. "/.wallpaper/"
local path_portrait = os.getenv("HOME") .. "/.wallpaper-portrait/"
local num_files = 0
math.randomseed(os.time())
-- To guarantee unique random numbers on every platform, pop a few
for i = 1, 10 do
    math.random()
end

-- LUA implementation of PHP scan dir
-- Returns all files (except . and ..) in "directory"
local function scandir(directory)
    num_files, t, popen = 0, {}, io.popen
    for filename in popen('ls -a "' .. directory .. '"'):lines() do
        -- If case to disregard "." and ".."
        if (not (filename == "." or filename == "..")) then
            num_files = num_files + 1
            t[num_files] = filename
        end
    end
    return t
end

function get_random_wallpaper(screen)
    local is_landscape = screen.geometry.width > screen.geometry.height
    local path = is_landscape and path_landscape or path_portrait
    local wallpapers = scandir(path)
    if num_files == 0 then
        return nil
    else
        return path .. wallpapers[math.random(1, num_files)]
    end
end

return get_random_wallpaper

-- }}}
