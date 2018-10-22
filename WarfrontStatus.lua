local addonName = "WarfrontStatus"
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
WarfrontStatus = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0" );
local icon = LibStub("LibDBIcon-1.0")
local LibQTip = LibStub('LibQTip-1.0')

local defaults = {
	profile = {
		MinimapButton = {
			hide = false,
		}
	}
};

local colors = {
	rare = { r = 0, g = 0.44, b = 0.87},
	epic = { r = 0.63921568627451, g = 0.2078431372549, b = 0.93333333333333 },
	white = { r = 1.0, g = 1.0, b = 1.0 },
	yellow = { r = 1.0, g = 1.0, b = 0.2 },
	grey = { r = 0.5, g = 0.5, b = 0.5 },
	red = { r = 1.0, g = 0.2, b = 0.2 }
}

local textures = {
	alliance = "|TInterface\\FriendsFrame\\PlusManz-Alliance:18|t",
	horde = "|TInterface\\FriendsFrame\\PlusManz-Horde:18|t",
	bossAvailable = "|TInterface\\WorldMap\\Skull_64Grey:18|t",
	bossDefeated = "|TInterface\\WorldMap\\Skull_64Red:18|t",
	toy = "|TInterface\\Icons\\INV_Misc_Toy_03:18|t",
	mount = "|TInterface\\Icons\\Ability_mount_ridinghorse:18|t",
    pet = "|TInterface\\Icons\\INV_Box_PetCarrier_01:18|t",
	gear = "|TInterface\\Icons\\INV_Helmet_25:18|t"
}

local frame;
local warfrontStatusLDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
	type = "data source",
	text = "Warfront Status",
	icon = "Interface\\Icons\\INV_AllianceWarEffort",
	OnClick = function(clickedframe, button)
		WarfrontStatus:ShowOptions() 
	end,
	OnEnter = function(self)
		frame = self
		WarfrontStatus:ShowToolTip()
	end,
})

function WarfrontStatus:ShowOptions()
end

function WarfrontStatus:ShowToolTip()

end

function WarfrontStatus:BOSS_KILL(event, id, name)

end

function WarfrontStatus:QUEST_TURNED_IN(event, questID)

end

function WarfrontStatus:PLAYER_LOGOUT()
	
end

local function HideSubTooltip()
	local subTooltip = WarfrontStatus.subTooltip
	if subTooltip then
		LibQTip:Release(subTooltip)
		subTooltip = nil
	end
	GameTooltip:Hide()
	WarfrontStatus.subTooltip = subTooltip
end


