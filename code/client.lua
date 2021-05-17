
Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118, ["Enter"] = 191
}

local Stones = 0
local StoneLists = {}
local IsPickingUp, IsProcessing, IsOpenMenu = false, false, false

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	Citizen.Wait(5000)
end)

function GenerateCoords(Zone) 
	while true do
		Citizen.Wait(1)

		local CoordX, CoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-10, 10)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-10, 10)

		CoordX = Zone.x + modX
		CoordY = Zone.y + modY

		local coordZ = GetCoordZ(CoordX, CoordY)
		local coord = vector3(CoordX, CoordY, coordZ)

		if ValidateObjectCoord(coord) then
			return coord
		end
	end
end

function GenerateCrabCoords()
	while true do
		Citizen.Wait(1)

		local crabCoordX, crabCoordY

		math.randomseed(GetGameTimer())
		local modX = math.random(-10, 10)

		Citizen.Wait(100)

		math.randomseed(GetGameTimer())
		local modY = math.random(-10, 10)

		crabCoordX = Config.Zone.Pos.x + modX
		crabCoordY = Config.Zone.Pos.y + modY

		local coordZ = GetCoordZ(crabCoordX, crabCoordY)
		local coord = vector3(crabCoordX, crabCoordY, coordZ)

		if ValidateObjectCoord(coord) then
			return coord
		end
	end
end

function GetCoordZ(x, y)
	local groundCheckHeights = { -27.77, 30.0, 40.0, 41.0, 42.0, 43.0, 44.0, 45.0, 46.0, 47.0, 48.0, 49.0, 50.0 }

	for i, height in ipairs(Config.GetCoordZ) do
		local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

		if foundGround then
			return z
		end
	end

	return 43.0
end

function ValidateObjectCoord(plantCoord)
	if Stones > 0 then
		local validate = true

		for k, v in pairs(StoneLists) do
			if GetDistanceBetweenCoords(plantCoord, GetEntityCoords(v), true) < 5 then
				validate = false
			end
		end

		if GetDistanceBetweenCoords(plantCoord, Config.Zone.Pos.x, Config.Zone.Pos.y, Config.Zone.Pos.z, false) > 50 then
			validate = false
		end

		return validate
	else
		return true
	end
end

