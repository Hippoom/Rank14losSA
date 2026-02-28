--[[
RSA_Core.lua - Core Functions, Config, Menu System
Part of Rank14losSA addon
]]

local RSA_VERSION = "1.0-Nampower"

--[[===========================================================================
	Core Functions
=============================================================================]]

function RSA_SlashCmdHandler(msg)
	if msg and string.lower(msg) == "save" then
		if RSA_AlertFrameX and RSA_AlertFrameY then
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RSA]|r Position saved: X=" .. math.floor(RSA_AlertFrameX) .. ", Y=" .. math.floor(RSA_AlertFrameY))
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[RSA]|r No position to save")
		end
		return
	end
	RSAMenuFrame_Toggle()
end

function RSA_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD")
	this:RegisterEvent("PLAYER_LOGOUT")
end

function RSA_OnEvent(event)
	if event == "PLAYER_LOGOUT" then return end
	
	if event == "PLAYER_ENTERING_WORLD" then
		this:UnregisterEvent("PLAYER_ENTERING_WORLD")
		
		local hasNamepower = (GetNampowerVersion ~= nil)

		if not hasNamepower then
			DEFAULT_CHAT_FRAME:AddMessage("|cffff0000============================================|r")
			DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[RSA] CRITICAL ERROR: Nampower NOT DETECTED!|r")
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00This addon REQUIRES Nampower to function.|r")
			DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00https://gitea.com/avitasia/nampower|r")
			DEFAULT_CHAT_FRAME:AddMessage("|cffff0000RSA addon has been DISABLED.|r")
			DEFAULT_CHAT_FRAME:AddMessage("|cffff0000============================================|r")

			SLASH_RSA1 = "/rsa"
			SlashCmdList["RSA"] = function()
				DEFAULT_CHAT_FRAME:AddMessage("|cffff0000[RSA]|r Nampower not detected!")
			end
			RSAMenuFrame:UnregisterAllEvents()
			if RSAConfig then RSAConfig.enabled = false end
			return
		end
		
		-- Initialize config
		if not RSAConfig or not RSAConfig.version or RSAConfig.version ~= RSA_VERSION then
			RSAConfig = {
				["enabled"] = true,
				["outside"] = true,
				["version"] = RSA_VERSION,
				["buffs"] = {
					["enabled"] = true,
					["AdrenalineRush"] = true, ["ArcanePower"] = true, ["Barkskin"] = true,
					["BattleStance"] = false, ["BerserkerRage"] = true, ["BerserkerStance"] = false,
					["BestialWrath"] = true, ["BladeFlurry"] = true, ["BlessingofFreedom"] = true,
					["BlessingofProtection"] = true, ["Cannibalize"] = true, ["ColdBlood"] = true,
					["Combustion"] = true, ["Dash"] = true, ["DeathWish"] = true,
					["DefensiveStance"] = false, ["DesperatePrayer"] = true, ["Deterrence"] = true,
					["DivineFavor"] = true, ["DivineShield"] = true, ["EarthbindTotem"] = true,
					["ElementalMastery"] = true, ["Evasion"] = true, ["Evocation"] = true,
					["FearWard"] = true, ["FirstAid"] = true, ["FrenziedRegeneration"] = true,
					["FreezingTrap"] = true, ["GroundingTotem"] = true, ["IceBlock"] = true,
					["InnerFocus"] = true, ["Innervate"] = true, ["Intimidation"] = true,
					["LastStand"] = true, ["ManaTideTotem"] = true, ["Nature'sGrasp"] = true,
					["Nature'sSwiftness"] = true, ["PowerInfusion"] = true, ["PresenceofMind"] = true,
					["RapidFire"] = true, ["Recklessness"] = true, ["Reflector"] = true,
					["Retaliation"] = true, ["Sacrifice"] = true, ["ShieldWall"] = true,
					["Sprint"] = true, ["Stoneform"] = true, ["SweepingStrikes"] = true,
					["Tranquility"] = true, ["TremorTotem"] = true, ["Trinket"] = true,
					["WilloftheForsaken"] = true, ["FreeAction"] = true,
				},
				["casts"] = {
					["enabled"] = true,
					["EntanglingRoots"] = true, ["EscapeArtist"] = true, ["Fear"] = true,
					["Hearthstone"] = true, ["Hibernate"] = true, ["HowlofTerror"] = true,
					["MindControl"] = true, ["Polymorph"] = true, ["RevivePet"] = true,
					["ScareBeast"] = true, ["WarStomp"] = true,
				},
				["debuffs"] = {
					["enabled"] = true,
					["Blind"] = true, ["ConcussionBlow"] = true, ["Counterspell-Silenced"] = true,
					["DeathCoil"] = true, ["Disarm"] = true, ["HammerofJustice"] = true,
					["IntimidatingShout"] = true, ["PsychicScream"] = true, ["Repetance"] = true,
					["ScatterShot"] = true, ["Seduction"] = true, ["Silence"] = true,
					["SpellLock"] = true, ["WyvernSting"] = true,
				},
				["fadingBuffs"] = {
					["enabled"] = true,
					["AdrenalineRush"] = true, ["ArcanePower"] = true, ["Barkskin"] = true,
					["BerserkerRage"] = true, ["BestialWrath"] = true, ["BladeFlurry"] = true,
					["BlessingofFreedom"] = true, ["BlessingofProtection"] = true, ["Combustion"] = true,
					["Dash"] = true, ["DeathWish"] = true, ["Deterrence"] = true,
					["DivineShield"] = true, ["Evasion"] = true, ["FrenziedRegeneration"] = true,
					["IceBlock"] = true, ["Innervate"] = true, ["LastStand"] = true,
					["Nature'sGrasp"] = true, ["RapidFire"] = true, ["Recklessness"] = true,
					["Retaliation"] = true, ["ShieldWall"] = true, ["Sprint"] = true,
					["Stoneform"] = true, ["WilloftheForsaken"] = true, ["FreeAction"] = true,
				},
				["use"] = {
					["enabled"] = true,
					["Kick"] = true, ["FlashBomb"] = true,
				},
			}
		end
		
		-- Migrate existing configs: add new buff entries
		if RSAConfig.buffs then
			local newBuffs = {
				"FreeAction",
			}
			for _, buff in ipairs(newBuffs) do
				if RSAConfig.buffs[buff] == nil then
					RSAConfig.buffs[buff] = true
				end
			end
		end
		
		-- Migrate existing configs: add new fadingBuffs entries
		if RSAConfig.fadingBuffs then
			local newFadingBuffs = {
				"AdrenalineRush", "ArcanePower", "BerserkerRage", "BestialWrath",
				"BladeFlurry", "BlessingofFreedom", "Combustion", "Dash", "DeathWish",
				"FrenziedRegeneration", "Innervate", "LastStand", "Nature'sGrasp",
				"RapidFire", "Recklessness", "Retaliation", "Sprint", "Stoneform",
				"WilloftheForsaken", "FreeAction",
			}
			for _, buff in ipairs(newFadingBuffs) do
				if RSAConfig.fadingBuffs[buff] == nil then
					RSAConfig.fadingBuffs[buff] = true
				end
			end
		end
		
		RSA_NP:Initialize()
		InitializeDistanceCheck()
		
		if RSA_AlertFrameEnabled == nil then RSA_AlertFrameEnabled = true end
		if RSA_AlertFrameBgAlpha == nil then RSA_AlertFrameBgAlpha = 0.7 end
		
		RSA_CreateAlertFrame()
		
		if RSAConfig.enabled then
			if not RSAConfig.outside then
				this:RegisterEvent("ZONE_CHANGED_NEW_AREA")
				RSA_UpdateState()
			else
				RSA_Enable()
			end
		end
		
		SlashCmdList["RSA"] = RSA_SlashCmdHandler
		SLASH_RSA1 = "/rsa"
		
	elseif event == "ZONE_CHANGED_NEW_AREA" then
		RSA_UpdateState()
	end
