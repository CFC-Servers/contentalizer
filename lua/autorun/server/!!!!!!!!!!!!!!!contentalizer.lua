if game.SinglePlayer() then return end

resource.AddFile = function( fileName )
    if not fileName then return end
    print( "[Contentalizer] resource.AddFile called for " .. fileName )
    print( debug.traceback("",3) )
end
resource.AddSingleFile = function( fileName )
    if not fileName then return end
    print( "[Contentalizer] resource.AddSingleFile called for " .. fileName or "nil" )
    print( debug.traceback("",3) )
end

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

local function hasMap( title )
    local files = file.Find( "maps/*", title )
    if files and next( files ) then
        return true
    end
    return false
end

local function findContent( path, addonName )
    local files, folders = file.Find( path .. "*", addonName )
    if files then
        for _, foundFile in ipairs( files ) do
            local extension = string.GetExtensionFromFilename( foundFile )
            if extension and exts[extension] then return true end
        end
    end

    if folders then
        for _, folder in ipairs( folders ) do
            if path .. folder ~= "lua" and findContent( path .. folder .. "/", addonName ) then
                return true
            end
        end
    end
    return false
end

print( "[Contentalizer] Checking for content in addons..." )
for _, addon in ipairs( engine.GetAddons() ) do
    if addon.wsid and addon.mounted and not hasMap( addon.title ) then
        local found = findContent( "", addon.title )
        if found then
            local title = string.Replace( addon.title, "\n", " " )
            local wsid = tostring( addon.wsid )
            resource.AddWorkshop( wsid )
            print( "[Contentalizer] Added " .. title .. " - " .. wsid )
        end
    end
end
print( "[Contentalizer] Done!" )
