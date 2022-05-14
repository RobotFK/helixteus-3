extends Node

var mod_list = {}
var added_buildings = {}
var added_mats = {}
var added_mets = {}
var added_picks = {}

func _ready():
	var mods = Directory.new()
	var error = mods.open("user://Mods")
	if error == OK:
		mods.list_dir_begin(true)
		var next = mods.get_next()
		while next != "":
			print(next)
			if ProjectSettings.load_resource_pack("user://Mods/%s" % next, true):
				next = next.rstrip(".zip")
				next = next.rstrip(".pck")
				var main = load("res://%s/Main.gd" % next)
				main = main.new()
				main.phase_1()
				mod_list[next] = main
			next = mods.get_next()
		mods.list_dir_end()
	else:
		mods.make_dir("user://Mods")
	
	update()

func add_building(b, data):
	added_buildings[b] = data
	
	var trans = Translation.new()
	trans.add_message(b + "_NAME", data.name)
	trans.add_message(b + "_DESC", data.desc)
	TranslationServer.add_translation(trans)

func add_mat(mat, data):
	added_mats[mat] = data

func add_met(met, data):
	added_mets[met] = data

func add_pick(p, data):
	added_picks[p] = data

func update():
	for key in added_buildings:
		Data.costs[key] = added_buildings[key].costs
		if added_buildings[key].has("path_1"):
			Data.path_1[key] = added_buildings[key].path_1
		if added_buildings[key].has("path_2"):
			Data.path_2[key] = added_buildings[key].path_2
		if added_buildings[key].has("path_3"):
			Data.path_3[key] = added_buildings[key].path_3
		
		if added_buildings[key].has("rsrc_icon"):
			Data.rsrc_icons[key] = added_buildings[key].rsrc_icon