end

function RSA_UpdateState()
	local zone = GetRealZoneText()
	if zone == "Alterac Valley" or zone == "Arathi Basin" or zone == "Warsong Gulch" then
		RSA_Enable()
	else
		RSA_Disable()
	end
end

function RSA_Disable()
	RSA_NP:Disable()
end

function RSA_Enable()
	RSA_NP:Enable()
end

function RSA_PlaySoundFile(spell, playerName, casterGUID, castDuration, spellID, itemID)
	RSA_ShowAlert(spell, playerName, casterGUID, castDuration, spellID, itemID)
	RSA_UpdatePortraitIcon(spell, playerName, casterGUID, spellID, itemID)
	
	-- DEBUG OUTPUT
	if RSA_NP and RSA_NP.debugMode then
		local isFade = string.sub(spell, -4) == "down"
		local displayName = isFade and string.sub(spell, 1, -5) or spell
		local eventType = "BUFF"
		
		if castDuration and tonumber(castDuration) and tonumber(castDuration) > 0 then
			eventType = "CAST"
		elseif isFade then
			eventType = "FADE"
		elseif spellID and RSA_USE_SPELL_IDS[spellID] then
			eventType = "USE"
		end
		
	-- Get spell name with rank from SpellInfo/Nampower
	local spellNameWithRank = displayName
	if spellID then
		local name = SpellInfo and SpellInfo(spellID)
		if not name and GetSpellRecField then
			name = GetSpellRecField(spellID, "spellName")
		end
		if name then spellNameWithRank = name end
	end
		
		DEFAULT_CHAT_FRAME:AddMessage("|cffff00ff========== R14 Debug ==========|r")
		DEFAULT_CHAT_FRAME:AddMessage("|cffff00ffEvent Type:|r " .. eventType)
		DEFAULT_CHAT_FRAME:AddMessage("|cffff00ffCaster:|r " .. (playerName or "Unknown"))
		DEFAULT_CHAT_FRAME:AddMessage("|cffff00ffSpell:|r " .. spellNameWithRank)
		
		-- Spell ID nur anzeigen wenn nicht Fade
		if not isFade then
			DEFAULT_CHAT_FRAME:AddMessage("|cffff00ffSpell ID:|r " .. tostring(spellID or "N/A"))
		end
		
		if castDuration and tonumber(castDuration) and tonumber(castDuration) > 0 then
			DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff00ffCast Time:|r %.2fs", tonumber(castDuration) / 1000))
		elseif not isFade then
			-- Zeige Duration für Buffs
			local duration = nil
			if spellID and RSA_SPELLID_DURATIONS[spellID] then
				duration = RSA_SPELLID_DURATIONS[spellID]
			elseif RSA_BUFF_DURATIONS[displayName] then
				duration = RSA_BUFF_DURATIONS[displayName]
			end
			if duration then
				DEFAULT_CHAT_FRAME:AddMessage(string.format("|cffff00ffDuration:|r %ds", duration))
			end
		end
		
		DEFAULT_CHAT_FRAME:AddMessage("|cffff00ffSound:|r " .. spell .. ".mp3")
		DEFAULT_CHAT_FRAME:AddMessage("|cffff00ff================================|r")
	end
	
	local mp3Path = "Interface\\AddOns\\Rank14losSA\\Voice\\"..spell..".mp3"
	PlaySoundFile(mp3Path, "Master")
