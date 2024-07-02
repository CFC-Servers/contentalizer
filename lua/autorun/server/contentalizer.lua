-- By Billy
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2716242595
-- https://github.com/WilliamVenner/contentalizer

if CLIENT or not game.IsDedicated() then return end -- Just in case people subscribe to it (which they will)

local exts = {
    vtf = true,
    vmt = true,
    mp3 = true,
    ogg = true,
    wav = true,
    mdl = true,
    phy = true,
    jpg = true,
    jpeg = true,
    png = true,
    properties = true,
}
local function findContent(path, dir)
    local f, d = file.Find(path .. "*", dir)
    if istable(f) then
        for _, f in ipairs(f) do
            local extension = string.GetExtensionFromFilename(f)
            if extension and exts[extension] then
                return true
            end
        end
    end

    if istable(d) then
        for _, d in ipairs(d) do
            if path .. d ~= "lua" and findContent(path .. d .. "/", dir) then
                return true
            end
        end
    end
    return false
end

print("[Contentalizer] Checking for content in addons...")
for _, addon in SortedPairsByMemberValue(engine.GetAddons(), "title") do
    if addon.wsid and addon.mounted then
        local found = findContent("", addon.title)
        if found then
            local title = string.Replace(addon.title, "\n", " ")
            local wsid = tostring(addon.wsid)
            print("[Contentalizer] Adding " .. title .. " - " .. wsid)
            resource.AddWorkshop(wsid)
        end
    end
end
print("[Contentalizer] Done!")
