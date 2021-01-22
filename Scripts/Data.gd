extends Node

var path_1 = {	"ME":{"value":0.12, "pw":1.15, "is_value_integer":false, "metal_costs":{"lead":40, "copper":50, "iron":60, "aluminium":60, "silver":60, "gold":60}},
				"PP":{"value":0.3, "pw":1.15, "is_value_integer":false, "metal_costs":{"lead":40, "copper":50, "iron":60, "aluminium":60, "silver":60, "gold":60}},
				"RL":{"value":0.03, "pw":1.15, "is_value_integer":false, "metal_costs":{"lead":100, "copper":150, "iron":150, "aluminium":150, "silver":150, "gold":150}},
				"MS":{"value":25, "pw":1.15, "is_value_integer":true, "metal_costs":{"lead":35, "copper":25, "iron":35, "aluminium":40, "silver":40, "gold":40}},
				"RCC":{"value":1.0, "pw":1.03, "is_value_integer":false, "metal_costs":{"lead":2000, "copper":2000, "iron":1800, "aluminium":1800, "silver":1800, "gold":1800}},
				"SC":{"value":50.0, "pw":1.15, "is_value_integer":false, "metal_costs":{"lead":300, "copper":300, "iron":300, "aluminium":300, "silver":300, "gold":300}},
				"GF":{"value":0.1, "pw":1.15, "is_value_integer":false, "metal_costs":{"lead":350, "copper":350, "iron":350, "aluminium":350, "silver":350, "gold":350}},
				"SE":{"value":20.0, "pw":1.15, "is_value_integer":false, "metal_costs":{"lead":200, "copper":200, "iron":200, "aluminium":200, "silver":200, "gold":200}},
				"MM":{"value":0.01, "pw":1.08, "is_value_integer":false, "metal_costs":{"lead":500, "copper":700, "iron":900, "aluminium":1100, "silver":1300, "gold":1500}},
}
var path_2 = {	"ME":{"value":15, "pw":1.16, "is_value_integer":true, "metal_costs":{"lead":40, "copper":50, "iron":60, "aluminium":60, "silver":60, "gold":60}},
				"PP":{"value":70, "pw":1.16, "is_value_integer":true, "metal_costs":{"lead":40, "copper":50, "iron":60, "aluminium":60, "silver":60, "gold":60}},
				"SC":{"value":4000, "pw":1.16, "is_value_integer":true, "metal_costs":{"lead":300, "copper":300, "iron":300, "aluminium":300, "silver":300, "gold":300}},
				"GF":{"value":600, "pw":1.16, "is_value_integer":true, "metal_costs":{"lead":350, "copper":350, "iron":350, "aluminium":350, "silver":350, "gold":350}},
				"SE":{"value":50, "pw":1.16, "is_value_integer":true, "metal_costs":{"lead":350, "copper":350, "iron":350, "aluminium":350, "silver":350, "gold":350}},
				"MM":{"value":4, "pw":1.08, "is_value_integer":true, "metal_costs":{"lead":500, "copper":700, "iron":900, "aluminium":1100, "silver":1300, "gold":1500}},
}
var path_3 = {	"SC":{"value":1.0, "pw":1.03, "is_value_integer":false, "metal_costs":{"lead":600, "copper":600, "iron":600, "aluminium":600, "silver":600, "gold":600}},
				"GF":{"value":1.0, "pw":1.05, "is_value_integer":false, "metal_costs":{"lead":700, "copper":700, "iron":700, "aluminium":700, "silver":700, "gold":700}},
				"SE":{"value":1.0, "pw":1.05, "is_value_integer":false, "metal_costs":{"lead":700, "copper":700, "iron":700, "aluminium":700, "silver":700, "gold":700}},
}

var costs = {	"ME":{"money":100, "energy":40, "time":12.0},
				"PP":{"money":80, "time":18.0},
				"RL":{"money":2000, "energy":600, "time":150.0},
				"MS":{"money":500, "energy":80, "time":40.0},
				"RCC":{"money":20000, "energy":4000, "time":280.0},
				"SC":{"money":2200, "energy":800, "time":150.0},
				"GF":{"money":1500, "energy":1000, "time":120.0},
				"SE":{"money":1500, "energy":500, "time":120.0},
				"MM":{"money":13000, "energy":7000, "time":400.0},
				"rover":{"money":5000, "energy":300, "time":80.0},
}