end

function RSA_Subtable(index)
	if index < RSA_BUFF then return "buffs"
	elseif index < RSA_CAST then return "casts"
	elseif index < RSA_DEBUFF then return "debuffs"
	elseif index < RSA_FADING then return "fadingBuffs"
	else return "use"
	end
end

function RSA_SoundText(index)
	if RSA_SOUND_OPTION_WHITE[index] then
		return "enabled"
	else
		return string.gsub(RSA_SOUND_OPTION_TEXT[index], " ", "")
	end
end

--[[===========================================================================
	Menu System
=============================================================================]]

function RSACheckButton_OnClick()
	if this.variable then
		if this:GetChecked() then
			RSAConfig[this.variable] = true
		else
			RSAConfig[this.variable] = false
		end
		if this.index == 1 then
			RSAMenuFrame_UpdateDependencies()
			if RSAConfig.outside and this:GetChecked() then
				RSA_Enable()
			else
				RSA_Disable()
			end
		elseif this.index == 2 then
			if this:GetChecked() then
				RSAMenuFrame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
				RSA_Enable()
			else
				RSAMenuFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
				RSA_UpdateState()
			end
		elseif this.index == 3 then
			RSA_AlertFrameEnabled = this:GetChecked()
		elseif this.index == 4 then
			RSA_ToggleMoveMode()
			this:SetChecked(RSA_MoveMode)
		end
	else
		if this:GetChecked() then
			RSAConfig[RSA_Subtable(this.index)][RSA_SoundText(this.index)] = true
		else
			RSAConfig[RSA_Subtable(this.index)][RSA_SoundText(this.index)] = false
		end
		if RSA_SOUND_OPTION_WHITE[this.index] then
			RSASoundOptionFrame_Update()
		end
	end
end

function RSAMenuFrame_Toggle()
	if RSAMenuFrame:IsVisible() then
		RSAMenuFrame:Hide()
	else
		RSAMenuFrame:Show()
	end
end

