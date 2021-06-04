extends "Panel.gd"

var tile
var atom_to_p:bool = true#MM: material or metal
var difficulty:float#Amount of time per unit of atom/metal
var energy_cost:float
var reaction:String = ""
var au_mult:float
var Z:int
var atom_costs:Dictionary = {}
var reactions:Dictionary = {	"H":{"Z":1, "energy_cost":200, "difficulty":0.01},
								"He":{"Z":2, "energy_cost":1000, "difficulty":0.015},
								"Ne":{"Z":10, "energy_cost":40000, "difficulty":2},
								"Xe":{"Z":54, "energy_cost":3000000, "difficulty":40},
								"Pu":{"Z":94, "energy_cost":14000000000, "difficulty":8000},
}

func _ready():
	set_process(false)
	set_polygon($Background.rect_size)
	$Title.text = tr("SPR_NAME")
	$Desc.text = tr("REACTIONS_PANEL_DESC")
	for _name in reactions:
		var btn = Button.new()
		btn.name = _name
		btn.rect_min_size.y = 30
		btn.expand_icon = true
		btn.text = tr("%s_NAME" % _name.to_upper())
		btn.connect("pressed", self, "_on_Atom_pressed", [_name])
		$ScrollContainer/VBoxContainer.add_child(btn)


func _on_Atom_pressed(_name:String):
	reset_poses(_name, reactions[_name].Z)
	energy_cost = reactions[_name].energy_cost
	difficulty = reactions[_name].difficulty
	refresh()

func refresh():
	tile = game.tile_data[game.c_t]
	au_mult = Helper.get_au_mult(tile)
	$Control/EnergyCostText.text = Helper.format_num(round(energy_cost * $Control/HSlider.value))
	$Control/TimeCostText.text = Helper.time_to_str(difficulty * $Control/HSlider.value * 1000 / tile.bldg.path_1_value)
	for reaction_name in reactions:
		var disabled:bool = false
		if game.particles.proton == 0 or game.particles.neutron == 0 or game.particles.electron == 0:
			disabled = true
		disabled = disabled and game.atoms[reaction_name] == 0 and (not tile.bldg.has("qty") or not tile.bldg.reaction == reaction_name)
		$ScrollContainer/VBoxContainer.get_node(reaction_name).disabled = disabled
	refresh_icon()
	if reaction == "":
		return
	set_process($Control3.visible)
	var max_value:float = 0.0
	if atom_to_p:
		max_value = game.atoms[reaction]
	else:
		for particle in game.particles:
			var max_value2 = game.particles[particle] / Z
			if max_value2 < max_value or max_value == 0.0:
				max_value = max_value2
	$Control/HSlider.max_value = max_value
	$Control/HSlider.step = int(max_value / 100.0)
	$Control/HSlider.visible = $Control/HSlider.max_value != 0
	if $Control3.visible:
		$Transform.visible = true
		$Transform.text = "%s (G)" % tr("STOP")
	else:
		$Transform.visible = $Control/HSlider.max_value != 0 and not tile.bldg.has("qty")
		$Transform.text = "%s (G)" % tr("TRANSFORM")
	#$Control/HSlider.value = $Control/HSlider.max_value

func reset_poses(_name:String, _Z:int):
	for btn in $ScrollContainer/VBoxContainer.get_children():
		btn["custom_colors/font_color"] = null
		btn["custom_colors/font_color_hover"] = null
		btn["custom_colors/font_color_pressed"] = null
		btn["custom_colors/font_color_disabled"] = null
	$ScrollContainer/VBoxContainer.get_node(_name)["custom_colors/font_color"] = Color(0, 1, 1, 1)
	$ScrollContainer/VBoxContainer.get_node(_name)["custom_colors/font_color_hover"] = Color(0, 1, 1, 1)
	$ScrollContainer/VBoxContainer.get_node(_name)["custom_colors/font_color_pressed"] = Color(0, 1, 1, 1)
	$ScrollContainer/VBoxContainer.get_node(_name)["custom_colors/font_color_disabled"] = Color(0, 1, 1, 1)
	reaction = _name
	Z = _Z
	#atom_to_p = true
	$Control2.visible = true
	#$Control2/From.rect_position = Vector2(480, 240)
	#$Control2/To.rect_position = Vector2(772, 240)
	$Control3.visible = tile.bldg.has("qty") and tile.bldg.reaction == reaction
	$Control.visible = not $Control3.visible
	if $Control3.visible and not tile.bldg.atom_to_p:
		_on_Switch_pressed(false)
	#_on_HSlider_value_changed(0)