var MS_costs = {	"M_DS_0":{"money":10000000000, "stone":800000000, "silicon":400000, "copper":2500000, "iron":16000000, "aluminium":5000000, "titanium":500000, "time":10 * 86400},
					"M_SE_0":{"money":700000, "stone":50000, "energy":50000, "copper":800, "iron":1000, "aluminium":300, "time":2*3600},#2*3600
					"M_SE_1":{"money":3200000, "stone":200000, "energy":200000, "copper":1000, "iron":1400, "aluminium":400, "time":8*3600},#8, 8, 12
					"M_SE_2":{"money":6800000, "stone":350000, "energy":350000, "copper":2000, "iron":2800, "aluminium":800, "time":8*3600},
					"M_SE_3":{"money":10000000, "stone":500000, "energy":500000, "copper":8000, "iron":10000, "aluminium":3000, "time":12*3600},
}

var MS_output = {	"M_DS_0":50000000
}

var MUs = {	"MV":{"base_cost":100, "pw":2.3},
			"MSMB":{"base_cost":100, "pw":1.6},
			"IS":{"base_cost":500, "pw":2.1},
			"AIE":{"base_cost":1000, "pw":1.9},
}
var minerals_icon = load("res://Graphics/Icons/minerals.png")
var energy_icon = load("res://Graphics/Icons/energy.png")
var stone_icon = load("res://Graphics/Icons/stone.png")
var SP_icon = load("res://Graphics/Icons/SP.png")
var glass_icon = load("res://Graphics/Materials/glass.png")
var sand_icon = load("res://Graphics/Materials/sand.png")
var coal_icon = load("res://Graphics/Materials/coal.png")
var MM_icon = load("res://Graphics/Icons/MM.png")

var desc_icons = {	"ME":[minerals_icon, minerals_icon],
					"PP":[energy_icon, energy_icon],
					"RL":[SP_icon],
					"MS":[minerals_icon],
					"SC":[stone_icon, stone_icon, null],
					"GF":[glass_icon, sand_icon, null],
					"SE":[energy_icon, coal_icon, null],
}

var rsrc_icons = {	"ME":minerals_icon,
					"PP":energy_icon,
					"RL":SP_icon,
					"SC":stone_icon,
					"GF":glass_icon,
					"SE":energy_icon,
					"MM":MM_icon,
}

func reload():
	path_1.ME.desc = tr("EXTRACTS_X") % ["@i %s/" + tr("S_SECOND")]
	path_1.PP.desc = tr("GENERATES_X") % ["@i %s/" + tr("S_SECOND")]
	path_1.RL.desc = tr("PRODUCES_X") % ["@i %s/" + tr("S_SECOND")]
	path_1.RCC.desc = tr("MULT_ROVER_STAT_BY") % ["%s"]
	path_1.MS.desc = tr("STORES_X") % [" @i %s"]
	path_1.SC.desc = tr("CRUSHES_X") % ["@i %s kg/" + tr("S_SECOND")]
	path_1.GF.desc = tr("PRODUCES_X") % ["@i %s kg/" + tr("S_SECOND")]
	path_1.SE.desc = tr("GENERATES_X") % ["@i %s/" + tr("S_SECOND")]
	path_1.MM.desc = tr("X_M_PER_SECOND") % ["%s", tr("S_SECOND")]
	path_2.ME.desc = tr("STORES_X") % [" @i %s"]
	path_2.PP.desc = tr("STORES_X") % [" @i %s"]
	path_2.SC.desc = tr("CAN_STORE_UP_TO") % [" @i %s kg"]
	path_2.GF.desc = tr("CAN_STORE_UP_TO") % [" @i %s kg"]
	path_2.SE.desc = tr("CAN_STORE_UP_TO") % [" @i %s kg"]
	path_2.MM.desc = tr("X_M_AT_ONCE")
	path_3.SC.desc = tr("OUTPUT_MULTIPLIER")
	path_3.GF.desc = tr("OUTPUT_MULTIPLIER")
	path_3.SE.desc = tr("OUTPUT_MULTIPLIER")