function RSAMenuFrame_Update()
	local button, fontString
	for i=1,4 do
		fontString = _G["RSAMenuFrameButton"..i.."Text"]
		fontString:SetText(RSA_MENU_TEXT[i])
		button = _G["RSAMenuFrameButton"..i]
		button.variable = RSA_MENU_SETS[i]
		button.index = i
		
		if i == 1 or i == 2 then
			button:SetChecked(RSAConfig[button.variable])
		elseif i == 3 then
			button:SetChecked(RSA_AlertFrameEnabled)
		elseif i == 4 then
			button:SetChecked(RSA_MoveMode)
		end
		
		if RSA_MENU_WHITE[i] then
			fontString:SetTextColor(1,1,1)
		end
	end
	
	if not RSAMenuFrame.alphaSlider then
		local slider = CreateFrame("Slider", "RSAAlphaSlider", RSAMenuFrame, "OptionsSliderTemplate")
		slider:SetWidth(180)
		slider:SetHeight(16)
		slider:SetPoint("TOPLEFT", RSAMenuFrameButton4, "BOTTOMLEFT", 0, -15)
		slider:SetMinMaxValues(0, 100)
		slider:SetValueStep(1)
		
		local displayValue = (RSA_AlertFrameBgAlpha / 0.7) * 100
		slider:SetValue(displayValue)
		
		_G[slider:GetName().."Low"]:SetText("0%")
		_G[slider:GetName().."High"]:SetText("100%")
		_G[slider:GetName().."Text"]:SetText("Background: " .. math.floor(displayValue) .. "%")
		
		slider:SetScript("OnValueChanged", function()
			local displayVal = this:GetValue()
			RSA_AlertFrameBgAlpha = (displayVal / 100) * 0.7
			_G[this:GetName().."Text"]:SetText("Bar Opacity: " .. math.floor(displayVal) .. "%")
			if RSA_AlertFrame and RSA_AlertFrame:IsVisible() then
				RSA_AlertFrame.bar:SetVertexColor(0.5, 0.5, 0.5, RSA_AlertFrameBgAlpha)
			end
		end)
		
		RSAMenuFrame.alphaSlider = slider
	else
		local displayValue = (RSA_AlertFrameBgAlpha / 0.7) * 100
		RSAMenuFrame.alphaSlider:SetValue(displayValue)
		_G[RSAMenuFrame.alphaSlider:GetName().."Text"]:SetText("Bar Opacity: " .. math.floor(displayValue) .. "%")
	end
	
	RSAMenuFrame_UpdateDependencies()
end

function RSAMenuFrame_UpdateDependencies()
	if RSAConfig.enabled then
		OptionsFrame_EnableCheckBox(RSAMenuFrameButton2)
	else
		OptionsFrame_DisableCheckBox(RSAMenuFrameButton2)
	end
end

function RSASoundOptionFrame_Toggle()
	if RSASoundOptionFrame:IsVisible() then
		RSASoundOptionFrame:Hide()
	else
		RSASoundOptionFrame:Show()
	end
end

function RSASoundOptionFrame_Update()
	local button, fontString
	local offset = FauxScrollFrame_GetOffset(RSASoundOptionFrameScrollFrame)
	for i=1,17 do
		local index = offset + i
		fontString = _G["RSASoundOptionFrameButton"..i.."Text"]
		fontString:SetText(RSA_SOUND_OPTION_TEXT[index])
		
		button = _G["RSASoundOptionFrameButton"..i]
		button.index = index
		
		if RSA_SOUND_OPTION_NOBUTTON[index] then
			button:Hide()
		else
			button:Show()
			button:SetChecked(RSAConfig[RSA_Subtable(index)][RSA_SoundText(index)])
		end
		
		if RSA_SOUND_OPTION_WHITE[index] then
			OptionsFrame_EnableCheckBox(button)
			fontString:SetTextColor(1,1,1)
		else
			if RSAConfig[RSA_Subtable(index)]["enabled"] then
				OptionsFrame_EnableCheckBox(button)
			else
				OptionsFrame_DisableCheckBox(button)
			end
		end
	end
	
	FauxScrollFrame_Update(RSASoundOptionFrameScrollFrame, table.getn(RSA_SOUND_OPTION_TEXT), 17, 16)
end

--[[===========================================================================
	Debug Commands
=============================================================================]]

SLASH_RSASTATUS1 = "/rsastatus"
SlashCmdList["RSASTATUS"] = function()
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00========== RSA Status ==========|r")
	if GetNampowerVersion then
		local a, b, c = GetNampowerVersion()
		DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff00ff00Nampower:|r v%d.%d.%d", a, b, c))
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Mode:|r " .. (pfUI and pfUI.libdebuff_spell_go_other_hooks and "pfUI hooks" or "Standalone"))
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Scanner:|r " .. (RSA_NP.enabled and "|cff00ff00ACTIVE|r" or "|cffff0000INACTIVE|r"))
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Nampower:|r |cffff0000NOT AVAILABLE|r")
	end
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00RSA Enabled:|r " .. tostring(RSAConfig and RSAConfig.enabled))
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Debug Mode:|r " .. (RSA_NP.debugMode and "|cffff00ffENABLED|r" or "DISABLED"))
	DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00================================|r")
end

SLASH_R14DEBUG1 = "/r14debug"
SlashCmdList["R14DEBUG"] = function()
	RSA_NP.debugMode = not RSA_NP.debugMode
	if RSA_NP.debugMode then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff00ff[R14 Debug]|r Debug mode |cff00ff00ENABLED|r")
	else
		DEFAULT_CHAT_FRAME:AddMessage("|cffff00ff[R14 Debug]|r Debug mode |cffff0000DISABLED|r")
	end
end
