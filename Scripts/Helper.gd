extends Node
#A place to put frequently used functions

@onready var game = get_node("/root/Game")
#var game
var notation:int = 1#0: standard, 1: SI, 2: scientific

func set_btn_color(btn):
	if not btn.get_parent_control():
		return
	for other_btn in btn.get_parent_control().get_children():
		other_btn["theme_override_colors/font_color"] = Color(1, 1, 1, 1)
		other_btn["theme_override_colors/font_color_hover"] = Color(1, 1, 1, 1)
		other_btn["theme_override_colors/font_color_pressed"] = Color(1, 1, 1, 1)
	btn["theme_override_colors/font_color"] = Color(0, 1, 1, 1)
	btn["theme_override_colors/font_color_hover"] = Color(0, 1, 1, 1)
	btn["theme_override_colors/font_color_pressed"] = Color(0, 1, 1, 1)

#put_rsrc helper function
func format_text(text_node, texture, path:String, show_available:bool, rsrc_cost, rsrc_available, mass_str:String = "", threshold:int = 6):
	texture.texture_normal = load("res://Graphics/" + path + ".png")
	var text:String
	var color:Color = Color(1.0, 1.0, 1.0, 1.0)
	if show_available:
		if path == "Icons/stone" and rsrc_available is Dictionary:
			rsrc_available = get_sum_of_dict(rsrc_available)
		text = "%s/%s" % [format_num(clever_round(rsrc_available, 3, false, true), threshold / 2), format_num(clever_round(rsrc_cost, 3, false, true), threshold / 2)] + mass_str
		if rsrc_available >= rsrc_cost:
			color = Color(0.0, 1.0, 0.0, 1.0)
		else:
			color = Color(1.0, 0.0, 0.0, 1.0)
	else:
		if path == "Icons/stone" and rsrc_cost is Dictionary:
			rsrc_cost = get_sum_of_dict(rsrc_cost)
		var minus:String = "-" if rsrc_cost < 0 else ""
		rsrc_cost = abs(rsrc_cost)
		var num_str:String = e_notation(rsrc_cost) if rsrc_cost < 0.0001 else format_num(clever_round(rsrc_cost, 3, false, true), threshold)
		if rsrc_cost == 0:
			num_str = "0"
		text = "%s%s%s" % [minus, num_str, mass_str]
	text_node.text = text
	text_node["theme_override_colors/font_color"] = color

func put_rsrc(container, min_size, objs, remove:bool = true, show_available:bool = false, mouse_events:bool = true):
	if remove:
		for child in container.get_children():
			child.free()
	var data = []
	for obj in objs:
		var rsrc = game.rsrc_scene.instantiate()
		var texture = rsrc.get_node("Texture2D")
		var atom:bool = false
		var tooltip:String = tr(obj.to_upper())
		if obj == "money":
			format_text(rsrc.get_node("Text"), texture, "Icons/money", show_available, objs[obj], game.money)
		elif obj == "stone":
			if tooltip == "Stone" and game.op_cursor:
				tooltip = "Rok"
			if not game.show.has("mining"):
				tooltip += "\n%s" % [tr("STONE_HELP")]
			format_text(rsrc.get_node("Text"), texture, "Icons/stone", show_available, objs[obj], game.stone, " kg")
		elif obj == "minerals":
			format_text(rsrc.get_node("Text"), texture, "Icons/minerals", show_available, objs[obj], game.minerals)
		elif obj == "energy":
			format_text(rsrc.get_node("Text"), texture, "Icons/energy", show_available, objs[obj], game.energy)
		elif obj == "SP":
			format_text(rsrc.get_node("Text"), texture, "Icons/SP", show_available, objs[obj], game.SP)
		elif obj == "time":
			texture.texture_normal = Data.time_icon
			rsrc.get_node("Text").text = time_to_str(objs[obj])
		elif game.mats.has(obj):
			if obj == "silicon" and not game.show.has("silicon"):
				tooltip += "\n%s" % [tr("HOW2SILICON")]
			format_text(rsrc.get_node("Text"), texture, "Materials/" + obj, show_available, objs[obj], game.mats[obj], " kg")
		elif game.mets.has(obj):
			format_text(rsrc.get_node("Text"), texture, "Metals/" + obj, show_available, objs[obj], game.mets[obj], " kg")
		elif game.atoms.has(obj):
			atom = true
			tooltip = tr(("%s_NAME" % obj).to_upper())
			format_text(rsrc.get_node("Text"), texture, "Atoms/" + obj, show_available, objs[obj], game.atoms[obj], " mol")
		elif game.particles.has(obj):
			format_text(rsrc.get_node("Text"), texture, "Particles/" + obj, show_available, objs[obj], game.particles[obj], " mol")
		else:
			for item_group_info in game.item_groups:
				if item_group_info.dict.has(obj):
					format_text(rsrc.get_node("Text"), texture, item_group_info.path + "/" + obj, show_available, objs[obj], game.get_item_num(obj))
		if mouse_events:
			rsrc.get_node("Texture2D").connect("mouse_entered",Callable(self,"on_rsrc_over").bind(tooltip))
			rsrc.get_node("Texture2D").connect("mouse_exited",Callable(self,"on_rsrc_out"))
		texture.custom_minimum_size = Vector2(1, 1) * min_size
		container.add_child(rsrc)
		data.append({"rsrc":rsrc, "name":obj})
	return data

func on_rsrc_over(st:String):
	game.show_tooltip(st)

func on_rsrc_out():
	game.hide_tooltip()

#Converts time in seconds to string format
func time_to_str (time:float): # time is in seconds
	if time < 0:
		time = 0
	var seconds = int(floor(time)) % 60
	var second_zero = "0" if seconds < 10 else ""
	var minutes = int(floor(time / 60)) % 60
	var minute_zero = "0" if minutes < 10 else ""
	var hours = int(floor(time / 3600)) % 24
	var days = int(floor (time / 86400)) % 365
	var years = int(floor (time / 31536000))
	var year_str = "" if years == 0 else ("%s%s " % [years, tr("YEARS")])
	var day_str = "" if days == 0 else ("%s%s " % [days, tr("DAYS")])
	var hour_str = "" if hours == 0 else ("%s:" % hours)
	return "%s%s%s%s%s:%s%s" % [year_str, day_str, hour_str, minute_zero, minutes, second_zero, seconds]

#Returns a random integer between low and high inclusive
func rand_int(low:int, high:int):
	return randi() % (high - low + 1) + low

func log10(n):
	return log(n) / log(10)

func get_state(T:float, P:float, node):
	var v = node.get_pos_from_TP(T, P)
	if Geometry2D.is_point_in_polygon(v, node.get_node("Superfluid").polygon):
		return "sc"
	elif Geometry2D.is_point_in_polygon(v, node.get_node("Liquid").polygon):
		return "l"
	elif Geometry2D.is_point_in_polygon(v, node.get_node("Gas").polygon):
		return "g"
	else:
		return "s"

func set_visibility(node):
	for other_node in node.get_parent_control().get_children():
		other_node.visible = false
	node.visible = true

func get_item_name (_name:String):
	if _name.substr(0, 7) == "speedup":
		return tr(game.speedups_info[_name].name) % game.speedups_info[_name].name_param
	if _name.substr(0, 9) == "overclock":
		return tr("OVERCLOCK") + " " + get_roman_num(int(_name[9]))
	if _name.substr(0, 5) == "drill":
		return tr("DRILL") + " " + get_roman_num(int(_name[5]))
	if _name.substr(0, 17) == "portable_wormhole":
		return tr("PORTABLE_WORMHOLE") + " " + get_roman_num(int(_name[17]))
	if len(_name.split("_")) > 1 and _name.split("_")[1] == "seeds":
		return tr("X_SEEDS") % tr(_name.split("_")[0].to_upper())
	return tr(_name.to_upper())

func get_plant_name(name:String):
	return tr("PLANT_TITLE").format({"metal":tr(name.split("_")[0].to_upper())})

func get_wid(size:float):
	return min(round(pow(size / 6000.0, 0.7) * 8.0) + 3, 100)

func e_notation(num:float, sd:int = 4):#e notation
	if num == 0:
		return "0"
	var e = floor(log10(num))
	var n = num * pow(10, -e)
	var n2 = clever_round(n, sd)
	if n2 == 10:
		n2 = 1
		e += 1
	return "%se%s" %  [n2, e]

func get_dir_from_name(_name:String):
	if get_type_from_name(_name) == "speedups_info":
		return "Items/Speedups"
	if get_type_from_name(_name) == "overclocks_info":
		return "Items/Overclocks"
	if get_type_from_name(_name) == "other_items_info":
		return "Items/Others"
	if get_type_from_name(_name) == "seeds_produce":
		return "Agriculture"
	if get_type_from_name(_name) == "craft_mining_info":
		return "Mining"
	if get_type_from_name(_name) == "craft_cave_info":
		return "Cave"
	match _name:
		"money":
			return "Icons"
		"minerals":
			return "Icons"
	return ""

func get_type_from_name(_name:String):
	if game.speedups_info.keys().has(_name):
		return "speedups_info"
	if game.overclocks_info.keys().has(_name):
		return "overclocks_info"
	if game.other_items_info.keys().has(_name):
		return "other_items_info"
	if game.seeds_produce.keys().has(_name):
		return "seeds_produce"
	if game.craft_mining_info.keys().has(_name):
		return "craft_mining_info"
	if game.craft_cave_info.keys().has(_name):
		return "craft_cave_info"
	return ""

