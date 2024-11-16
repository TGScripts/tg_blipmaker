ESX = nil

ESX = exports["es_extended"]:getSharedObject()

local blips = {}

RegisterNetEvent('tg_blipmaker:addblip')
AddEventHandler('tg_blipmaker:addblip', function(blipData)
    table.insert(blips, blipData)
    TriggerClientEvent('tg_blipmaker:syncblips', -1, blips)
end)

RegisterNetEvent('tg_blipmaker:removeblip')
AddEventHandler('tg_blipmaker:removeblip', function(index)
    if blips[index] then
        TriggerClientEvent('tg_blipmaker:killblip', -1, blips[index].handle)
        table.remove(blips, index)
        TriggerClientEvent('tg_blipmaker:syncblips', -1, blips)
    end
end)

AddEventHandler('playerJoining', function(playerId)
    TriggerClientEvent('tg_blipmaker:syncblips', playerId, blips)
end)

RegisterNetEvent("tg_blipmaker:checkcreationperms")
AddEventHandler("tg_blipmaker:checkcreationperms", function(blipData)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and isPlayerAuthorized(xPlayer) then
        TriggerClientEvent("tg_blipmaker:createblip", source, blipData)
    else
        TriggerClientEvent("tg_blipmaker:notify", source, _('not_authorized'))
        print("Player ID: "..source.." is not authorized to create a blip.")
    end
end)

RegisterNetEvent("tg_blipmaker:checkdeletionperms")
AddEventHandler("tg_blipmaker:checkdeletionperms", function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer and isPlayerAuthorized(xPlayer) then
        TriggerClientEvent("tg_blipmaker:deleteblip", source)
    else
        TriggerClientEvent("tg_blipmaker:notify", source, _('not_authorized'))
        print("Player ID: "..source.." is not authorized to delete a blip.")
    end
end)

function isPlayerAuthorized(xPlayer)
    local playerGroup = xPlayer.getGroup()
    for _, AllowedGroup in ipairs(Config.AllowedGroups) do
        if playerGroup == AllowedGroup then
            return true
        end
    end
    return false
end

if Config.Debug then
    RegisterCommand('debugblips', function()
        print(_('debug_message'))
        for i, blipData in ipairs(blips) do
            print(i, blipData.text, "~s~" .. json.encode(blipData.coords))
        end
    end, false)
end