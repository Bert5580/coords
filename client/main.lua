-- coords | v2.0.0
-- FX Standalone. Provides /coords to display and copy vector4 player coordinates.
-- Improvements:
--   * No UI on resource start
--   * Proper NUI focus handling + ESC to close
--   * Mouse enabled only when UI is open
--   * Clean state machine, no busy loops
--   * Robust nil/invalid checks; safe string formatting
--   * Prints vector4 to client console and chat when captured
--   * Optional keybind (unbound by default): "coordstoggle"
--   * Defensive cleanup on resource stop
--   * Configurable heading precision and decimals

local RESOURCE_VERSION = '2.0.0'

local isUiOpen = false
local lastVectorStr = nil

local Config = {
    Decimals = 3,         -- decimal places for x,y,z
    HeadingDecimals = 2,  -- decimal places for heading
    PrintOnOpen = true,   -- print coords immediately on open
    ChatOnCopy = true,    -- show chat message when copied
    Command = 'coords'    -- command name
}

--- Utility: Safe number formatter
local function round(num, decimalPlaces)
    if type(num) ~= 'number' then return 0.0 end
    local mult = 10 ^ (decimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--- Utility: Builds a vector4 string
local function buildVector4String(ped)
    if not ped or not DoesEntityExist(ped) then
        return nil, 'Ped does not exist'
    end
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped) or 0.0

    local x = round(coords.x, Config.Decimals)
    local y = round(coords.y, Config.Decimals)
    local z = round(coords.z, Config.Decimals)
    local h = round(heading, Config.HeadingDecimals)

    return string.format('vector4(%.3f, %.3f, %.3f, %.2f)', x, y, z, h), nil
end

--- Internal: Sends UI payload
local function nuiSend(type_, payload)
    SendNUIMessage({
        type = type_,
        payload = payload or {}
    })
end

--- Opens the UI and focuses it
local function openUi()
    if isUiOpen then return end
    isUiOpen = true
    SetNuiFocus(true, true)  -- focus + mouse
    nuiSend('open', { version = RESOURCE_VERSION })

    local ped = PlayerPedId()
    local vec, err = buildVector4String(ped)
    if vec then
        lastVectorStr = vec
        nuiSend('coords', { text = vec })
        if Config.PrintOnOpen then
            print(('[coords] %s'):format(vec))
            TriggerEvent('chat:addMessage', { args = { '^2coords^7', vec } })
        end
    else
        nuiSend('error', { text = err or 'Unknown error' })
    end
end

--- Closes the UI and releases focus
local function closeUi()
    if not isUiOpen then return end
    isUiOpen = false
    nuiSend('close', {})
    SetNuiFocus(false, false)
end

--- Command: /coords
RegisterCommand(Config.Command, function(_src, _args)
    if isUiOpen then
        closeUi()
    else
        openUi()
    end
end, false)

--- Key mapping (unbound by default). Players can bind like:
---   /bind keyboard F10 coordstoggle
RegisterKeyMapping('coordstoggle', 'Toggle coords UI', 'keyboard', 'NONE')
RegisterCommand('coordstoggle', function()
    if isUiOpen then closeUi() else openUi() end
end, false)

--- NUI callback: close (ESC or Cancel)
RegisterNUICallback('close', function(_, cb)
    closeUi()
    if cb then cb({ ok = true }) end
end)

--- NUI callback: copy (Copy button)
RegisterNUICallback('copy', function(_, cb)
    local ped = PlayerPedId()
    local vec, err = buildVector4String(ped)
    if vec then
        lastVectorStr = vec
        nuiSend('coords', { text = vec, copied = true })
        if Config.ChatOnCopy then
            TriggerEvent('chat:addMessage', { args = { '^2coords^7', ('Copied: %s'):format(vec) } })
        end
        print(('[coords] Copied: %s'):format(vec))
        if cb then cb({ ok = true, text = vec }) end
    else
        nuiSend('error', { text = err or 'Unknown error' })
        if cb then cb({ ok = false, error = err }) end
    end
end)

--- Defensive cleanup
AddEventHandler('onResourceStop', function(resName)
    if resName ~= GetCurrentResourceName() then return end
    if isUiOpen then
        SetNuiFocus(false, false)
        nuiSend('close', {})
    end
end)