func format_num(num:float, clever_round:bool = false, threshold:int = 6):
	if clever_round:
		num = clever_round(num)
	var sgn = ""
	if num < 0:
		num *= -1
		sgn = "-"
	if num < pow(10, threshold):
		var string = str(num)
		var arr = string.split(".")
		if len(arr) == 1:
			arr.append("")
		else:
			arr[1] = "." + arr[1]
		var mod = arr[0].length() % 3
		var res = ""
		for i in range(0, arr[0].length()):
			if i != 0 and i % 3 == mod:
				res += ","
			res += string[i]
		return sgn + res + arr[1]
	else:
		var suff:String = ""
		var p:float = log(num) / log(10)
		if is_equal_approx(p, ceil(p)):
			p = ceil(p)
		else:
			p = int(p)
		var div = max(pow(10, snapped(p - 1, 3)), 1)
		if notation == 2 and p >= 3 or p >= 33:
			return e_notation(num, 3)
		if p >= 3 and p < 6:
			suff = "k"
		elif p < 9:
			suff = "M"
		elif p < 12:
			suff = "G" if notation == 1 else "B"
		elif p < 15:
			suff = "T"
		elif p < 18:
			suff = "P" if notation == 1 else "q"
		elif p < 21:
			suff = "E" if notation == 1 else "Q"
		elif p < 24:
			suff = "Z" if notation == 1 else "s"
		elif p < 27:
			suff = "Y" if notation == 1 else "S"
		elif p < 30:
			suff = "R" if notation == 1 else "O"
		elif p < 33:
			suff = "Q" if notation == 1 else "N"
		return "%s%s%s" % [sgn, clever_round(num / div, 3), suff]

#Assumes that all values of dict are floats/integers
func get_sum_of_dict(dict:Dictionary):
	var sum = 0
	for el in dict.values():
		sum += el
	return sum

func get_el_color(element:String):
	match element:
		"O":
			return Color(1, 0.2, 0.2, 1)
		"Si":
			return Color(0.7, 0.7, 0.7, 1)
		"Ca":
			return Color(0.8, 1, 0.8, 1)
		"Al":
			return Color(0.6, 0.6, 0.6, 1)
		"Mg":
			return Color(0.69, 0.69, 0.53, 1)
		"Na":
			return Color(0.92, 0.98, 1, 1)
		"Ni":
			return Color(0.8, 0.8, 0.8, 1)
		"H", "Fe":
			return Color(0.9, 0.9, 0.9, 1)
		"He":
			return Color(0.8, 0.5, 1.0, 1)
		"H2O":
			return Color(0.2, 0.7, 1.0, 1)
		"C":
			return Color(0.15, 0.15, 0.15, 1)
		_:
			return Color(randf() * 0.5, randf() * 0.5, randf() * 0.5, 1)

func mult_dict_by(dict:Dictionary, value:float):
	var dict2:Dictionary = dict.duplicate(true)
	for el in dict:
		dict2[el] = dict[el] * value
	return dict2

func get_crush_info(tile_obj):
	var time = Time.get_unix_time_from_system()
	var crush_spd = tile_obj.bldg.path_1_value * game.u_i.time_speed
	var constr_delay = 0
	if tile_obj.bldg.has("is_constructing"):
		constr_delay = tile_obj.bldg.construction_date + tile_obj.bldg.construction_length - time
	var progress = max(0, (time - tile_obj.bldg.start_date + constr_delay) * crush_spd / tile_obj.bldg.stone_qty)
	var qty_left = max(0, round(tile_obj.bldg.stone_qty - (time - tile_obj.bldg.start_date + constr_delay) * crush_spd))
	return {"crush_spd":crush_spd, "progress":progress, "qty_left":qty_left}

func get_prod_info(tile_obj):
	var time = Time.get_unix_time_from_system()
	var spd = tile_obj.bldg.path_1_value * game.u_i.time_speed * get_IR_mult(tile_obj.bldg.name)
	#qty1: resource being used. qty2: resource being produced
	var qty_left = clever_round(max(0, tile_obj.bldg.qty1 - (time - tile_obj.bldg.start_date) * spd / tile_obj.bldg.ratio))
	var qty_made = clever_round(min(tile_obj.bldg.qty2, (time - tile_obj.bldg.start_date) * spd))
	var progress = qty_made / tile_obj.bldg.qty2#1 = complete
	return {"spd":spd, "progress":progress, "qty_made":qty_made, "qty_left":qty_left}

var overlay_rsrc = preload("res://Graphics/Elements/Default.png")
func add_overlay(parent, self_node, c_v:String, obj_info, overlays:Array):
	var overlay_texture = overlay_rsrc
	var overlay = TextureButton.new()
	overlay.texture_normal = overlay_texture
	overlay.visible = false
	parent.add_child(overlay)
	var id
	var l_id
	if obj_info is Array:
		id = obj_info[0]
		l_id = obj_info[1]
	else:
		id = obj_info.id
		l_id = obj_info.l_id
	overlays.append({"circle":overlay, "id":l_id})
	overlay.connect("mouse_entered",Callable(self_node,"on_%s_over" % [c_v]).bind(l_id))
	overlay.connect("mouse_exited",Callable(self_node,"on_%s_out" % [c_v]))
	overlay.connect("pressed",Callable(self_node,"on_%s_click" % [c_v]).bind(id, l_id))
	overlay.position = Vector2(-300 / 2, -300 / 2)
	overlay.pivot_offset = Vector2(300 / 2, 300 / 2)

func toggle_overlay(obj_btns, overlays, overlay_visible):
	for obj_btn in obj_btns:
		obj_btn.visible = not overlay_visible
	for overlay in overlays:
		overlay.circle.visible = overlay_visible and overlay.circle.modulate.a == 1.0

func change_circle_size(value, overlays):
	for overlay in overlays:
		overlay.circle.scale.x = 2 * value
		overlay.circle.scale.y = 2 * value

func save_obj(type:String, id:int, arr):
	var file_path:String = "user://%s/Univ%s/%s/%s.hx3" % [game.c_sv, game.c_u, type, id]
	var save = FileAccess.open(file_path, FileAccess.WRITE)
	save.store_var(arr)
	save.close()

func get_rover_weapon_text(_name:String):
	return "%s\n%s\n%s" % [get_rover_weapon_name(_name), "%s: %s" % [tr("DAMAGE"), Data.rover_weapons[_name].damage], "%s: %s%s" % [tr("COOLDOWN"), Data.rover_weapons[_name].cooldown, tr("S_SECOND")]]

func get_rover_weapon_name(_name:String):
	var laser = _name.split("_")
	return tr(laser[0].to_upper() + "_LASER").format({"laser":tr(laser[1])})

func get_rover_mining_text(_name:String):
	return "%s\n%s\n%s" % [get_rover_mining_name(_name), "%s: %s" % [tr("MINING_SPEED"), Data.rover_mining[_name].speed], "%s: %s" % [tr("RANGE"), Data.rover_mining[_name].rnge]]

func get_rover_mining_name(_name:String):
	var laser = _name.split("_", true, 1)
	return tr(laser[0].to_upper() + "_LASER").format({"laser":tr(laser[1].to_upper())})

func set_back_btn(back_btn):
	back_btn.text = "<- %s (%s)" % [tr("BACK"), OS.get_keycode_string(DisplayServer.keyboard_get_keycode_from_physical(KEY_Z))]

