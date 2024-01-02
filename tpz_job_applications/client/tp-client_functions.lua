
--[[-------------------------------------------------------
 Prompts
]]---------------------------------------------------------

Prompts       = GetRandomIntInRange(0, 0xffffff)
PromptsList   = {}

RegisterActionPrompt = function()

    local str      = Locales['PROMPT_FOOTER_DESCRIPTION']
    local keyPress = Config.PromptKey.key

    local dPrompt = PromptRegisterBegin()
    PromptSetControlAction(dPrompt, keyPress)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(dPrompt, str)
    PromptSetEnabled(dPrompt, 1)
    PromptSetVisible(dPrompt, 1)
    PromptSetStandardMode(dPrompt, 1)
    PromptSetHoldMode(dPrompt, 1000)
    PromptSetGroup(dPrompt, Prompts)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, dPrompt, true)
    PromptRegisterEnd(dPrompt)

    PromptsList = dPrompt
end

--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for i, v in pairs(Config.Locations) do
        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end
    end

end)

Citizen.CreateThread(function ()
    for index, blip in pairs (Config.Locations) do

        if blip.BlipData and blip.BlipData.Allowed then

            local blipHandle = N_0x554d9d53f696d002(1664425300, blip.Coords.x, blip.Coords.y, blip.Coords.z)
    
            SetBlipSprite(blipHandle, blip.BlipData.Sprite, 1)
            SetBlipScale(blipHandle, 0.1)
            Citizen.InvokeNative(0x9CB1A1623062F402, blipHandle, blip.BlipData.Title)
    
                    
            Config.Locations[index].BlipHandle = blipHandle

        end

    end
end)


--[[-------------------------------------------------------
 General Functions
]]---------------------------------------------------------

-- @GetTableLength returns the length of a table.
function GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function GetNearestPlayers(distance)
	local closestDistance = distance
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed, true, true)
	local closestPlayers = {}

	for _, player in pairs(GetActivePlayers()) do
		local target = GetPlayerPed(player)

		if target ~= playerPed then
			local targetCoords = GetEntityCoords(target, true, true)
			local distance = #(targetCoords - coords)

			if distance < closestDistance then
				table.insert(closestPlayers, player)
			end
		end
	end
	return closestPlayers
end