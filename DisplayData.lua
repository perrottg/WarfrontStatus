local L = LibStub("AceLocale-3.0"):GetLocale("WarfrontStatus")
local DISPLAY_DATA = nil

function AddWarfrontRares()
	local category = {}
	local mapInfo = C_Map.GetMapInfo(14)

	category.name = L["Rares"] 
    category.title = mapInfo.name..' '..L["Rares"] 
    category.bosses = {		
		{ 
			name = "Beastrider Kama", 
			questId = 53083, 
			id = 142709, 			
			drops = { mount = 1180, gear = 280 }
		},
		{ name = "Branchlord Aldrus", id = 142508, questId = 53013, drops = { pet = 143503, gear = 280 } },
		{ name = "Burning Goliath", questId = 53017, id = 141615, drops = { item = 163691, gear = 280 }},
		{ name = "Cresting Goliath", questId = 53018, id = 141618, drops = { item = 163700, gear = 280 }},
		{ name = "Darbel Montrose", id = 142688, questId = 53084, drops = { pet = 143507, gear = 280 }},
		{ 
			name = "Doomrider Helgrim", 
			id = 142741, 
			questId = 53085, 
			faction = 'Alliance', 
			drops = { mount = 1174, gear = 280 }
		},
		{ name = "Echo of Myzrael", id = 141668, questId = 53059, drops = { pet = 143515, gear = 280 }},		
		{ name = "Foulbelly", id = 142686, questId = 53086, drops = { toy = 163735, gear = 280 }},
		{ name = "Fozruk", id = 142433, questId = 53019, drops = { pet = 143627, gear = 280 }},
		{ name = "Geomancer Flintdagger", id = 142662, questId = 53060, drops = { toy = 163713, gear = 280 }},
		{ name = "Horrific Apparition", id = 142725, questId = 53087, drops = { toy = 163736, gear = 280 }},
		{ 
			name = "Knight-Captain Aldrin", 
			id = 142739, 
			questId = 53088, 
			faction = 'Horde', 
			drops = { mount = 1173, gear = 280 }
		},
		{ name = "Kor'gresh Coldrage", id = 142112, questId = 53058, drops = { toy = 163744, gear = 280 }},
		{ name = "Kovork", id = 142684, questId = 53089, drops = { toy = 163750, gear = 280 }},
		{ name = "Man-Hunter Rog", id = 142716, questId = 53090, drops = { pet = 143628, gear = 280 }},
		{ name = "Molok the Crusher", id = 141942, questId = 53057, drops = { toy = 163775, gear = 280 }},
		{ 
			name = "Overseer Krix", 
			id = 142423, 
			questId = 53014, 
			drops = { mount = 1182, gear = 280 }
		},
		{ 
			name = "Nimar the Slayer", 
			id = 142692, questId = 53091, 
			drops = { mount = 1185, gear = 280 }
		},
		{ name = "Plaguefeather", id = 142435, questId = 53020, drops = { pet = 143564, gear = 280 }},
		{ name = "Ragebeak", id = 142436, questId = 53016, drops = { pet = 143563, gear = 280 }},
		{ name = "Rumbling Goliath", questId = 53021, id = 141620, drops = { item = 163701, gear = 280 }},
		{ name = "Ruul Onestone", id = 142683, questId = 53092, drops = { toy = 163741, gear = 280 }},
		{ name = "Singer", id = 142690, questId = 53093, drops = { toy = 163738, gear = 280 }},
		{ 
			name = "Skullripper", 
			id = 142437, 
			questId = 53022, 
			drops = { mount = 1183, gear = 280 }
		},
		{ name = "Thundering Goliath", questId = 53023, id = 141616, drops = { item = 163698, gear = 280 }},
		{ name = "Venomarus", id = 142438, questId = 53024, drops = { pet = 143499, gear = 280 }},
		{ name = "Yogursa", id = 142440, questId = 53015, drops = { pet = 143533, gear = 280 }},
		{ 
			name = "Zalas Witherbark", 
			id = 142682, 
			questId = 53094, 
			drops = { toy = 163745, gear = 280 }
		}
	}

	category.showDrops = true

    DISPLAY_DATA[#DISPLAY_DATA +1] = category
end

function WarfrontStatus:GetDisplayData(update)
	if update or DISPLAY_DATA == nil or #DISPLAY_DATA == 0 then		
		DISPLAY_DATA = {}

		AddWarfrontRares()
	end

	return DISPLAY_DATA
end




