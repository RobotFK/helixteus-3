extends Node2D

@onready var game = get_node("/root/Game")
var W:int
var H:int
var LOD:int
var whites:Array = []
var coefficients = []
var wid_p:int
var wid_p2:int
var hv2:float
var h_start:float
var whites_p = []
var frame = 0
var frames:Array
var white_pixel_num = 0
var phase = 0
var BG_alpha = 0.0

func _ready():
	set_process(false)
	
func load_data(_LOD):
	LOD = _LOD
#	var data = FileAccess.open("data100.txt", FileAccess.READ)
	wid_p2 = wid_p * LOD
	if is_processing():
		return
	if wid_p2 > 360:
		game.popup("Too many exclamation marks!", 2.0)
		return
	var data
	if wid_p2 > 120:
		W = 480
		H = 360
		data = FileAccess.open_compressed("Easter eggs/Bad apple/badappledata100", FileAccess.READ, FileAccess.COMPRESSION_DEFLATE)
	else:
		W = 120
		H = 90
		data = FileAccess.open_compressed("Easter eggs/Bad apple/badappledata25", FileAccess.READ, FileAccess.COMPRESSION_DEFLATE)
	var st = data.get_as_text()
	frames = st.split("\n")
#	var data2 = FileAccess.open_compressed("res://badappledata100", FileAccess.WRITE, FileAccess.COMPRESSION_DEFLATE)
#	data2.store_string(st)
#	data2.close()
	hv2 = float(H) * wid_p2 / W
	h_start = (wid_p2 - hv2) / 2.0
	whites.resize(W * H)
	whites_p.resize(wid_p2 * wid_p2)
	coefficients.resize(wid_p2 * wid_p2)
	for i in range(wid_p2 * wid_p2):
		coefficients[i] = 0
	for i in len(whites):
		var x = i % W
		var y = i / W
		var x_p = int(x / float(W) * wid_p2)
		var y_p = int(y / float(H) * hv2 + h_start)
		var ind_p = x_p + y_p * wid_p2
		coefficients[ind_p] += 1
	for i in len(coefficients):
		if coefficients[i] > 0:
			coefficients[i] = 1.0 / coefficients[i]
	for i in len(whites):
		whites[i] = false
	for i in len(whites_p):
		whites_p[i] = 0.0
	start_time = Time.get_unix_time_from_system()
	curr_time = start_time
	video_time = start_time
	set_process(true)

func _draw():
#	if white_pixel_num > W * H / 2:
#		draw_rect(Rect2(0, 0, W*20, H*20), Color.WHITE)
#		for i in len(whites):
#			if not whites[i]:
#				draw_rect(Rect2((i%W)*20, i/W*20, 20, 20), Color.BLACK)
#	else:
#		draw_rect(Rect2(0, 0, W*20, H*20), Color.BLACK)
#		for i in len(whites):
#			if whites[i]:
#				draw_rect(Rect2((i%W)*20, i/W*20, 20, 20), Color.WHITE)
	if phase == 0 or phase == 2:
		draw_rect(Rect2(0, 0, wid_p*200, wid_p*200), Color(0, 0, 0, BG_alpha))
	else:
		for i in len(whites_p):
			var shade = whites_p[i]
			draw_rect(Rect2((i%wid_p2)*200.0/LOD, i/wid_p2*200.0/LOD, 200.0/LOD, 200.0/LOD), Color(0.0, 0.0, 0.0, 1.0 - shade))


var start_time:float
var curr_time:float
var video_time:float

func _process(delta):
	if phase == 0:
		BG_alpha += delta
		queue_redraw()
		if BG_alpha >= 1.0:
			phase = 1
	elif phase == 1:
		if curr_time >= video_time:
			var frames_to_process = int(ceil(game.u_i.time_speed / Engine.max_fps * 30.0))
			draw_frame(frames_to_process)
			video_time += 1/30.0 / game.u_i.time_speed * frames_to_process
		curr_time += delta
	elif phase == 2:
		BG_alpha -= delta * 4.0
		queue_redraw()
		if BG_alpha <= 0.0:
			phase = 0
			set_process(false)


func draw_frame(frames_to_process:int):
	for h in frames_to_process:
		var pixelsStr = frames[frame].split(";")#pixelsStr = ["119,41", "119,42", ...]
		if len(pixelsStr) > 1:
			for pixelStr in pixelsStr:
				var pixelCoords = pixelStr.split(",")
				if len(pixelCoords) > 1:
					var y_coord = int(pixelCoords[-1])
					var prev_x = -1
					for i in range(0, len(pixelCoords)-1):
						var x_coord = int(pixelCoords[i])
						if i%2 == 1:
							for j in range(prev_x, x_coord):
								var ind = j + y_coord * W
								whites[ind] = not whites[ind]
								var x_p = int(j / float(W) * wid_p2)
								var y_p = int(y_coord / float(H) * hv2 + h_start)
								var ind_p = x_p + y_p * wid_p2
								whites_p[ind_p] += coefficients[ind_p] if whites[ind] else -coefficients[ind_p]
								white_pixel_num += 1 if whites[ind] else -1
							prev_x = -1
						else:
							prev_x = x_coord
					if prev_x != -1:
						for j in range(prev_x, W):
							var ind = j + y_coord * W
							whites[ind] = not whites[ind]
							var x_p = int(j / float(W) * wid_p2)
							var y_p = int(y_coord / float(H) * hv2 + h_start)
							var ind_p = x_p + y_p * wid_p2
							whites_p[ind_p] += coefficients[ind_p] if whites[ind] else -coefficients[ind_p]
							white_pixel_num += 1 if whites[ind] else -1
		frame += 1
	queue_redraw()
	if frame >= len(frames):
		phase = 2
		frame = 0