var lakes = {	"water":{"color":Color(0.38, 0.81, 1.0, 1.0)}}

#Science for unlocking game features
var science_unlocks = {	
						#Agriculture Sciences
						"SA":{"cost":100, "parent":""},
						
						#Auto mining
						"AM":{"cost":10000, "parent":""},
						
						#Rover Sciences
						"RC":{"cost":250, "parent":""},
						"OL":{"cost":1000, "parent":"RC"},
						"YL":{"cost":8000, "parent":"OL"},
						"GL":{"cost":40000, "parent":"YL"},
						"BL":{"cost":200000, "parent":"GL"},
						"PL":{"cost":800000, "parent":"BL"},
						"UVL":{"cost":2000000, "parent":"PL"},
						"XRL":{"cost":10000000, "parent":"UVL"},
						"GRL":{"cost":30000000, "parent":"XRL"},
						"UGRL":{"cost":200000000, "parent":"GRL"},
						
						#Ship Sciences
						"SCT":{"cost":1500, "parent":"RC"},
						"SUP":{"cost":15000, "parent":"SCT"},
						"CD":{"cost":4000, "parent":"SUP"},
						"ID":{"cost":10000, "parent":"CD"},
						"FD":{"cost":150000, "parent":"ID"},
						"PD":{"cost":1200000, "parent":"FD"},
						
						#Megastructure Sciences
						"MAE":{"cost":100000, "parent":""},
						#Dyson sphere
						"DS1":{"cost":8000000, "parent":"MAE"},
						"DS2":{"cost":250000000, "parent":"DS1"},
						"DS3":{"cost":500000000, "parent":"DS2"},
						"DS4":{"cost":750000000, "parent":"DS3"},
						#Space elevator
						"SE1":{"cost":150000, "parent":"MAE"},
						"SE2":{"cost":500000, "parent":"SE1"},
						"SE3":{"cost":1000000, "parent":"SE2"},
						
}
var infinite_research_sciences = {	"MEE":{"cost":5000, "pw":6.2, "value":1.2},
									"PPE":{"cost":5000, "pw":6.2, "value":1.2},
									"RLE":{"cost":25000, "pw":6.8, "value":1.2},
									"MSE":{"cost":7000, "pw":6.2, "value":1.2},
									"MMS":{"cost":3000, "pw":6.0, "value":1.2},
}

