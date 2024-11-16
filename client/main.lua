ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local blips = {}

RegisterCommand('addblip', function(source, args)
    TriggerServerEvent("tg_blipmaker:checkcreationperms", args)
end, false)

RegisterNetEvent('tg_blipmaker:createblip')
AddEventHandler('tg_blipmaker:createblip', function(args)
    if #args < 4 then
        tg_shownotification(_('args_missing'))
        return
    end

    local bliptype = tonumber(args[1])
    local blipname = table.concat(args, " ", 2, #args - 2)
    local blipscale = tonumber(args[#args - 1])
    local blipcolor = tonumber(args[#args])

    if blipscale % 1 == 0 then
        blipscale = blipscale + 0.0
    end

    if bliptype < 0 or bliptype > 883 or blipscale < 0.5 or blipscale > 10 or blipcolor < 0 or blipcolor > 85 then
        tg_shownotification(_('invalid_parameter'))
        return
    end

    local playercoords = GetEntityCoords(PlayerPedId())
    local blipData = {coords = playercoords, type = bliptype, text = blipname, scale = blipscale, color = blipcolor, handle = nil}

    TriggerServerEvent('tg_blipmaker:addblip', blipData)
    tg_shownotification(_('new_successfull'))
end)

RegisterCommand('removeblip', function()
    TriggerServerEvent("tg_blipmaker:checkdeletionperms")
end, false)

RegisterNetEvent('tg_blipmaker:deleteblip')
AddEventHandler('tg_blipmaker:deleteblip', function()
    if #blips == 0 then
        tg_shownotification(_('no_blips_to_remove'))
        return
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local closestIndex, closestDistance = nil, 50.0

    for i, blipData in ipairs(blips) do
        local dist = #(playerCoords - blipData.coords)
        if dist < closestDistance then
            closestDistance, closestIndex = dist, i
        end
    end

    if closestIndex then
        local blipHandle = blips[closestIndex].handle
        TriggerServerEvent('tg_blipmaker:removeblip', closestIndex, blipHandle)
        tg_shownotification(_('blip_removed'))
    else
        tg_shownotification(_('rem_no_blip_nearby'))
    end
end)

RegisterNetEvent('tg_blipmaker:syncblips')
AddEventHandler('tg_blipmaker:syncblips', function(serverBlips)
    for _, blip in pairs(blips) do
        if blip.handle then
            RemoveBlip(blip.handle)
        end
    end

    blips = serverBlips

    for _, blipData in pairs(blips) do
        local newblip = AddBlipForCoord(blipData.coords.x, blipData.coords.y, blipData.coords.z)
        SetBlipSprite(newblip, blipData.type)
        SetBlipScale(newblip, blipData.scale)
        SetBlipColour(newblip, blipData.color)
        SetBlipDisplay(newblip, 4)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.text)
        EndTextCommandSetBlipName(newblip)
        blipData.handle = newblip
    end
end)

RegisterNetEvent('tg_blipmaker:killblip')
AddEventHandler('tg_blipmaker:killblip', function(blipHandle)
    if blipHandle then
        RemoveBlip(blipHandle)
    end
end)

RegisterNetEvent('tg_blipmaker:notify')
AddEventHandler('tg_blipmaker:notify', function(message)
    tg_shownotification(message)
end)

function tg_shownotification(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostMessagetext("CHAR_DEFAULT", "CHAR_DEFAULT", false, 0, "TG Blipmaker Script", "")
end

TriggerEvent('chat:addSuggestion', '/addblip', _('chat_add'), {
    { name=_('chat_add_type_title'), help=_('chat_add_type_help') },
    { name=_('chat_add_name_title'), help=_('chat_add_name_help') },
    { name=_('chat_add_scale_title'), help=_('chat_add_scale_help') },
    { name=_('chat_add_color_title'), help=_('chat_add_color_help') }
})

TriggerEvent('chat:addSuggestion', '/removeblip', _('chat_rem_blip'), {})

if Config.Debug then
    TriggerEvent('chat:addSuggestion', '/debugblips', _('chat_debug_blip'), {})
end