if CLIENT then return end -- This file is in shared because shared autorun scripts run before server/client.
if game.SinglePlayer() then return end

resource.AddFile = function( fileName )
    if not fileName then return end
    print( "[Contentalizer] resource.AddFile called for " .. fileName )
    print( debug.traceback( "", 3 ) )
end
resource.AddSingleFile = function( fileName )
    if not fileName then return end
    print( "[Contentalizer] resource.AddSingleFile called for " .. fileName or "nil" )
    print( debug.traceback( "", 3 ) )
end

resource.AddedWorkshop = resource.AddedWorkshop or {}
resource_AddWorkshop = resource_AddWorkshop or resource.AddWorkshop
function resource.AddWorkshop( wsid )
    resource_AddWorkshop( wsid )

    resource.AddedWorkshop[wsid] = true
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

concommand.Add( "workshopdl_size", function( ply )
    if IsValid( ply ) then return end

    local function niceSize( byteSize )
        local negative = byteSize < 0
        if negative then
            byteSize = -byteSize
        end

        local kb = byteSize / 1024
        if kb < 1024 then
            return ( negative and "-" or "" ) .. math.Round( kb ) .. " KB"
        elseif kb < 1024 * 1024 then
            return ( negative and "-" or "" ) .. math.Round( kb / 1024 ) .. " MB"
        elseif kb < 1024 * 1024 * 1024 then
            return ( negative and "-" or "" ) .. math.Round( kb / ( 1024 * 1024 ), 2 ) .. " GB"
        end

        return byteSize .. " bytes"
    end

    local addonCount = table.Count( resource.AddedWorkshop )
    local doneCount = 0

    local addonInfo = {}
    for id in pairs( resource.AddedWorkshop ) do
        if not tonumber( id ) then
            addonCount = addonCount - 1
            continue
        end

        steamworks.FileInfo( id, function( info )
            addonInfo[id] = info
            doneCount = doneCount + 1
            if addonCount == doneCount then
                local addons = {}
                local addonSize = 0

                for _, mapInfo in pairs( addonInfo ) do
                    if mapInfo and mapInfo.size > 0 then
                        table.insert( addons, mapInfo )
                        addonSize = addonSize + ( mapInfo.size or 0 )
                    end
                end

                table.sort( addons, function( a, b )
                    return ( a.size or 0 ) > ( b.size or 0 )
                end )

                print( "Addons:" )
                for _, addonInfo2 in ipairs( addons ) do
                    print( addonInfo2.id .. " " .. addonInfo2.title .. " (" .. niceSize( addonInfo2.size ) .. ")" )
                end

                print( "\nTotal Addons: " .. addonCount .. " (" .. niceSize( addonSize ) .. ")" )
                print( "Average Addon Size: " .. niceSize( addonSize / addonCount ) )
            end
        end )
    end
end )
