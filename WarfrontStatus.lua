local addonName = "WarfrontStatus"
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
WarfrontStatus = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");
local icon = LibStub("LibDBIcon-1.0")
local LibQTip = LibStub('LibQTip-1.0')

local defaults = {
	global = {
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
	red = { r = 1.0, g = 0.2, b = 0.2 },
	green = { r = 0.2, g = 1.0, b = 0.2 }
}

local textures = {
	alliance = "|TInterface\\FriendsFrame\\PlusManz-Alliance:18|t",
	horde = "|TInterface\\FriendsFrame\\PlusManz-Horde:18|t",
	toy = "|TInterface\\Icons\\INV_Misc_Toy_03:18|t",
	mount = "|TInterface\\Icons\\Ability_mount_ridinghorse:18|t",
	pet = "|TInterface\\Icons\\INV_Box_PetCarrier_01:18|t",
	check = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:16|t",
	boss = "|TInterface\\Scenarios\\ScenarioIcon-Boss:16|t",
	quest = "|TInterface\\GossipFrame\\AvailableQuestIcon:16|t"
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

function WarfrontStatus:PLAYER_ENTERING_WORLD()
	WarfrontStatus:SaveCharacterInfo()
end


function WarfrontStatus:PLAYER_LEAVING_WORLD()
	WarfrontStatus:SaveCharacterInfo()
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
	local currencies = WarfrontStatus:GetCurrencies()
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
	tooltip:SetCell(line, 4, characterInfo.averageItemLevel, "RIGHT")

	column = 5

	for _, currency in pairs(currencies) do
		tooltip:SetCell(line, column, characterInfo.currencies[currency.currencyID], "RIGHT")
		column = column+1
	end
		
	for _, category in pairs(data) do
		local progress = 0
		local total = 0
		local items = category.items

		for _, item in pairs(items) do
			if characterInfo.questsCompleted[item.questID]  then
				progress = progress + 1
			end
			if not item.faction or characterInfo.faction == item.faction then
				total = total + 1
			end
		end

		if progress >= total then
			tooltip:SetCellTextColor(line, column, colors.green.r, colors.green.g, colors.green.b)

			tooltip:SetCell(line, column, textures.check)
		else  
			tooltip:SetCell(line, column, progress.."/".. total)
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
	local currencies = WarfrontStatus:GetCurrencies()

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

	tooltip:SetCell(line, column, "Gear", "RIGHT", nil, nil, nil, nil, 50)
	tooltip:SetCellTextColor(line, column, colors.yellow.r, colors.yellow.g, colors.yellow.b)
	column = column + 1

	for _, currency in pairs(currencies) do
		tooltip:SetCell(line, column, "|T"..currency.texture..":0|t", "RIGHT")
		tooltip:SetCellTextColor(line, column, colors.yellow.r, colors.yellow.g, colors.yellow.b)
		column = column+1
	end

	for _, category in pairs(data) do
		tooltip:SetCell(line, column, category.name, "CENTER")
		tooltip:SetCellTextColor(line, column, colors.yellow.r, colors.yellow.g, colors.yellow.b)
		column = column+1
	end

	return line
end

local function ShowKill(item, completed)
	local subTooltip = WarfrontStatus.subTooltip
	local line = subTooltip:AddLine()
	local color = colors.white
	local dropTexture = ""
	
	if completed then 
		subTooltip:SetCell(line, 3, textures.check, nil, "CENTER", nil, nil, nil, nil, 20, 0)
		color = colors.green
	end

	if item.drops then	
		if item.drops.mount then
			dropTexture = dropTexture.." "..textures.mount
		end
		if item.drops.pet then
			dropTexture = dropTexture.." "..textures.pet		
		end	
		if item.drops.toy then
			dropTexture = dropTexture.." "..textures.toy
		end			
	end
	
	if item.type == "quest" then
		subTooltip:SetCell(line, 1, textures.quest.." "..(item.displayName or item.name), nil, "LEFT")

		if item.rewards then
			local rewards = item.rewards
			local rewardsText = ""
			for _, reward in pairs(rewards) do
				if reward.currencyID then
					local name, _, texture = GetCurrencyInfo(reward.currencyID)	
					rewardsText = rewardsText.."|T"..texture.. ":16|t "..reward.amount.." "
				elseif reward.itemID then
					local name, _, _, _, _, _, _, _ ,_, texture = GetItemInfo(reward.itemID)	
					rewardsText = rewardsText.."|T"..texture.. ":16|t ".." "
				end
			end
			subTooltip:SetCell(line, 2, rewardsText, nil, "LEFT")
		end		
	else
		subTooltip:SetCell(line, 1, textures.boss.." "..(item.displayName or item.name), nil, "LEFT")
		subTooltip:SetCell(line, 2, dropTexture, nil, "LEFT")
	end
	
	subTooltip:SetCellTextColor(line, 1, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 3, color.r, color.g, color.b)
end

function WarfrontStatus:ShowSubTooltip(cell, info)	
	local character = info.character
	local category = info.region
	local subTooltip = WarfrontStatus.subTooltip
	local color = colors.yellow
	local columnHeaders = category.columns
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
	
	line = subTooltip:AddLine(columnHeaders[1], columnHeaders[2], columnHeaders[3])
	--line = subTooltip:AddLine(" ")

	
	subTooltip:SetCellTextColor(line, 1, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 2, color.r, color.g, color.b)
	subTooltip:SetCellTextColor(line, 3, color.r, color.g, color.b)
	subTooltip:AddSeparator(1, 1, 1, 1, 1.0)
	subTooltip:AddSeparator(3,0,0,0,0)
	
	for _, item in pairs(category.items) do
		local completed = (character.questsCompleted and character.questsCompleted[item.questID])
									
		if not item.faction or character.faction == item.faction then
			ShowKill(item, completed)
		end
	end	
	
	subTooltip:AddSeparator(6,0,0,0,0)

	subTooltip:Show()
end

local function RealmClick(cell, realmName)
	WarfrontStatus.db.global.realms[realmName].collapsed = not WarfrontStatus.db.global.realms[realmName].collapsed
	WarfrontStatus:ShowToolTip()
end

local function CharacterSort(a, b)
	if a.level > b.level then
		return true
	elseif a.level < b.level then
		return false
	else
		return a.averageItemLevel > b.averageItemLevel
	end
end

local function ShowRealm(realmName)
	local realmInfo = WarfrontStatus.db.global.realms[realmName]
	local characters = nil
	local collapsed = false

	if realmInfo then
		characters = realmInfo.characters
		collapsed = realmInfo.collapsed
	end

	local tooltip = WarfrontStatus.tooltip
	local minimumLevel = 1

	if not characters then
		return 
	end

	local sortedCharacters = {}

	for name, character in pairs(characters) do
		if (realmName ~= GetRealmName() or name ~= UnitName("player")) then
			character.name = name
			table.insert(sortedCharacters, character);
		end
	end

	if #sortedCharacters == 0 then
		return
	end

	table.sort(sortedCharacters, CharacterSort)

	tooltip:AddSeparator(2,0,0,0,0)

	if not collapsed then
		line = ShowHeader(tooltip, "|TInterface\\Buttons\\UI-MinusButton-Up:16|t", realmName)

		tooltip:AddSeparator(3,0,0,0,0)

		for _, character in pairs(sortedCharacters) do
			ShowCharacter(character.name, character)
		end

		tooltip:AddSeparator(1, 1, 1, 1, 1.0)
	else
		line = ShowHeader(tooltip, "|TInterface\\Buttons\\UI-PlusButton-Up:16|t", realmName)
	end

	tooltip:SetCellTextColor(line, 2, colors.yellow.r, colors.yellow.g, colors.yellow.b)	
	tooltip:SetCellScript(line, 1, "OnMouseUp", RealmClick, realmName)
end

function WarfrontStatus:ShowToolTip()
	local tooltip = WarfrontStatus.tooltip
	local currencies = WarfrontStatus:GetCurrencies() or {}
	local categories = WarfrontStatus:GetDisplayData() or {}

	if LibQTip:IsAcquired("WarfrontStatusTooltip") and tooltip then
		tooltip:Clear()
	else
		local columnCount = 4 + #categories + #currencies

		tooltip = LibQTip:Acquire("WarfrontStatusTooltip", columnCount, "CENTER", "LEFT", "CENTER", "CENTER", "CENTER", "CENTER")
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

	ShowRealm(GetRealmName())

	realmNames = {}
				
	for k,v in pairs(WarfrontStatus.db.global.realms) do
		if (k ~= GetRealmName()) then
			table.insert(realmNames, k);
		end
	end
			
	for k,v in pairs(realmNames) do
		ShowRealm(v)
	end

	tooltip:AddSeparator(3,0,0,0,0)

	if (frame) then
		tooltip:SetAutoHideDelay(0.01, frame)
		tooltip:SmartAnchorTo(frame)
	end 

	tooltip:UpdateScrolling()
	tooltip:Show()
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

function WarfrontStatus:SaveCharacterInfo(info)
	local characterName = UnitName("player")
	local realmInfo = WarfrontStatus:GetRealmInfo(GetRealmName())
	local characterInfo = info or WarfrontStatus:GetCharacterInfo()

	realmInfo.characters = realmInfo.characters or {}
	realmInfo.characters[characterName]  = characterInfo

	self.db.global.realms = self.db.global.realms or  {}
	self.db.global.realms[GetRealmName()] = realmInfo
end

function WarfrontStatus:GetCharacterInfo()
	local realmInfo = WarfrontStatus:GetRealmInfo(GetRealmName())
	local characterInfo = realmInfo.characters[UnitName("player")] or {}
	local data = WarfrontStatus:GetDisplayData()
	local currencies = WarfrontStatus:GetCurrencies()
	local averageItemLevel = floor(GetAverageItemLevel())

	characterInfo.lastUpdate = time()
	_, characterInfo.class = UnitClass("player")
	characterInfo.level = UnitLevel("player")
	characterInfo.faction = UnitFactionGroup("player")
	if averageItemLevel and averageItemLevel > 0 then
		characterInfo.averageItemLevel = averageItemLevel
	end
	characterInfo.currencies = characterInfo.currencies or {}
	characterInfo.questsCompleted = characterInfo.questsCompleted or {}

	for _, currency in pairs(currencies) do
		_, characterInfo.currencies[currency.currencyID] = GetCurrencyInfo(currency.currencyID)
	end

	for _, category in pairs(data) do
		for _, item in pairs(category.items) do
			if item.questID and IsQuestFlaggedCompleted(item.questID) then
				characterInfo.questsCompleted[item.questID] =  time()
			end
		end
	end

	return characterInfo
end

local function UpdateCharacterInfo()
	WarfrontStatus:SaveCharacterInfo()
end

function WarfrontStatus:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("WarfrontStatusDB", defaults,true)

	
	self.MinimapButton = { hide = false }

	icon:Register(addonName, warfrontStatusLDB, self.MinimapButton)

	--icon:Show(addonName)
end

function WarfrontStatus:OnEnable()
	self:RegisterEvent("BOSS_KILL")
	self:RegisterEvent("QUEST_TURNED_IN")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_LEAVING_WORLD")

	WarfrontStatus:ScheduleTimer(UpdateCharacterInfo, 3)
end

function WarfrontStatus:OnDisable()
	self:UnregisterEvent("BOSS_KILL")
	self:UnregisterEvent("QUEST_TURNED_IN")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("PLAYER_LEAVING_WORLD")
end