function SpawnObjects()
	while Stones < 25 do
		Citizen.Wait(0)
		local CrabCoords = GenerateCrabCoords()

		local ListStone = {
			{ Name = Config.object },
			{ Name = Config.object }
		}

		local random_stone = math.random(#ListStone)

		ESX.Game.SpawnLocalObject(ListStone[random_stone].Name, CrabCoords, function(object)
			PlaceObjectOnGroundProperly(object)
			FreezeEntityPosition(object, true)

			table.insert(StoneLists, object)
			Stones = Stones + 1
		end)
	end
end

-- Spawn Object
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local PlayerCoords = GetEntityCoords(PlayerPedId())

		if GetDistanceBetweenCoords(PlayerCoords, Config.Zone.Pos.x, Config.Zone.Pos.y, Config.Zone.Pos.z, true) < 50 then
			SpawnObjects()
			Citizen.Wait(500)
		else
			Citizen.Wait(500)
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()

	local Config1 = Config.Zone
	local blip1 = AddBlipForCoord(Config1.Pos.x, Config1.Pos.y, Config1.Pos.z)

	SetBlipSprite (blip1, Config1.Blips.Id)
	SetBlipDisplay(blip1, 4)
	SetBlipScale  (blip1, Config1.Blips.Size)
	SetBlipColour (blip1, Config1.Blips.Color)
	SetBlipAsShortRange(blip1, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(Config1.Blips.Text)
	EndTextCommandSetBlipName(blip1)

end)

RegisterNetEvent('renzer_treasure:pickaxe')
AddEventHandler('renzer_treasure:pickaxe', function ()
    TriggerEvent('esx_inventoryhud:closeHud')
			if not pickcaxe then
			
			pickcaxe = true
			local ped = GetPlayerPed(-1)
			local position = GetEntityCoords(GetPlayerPed(PlayerId()), false)
			local object = GetClosestObjectOfType(position.x, position.y, position.z, 15.0, GetHashKey(Config.prop), false, false, false)
			if object ~= 0 then
				DeleteObject(object)
			end

			local x,y,z = table.unpack(GetEntityCoords(ped))
			local drillProp = GetHashKey('hei_prop_heist_drill')
			local boneIndex = GetPedBoneIndex(ped, 28422)
			RequestModel(drillProp)
				while not HasModelLoaded(drillProp) do
					Citizen.Wait(100)
				end
				attachedDrill = CreateObject(drillProp, 1.0, 1.0, 1.0, 1, 1, 0)
				AttachEntityToEntity(attachedDrill, ped, boneIndex, 0.0, 0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
				
				SetEntityAsMissionEntity(attachedDrill, true, true)
			
			
			else
			local ped = GetPlayerPed(-1)
			local position = GetEntityCoords(GetPlayerPed(PlayerId()), false)
			local object = GetClosestObjectOfType(position.x, position.y, position.z, 15.0, GetHashKey(Config.prop), false, false, false)
			if object ~= 0 then
				DeleteObject(object)
			end

			local x,y,z = table.unpack(GetEntityCoords(ped))
			local prop = CreateObject(GetHashKey(Config.prop), x, y, z + 0.2, true, true, true)
			local boneIndex = GetPedBoneIndex(ped, 57005)
			AttachEntityToEntity(prop, ped, boneIndex, 0.16, 0.00, 0.00, 600.0, 20.00, 140.0, true, true, false, true, 1, true)
			
			
			ClearPedTasks(ped)
			pickcaxe = false
			DetachEntity(prop, ped, boneIndex, 0.16, 0.00, 0.00, 600.0, 20.00, 140.0, true, true, false, true, 1, true)
			DeleteObject(prop)
			end

end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		local nearbyObject, nearbyID
		local x = math.random(1,Config.deleteobject)
		local ped = GetPlayerPed(-1)
		for i=1, #StoneLists, 1 do
			if GetDistanceBetweenCoords(coords, GetEntityCoords(StoneLists[i]), false) < 1.2 then
				nearbyObject, nearbyID = StoneLists[i], i
			end
		end
		if nearbyObject and IsPedOnFoot(playerPed) then
			if pickcaxe then 
				DrawTxtmaxez(0.960, 0.600, 1.0,1.0,0.55,"~y~กด E เพื่อเจาะ", 255,255,255,255)
				if IsControlJustReleased(0, Keys['E']) then
					local animDict = "anim@heists@fleeca_bank@drilling"
					local animLib = "drill_straight_idle"
					RequestAnimDict(animDict)
					while not HasAnimDictLoaded(animDict) do
						Citizen.Wait(50)
					end
					TaskPlayAnim(ped,animDict,animLib,1.0, -1.0, -1, 2, 0, 0, 0, 0)
					RequestAmbientAudioBank("DLC_HEIST_FLEECA_SOUNDSET", 0)
					RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL", 0)
					RequestAmbientAudioBank("DLC_MPHEIST\\HEIST_FLEECA_DRILL_2", 0)
					drillSound = GetSoundId()
					PlaySoundFromEntity(drillSound, "Drill", attachedDrill, "DLC_HEIST_FLEECA_SOUNDSET", 1, 0)
					local particleDictionary = "scr_fbi5a"
					local particleName = "scr_bio_grille_cutting"
	
					RequestNamedPtfxAsset(particleDictionary)
					while not HasNamedPtfxAssetLoaded(particleDictionary) do
					  Citizen.Wait(0)
					end
	
					SetPtfxAssetNextCall(particleDictionary)
					effect = StartParticleFxLoopedOnEntity(particleName, attachedDrill, 0.0, -0.6, 0.0, 0.0, 0.0, 0.0, 2.0, 0, 0, 0)
					ShakeGameplayCam("ROAD_VIBRATION_SHAKE", 1.0)
					FreezeEntityPosition(playerPed, true)
					TriggerEvent("mythic_progbar:client:progress", {
						name = "unique_action_name",
						duration = Config.timedoing,
						label = "กำลังเจาะ",
						useWhileDead = false,
						canCancel = false,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						}
				    },   
				  	function(status)
					   if not status then
						   -- Do Something If Event Wasn't Cancelled
					  end
					end)
					Citizen.Wait(Config.timedoing)
					StopSound(drillSound)
    				FreezeEntityPosition(ped, false)
    				StopParticleFxLooped(effect, 0)
    				StopGameplayCamShaking(true)
					TriggerServerEvent('renzer_treasure:pickedUp')
					ClearPedTasks(playerPed)
						if x == 1 then
							ESX.Game.DeleteObject(nearbyObject)
							table.remove(StoneLists, nearbyID)
							Stones = Stones - 1
						end
						FreezeEntityPosition(playerPed, false)
					ClearPedTasks(playerPed)
				end
			else
				DrawTxtmaxez(0.960, 0.600, 1.0,1.0,0.55,"~r~⚠️ คุณต้องถือ ~w~สว่าน ~r~ก่อน ⚠️", 255,255,255,255)
			end
		end
	end
end)


function anim()
	RequestAnimDict(animDict)
				while not HasAnimDictLoaded(animDict) do
					Citizen.Wait(50)
				end
	TaskPlayAnim(ped,"anim@heists@fleeca_bank@drilling","drill_straight_idle",1.0, -1.0, -1, 2, 0, 0, 0, 0)
end




RegisterFontFile('font4thai')
fontId = RegisterFontId('font4thai')

function DrawTxtmaxez(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(fontId)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end




function deleteobject ()

local nearbyObject, nearbyID
local x = math.random(1,2)

if x == 2 then
ESX.Game.DeleteObject(nearbyObject)
table.remove(StoneLists, nearbyID)
Stones = Stones - 1
end
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		for k, v in pairs(StoneLists) do
			ESX.Game.DeleteObject(v)
		end
	end
end)