func _on_Switch_pressed(refresh:bool = true):
	var pos = $Control2/To.rect_position
	$Control2/To.rect_position = $Control2/ScrollContainer.rect_position
	$Control2/ScrollContainer.rect_position = pos
	atom_to_p = not atom_to_p
	if refresh:
		#_on_HSlider_value_changed($Control/HSlider.value)
		refresh()

func _on_HSlider_value_changed(value):
	var atom_dict = {}
	var p_costs = {"proton":value, "neutron":value, "electron":value}
	for particle in p_costs:
		p_costs[particle] *= Z
	atom_dict[reaction] = value
	Helper.put_rsrc($Control2/ScrollContainer/From, 32, atom_dict, true, atom_to_p)
	Helper.put_rsrc($Control2/To, 32, p_costs, true, not atom_to_p)
	refresh()

func _on_Transform_pressed():
	if tile.bldg.has("qty"):
		set_process(false)
		var reaction_info = Helper.get_reaction_info(tile)
		var MM_value = reaction_info.MM_value
		var progress = reaction_info.progress
		var rsrc_to_add:Dictionary
		var num
		if tile.bldg.atom_to_p:
			rsrc_to_add[reaction] = max(0, tile.bldg.qty - MM_value)
			num = MM_value * Z
		else:
			rsrc_to_add[reaction] = MM_value
			num = max(0, tile.bldg.qty - MM_value) * Z
		rsrc_to_add.proton = num
		rsrc_to_add.neutron = num
		rsrc_to_add.electron = num
		rsrc_to_add.energy = round((1 - progress) * energy_cost / au_mult * tile.bldg.qty)
		game.add_resources(rsrc_to_add)
		tile.bldg.erase("qty")
		tile.bldg.erase("start_date")
		tile.bldg.erase("reaction")
		tile.bldg.erase("difficulty")
		$Control.visible = true
		$Control3.visible = false
		refresh_icon()
#		$Transform.text = "%s (G)" % tr("TRANSFORM")
		#_on_HSlider_value_changed($Control/HSlider.value)
	else:
		var rsrc = $Control/HSlider.value
		if rsrc == 0:
			return
		var rsrc_to_deduct = {}
		if atom_to_p:
			rsrc_to_deduct[reaction] = rsrc
		else:
			rsrc_to_deduct = {"proton":rsrc * Z, "neutron":rsrc * Z, "electron":rsrc * Z}
		rsrc_to_deduct.energy = round(energy_cost * rsrc / au_mult)
		if not game.check_enough(rsrc_to_deduct):
			game.popup(tr("NOT_ENOUGH_RESOURCES"), 1.5)
			return
		game.deduct_resources(rsrc_to_deduct)
		tile.bldg.qty = rsrc
		tile.bldg.start_date = OS.get_system_time_msecs()
		tile.bldg.reaction = reaction
		tile.bldg.difficulty = difficulty
		tile.bldg.atom_to_p = atom_to_p
		for rsrc2 in game.view.obj.rsrcs:
			if rsrc2.id == game.c_t:
				rsrc2.node.get_node("TextureRect").texture = load("res://Graphics/Atoms/%s.png" % reaction)
				break
		set_process(true)
		$Control.visible = false
		$Control3.visible = true
		refresh_icon()
#		$Transform.text = "%s (G)" % tr("STOP")
	refresh()
	game.HUD.refresh()

func _process(delta):
	if not tile or tile.empty():
		_on_close_button_pressed()
		set_process(false)
		return
	if not tile.bldg.has("start_date"):
		set_process(false)
		return
	var reaction_info = Helper.get_reaction_info(tile)
	#MM produced or MM used
	var MM_value = reaction_info.MM_value
	$Control3/TextureProgress.value = reaction_info.progress
	var MM_dict = {}
	var atom_dict:Dictionary = {}
	var num
	if tile.bldg.atom_to_p:
		num = MM_value * Z
		atom_dict[reaction] = max(0, tile.bldg.qty - MM_value)
	else:
		num = max(0, tile.bldg.qty - MM_value) * Z
		atom_dict[reaction] = MM_value
	MM_dict = {"proton":num, "neutron":num, "electron":num}
	Helper.put_rsrc($Control2/ScrollContainer/From, 32, atom_dict)
	Helper.put_rsrc($Control2/To, 32, MM_dict)
	$Control3/TimeRemainingText.text = Helper.time_to_str(max(0, difficulty * (tile.bldg.qty - MM_value) * 1000 / tile.bldg.path_1_value))

func refresh_icon():
	for r in $ScrollContainer/VBoxContainer.get_children():
		r.icon = Data.time_icon if tile.bldg.has("reaction") and r.name == tile.bldg.reaction else null
