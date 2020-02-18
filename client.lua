
function DisplayHelpText(string1, string2, string3, time)
    BeginTextCommandDisplayHelp("THREESTRINGS")
    AddTextComponentSubstringWebsite(string1)
    AddTextComponentSubstringWebsite(string2)
    AddTextComponentSubstringWebsite(string3)
	EndTextCommandDisplayHelp(0, 0, 1, time or -1)
end

intensity = {"low", "med", "high"}
direction = {"left", "center", "up"}
height = {"up", "", "down"}
vars = {"a", "b"}
shakeIntensity = {0.25, 0.5, 1.0}

currentIntensity = 1

lastAnim = "med_center"
anim = "med_center"

isDancing = false

RegisterCommand("dance", function()
	Citizen.CreateThread(function()
		if isDancing == true then
			return
		end
		
		DisplayHelpText("Press ~INPUTGROUP_MOVE~ to change direction.", "~n~Press ~INPUT_SPRINT~ and ~INPUT_JUMP~ to change intensity.", "~n~Press ~INPUT_ENTER~ to exit.", 5000)
		
		local ped = PlayerPedId()
		
		local gender = "male"
		if GetEntityModel(ped) == `mp_f_freemode_01` then gender = "female" end
		
		danceVar = "anim@amb@nightclub@mini@dance@dance_solo@"..gender.."@var_".. vars[math.random(1, 2)] .."@"
		
		if not HasAnimDictLoaded(danceVar) then
			BeginTextCommandBusyspinnerOn("STRING")
			AddTextComponentString("LOADING DANCE ANIM")
			EndTextCommandBusyspinnerOn(1)
			RequestAnimDict(danceVar)
			repeat Wait(0) until HasAnimDictLoaded(danceVar)
		end
		
		
		if not HasAnimDictLoaded("anim@amb@nightclub@dancers@club_ambientpedsfaces@") then
			BeginTextCommandBusyspinnerOn("STRING")
			AddTextComponentString("LOADING FACIAL ANIM")
			EndTextCommandBusyspinnerOn(1)
			RequestAnimDict("anim@amb@nightclub@dancers@club_ambientpedsfaces@")
			repeat Wait(0) until HasAnimDictLoaded("anim@amb@nightclub@dancers@club_ambientpedsfaces@")
		end
		
		BusyspinnerOff()
		
		currentIntensity = 1
		
		ShakeGameplayCam("CLUB_DANCE_SHAKE", 0.5)
		SetGameplayCamShakeAmplitude(shakeIntensity[currentIntensity])
		
		-- TaskPlayAnim(ped, danceVar, "intro", 8.0, -8, -1, 0, 0, 0, 0, 0)
		-- Wait(GetAnimDuration(danceVar, "intro")*1000)
		
		TaskPlayAnim(ped, danceVar, anim, 8.0, -8, -1, 1, 0, 0, 0, 0)
		
		isDancing = true
		
		while true do Wait(0)
		
			DisableControlAction(0, 37, true)
		
			lastAnim = anim
			
			animheight = ""
			animdirection = "center"
			
			currentTime = GetEntityAnimCurrentTime(PlayerPedId(), danceVar, lastAnim)
			
			if IsControlPressed(0, 32) then
				animheight = "_up"
			end
			
			if IsControlPressed(0, 33) then
				animheight = "_down"
			end
			
			if IsControlPressed(0, 34) then
				animdirection = "left"
			end
			
			if IsControlPressed(0, 35) then
				animdirection = "right"
			end
			
			
			-- DECREASE INTENSITY
			if IsControlJustPressed(0, 21) and currentIntensity > 1 then
				currentIntensity = currentIntensity - 1
			end
			
			-- INCREASE INTENSITY
			if IsControlJustPressed(0, 22) and currentIntensity < 3 then
				currentIntensity = currentIntensity + 1
			end
			
			local x, y, z = table.unpack(GetEntityRotation(ped, 0))
			
			
			-- SPIN RIGHT
			if IsControlPressed(0, 153) then
				SetEntityRotation(ped, x, y, z-0.5, 0, true)
			end
			
			-- SPIN LEFT
			if IsControlPressed(0, 152) then
				SetEntityRotation(ped, x, y, z+0.5, 0, true)
			end
			
			
			-- QUIT
			if IsControlJustPressed(0, 23) then
				TaskPlayAnim(ped, "", "", 4.0, 4.0, -1, 1, 0, 0, 0, 0) 
				PlayFacialAnim(PlayerPedId(), "", "")
				StopGameplayCamShaking(false)
				RemoveAnimDict(danceVar)
				isDancing = false
				return
			end
			
			
			animintensity = intensity[currentIntensity]
			
			anim = animintensity ..'_'.. animdirection ..animheight
			
			-- SetTextFont(0)
			-- SetTextProportional(1)
			-- SetTextScale(0.0, 0.55)
			-- SetTextColour(255, 255, 255, 255)
			-- SetTextDropshadow(0, 0, 0, 0, 255)
			-- SetTextEdge(2, 0, 0, 0, 150)
			-- SetTextDropShadow()
			-- SetTextOutline()
			-- SetTextEntry("STRING")
			-- SetTextCentre(1)
			-- AddTextComponentString(anim)
			-- DrawText(0.5, 0.1)
			
			if lastAnim ~= anim then
				currentTime = GetEntityAnimCurrentTime(PlayerPedId(), danceVar, lastAnim)
				SetGameplayCamShakeAmplitude(shakeIntensity[currentIntensity])
				-- TaskPlayAnim(PlayerPedId(), danceVar, anim, 4.0, 4.0, -1, 1, 1.0, false, false, false) 
				TaskPlayAnimAdvanced(PlayerPedId(), danceVar, anim, GetEntityCoords(PlayerPedId()), GetEntityRotation(PlayerPedId()), 4.0, 4.0, -1, 1, currentTime, false, false, false) 
				PlayFacialAnim(PlayerPedId(), "mood_dancing_"..animintensity.."_2", "anim@amb@nightclub@dancers@club_ambientpedsfaces@")
			end
		end
	end)
end)