local function ShowCharacter(characterName, characterInfo)
	local data = WarfrontStatus:GetDisplayData()
	local tooltip = WarfrontStatus.tooltip
	local line = tooltip:AddLine()
	local factionIcon = ""


	if characterInfo.faction and characterInfo.faction == "Alliance" then
		factionIcon = textures.alliance
	elseif characterInfo.faction and characterInfo.faction == "Horde" then
		factionIcon = textures.horde
	end

	tooltip:SetCell(line, 2, factionIcon.." "..characterName)
	tooltip:SetCell(line, 3, characterInfo.level, "RIGHT")

	column = 4
		
	for _, category in pairs(data) do
		local kills = 0
		local bosses = category.bosses

		for _, boss in pairs(bosses) do
			if characterInfo.warfrontStatus[boss.name]  then
				kills = kills + 1
			end
		end

		if kills >= #bosses then
			tooltip:SetCell(line, column, textures.bossDefeated)
		else  
			tooltip:SetCell(line, column, kills.."/".. #bosses)
		end

		tooltip:SetCellScript(line, column, "OnEnter", function(self)
			local info = { character=characterInfo, region=category}
			WarfrontStatus:ShowSubTooltip(self, info)
		end)

		tooltip:SetCellScript(line, column, "OnLeave", HideSubTooltip)


		column = column+1

	end

	if characterInfo.class then
		local color = RAID_CLASS_COLORS[characterInfo.class]
		tooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
	end	

end

local function ShowHeader(tooltip, marker, headerName)
	local data = WarfrontStatus:GetDisplayData()

	local line = tooltip:AddHeader()
	local column = 2

	if (marker) then
		tooltip:SetCell(line, 1, marker)
	end
	
	tooltip:SetCell(line, column, headerName, nil, nil, nil, nil, nil, 50)
	tooltip:SetCellTextColor(line, column, colors.yellow.r, colors.yellow.g, colors.yellow.b)
	column = column + 1

	tooltip:SetCell(line, column, "Level", "RIGHT", nil, nil, nil, nil, 50)
	tooltip:SetCellTextColor(line, column, colors.yellow.r, colors.yellow.g, colors.yellow.b)
	column = column + 1

	for _, category in pairs(data) do
		tooltip:SetCell(line, column, category.name, "CENTER")
		tooltip:SetCellTextColor(line, column, colors.yellow.r, colors.yellow.g, colors.yellow.b)
		column = column+1
	end

	return line
end

local function ShowKill(boss, killed)
	local subTooltip = WarfrontStatus.subTooltip
	local line = subTooltip:AddLine()
	local bossTexture = textures.bossAvailable
	local color = colors.grey
	local dropTexture = ""
	
	if killed then 
		bossTexture = textures.bossDefeated
		color = colors.red
	end

	if boss.drops then	
		--if boss.drops.gear then
		--	dropTexture = dropTexture.." "..textures.gear..boss.drops.gear			
		--end	
		if boss.drops.mount then
			dropTexture = dropTexture.." "..textures.mount
		end
		if boss.drops.pet then
			dropTexture = dropTexture.." "..textures.pet		
		end	
		if boss.drops.toy then
			dropTexture = dropTexture.." "..textures.toy
		end			
	end
	
	subTooltip:SetCell(line, 1, boss.displayName or boss.name, nil, "LEFT")
	subTooltip:SetCell(line, 2, dropTexture, nil, "LEFT")
	subTooltip:SetCell(line, 3, bossTexture, nil, "CENTER", nil, nil, nil, nil, 20, 0)
	subTooltip:SetCellTextColor(line, 1, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 3, color.r, color.g, color.b)
end

function WarfrontStatus:ShowSubTooltip(cell, info)	
	local character = info.character
	local category = info.region
	local subTooltip = WarfrontStatus.subTooltip
	local color = colors.yellow
	local footer = ""
		
	if LibQTip:IsAcquired("WarfrontStatusSubTooltip") and subTooltip then
		subTooltip:Clear()
	else 
		subTooltip = LibQTip:Acquire("WarfrontStatusSubTooltip", 3, "LEFT", "LEFT", "CENTER")
		WarfrontStatus.subTooltip = subTooltip	
	end	
	
	subTooltip:ClearAllPoints()
	subTooltip:SetClampedToScreen(true)
	subTooltip:SetPoint("TOP", WarfrontStatus.tooltip, "TOP", 30, 0)
	subTooltip:SetPoint("RIGHT", WarfrontStatus.tooltip, "LEFT", -20, 0)
	
	line = subTooltip:AddHeader(category.title)	
	subTooltip:SetCellTextColor(line, 1, color.r, color.g, color.b)
	subTooltip:AddSeparator(6,0,0,0,0)
	
	line = subTooltip:AddLine("NPC", "Drops", "Status")
	subTooltip:SetCellTextColor(line, 1, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 3, color.r, color.g, color.b)
	subTooltip:AddSeparator(1, 1, 1, 1, 1.0)
	subTooltip:AddSeparator(3,0,0,0,0)
	
	for _, boss in pairs(category.bosses) do
		local killed = (character.warfrontStatus and character.warfrontStatus[boss.name])
									
		if not boss.faction or character.faction == boss.faction then
			ShowKill(boss, killed)
		end
	end	
	
	subTooltip:AddSeparator(6,0,0,0,0)
	line = subTooltip:AddLine()
	
	footer = format("Legend: %sdefeated  %savailable", textures.bossDefeated, textures.bossAvailable)
	

	--subTooltip:SetCell(line, 1, footer , nil, LEFT, 3)
	
	subTooltip:SetCell(line, 1, footer , nil, LEFT, 3)	
	subTooltip:Show()
end

local function ShowRealm(realmName)
	local realmInfo = self.db.global.realms[realmName]
	local characters = nil
	local collapsed = false
	--local epoch = time() - (WorldBossStatus.db.global.characterOptions.inactivityThreshold * 24 * 60 * 60)

	if realmInfo then
		characters = realmInfo.characters
		collapsed = realmInfo.collapsed
	end

	local characterNames = {}
	local currentCharacterName = UnitName("player")
	local currentRealmName = GetRealmName()
	local tooltip = WarfrontStatus.tooltip
	--local levelRestriction = WorldBossStatus.db.global.characterOptions.levelRestruction or false;
	local minimumLevel = 1

	--if WorldBossStatus.db.global.characterOptions.levelRestriction then
	--	minimumLevel = WorldBossStatus.db.global.characterOptions.minimumLevel		
	--	if not minimumLevel then minimumLevel = 90 end
	--end	
		
	if not characters then
		return 
	end

	for k,v in pairs(characters) do
		local inlcude = true
		if (realmName ~= currentRealmName or k ~= currentCharacterName) and 
		   (not WorldBossStatus.db.global.characterOptions.removeInactive or v.lastUpdate > epoch)  and
   		   (v.level >= minimumLevel) then
				table.insert(characterNames, k);
		end
	end

	if (table.getn(characterNames) == 0) then
		return
	end
			   
	table.sort(characterNames)

	tooltip:AddSeparator(2,0,0,0,0)

	if not collapsed then
		line = ShowHeader(tooltip, "|TInterface\\Buttons\\UI-MinusButton-Up:16|t", realmName)

		tooltip:AddSeparator(3,0,0,0,0)

		for k,v in pairs(characterNames) do
			WarfrontStatus:ShowCharacter(v, characters[v])
		end

		tooltip:AddSeparator(1, 1, 1, 1, 1.0)
	else
		line = ShowHeader(tooltip, "|TInterface\\Buttons\\UI-PlusButton-Up:16|t", realmName)
	end

	tooltip:SetCellTextColor(line, 2, colors.yellow.r, colors.yellow.g, colors.yellow.b)	
	tooltip:SetCellScript(line, 1, "OnMouseUp", RealmOnClick, realmName)
end

function RealmOnClick(cell, realmName)
	WorldBossStatus.db.global.realms[realmName].collapsed = not WorldBossStatus.db.global.realms[realmName].collapsed
	WorldBossStatus:ShowToolTip()
end

function WarfrontStatus:ShowToolTip()
	local tooltip = WarfrontStatus.tooltip

	if LibQTip:IsAcquired("WarfrontStatusTooltip") and tooltip then
		tooltip:Clear()
	else
		local columnCount = 5

		tooltip = LibQTip:Acquire("WarfrontStatusTooltip", columnCount, "CENTER", "LEFT", "CENTER", "CENTER", "CENTER")
		WarfrontStatus.tooltip = tooltip 
	end

	local line = tooltip:AddHeader(" ")
	tooltip:SetCell(1, 1, "|TInterface\\Icons\\INV_AllianceWarEffort:16|t "..L["Warfront Status"], nil, "LEFT", tooltip:GetColumnCount())
	tooltip:AddSeparator(6,0,0,0,0)
	ShowHeader(tooltip, nil, L["Character"])
	tooltip:AddSeparator(6,0,0,0,0)
			
	local info = WarfrontStatus:GetCharacterInfo()
	ShowCharacter(UnitName("player"), info)
	tooltip:AddSeparator(6,0,0,0,0)
	tooltip:AddSeparator(1, 1, 1, 1, 1.0)

	--ShowRealm(GetRealmName())

	tooltip:AddSeparator(3,0,0,0,0)

	if (frame) then
		tooltip:SetAutoHideDelay(0.01, frame)
		tooltip:SmartAnchorTo(frame)
	end 

	tooltip:UpdateScrolling()
	tooltip:Show()
end

function GetWarfrontStatus()
	local data = WarfrontStatus:GetDisplayData()
	local warfrontStatus = {}

	for _, category in pairs(data) do
		for _, boss in pairs(category.bosses) do
			if boss.questId and IsQuestFlaggedCompleted(boss.questId) then
				warfrontStatus[boss.name] =  time()
			end
		end
	end

	return warfrontStatus
end

function WarfrontStatus:GetRealmInfo(realmName)
	if not self.db.global.realms then
		self.db.global.realms = {}
	end

	local realmInfo = self.db.global.realms[realmName]
	
	if not realmInfo then
		realmInfo = {}
		realmInfo.characters = {}
	end

	return realmInfo
end

function WarfrontStatus:GetCharacterInfo()
	local realmInfo = WorldBossStatus:GetRealmInfo(GetRealmName())
	local characterInfo = realmInfo.characters[UnitName("player")] or {}

	characterInfo.warfrontStatus = GetWarfrontStatus()
	characterInfo.lastUpdate = time()
	_, characterInfo.class = UnitClass("player")
	characterInfo.level = UnitLevel("player")
	characterInfo.faction = UnitFactionGroup("player")

	return characterInfo
end

function WarfrontStatus:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("WarfrontStatusDB", defaults)

	
	self.MinimapButton = { hide = false }

	icon:Register(addonName, warfrontStatusLDB, self.MinimapButton)

	--icon:Show(addonName)
end

function WarfrontStatus:OnEnable()
	self:RegisterEvent("BOSS_KILL")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("PLAYER_LOGOUT")
end

function WarfrontStatus:OnDisable()
	self:UnregisterEvent("BOSS_KILL")
	self:UnregisterEvent("QUEST_TURNED_IN")
	self:UnregisterEvent("PLAYER_LOGOUT")
end