var rover_armor = {	"lead_armor":{"HP":5, "defense":3, "costs":{"lead":40}},
					"copper_armor":{"HP":10, "defense":5, "costs":{"copper":40}},
					"iron_armor":{"HP":15, "defense":7, "costs":{"iron":40}},
					"aluminium_armor":{"HP":20, "defense":9, "costs":{"aluminium":80}},
					"silver_armor":{"HP":25, "defense":11, "costs":{"silver":80}},
					"gold_armor":{"HP":35, "defense":14, "costs":{"gold":100}},
					"gemstone_armor":{"HP":50, "defense":18, "costs":{"amethyst":30, "quartz":30, "topaz":30, "sapphire":30, "emerald":30, "ruby":30}},
}
var rover_wheels = {	"lead_wheels":{"speed":1.0, "costs":{"lead":30}},
						"copper_wheels":{"speed":1.05, "costs":{"copper":30}},
						"iron_wheels":{"speed":1.1, "costs":{"iron":30}},
						"aluminium_wheels":{"speed":1.15, "costs":{"aluminium":60}},
						"silver_wheels":{"speed":1.2, "costs":{"silver":60}},
						"gold_wheels":{"speed":1.3, "costs":{"gold":75}},
						"gemstone_wheels":{"speed":1.4, "costs":{"amethyst":25, "quartz":25, "topaz":25, "sapphire":25, "emerald":25, "ruby":25}},
}
var rover_CC = {	"lead_CC":{"capacity":2500, "costs":{"lead":70}},
					"copper_CC":{"capacity":3500, "costs":{"copper":70}},
					"iron_CC":{"capacity":4000, "costs":{"iron":70}},
					"aluminium_CC":{"capacity":4500, "costs":{"aluminium":100}},
					"silver_CC":{"capacity":5000, "costs":{"silver":100}},
					"gold_CC":{"capacity":6000, "costs":{"gold":140}},
					"gemstone_CC":{"capacity":7000, "costs":{"amethyst":50, "quartz":50, "topaz":50, "sapphire":50, "emerald":50, "ruby":50}},
}
var rover_weapons = {	"red_laser":{"damage":5, "cooldown":0.2, "costs":{"money":3000, "silicon":5, "time":10}},
						"orange_laser":{"damage":10, "cooldown":0.195, "costs":{"money":20000, "silicon":10, "time":60}},
						"yellow_laser":{"damage":22, "cooldown":0.19, "costs":{"money":150000, "silicon":15, "time":360}},
						"green_laser":{"damage":48, "cooldown":0.185, "costs":{"money":900000, "silicon":20, "time":1500}},
						"blue_laser":{"damage":100, "cooldown":0.18, "costs":{"money":2500000, "silicon":50, "quartz":25, "time":4500}},
						"purple_laser":{"damage":185, "cooldown":0.175, "costs":{"money":7500000, "silicon":100, "quartz":50, "time":9000}},
						"UV_laser":{"damage":250, "cooldown":0.17, "costs":{"money":32500000, "silicon":200, "quartz":100, "time":18000}},
						"xray_laser":{"damage":600, "cooldown":0.165, "costs":{"money":125000000, "silicon":500, "quartz":200, "time":30000}},
						"gammaray_laser":{"damage":1250, "cooldown":0.16, "costs":{"money":2500000000, "silicon":1000, "quartz":500, "time":65000}},
						"ultragammaray_laser":{"damage":10000, "cooldown":1, "costs":{"money":20000000000, "silicon":2500, "quartz":1000, "time":100000}},
}#														rnge: mining range
var rover_mining = {	"red_mining_laser":{"speed":1, "rnge":250, "costs":{"money":3000, "silicon":5, "time":10}},
						"orange_mining_laser":{"speed":1.4, "rnge":260, "costs":{"money":20000, "silicon":10, "time":60}},
						"yellow_mining_laser":{"speed":1.9, "rnge":270, "costs":{"money":150000, "silicon":15, "time":360}},
						"green_mining_laser":{"speed":2.5, "rnge":285, "costs":{"money":900000, "silicon":20, "time":1500}},
						"blue_mining_laser":{"speed":3, "rnge":300, "costs":{"money":2500000, "silicon":50, "quartz":25, "time":4500}},
						"purple_mining_laser":{"speed":3.6, "rnge":315, "costs":{"money":7500000, "silicon":100, "quartz":50, "time":9000}},
						"UV_mining_laser":{"speed":4.3, "rnge":330, "costs":{"money":32500000, "silicon":200, "quartz":100, "time":18000}},
						"xray_mining_laser":{"speed":5.1, "rnge":350, "costs":{"money":125000000, "silicon":500, "quartz":200, "time":30000}},
						"gammaray_mining_laser":{"speed":6, "rnge":380, "costs":{"money":2500000000, "silicon":1000, "quartz":500, "time":65000}},
						"ultragammaray_mining_laser":{"speed":10, "rnge":230, "costs":{"money":20000000000, "silicon":2500, "quartz":1000, "time":100000}},
}
var bullet_data = [{"damage":7, "accuracy":1.0}, {"damage":10, "accuracy":1.05}]
var laser_data = [{"damage":4, "accuracy":1.5}, {"damage":6, "accuracy":1.6}]
var bomb_data = [{"damage":12, "accuracy":0.7}, {"damage":16, "accuracy":0.72}]
var light_data = [{"damage":3, "accuracy":1.2}, {"damage":5, "accuracy":1.25}]