func show_dmg(dmg:float, pos:Vector2, parent, size:int = 40, missed:bool = false, crit:bool = false):
	var lb:Label = Label.new()
	#lb["custom_fonts/font"] = dmg_txt_rsrc
	lb.light_mask = 0
	if missed:
		lb["theme_override_colors/font_color"] = Color(1, 1, 0, 1)
		lb.text = tr("MISSED")
	else:
		lb["theme_override_colors/font_color"] = Color(1, 0.2, 0.2, 1)
		lb.text = "- %s" % format_num(dmg)
		if crit:
			lb.text = "%s\n- %s" % [tr("CRITICAL"), format_num(dmg)]
		else:
			lb.text = "- %s" % format_num(dmg)
	lb["theme_override_colors/font_outline_color"] = Color.BLACK
	lb["theme_override_constants/outline_size"] = 3
	lb.position = pos - Vector2(0, 40)
	lb["theme_override_font_sizes/font_size"] = size
	parent.add_child(lb)
	var dur = 1.5 if crit else 1.0
	if game:
		dur /= game.u_i.time_speed
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(lb, "modulate", Color(1, 1, 1, 0), dur)
	tween.tween_property(lb, "position", pos - Vector2(0, 55), dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_callback(lb.queue_free).set_delay(dur)
	#lb.light_mask = 2

func add_minerals(amount:float, add:bool = true):
	var min_cap = 200 + (game.mineral_capacity - 200) * get_IR_mult("MS")
	var mineral_space_available:float = round(min_cap) - round(game.minerals)
	if mineral_space_available >= amount:
		if add:
			game.minerals += amount
		return {"added":amount, "remainder":0}
	else:
		if game.science_unlocked.has("ASM2") and game.autosell:
			if add:
				game.add_resources({"money":(game.minerals + amount - min_cap) * (game.MUs.MV + 4)})
				game.minerals = min_cap
			return {"added":amount, "remainder":0}
		elif game.science_unlocked.has("ASM") and game.autosell:
			if add:
				var diff:float = round(amount) - round(mineral_space_available)
				game.minerals = fmod(diff, round(min_cap))
				game.add_resources({"money":max(1, ceil(diff / min_cap)) * round(min_cap) * (game.MUs.MV + 4)})
			return {"added":amount, "remainder":0}
		else:
			if add:
				game.minerals = min_cap
			return {"added":mineral_space_available, "remainder":amount - mineral_space_available}

func get_total_energy_cap():
	return 7500 + (game.energy_capacity - 7500) * get_IR_mult("B") + game.capacity_bonus_from_substation * get_IR_mult("PP") * game.u_i.time_speed

func add_energy(amount:float):
	var energy_cap = get_total_energy_cap()
	var energy_space_available:float = round(energy_cap) - round(game.energy)
	if energy_space_available >= amount:
		game.energy += amount
		return {"added":amount, "remainder":0}
	else:
		game.energy = energy_cap
		return {"added":energy_space_available, "remainder":amount - energy_space_available}

func get_au_mult(tile:Dictionary):
	if tile.has("aurora"):
		return 1.0 + tile.aurora.au_int
	else:
		return 1.0

func get_layer(tile:Dictionary, p_i:Dictionary):
	var layer:String = ""
	if tile.has("crater") and tile.crater.has("init_depth"):
		layer = "crater"
	elif tile.depth <= p_i.crust_start_depth:
		layer = "surface"
	elif tile.depth <= p_i.mantle_start_depth:
		layer = "crust"
	elif tile.depth <= p_i.core_start_depth:
		layer = "mantle"
	else:
		layer = "core"
	return layer

func get_rock_layer(tile:Dictionary, p_i:Dictionary):
	var layer:String = ""
	if tile.depth <= p_i.mantle_start_depth:
		layer = "crust"
	elif tile.depth <= p_i.core_start_depth:
		layer = "mantle"
	else:
		layer = "core"
	return layer

func get_rsrc_from_rock(contents:Dictionary, tile:Dictionary, p_i:Dictionary, is_MM:bool = false):
	var layer:String = get_layer(tile, p_i)
	for content in contents:
		var amount = contents[content]
		if game.mats.has(content):
			game.mats[content] += amount
			if not game.show.has("plant_button") and content == "soil":
				game.show.plant_button = true
			if game.help.has("materials"):
				if not is_MM:
					game.popup_window(tr("YOU_MINED_MATERIALS"), tr("MATERIALS"))
				game.help.erase("materials")
			if not game.show.has("materials"):
				game.show.materials = true
				game.HUD.craft.visible = true
				game.inventory.get_node("TabBar/Materials").visible = true
		elif game.mets.has(content):
			if not game.help.has("metals"):
				if not is_MM:
					game.popup_window(tr("YOU_MINED_METALS"), tr("METALS"))
				game.help.metals = true
			if not game.show.has("metals"):
				game.show.metals = true
				game.inventory.get_node("TabBar/Metals").visible = true
			game.mets[content] += amount
		elif content == "stone":
			game.add_resources({"stone":contents.stone})
		elif content == "ship_locator":
			if not game.objective.is_empty() and game.objective.type == game.ObjectiveType.SIGNAL and game.objective.id == 11:
				game.objective.current += 1
			game.second_ship_hints.ship_locator = true
			tile.erase("ship_locator_depth")
		else:
			game[content] += amount
		if tile.has("artifact") and tile.depth >= 5000:
			game.fourth_ship_hints.artifact_found = true
			tile.erase("artifact")
			if game.fourth_ship_hints.boss_rekt:
				game.popup_window("%s\n%s" % [tr("ARTIFACT_FOUND_DESC"), tr("ARTIFACT_FOUND_DESC2")], tr("ARTIFACT_FOUND"))
			else:
				game.popup_window(tr("ARTIFACT_FOUND_DESC"), tr("ARTIFACT_FOUND"))
		if not game.show.has(content):
			game.show[content] = true
		if content == "sand" and not game.new_bldgs.has("GF"):
			game.new_bldgs.GF = true
		if content == "coal" and not game.new_bldgs.has("SE"):
			game.new_bldgs.SE = true
		if content == "stone" and not game.new_bldgs.has("SC"):
			game.new_bldgs.SC = true
	if tile.has("current_deposit") and tile.current_deposit.progress > tile.current_deposit.size - 1:
		tile.erase("current_deposit")
	if tile.has("crater") and tile.crater.has("init_depth") and tile.depth > 3 * tile.crater.init_depth:
		tile.erase("crater")

func mass_generate_rock(tile:Dictionary, p_i:Dictionary, depth:int):
	var aurora_mult = clever_round(get_au_mult(tile))
	var h_mult = game.u_i.planck
	var contents = {}
	var other_volume = 0#in m^3
	#We assume all materials have a density of 1.5g/cm^3 to simplify things
	var rho = 1.5
	#Material quantity penalty the further you go from surface
	var depth_limit_mult = max(1, 1 + (((2 * tile.depth + depth) / 2.0) - p_i.crust_start_depth) / float(p_i.crust_start_depth))
	for mat in p_i.surface.keys():
		var chance_mult:float = min(p_i.surface[mat].chance / depth_limit_mult * aurora_mult, 1)
		var amount = p_i.surface[mat].amount * randf_range(0.8, 1.2) / depth_limit_mult * aurora_mult * chance_mult * depth * h_mult
		if amount < 1:
			continue
		contents[mat] = amount
		other_volume += amount / rho / 1000
	for met in game.met_info:
		var met_info = game.met_info[met]
		var chance_mult:float = 0.25 * aurora_mult
		var amount:float
		if tile.has("crater") and met == tile.crater.metal:
			chance_mult = min(7.0 / (7.0 + 1 / (chance_mult * 6.0)), 1)
			amount = randf_range(0.2, 0.225) * min(depth, 2 * tile.crater.init_depth)
		else:
			chance_mult = min(7.0 / (7.0 + 1 / chance_mult), 1)
			var end_depth:int = tile.depth + depth
			var met_start_depth:int = met_info.min_depth + p_i.crust_start_depth
			var met_end_depth:int = met_info.max_depth + p_i.crust_start_depth
			var num_tiles:int = end_depth - met_start_depth
			var num_tiles2:int = met_end_depth - tile.depth
			var num_tiles3:int = clamp(min(num_tiles, num_tiles2), 0, min(depth, met_end_depth - met_start_depth))
			amount = randf_range(0.4, 0.45) * num_tiles3
		amount *= 20 * chance_mult * aurora_mult * h_mult / pow(met_info.rarity, 0.5)
		if amount < 1:
			continue
		contents[met] = amount
		other_volume += amount / met_info.density / 1000 / h_mult
		#   									                          	    V Every km, rock density goes up by 0.01
	var stone_amount = max(0, clever_round((depth - other_volume) * 1000 * (2.85 + (2 * min(tile.depth + depth, 1000.0 * p_i.size / 2.0)) / 200000.0) * h_mult))
	contents.stone = get_stone_comp_from_amount(p_i[get_rock_layer(tile, p_i)], stone_amount)
	return contents

func get_stone_comp_from_amount(p_i_layer:Dictionary, amount:float):
	var stone = {}
	for comp in p_i_layer:
		stone[comp] = p_i_layer[comp] * amount
	return stone

func generate_rock(tile:Dictionary, p_i:Dictionary):
	var aurora_mult = clever_round(get_au_mult(tile))
	var h_mult = game.u_i.planck
	var contents = {}
	var other_volume = 0#in m^3
	#We assume all materials have a density of 1.5g/cm^3 to simplify things
	var rho = 1.5
	#Material quantity penalty the further you go from surface
	var depth_limit_mult = max(1, 1 + (tile.depth - p_i.crust_start_depth) / float(p_i.crust_start_depth))
	if depth_limit_mult > 0.01:
		for mat in p_i.surface.keys():
			if p_i.has("tile_num"):
				var amount = p_i.surface[mat].amount * p_i.surface[mat].chance / depth_limit_mult * h_mult
				contents[mat] = amount
				other_volume += amount / rho / 1000 / h_mult
			elif randf() < p_i.surface[mat].chance / depth_limit_mult * aurora_mult:
				var amount = clever_round(p_i.surface[mat].amount * randf_range(0.8, 1.2) / depth_limit_mult * aurora_mult * h_mult)
				if amount < 1:
					continue
				contents[mat] = amount
				other_volume += amount / rho / 1000 / h_mult
	if get_layer(tile, p_i) != "surface" and not tile.has("current_deposit"):
		for met in game.met_info:
			var crater_metal = tile.has("crater") and tile.crater.has("init_depth") and met == tile.crater.metal
			if game.met_info[met].min_depth < tile.depth - p_i.crust_start_depth and tile.depth - p_i.crust_start_depth < game.met_info[met].max_depth or crater_metal:
				if randf() < 0.25 * (6 if crater_metal else 1) * aurora_mult / pow(game.met_info[met].rarity, 0.2):
					tile.current_deposit = {"met":met, "size":rand_int(4, 10), "progress":1}
	if tile.has("current_deposit"):
		var met = tile.current_deposit.met
		var size = tile.current_deposit.size
		var progress2 = tile.current_deposit.progress
		var amount_multiplier = -abs(2.0/size * progress2 - 1) + 1
		var crater_metal = tile.has("crater") and tile.crater.has("init_depth") and met == tile.crater.metal
		var amount = clever_round(20 * (3 if crater_metal else 1) * randf_range(0.4, 0.45) * amount_multiplier * aurora_mult * h_mult / pow(game.met_info[met].rarity, 0.3))
		contents[met] = amount
		other_volume += amount / game.met_info[met].density / 1000 / h_mult
		tile.current_deposit.progress += 1
		#   									                          	    V Every km, rock density goes up by 0.01
	var stone_amount = max(0, clever_round((1 - other_volume) * 1000 * (2.85 + tile.depth / 100000.0) * h_mult))
	if stone_amount != 0:
		contents.stone = get_stone_comp_from_amount(p_i[get_rock_layer(tile, p_i)], stone_amount)
	if tile.has("ship_locator_depth") and tile.depth >= tile.ship_locator_depth:
		contents.ship_locator = 1
	return contents

func get_IR_mult(bldg_name):
	var mult = 1.0
	var sc:String
	if bldg_name in [Building.POWER_PLANT, Building.SOLAR_PANEL, Building.STEAM_ENGINE]:
		sc = "EPE"
	elif bldg_name in [Building.ATOM_MANIPULATOR, Building.SUBATOMIC_PARTICLE_REACTOR]:
		sc = "PME"
	elif bldg_name in [Building.MINERAL_SILO, Building.BATTERY, "M_DS", "M_MME"]:
		sc = "STE"
	else:
		sc = "%sE" % bldg_name
	if game.infinite_research.has(sc):
		mult = pow(game.maths_bonus.IRM, game.infinite_research[sc])
	return mult

func add_ship_XP(id:int, XP:float):
	var ship_data = game.ship_data
	ship_data[id].XP += XP
	while ship_data[id].XP >= ship_data[id].XP_to_lv:
		ship_data[id].XP -= ship_data[id].XP_to_lv
		ship_data[id].XP_to_lv = round(ship_data[id].XP_to_lv * game.maths_bonus.SLUGF_XP)
		ship_data[id].lv += 1
		ship_data[id].total_HP = round(ship_data[id].total_HP * game.maths_bonus.SLUGF_Stats)
		ship_data[id].HP = ship_data[id].total_HP
		ship_data[id].atk = round(ship_data[id].atk * game.maths_bonus.SLUGF_Stats)
		ship_data[id].acc = round(ship_data[id].acc * game.maths_bonus.SLUGF_Stats)
		ship_data[id].eva = round(ship_data[id].eva * game.maths_bonus.SLUGF_Stats)

func add_weapon_XP(id:int, weapon:String, XP:float):
	var ship_data = game.ship_data
	ship_data[id][weapon].XP += XP
	while ship_data[id][weapon].XP >= ship_data[id][weapon].XP_to_lv and ship_data[id][weapon].lv < 5:
		ship_data[id][weapon].XP -= ship_data[id][weapon].XP_to_lv
		ship_data[id][weapon].XP_to_lv = [100, 800, 4000, 0][ship_data[id][weapon].lv - 1]
		ship_data[id][weapon].lv += 1

func add_label(txt:String, idx:int = -1, center:bool = true, autowrap:bool = false):
	var vbox = game.get_node("UI/Panel/VBox")
	var label = Label.new()
	if autowrap:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if autowrap:
		label.size.x = 250
		label.custom_minimum_size.x = 250
	if center:
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.text = txt
	vbox.add_child(label)
	if idx != -1:
		vbox.move_child(label, idx)

#solar panels
func get_SP_production(temp:float, value:float):
	return value * temp / 273.0

#atm extractor
func get_AE_production(pressure:float, value:float):
	return value * pressure

func get_PCNC_production(pressure:float, value:float):
	return value / pressure

func update_rsrc(p_i, tile_id:int, rsrc = null, active:bool = false):
	var curr_time = Time.get_unix_time_from_system()
	var current_bar_value = 0
	var capacity_bar_value = 0
	var rsrc_text = ""
	var tile_data:Dictionary = game.tile_data
	if tile_defined(tile_data.unique_buildings, tile_id):
		if tile_data.unique_buildings[tile_id].has("repair_cost"):
			return
		if tile_data.unique_buildings[tile_id].name == "cellulose_synthesizer":
			current_bar_value = tile_data.unique_buildings[tile_id].get("production", 0.0)
			rsrc_text = "%s kg/s" % format_num(current_bar_value, true)
		elif tile_data.unique_buildings[tile_id].name == "nuclear_fusion_reactor":
			current_bar_value = tile_data.unique_buildings[tile_id].get("production", 0.0)
			rsrc_text = "%s/s" % format_num(round(current_bar_value))
		elif tile_data.unique_buildings[tile_id].name == "substation":
			current_bar_value = round(tile_data.unique_buildings[tile_id].get("capacity_bonus", 0.0) * get_IR_mult("PP") * game.u_i.time_speed)
			rsrc_text = "+ %s" % format_num(current_bar_value)
		if is_instance_valid(rsrc):
			rsrc.set_current_bar_value(current_bar_value)
			rsrc.set_capacity_bar_value(capacity_bar_value)
			rsrc.set_text(rsrc_text)
		return
	var building:Dictionary = tile_data.buildings[tile_id]
	if not is_instance_valid(rsrc) and building.name in [Building.STONE_CRUSHER, Building.GLASS_FACTORY, Building.STEAM_ENGINE, Building.SUBATOMIC_PARTICLE_REACTOR]:
		return
	if building.has("construction_date"):
		update_bldg_constr(tile_id, p_i)
		if building.has("is_constructing"):
			return
	var prod:float = p_i.tile_num if p_i.has("tile_num") else 1
	if building.name == "AE":
		prod *= building.path_1_value * get_prod_mult(tile) * p_i.pressure
		rsrc_text = "%s mol/%s" % [format_num(prod, true), tr("S_SECOND")]
	elif building.name == "ME":
		prod *= building.path_1_value * get_prod_mult(tile) * (tile.ash.richness if tile.has("ash") else 1.0) * (tile.mineral_replicator_bonus if tile.has("mineral_replicator_bonus") else 1.0)
		rsrc_text = "%s/%s" % [format_num(prod, true), tr("S_SECOND")]
	elif building.name == "SP":
		prod *= get_SP_production(p_i.temperature, building.path_1_value * get_prod_mult(tile) * get_au_mult(tile)) * (tile.substation_bonus if tile.has("substation_bonus") else 1.0)
		rsrc_text = "%s/%s" % [format_num(prod, true), tr("S_SECOND")]
	elif building.name == "PP":
		prod *= building.path_1_value * get_prod_mult(tile) * (tile.substation_bonus if tile.has("substation_bonus") else 1.0)
		rsrc_text = "%s/%s" % [format_num(prod, true), tr("S_SECOND")]
	elif building.name == "RL":
		prod *= building.path_1_value * get_prod_mult(tile) * (tile.observatory_bonus if tile.has("observatory_bonus") else 1.0)
		rsrc_text = "%s/%s" % [format_num(prod, true), tr("S_SECOND")]
	elif building.name in ["PC", "NC"]:
		prod *= building.path_1_value * p_i.pressure * get_prod_mult(tile)
		rsrc_text = "%s/%s" % [format_num(prod, true), tr("S_SECOND")]
	elif building.name == "EC":
		prod *= building.path_1_value / tile.aurora.au_int * get_prod_mult(tile)
		rsrc_text = "%s/%s" % [format_num(prod, true), tr("S_SECOND")]
	elif building.name == "SC":
		if building.has("stone"):
			var c_i = get_crush_info(tile)
			rsrc_text = str(c_i.qty_left)
			capacity_bar_value = 1 - c_i.progress
		else:
			rsrc_text = ""
			capacity_bar_value = 0
	elif building.name == "GF":
		if building.has("qty1"):
			var prod_i = get_prod_info(tile)
			rsrc_text = "%s kg" % [prod_i.qty_made]
			capacity_bar_value = prod_i.progress
		else:
			rsrc_text = ""
			capacity_bar_value = 0
	elif building.name == "SE":
		if building.has("qty1"):
			var prod_i = get_prod_info(tile)
			rsrc_text = "%s" % [round(prod_i.qty_made)]
			capacity_bar_value = prod_i.progress
		else:
			rsrc_text = ""
			capacity_bar_value = 0
	elif building.name == "GH":
		if tile.has("auto_GH"):
			rsrc_text = "%s kg/s" % format_num(tile.auto_GH.produce[tile.auto_GH.seed.split("_")[0]] * get_au_mult(tile), true)
		else:
			rsrc_text = ""
	elif building.name == "MM":
		prod = building.path_1_value * get_prod_mult(tile) * tile.get("mining_outpost_bonus", 1.0)
		rsrc_text = "%s m/s" % format_num(prod, true)
		current_bar_value = fposmod((curr_time - building.collect_date) * prod, 1.0)
	else:
		if Mods.added_buildings.has(building.name):
			Mods.mod_list[Mods.added_buildings[building.name].mod].calculate(p_i, tile, rsrc, curr_time)
	if is_instance_valid(rsrc):
		rsrc.set_current_bar_value(current_bar_value)
		rsrc.set_capacity_bar_value(capacity_bar_value)
		rsrc.set_text(rsrc_text)

func get_prod_mult(tile):
	var mult = get_IR_mult(tile.bldg.name) * (game.u_i.time_speed if Data.path_1.has(tile.bldg.name) and Data.path_1[tile.bldg.name].has("time_based") else 1.0)
	if tile.bldg.has("overclock_mult"):
		mult *= tile.bldg.overclock_mult
	return mult

func has_IR(bldg_name:String):
	return bldg_name in ["ME", "PP", "RL", "MS", "SP", "AMN", "SPR"]

func add_item_to_coll(dict:Dictionary, item:String, num):
	if num is Dictionary:
		if not dict.has("stone"):
			dict.stone = {}
		for el in num:
			if dict.stone.has(el):
				dict.stone[el] += num[el]
			else:
				dict.stone[el] = num[el]
	else:
		if num == 0:
			return
		if dict.has(item):
			dict[item] += num
		else:
			dict[item] = num

func ships_on_planet(p_id:int):#local planet id
	return game.c_c == game.ships_travel_data.c_coords.c and game.c_g == game.ships_travel_data.c_coords.g and game.c_s == game.ships_travel_data.c_coords.s and p_id == game.ships_travel_data.c_coords.p

func update_ship_travel():
	if game.ships_travel_data.travel_view == "-" or game.ships_travel_data.travel_length == NAN:
		return 1
	var progress:float = (Time.get_unix_time_from_system() - game.ships_travel_data.travel_start_date) / float(game.ships_travel_data.travel_length)
	if progress >= 1:
		game.get_node("Ship").mouse_filter = TextureButton.MOUSE_FILTER_IGNORE
		game.ships_travel_data.travel_view = "-"
		game.ships_travel_data.c_coords = game.ships_travel_data.dest_coords.duplicate(true)
		game.ships_travel_data.c_g_coords = game.ships_travel_data.dest_g_coords.duplicate(true)
		var p_i = game.open_obj("Systems", game.ships_travel_data.c_g_coords.s)[game.ships_travel_data.c_coords.p]
		if p_i.has("unique_bldgs") and p_i.unique_bldgs.has("spaceport") and not p_i.unique_bldgs.spaceport[0].has("repair_cost"):
			var tier = p_i.unique_bldgs.spaceport[0].tier
			game.autocollect.ship_XP = tier
			if is_instance_valid(game.HUD):
				game.HUD.set_ship_btn_shader(true, tier)
	return progress

func update_bldg_constr(tile_id:int, p_i:Dictionary):
	var curr_time = Time.get_unix_time_from_system()
	var tile_data:Dictionary = game.tile_data
	var building = game.tile_data.buildings[tile_id]
	var start_date = building.construction_date
	var length = building.construction_length
	var progress = (curr_time - start_date) / float(length)
	var update_boxes:bool = false
	if progress >= 1:
		if building.has("is_constructing"):
			building.erase("is_constructing")
			game.universe_data[game.c_u].xp += building.XP
			if not game.objective.is_empty() and game.objective.type == game.ObjectiveType.BUILD and game.objective.data == building.name:
				game.objective.current += 1
			if building.has("rover_id"):
				game.rover_data[building.rover_id].ready = true
				building.erase("rover_id")
			if tile_data.attributes.has(tile_id) and tile_data.attributes[tile_id].has("auto_GH"):
				var auto_GH:Dictionary = tile_data.attributes[tile_id].auto_GH
				auto_GH.cellulose_drain *= building.cell_mult
				for p in auto_GH.produce:
					if p in game.met_info.keys():
						auto_GH.produce[p] *= building.prod_mult
					else:# Any production other than metal will be considered proportional to cellulose drain
						auto_GH.produce[p] *= building.cell_mult
				add_GH_produce_to_autocollect(auto_GH.produce, tile.aurora.au_int if tile.has("aurora") else 0.0)
				game.autocollect.mats.cellulose -= auto_GH.cellulose_drain
				if auto_GH.has("soil_drain"):
					game.autocollect.mats.soil -= auto_GH.soil_drain
			if game.c_v == "planet":
				update_boxes = true
			var overclock_mult:float = building.overclock_mult if building.has("overclock_mult") else 1.0
			if building.name == "MS":
				game.mineral_capacity += building.cap_upgrade
			elif building.name == "B":
				game.energy_capacity += building.cap_upgrade
			elif building.name == "NSF":
				game.neutron_cap += building.cap_upgrade
			elif building.name == "ESF":
				game.electron_cap += building.cap_upgrade
			elif building.name == "RL":
				game.autocollect.rsrc.SP += building.path_1_value * overclock_mult * tile.get("observatory_bonus", 1.0)
			elif building.name == "ME":
				game.autocollect.rsrc.minerals += building.path_1_value * overclock_mult * (tile.ash.richness if tile.has("ash") else 1.0) * tile.get("mineral_replicator_bonus", 1.0)
			elif building.name == "PP":
				var energy_prod = building.path_1_value * overclock_mult * (tile.substation_bonus if tile.has("substation_bonus") else 1.0)
				game.autocollect.rsrc.energy += energy_prod
				if building.has("cap_upgrade") and building.cap_upgrade > 0: # Save migration
					game.capacity_bonus_from_substation += building.cap_upgrade
					if tile.has("substation_tile"):
						game.tile_data[tile.substation_tile].unique_bldg.capacity_bonus += building.cap_upgrade
			elif building.name == "SP":
				var energy_prod = get_SP_production(p_i.temperature, building.path_1_value * overclock_mult * get_au_mult(tile) * tile.get("substation_bonus", 1.0))
				game.autocollect.rsrc.energy += energy_prod
				if building.has("cap_upgrade"): # Save migration
					game.capacity_bonus_from_substation += building.cap_upgrade
					if tile.has("substation_tile"):
						game.tile_data[tile.substation_tile].unique_bldg.capacity_bonus += building.cap_upgrade
			elif building.name == "AE":
				var base = building.path_1_value * overclock_mult * p_i.pressure
				for el in p_i.atmosphere:
					var base_prod:float = base * p_i.atmosphere[el]
					game.show[el] = true
					add_atom_production(el, base_prod)
				add_energy_from_NFR(p_i, base)
				add_energy_from_CS(p_i, base)
#			elif building.name == "PC":
#				game.autocollect.particles.proton += building.path_1_value * overclock_mult / building.planet_pressure
#			elif building.name == "NC":
#				game.autocollect.particles.neutron += building.path_1_value * overclock_mult / building.planet_pressure
#			elif building.name == "EC":
#				game.autocollect.particles.electron += building.path_1_value * overclock_mult * tile.aurora.au_int
			elif building.name == "CBD":
				var _tile_data:Array
				var same_p:bool = game.c_p_g == building.c_p_g
				if same_p:
					_tile_data = game.tile_data
				else:
					_tile_data = game.open_obj("Planets", building.c_p_g)
				var n:int = building.path_3_value
				var wid:int = building.wid
				for i in n:
					var x:int = building.x_pos + i - n / 2
					if x < 0 or x >= wid:
						continue
					for j in n:
						var y:int = building.y_pos + j - n / 2
						if y < 0 or y >= building.wid or x == building.x_pos and y == building.y_pos:
							continue
						var id:int = x % wid + y * wid
						if _tile_data[id] == null:
							_tile_data[id] = {}
						var _tile = _tile_data[id]
						var id_str:String = str(_tile_data.find(tile))
						if not _tile.has("cost_div_dict"):
							_tile.cost_div = building.path_1_value
							_tile.cost_div_dict = {}
						else:
							_tile.cost_div = max(_tile.cost_div, building.path_1_value)
						_tile.cost_div_dict[id_str] = building.path_1_value
						if not _tile.has("overclock_dict"):
							_tile.overclock_bonus = building.path_2_value
							_tile.overclock_dict = {}
						else:
							_tile.overclock_bonus = max(_tile.overclock_bonus, building.path_2_value)
						_tile.overclock_dict[id_str] = building.path_2_value
				if not same_p:
					save_obj("Planets", building.c_p_g, _tile_data)
	return update_boxes

func add_energy_from_NFR(p_i:Dictionary, base:float):
	if not p_i.unique_bldgs.has("nuclear_fusion_reactor"):
		return
	for nfr in p_i.unique_bldgs.nuclear_fusion_reactor:
		var unique_mult = get_NFR_prod_mult(nfr.tier)
		if not nfr.has("repair_cost"):
			var S = 0.0
			if p_i.atmosphere.has("NH3"):
				S += base * unique_mult * 3 * p_i.atmosphere.NH3
			if p_i.atmosphere.has("CH4"):
				S += base * unique_mult * 4 * p_i.atmosphere.CH4
			if p_i.atmosphere.has("H2O"):
				S += base * unique_mult * 2 * p_i.atmosphere.H2O
			if p_i.atmosphere.has("H"):
				S += base * unique_mult * 1 * p_i.atmosphere.H
			game.autocollect.rsrc.energy += S
			game.tile_data[nfr.tile].unique_bldg.production = game.tile_data[nfr.tile].unique_bldg.get("production", 0) + S

func add_energy_from_CS(p_i:Dictionary, base:float):
	if not p_i.unique_bldgs.has("cellulose_synthesizer"):
		return
	for cs in p_i.unique_bldgs.cellulose_synthesizer:
		var unique_mult = get_CS_prod_mult(cs.tier)
		if not cs.has("repair_cost"):
			var cellulose = {"C":0, "H":0, "O":0}
			if p_i.atmosphere.has("NH3"):
				cellulose.H += p_i.atmosphere.NH3 * 3
			if p_i.atmosphere.has("CH4"):
				cellulose.C += p_i.atmosphere.CH4
				cellulose.H += p_i.atmosphere.CH4 * 4
			if p_i.atmosphere.has("H2O"):
				cellulose.H += p_i.atmosphere.H2O * 2
				cellulose.O += p_i.atmosphere.H2O
			if p_i.atmosphere.has("CO2"):
				cellulose.C += p_i.atmosphere.CO2
				cellulose.O += p_i.atmosphere.CO2 * 2
			if p_i.atmosphere.has("H"):
				cellulose.H += p_i.atmosphere.H
			if p_i.atmosphere.has("O"):
				cellulose.O += p_i.atmosphere.O
			cellulose.C /= 6.0
			cellulose.H /= 10.0
			cellulose.O /= 5.0
			var cellulose_molecules:float = [cellulose.C, cellulose.H, cellulose.O].min()
			game.autocollect.mats.cellulose += base * unique_mult * cellulose_molecules
			game.tile_data[cs.tile].unique_bldg.production = game.tile_data[cs.tile].unique_bldg.get("production", 0) + base * unique_mult * cellulose_molecules

func add_atom_production(el:String, base_prod:float):
	if el == "NH3":
		game.autocollect.atoms.N = 1 * base_prod + game.autocollect.atoms.get("N", 0)
		game.autocollect.atoms.H = 3 * base_prod + game.autocollect.atoms.get("H", 0)
	elif el == "CO2":
		game.autocollect.atoms.C = 1 * base_prod + game.autocollect.atoms.get("C", 0)
		game.autocollect.atoms.O = 2 * base_prod + game.autocollect.atoms.get("O", 0)
	elif el == "CH4":
		game.autocollect.atoms.C = 1 * base_prod + game.autocollect.atoms.get("C", 0)
		game.autocollect.atoms.H = 4 * base_prod + game.autocollect.atoms.get("H", 0)
	elif el == "H2O":
		game.autocollect.atoms.H = 2 * base_prod + game.autocollect.atoms.get("H", 0)
		game.autocollect.atoms.O = 1 * base_prod + game.autocollect.atoms.get("O", 0)
	else:
		game.autocollect.atoms[el] = 1 * base_prod + game.autocollect.atoms.get(el, 0)

func get_reaction_info(tile):
	var MM_value:float = clamp((Time.get_unix_time_from_system() - tile.bldg.start_date) / tile.bldg.difficulty * tile.bldg.path_1_value * get_IR_mult(tile.bldg.name) * game.u_i.time_speed, 0, tile.bldg.qty)
	return {"MM_value":MM_value, "progress":MM_value / tile.bldg.qty}

func update_MS_rsrc(dict:Dictionary):
	var curr_time = Time.get_unix_time_from_system()
	var prod:float
	if dict.has("tile_num"):
		if dict.bldg.name == "AE":
			prod = 1.0 / get_AE_production(dict.pressure, dict.bldg.path_1_value) / dict.tile_num / game.u_i.time_speed
		else:
			prod = 1.0 / dict.bldg.path_1_value
			if dict.bldg.name != "MM":
				prod /= dict.tile_num
			prod /= get_prod_mult(dict)
		var stored = dict.bldg.stored
		var c_d = dict.bldg.collect_date
		var c_t = curr_time
		if dict.bldg.has("path_2_value"):
			var cap = dict.bldg.path_2_value * dict.bldg.IR_mult
			if dict.bldg.name != "MM":
				cap = round(cap * dict.tile_num)
			else:
				cap = round(cap)
			var ac_b:bool = dict.bldg.name in ["PP", "ME"]
			if stored < cap and c_t - c_d > prod and (not dict.has("autocollect") and ac_b or not ac_b):
				var rsrc_num = floor((c_t - c_d) / prod)
				dict.bldg.stored += rsrc_num
				dict.bldg.collect_date += prod * rsrc_num
				if dict.bldg.stored >= cap:
					dict.bldg.stored = cap
		else:
			if c_t - c_d > prod:
				if not dict.has("autocollect"):
					var rsrc_num = floor((c_t - c_d) / prod)
					dict.bldg.stored += rsrc_num
					dict.bldg.collect_date += prod * rsrc_num
		return min((c_t - c_d) / prod, 1)
	else:
		return 0

func get_DS_output(star:Dictionary, next_lv:int = 0):
	return Data.MS_output["M_DS_%s" % ((star[7].MS_lv + next_lv) if star[7].has("MS_lv") else next_lv - 1)] * star[6] * game.u_i.planck  * 0.5

func get_DS_capacity(star:Dictionary, next_lv:int = 0):
	if next_lv == -1 and star.has("MS") and star[7].MS_lv == 0:
		return 0
	return Data.MS_output["M_DS_%s" % ((star[7].MS_lv + next_lv) if star[7].has("MS_lv") else next_lv - 1)] * pow(star[2], 2) * game.u_i.planck * 5000.0 * game.u_i.charge

func get_MB_output(star:Dictionary):
	return Data.MS_output.M_MB * star[6] * game.u_i.planck

func get_MME_output(p_i:Dictionary, next_lv:int = 0):
	return Data.MS_output["M_MME_%s" % ((p_i.MS_lv + next_lv) if p_i.has("MS_lv") else next_lv - 1)] * pow(p_i.size / 12000.0, 2) * max(1, pow(p_i.pressure, 0.5))

func get_MME_capacity(p_i:Dictionary, next_lv:int = 0):
	if next_lv == -1 and p_i.has("MS") and p_i.MS_lv == 0:
		return 0
	return Data.MS_output["M_MME_%s" % ((p_i.MS_lv + next_lv) if p_i.has("MS_lv") else next_lv - 1)] * pow(p_i.size / 1200.0, 2)

func get_conquer_all_data():
	var max_ship_lv:int = 0
	var HX_data:Array = []
	for ship in game.ship_data:
		max_ship_lv = max(ship.lv, max_ship_lv)
	var furthest_unconquered_planet_distance = 0
	var closest_unconquered_planet_distance = INF
	for planet in game.planet_data:
		if planet.has("conquered") or not planet.has("HX_data"):
			continue
		#closest_unconquered_planet_distance = min(closest_unconquered_planet_distance, planet.distance)
		furthest_unconquered_planet_distance = max(furthest_unconquered_planet_distance, planet.distance)
		for HX in planet.HX_data:
			if HX.lv > max_ship_lv - 5:
				HX_data.append(HX)
	var energy_cost = 70000 * (furthest_unconquered_planet_distance) / pow(game.u_i.speed_of_light, 2)
	if game.science_unlocked.has("FTL"):
		energy_cost /= 10.0
	if game.science_unlocked.has("IGD"):
		energy_cost /= 100.0
	return {"HX_data":HX_data, "energy_cost":round(energy_cost)}

var hbox_theme = preload("res://Resources/default_theme.tres")
var text_border_theme = preload("res://Resources/TextBorder.tres")
func add_lv_boxes(obj:Dictionary, v:Vector2, sc:float = 1.0):
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.theme = hbox_theme
	hbox["theme_override_constants/separation"] = -1
	if obj.bldg.has("path_1"):
		var path_1 = Label.new()
		path_1.name = "Path1"
		path_1.text = str(obj.bldg.path_1)
		path_1.connect("mouse_entered",Callable(self,"on_path_enter").bind("1", obj))
		path_1.connect("mouse_exited",Callable(self,"on_path_exit"))
		path_1["theme_override_styles/normal"] = text_border_theme
		hbox.add_child(path_1)
		hbox.mouse_filter = hbox.MOUSE_FILTER_IGNORE
		path_1.mouse_filter = path_1.MOUSE_FILTER_PASS
	if obj.bldg.has("path_2"):
		var path_2 = Label.new()
		path_2.name = "Path2"
		path_2.text = str(obj.bldg.path_2)
		path_2.connect("mouse_entered",Callable(self,"on_path_enter").bind("2", obj))
		path_2.connect("mouse_exited",Callable(self,"on_path_exit"))
		path_2["theme_override_styles/normal"] = text_border_theme
		path_2.mouse_filter = path_2.MOUSE_FILTER_PASS
		hbox.add_child(path_2)
	if obj.bldg.has("path_3"):
		var path_3 = Label.new()
		path_3.name = "Path3"
		path_3.text = str(obj.bldg.path_3)
		path_3.connect("mouse_entered",Callable(self,"on_path_enter").bind("3", obj))
		path_3.connect("mouse_exited",Callable(self,"on_path_exit"))
		path_3["theme_override_styles/normal"] = text_border_theme
		path_3.mouse_filter = path_3.MOUSE_FILTER_PASS
		hbox.add_child(path_3)
	hbox.size.x = 200
	hbox.scale *= sc
	hbox.position = v - Vector2(100, 90) * sc
	#hbox.visible = get_parent().scale.x >= 0.25
	return hbox

func on_path_enter(path:String, obj:Dictionary):
	game.hide_adv_tooltip()
	if not obj.is_empty() and obj.has("bldg"):
		game.show_tooltip("%s %s %s %s" % [tr("PATH"), path, tr("LEVEL"), obj.bldg["path_" + path]])

func on_path_exit():
	game.hide_tooltip()

func clever_round (num:float, sd:int = 3, st:bool = false, _floor:bool = false):#sd: significant digits
	var e = floor(log10(abs(num)))
	if e < -4 and st:
		return e_notation(num, sd)
	if sd < e + 1:
		if _floor:
			return floor(num)
		else:
			return round(num)
	return snapped(num, pow(10, e - sd + 1))

const Y9 = Color(25, 0, 0, 255) / 255.0
const Y0 = Color(66, 0, 0, 255) / 255.0
const T0 = Color(117, 0, 0, 255) / 255.0
const L0 = Color(189, 32, 23, 255) / 255.0
const M0 = Color(255, 181, 108, 255) / 255.0
const K0 = Color(255, 218, 181, 255) / 255.0
const G0 = Color(255, 237, 227, 255) / 255.0
const F0 = Color(249, 245, 255, 255) / 255.0
const A0 = Color(213, 224, 255, 255) / 255.0
const B0 = Color(162, 192, 255, 255) / 255.0
const O0 = Color(140, 177, 255, 255) / 255.0
const Q0 = Color(134, 255, 117, 255) / 255.0
const R0 = Color(255, 100, 255, 255) / 255.0
const Z0 = Color(100, 30, 255, 255) / 255.0

func get_star_modulate (star_class:String):
	var w = int(star_class[1]) / 10.0#weight for lerps
	var m:Color
	match star_class[0]:
		"Y":
			m = lerp(Y0, Y9, w)
		"T":
			m = lerp(T0, Y0, w)
		"L":
			m = lerp(L0, T0, w)
		"M":
			m = lerp(M0, L0, w)
		"K":
			m = lerp(K0, M0, w)
		"G":
			m = lerp(G0, K0, w)
		"F":
			m = lerp(F0, G0, w)
		"A":
			m = lerp(A0, F0, w)
		"B":
			m = lerp(B0, A0, w)
		"O":
			m = lerp(O0, B0, w)
		"Q":
			m = lerp(Q0, O0, w)
		"R":
			m = lerp(R0, Q0, w)
		"Z":
			m = lerp(Z0, R0, w)
	return m

func get_final_value(p_i:Dictionary, dict:Dictionary, path:int, n:int = 1):
	var bldg:String = dict.bldg.name
	var mult:float = get_prod_mult(dict)
	if bldg in ["MM", "GH", "AMN", "SPR"]:
		n = 1
	if path == 1:
		if bldg == "SP":
			return clever_round(get_SP_production(p_i.temperature, dict.bldg.path_1_value * mult * get_au_mult(dict) * (dict.substation_bonus if dict.has("substation_bonus") else 1.0)) * n)
		elif bldg == "AE":
			return clever_round(get_AE_production(p_i.pressure, dict.bldg.path_1_value) * n)
		elif bldg in ["MS", "NSF", "ESF"]:
			return dict.bldg.path_1_value * get_IR_mult(bldg) * n
		elif bldg == "B":
			return dict.bldg.path_1_value * mult * get_IR_mult("B") * n * game.u_i.charge
		elif bldg in ["SPR"]:
			return dict.bldg.path_1_value * mult * n * game.u_i.charge
		elif bldg in ["PC", "NC"]:
			return dict.bldg.path_1_value * mult * n / p_i.pressure
		elif bldg == "EC":
			return dict.bldg.path_1_value * mult * n * (dict.aurora.au_int if dict.has("aurora") else 1.0)
		elif bldg == "ME":
			return dict.bldg.path_1_value * (dict.ash.richness if dict.has("ash") else 1.0) * mult * n * (dict.mineral_replicator_bonus if dict.has("mineral_replicator_bonus") else 1.0)
		elif bldg == "PP":
			return dict.bldg.path_1_value * mult * n * (dict.substation_bonus if dict.has("substation_bonus") else 1.0)
		elif bldg == "RL":
			return dict.bldg.path_1_value * mult * n * (dict.observatory_bonus if dict.has("observatory_bonus") else 1.0)
		elif bldg == "MM":
			return dict.bldg.path_1_value * mult * n * (dict.mining_outpost_bonus if dict.has("mining_outpost_bonus") else 1.0)
		else:
			return dict.bldg.path_1_value * mult * n
	elif path == 2:
		if bldg == "SPR":
			return dict.bldg.path_2_value * mult * n * game.u_i.charge
		elif bldg == "SE":
			return dict.bldg.path_2_value * n
		else:
			return dict.bldg.path_2_value * mult * n
	elif path == 3:
		if bldg == "SE":
			return dict.bldg.path_3_value * get_IR_mult("SE")
		else:
			return dict.bldg.path_3_value

func get_bldg_tooltip(p_i:Dictionary, dict:Dictionary, n:float = 1):
	var tooltip:String = ""
	var bldg:String = dict.bldg.name
	var path_1_value = get_final_value(p_i, dict, 1, n) if dict.bldg.has("path_1_value") else 0.0
	var path_2_value = get_final_value(p_i, dict, 2, n) if dict.bldg.has("path_2_value") else 0.0
	var path_3_value = get_final_value(p_i, dict, 3, n) if dict.bldg.has("path_3_value") else 0.0
	return get_bldg_tooltip2(bldg, path_1_value, path_2_value, path_3_value)

func get_bldg_tooltip2(bldg:String, path_1_value, path_2_value, path_3_value):
	match bldg:
		"ME", "PP", "SP", "AE", "MM":
			return (Data.path_1[bldg].desc) % [format_num(path_1_value, true)]
		"AMN", "SPR":
			return (Data.path_1[bldg].desc + "\n" + Data.path_2[bldg].desc) % [format_num(path_1_value, true), format_num(path_2_value, true)]
		"SC", "GF", "SE":
			return "%s\n%s\n%s" % [Data.path_1[bldg].desc % format_num(path_1_value, true), Data.path_2[bldg].desc % format_num(path_2_value, true), Data.path_3[bldg].desc % clever_round(path_3_value)]
		"RL", "PC", "NC", "EC":
			return (Data.path_1[bldg].desc) % [format_num(path_1_value, true)]
		"MS", "NSF", "ESF", "B":
			return (Data.path_1[bldg].desc) % [format_num(round(path_1_value))]
		"RCC", "SY":
			return (Data.path_1[bldg].desc % format_num(path_1_value, true)) + "\n[color=#88CCFF]" + tr("CLICK_TO_CONFIGURE") + "[/color]"
		"GH":
			return (Data.path_1[bldg].desc + "\n" + Data.path_2[bldg].desc) % [format_num(path_1_value, true), format_num(path_2_value, true)]
		"CBD":
			return "%s\n%s\n%s" % [
				Data.path_1[bldg].desc % clever_round(path_1_value),
				Data.path_2[bldg].desc % path_2_value,
				Data.path_3[bldg].desc.format({"n":path_3_value})]
		_:
			return ""

func set_overlay_visibility(gradient:Gradient, overlay, offset:float):
	overlay.circle.modulate = gradient.sample(offset)
	overlay.circle.visible = game.overlay.toggle_btn.button_pressed and (not game.overlay.hide_obj_btn.button_pressed or offset >= 0 and offset <= 1)
	overlay.circle.modulate.a = 1.0 if overlay.circle.visible else 0.0

func remove_recursive(path):
	# Open directory
	var directory = DirAccess.open(path)
	if directory:
		# List directory content
		directory.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = directory.get_next()
		while file_name != "":
			if directory.current_is_dir():
				remove_recursive(path + "/" + file_name)
			else:
				directory.remove(file_name)
			file_name = directory.get_next()
		
		# Remove current path
		directory.remove(path)
	else:
		print("Error removing " + path)

func get_SC_output(expected_rsrc:Dictionary, amount:float, path_3_value:float, total_stone:float):
	for el in game.stone:
		var item:String
		var el_num = 0
		if el == "Si":
			item = "silicon"
			el_num = game.stone[el] * amount / total_stone / 30.0
		elif el == "Fe" and game.science_unlocked.has("ISC"):
			item = "iron"
			el_num = game.stone[el] * amount / total_stone / 30.0
		elif el == "Al" and game.science_unlocked.has("ISC"):
			item = "aluminium"
			el_num = game.stone[el] * amount / total_stone / 50.0
		elif el == "O":
			item = "sand"
			el_num = game.stone[el] * amount / total_stone / 2.0
		elif el == "Ti" and game.science_unlocked.has("ISC"):
			item = "titanium"
			el_num = game.stone[el] * amount / total_stone / 500.0
		el_num = snapped(el_num * path_3_value, 0.001)
		if el_num != 0:
			expected_rsrc[item] = el_num

func flatten(arr:Array):
	var arr2:Array = []
	for i in len(arr):
		arr2.append_array(arr[i])
	return arr2

func add_to_dict(dict:Dictionary, key:String, value):
	if dict.has(key):
		dict[key] += value
	else:
		dict[key] = value

func add_dict_to_dict(dict1:Dictionary, dict2:Dictionary):
	for key in dict2:
		if dict1.has(key):
			dict1[key] += dict2[key]
		else:
			dict1[key] = dict2[key]

func get_modifier_string(modifiers:Dictionary, au_str:String, icons:Array):
	var au_str_end:String = "[/aurora]" if au_str != "" else ""
	var st:String = ""
	for modifier in modifiers:
		if Data.cave_modifiers[modifier].has("double_treasure_at"):
			var treasure_bonus_str:String = ""
			var cave_mod:float = modifiers[modifier]
			var double_treasure_at:float = Data.cave_modifiers[modifier].double_treasure_at
			var mod_color:String = ""
			if cave_mod > 1.0:
				if double_treasure_at > 1.0:
					var gradient:Gradient = preload("res://Resources/IntensityGradient.tres")
					mod_color = gradient.sample(inverse_lerp(1.0, double_treasure_at, cave_mod) / 2.0).to_html(false)
					if not Data.cave_modifiers[modifier].has("no_treasure_mult"):
						treasure_bonus_str = " (x%s %s@i%s)" % [clever_round(remap(cave_mod, 1.0, double_treasure_at, 0, 1) + 1.0), au_str_end, au_str]
						icons.append(preload("res://Graphics/Icons/Inventory.png"))
				else:
					mod_color = lerp(Color.GREEN, Color.WHITE, inverse_lerp(1.0 / double_treasure_at, 1.0, cave_mod)).to_html(false)
				st += "\n%s: %s+%s%%[/color]%s%s" % [
					tr(modifier.to_upper()),
					au_str_end + "[color=#%s]" % mod_color,
					clever_round((cave_mod - 1.0) * 100.0),
					au_str,
					treasure_bonus_str,
				]
			else:
				if double_treasure_at < 1.0:
					var gradient:Gradient = preload("res://Resources/IntensityGradient.tres")
					mod_color = gradient.sample(inverse_lerp(1.0, double_treasure_at, cave_mod) / 2.0).to_html(false)
					if not Data.cave_modifiers[modifier].has("no_treasure_mult"):
						treasure_bonus_str = " (x%s %s@i%s)" % [clever_round(remap(1.0 / cave_mod, 1.0, 1.0 / double_treasure_at, 0, 1) + 1.0), au_str_end, au_str]
						icons.append(preload("res://Graphics/Icons/Inventory.png"))
				else:
					mod_color = lerp(Color.GREEN, Color.WHITE, inverse_lerp(1.0 / double_treasure_at, 1.0, cave_mod)).to_html(false)
				st += "\n%s: %s-%s%%[/color]%s%s" % [
					tr(modifier.to_upper()),
					au_str_end + "[color=#%s]" % mod_color,
					clever_round((1.0 - cave_mod) * 100.0),
					au_str,
					treasure_bonus_str,
				]
		elif Data.cave_modifiers[modifier].has("treasure_if_true"):
			st += "\n%s[color=red]%s[/color]%s (x%s %s@i%s)" % [
				"[/aurora]" if au_str != "" else "",
				tr(modifier.to_upper()),
				au_str,
				Data.cave_modifiers[modifier].treasure_if_true,
				au_str_end,
				au_str,
			]
			icons.append(preload("res://Graphics/Icons/Inventory.png"))
	return st

func get_time_div(time:float):
	return round(time / game.u_i.time_speed * 10.0) / 10.0

func get_RE_info(RE_name:String):
	if RE_name == "armor_3":
		return (tr("RE_" + RE_name.to_upper()) % get_time_div(15.0))
	elif RE_name == "armor_4":
		return (tr("RE_" + RE_name.to_upper()) % [get_time_div(0.5), get_time_div(2.0)])
	elif RE_name == "armor_5":
		return (tr("RE_" + RE_name.to_upper()) % get_time_div(1.5))
	elif RE_name == "laser_2":
		return (tr("RE_" + RE_name.to_upper()) % get_time_div(10.0))
	elif RE_name == "laser_4":
		return (tr("RE_" + RE_name.to_upper()) % [get_time_div(1.0), get_time_div(0.8)])
	elif RE_name == "laser_5":
		return (tr("RE_" + RE_name.to_upper()) % [get_time_div(0.5), get_time_div(1.0)])
	elif RE_name == "laser_8":
		return (tr("RE_" + RE_name.to_upper()) % get_time_div(11.0))
	else:
		return tr("RE_" + RE_name.to_upper())

func remove_GH_produce_from_autocollect(produce:Dictionary, au_int:float):
	for p in produce:
		if p == "minerals":
			game.autocollect.mats.minerals -= produce[p]
		elif game.mat_info.has(p):
			game.autocollect.mats[p] -= produce[p]
		elif game.met_info.has(p):
			var met_prod = produce[p] * (1.0 + au_int)
			game.autocollect.mets[p] -= met_prod

func add_GH_produce_to_autocollect(produce:Dictionary, au_int:float):
	for p in produce:
		if p == "minerals":
			game.autocollect.mats.minerals = produce[p] + game.autocollect.mats.get(p, 0.0)
		elif game.mat_info.has(p):
			game.autocollect.mats[p] = produce[p] + game.autocollect.mats.get(p, 0.0)
		elif game.met_info.has(p):
			var met_prod = produce[p] * (1.0 + au_int)
			game.autocollect.mets[p] = met_prod + game.autocollect.mets.get(p, 0.0)

func set_resolution(index:int):
	var res:Vector2 = get_viewport().size
	#get_viewport().size_2d_override_stretch = true 
	if index == 0:
		get_viewport().size_2d_override_stretch = false
		if ((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN)):
			res = DisplayServer.screen_get_size()
			game.current_viewport_dimensions = res
			get_viewport().size = res
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (false) else Window.MODE_WINDOWED
			get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (true) else Window.MODE_WINDOWED
		else:
			res = Vector2(1280, 720)
	elif index == 1:
		res = Vector2(3820, 2160)
	elif index == 2:
		res = Vector2(2560, 1440)
	elif index == 3:
		res = Vector2(1920, 1080)
	elif index == 4:
		res = Vector2(1280, 720)
	elif index == 5:
		res = Vector2(853, 480)
	elif index == 6:
		res = Vector2(640, 360)
	elif index == 7:
		res = Vector2(427, 240)
	elif index == 8:
		res = Vector2(256, 144)
	elif index == 9:
		res = Vector2(128, 72)
	elif index == 10:
		res = Vector2(64, 36)
	elif index == 11:
		res = Vector2(32, 18)
	elif index == 12:
		res = Vector2(16, 9)
	game.current_viewport_dimensions = res
	get_viewport().size = res

func get_roman_num(num:int):
	if num > 3999:
		return str(num)
	var strs = [["","I","II","III","IV","V","VI","VII","VIII","IX"],["","X","XX","XXX","XL","L","LX","LXX","LXXX","XC"],["","C","CC","CCC","CD","D","DC","DCC","DCCC","CM"],["","M","MM","MMM"]];
	var num_str:String = str(num)

	var res = ""
	var n = num_str.length()
	var c = 0;
	while c < n:
		res = strs[c][int(num_str[n - c - 1])] + res
		c += 1
	return res

func get_spaceport_exit_cost_reduction(tier:int):
	if tier > 1:
		return 1.0
	else:
		return 0.5

func get_spaceport_travel_cost_reduction(tier:int):
	if tier > 4:
		return 1.0
	else:
		return [0.25, 0.75, 0.99, 0.9999][tier-1]

func get_spaceport_xp_mult(tier:int):
	return pow(4, tier-1)

func get_unique_bldg_area(tier:int):
	return tier * 2 + 1

func get_MR_Obs_Outpost_prod_mult(tier:int):
	return 2.5 * pow(4, tier-1)

func get_substation_prod_mult(tier:int):
	return 1.5 * pow(3, tier-1)

func get_substation_capacity_bonus(tier:int):
	return 1200 * pow(3, tier-1)

func get_AG_au_int_mult(tier:int):
	return 2.0 * pow(3, tier-1)

func get_AG_num_auroras(tier:int):
	return 10 * pow(2, tier-1)

func get_NFR_prod_mult(tier:int):
	return 500 * pow(4, tier-1)

func get_CS_prod_mult(tier:int):
	return 10 * pow(4, tier-1)

func set_unique_bldg_bonuses(p_i:Dictionary, unique_bldg:Dictionary, tile_id:int, wid:int):
	var x_pos = tile_id % wid
	var y_pos = tile_id / wid
	var tier = unique_bldg.tier
	var n = Helper.get_unique_bldg_area(tier)
	var tile_data = game.tile_data
	if unique_bldg.name in [UniqueBuilding.MINERAL_REPLICATOR, UniqueBuilding.OBSERVATORY, UniqueBuilding.SUBSTATION, UniqueBuilding.MINING_OUTPOST]:
		for i in n:
			var x:int = x_pos + i - n / 2
			if x < 0 or x >= wid:
				continue
			for j in n:
				var y:int = y_pos + j - n / 2
				if y < 0 or y >= wid or x == x_pos and y == y_pos:
					continue
				var id:int = x + y * wid
				var mult = Helper.get_substation_prod_mult(tier) if unique_bldg.name == UniqueBuilding.SUBSTATION else Helper.get_MR_Obs_Outpost_prod_mult(tier)
				var bonus_str = str(unique_bldg.name + "_bonus")
				if Helper.tile_defined(tile_data.attributes, id):
					if tile_data.attributes[id].has(bonus_str) and mult < tile_data.attributes[id][bonus_str]:
						return
					tile_data.attributes[id][bonus_str] = mult
				else:
					tile_data.attributes[id] = {bonus_str:mult}
				if Helper.tile_defined(tile_data.buildings, id) and not tile_data.buildings[id].has("is_constructing") and unique_bldg.name != "mining_outpost":
					var overclock_mult:float = tile_data.buildings[id].get("overclock_mult", 1.0)
					var bldg_name = tile_data.buildings[id].name
					var prod = tile_data.buildings[id].path_1_value
					var base = prod * overclock_mult * mult
					var diff = prod * overclock_mult * (mult - 1.0)
					if unique_bldg.name == "mineral_replicator" and bldg_name == "ME":
						if Helper.tile_defined(tile_data.ashes, id):
							game.autocollect.rsrc.minerals += diff * abs(tile_data.ashes[id])
						else:
							game.autocollect.rsrc.minerals += diff
					elif unique_bldg.name == "observatory" and bldg_name == "RL":
						game.autocollect.rsrc.SP += diff
					elif unique_bldg.name == "substation":
						var cap_bonus_mult = Helper.get_substation_capacity_bonus(tier)# 1200 seconds for tier 1, more for tier 2 etc.
						if bldg_name == "PP":
							game.autocollect.rsrc.energy += diff
							unique_bldg.capacity_bonus = unique_bldg.get("capacity_bonus", 0) + base * cap_bonus_mult
							game.capacity_bonus_from_substation += unique_bldg.capacity_bonus
						elif bldg_name == "SP":
							var au_mult = 1.0
							if Helper.tile_defined(tile_data.auroras, id):
								au_mult = tile_data.auroras[id]
							var energy_prod = Helper.get_SP_production(p_i.temperature, diff * au_mult)
							var energy_prod_base = Helper.get_SP_production(p_i.temperature, base * au_mult)
							game.autocollect.rsrc.energy += energy_prod
							unique_bldg.capacity_bonus = unique_bldg.get("capacity_bonus", 0) + energy_prod_base * cap_bonus_mult
							game.capacity_bonus_from_substation += unique_bldg.capacity_bonus
				if unique_bldg.name == "substation":
					tile_data.attributes[id].substation_tile = tile_id
					unique_bldg.capacity_bonus = unique_bldg.get("capacity_bonus", 0)
	elif unique_bldg.name in [UniqueBuilding.NUCLEAR_FUSION_REACTOR, UniqueBuilding.CELLULOSE_SYNTHESIZER]:
		for i in len(game.tile_data.buildings):
			if Helper.tile_defined(tile_data.buildings, i) and tile_data.buildings[i].name == "AE" and not tile_data.buildings[i].has("is_constructing"):
				var overclock_mult = tile_data.buildings[i].get("overclock_mult", 1.0)
				var mult = 1.0
				var base = 1.0
				var prod = tile_data.buildings[i].path_1_value
				if unique_bldg.name == UniqueBuilding.NUCLEAR_FUSION_REACTOR:
					mult = Helper.get_NFR_prod_mult(tier)
					base = prod * overclock_mult * mult
					Helper.add_energy_from_NFR(p_i, base)
				elif unique_bldg.name == UniqueBuilding.CELLULOSE_SYNTHESIZER:
					mult = Helper.get_CS_prod_mult(tier)
					base = prod * overclock_mult * mult
					Helper.add_energy_from_CS(p_i, base)
	elif unique_bldg.name == UniqueBuilding.SPACEPORT:
		if game.c_s_g == game.ships_travel_data.c_g_coords.s and game.c_p == game.ships_travel_data.c_coords.p:
			game.autocollect.ship_XP = tier
			game.HUD.set_ship_btn_shader(true, tier)

# get_sphere_volume
func get_sph_V(outer:float, inner:float = 0):
	outer /= 150.0#I have to reduce the size of planets otherwise it's too OP
	inner /= 150.0
	return 4/3.0 * PI * (pow(outer, 3) - pow(inner, 3))

func tile_defined(data, id:int):
	return data is Array and data[id] != null or data is Dictionary and data.has(id)

var discord = true

func setup_discord():
#	discord_sdk.app_id = 1101755847325003846 # Application ID
#	if discord_sdk.get_is_discord_working():
#		discord_sdk.large_image = "game"
#		discord_sdk.large_image_text = "Helixteus 3"
#		discord_sdk.start_timestamp = int(Time.get_unix_time_from_system())
	pass

func refresh_discord(details:String = "", state:String = "", small_image:String = "", small_image_text:String = ""):
#	if discord_sdk.get_is_discord_working():
#		if details == "clear":
#			discord_sdk.clear()
#			return
#		if not discord:
#			return
#		if details != "":
#			discord_sdk.details = details
#		if state != "":
#			discord_sdk.state = state
#		if small_image != "":
#			discord_sdk.small_image = small_image
#		if small_image_text != "":
#			discord_sdk.small_image_text = small_image_text
#		discord_sdk.refresh()
	pass
