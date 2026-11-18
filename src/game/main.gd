extends Node3D

var player: CharacterBody3D
var camera: Camera3D
var score: int = 0
var high_score: int = 0
var game_running: bool = false
var speed: float = 10.0
var max_speed: float = 30.0
var lane_width: float = 4.0
var segments: Array = []
var segment_length: float = 20.0
var next_spawn_z: float = 0.0

@onready var ui_layer = CanvasLayer.new()
@onready var score_label = Label.new()
@onready var start_panel = Panel.new()
@onready var game_over_panel = Panel.new()

func _ready():
	setup_environment()
	setup_ui()
	load_high_score()
	reset_game()

func setup_environment():
	var env = WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color(0.05, 0.02, 0.1)
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	add_child(env)

	var sun = DirectionalLight3D.new()
	sun.transform.basis = Basis(Vector3(1, -1, -1).normalized(), deg_to_rad(-45))
	sun.shadow_enabled = true
	add_child(sun)

	player = CharacterBody3D.new()
	var mesh = MeshInstance3D.new()
	mesh.mesh = SphereMesh.new()
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color.CYAN
	mat.metallic = 0.5
	mat.roughness = 0.2
	mesh.material_override = mat
	player.add_child(mesh)
	var col = CollisionShape3D.new()
	col.shape = SphereShape3D.new()
	player.add_child(col)
	add_child(player)
	player.position = Vector3(0, 1, 0)

	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(0, 5, 8)
	camera.rotation_degrees = Vector3(-25, 0, 0)

func setup_ui():
	add_child(ui_layer)
	
	score_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.text = " النقاط: 0"
	ui_layer.add_child(score_label)

	# Start Panel
	start_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(start_panel)
	var start_btn = Button.new()
	start_btn.text = "ابدأ اللعب"
	start_btn.set_anchors_preset(Control.PRESET_CENTER)
	start_btn.custom_minimum_size = Vector2(200, 80)
	start_btn.add_theme_font_size_override("font_size", 40)
	start_btn.pressed.connect(start_game)
	start_panel.add_child(start_btn)
	
	# Game Over Panel
	game_over_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_panel.visible = false
	ui_layer.add_child(game_over_panel)
	var go_vbox = VBoxContainer.new()
	go_vbox.set_anchors_preset(Control.PRESET_CENTER)
	game_over_panel.add_child(go_vbox)
	var go_label = Label.new()
	go_label.text = "انتهت اللعبة!"
	go_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	go_label.add_theme_font_size_override("font_size", 60)
	go_vbox.add_child(go_label)
	var restart_btn = Button.new()
	restart_btn.text = "إعادة المحاولة"
	restart_btn.add_theme_font_size_override("font_size", 40)
	restart_btn.pressed.connect(reset_game)
	go_vbox.add_child(restart_btn)

func start_game():
	start_panel.visible = false
	game_over_panel.visible = false
	game_running = true
	score = 0
	speed = 10.0
	update_score_label()

func reset_game():
	game_running = false
	for s in segments:
		s.queue_free()
	segments.clear()
	next_spawn_z = 0.0
	player.position = Vector3(0, 1, 0)
	for i in range(10):
		spawn_segment()
	start_panel.visible = true
	game_over_panel.visible = false

func spawn_segment():
	var node = Node3D.new()
	var floor_mesh = MeshInstance3D.new()
	floor_mesh.mesh = PlaneMesh.new()
	floor_mesh.mesh.size = Vector2(lane_width * 3, segment_length)
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.1, 0.2)
	floor_mesh.material_override = mat
	node.add_child(floor_mesh)
	node.position.z = next_spawn_z - segment_length / 2.0
	
	if next_spawn_z < -20:
		# Spawn obstacles
		if randf() > 0.4:
			spawn_object(node, "obstacle")
		# Spawn stars
		if randf() > 0.5:
			spawn_object(node, "star")
	
	add_child(node)
	segments.append(node)
	next_spawn_z -= segment_length

func spawn_object(parent, type):
	var obj = Area3D.new()
	var mesh = MeshInstance3D.new()
	var col = CollisionShape3D.new()
	if type == "obstacle":
		mesh.mesh = BoxMesh.new()
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.RED
		mesh.material_override = mat
		col.shape = BoxShape3D.new()
		obj.add_to_group("obstacles")
	else:
		mesh.mesh = PrismMesh.new()
		mesh.scale = Vector3(0.6, 0.6, 0.2)
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color.GOLD
		mat.emission_enabled = true
		mat.emission = Color.GOLD
		mesh.material_override = mat
		col.shape = SphereShape3D.new()
		obj.add_to_group("stars")
	
	obj.add_child(mesh)
	obj.add_child(col)
	obj.position = Vector3(randf_range(-lane_width, lane_width), 1, randf_range(-segment_length/2, segment_length/2))
	parent.add_child(obj)
	obj.body_entered.connect(_on_body_entered.bind(obj, type))

func _on_body_entered(body, obj, type):
	if body == player:
		if type == "obstacle":
			game_over()
		else:
			score += 10
			update_score_label()
			obj.queue_free()

func game_over():
	game_running = false
	game_over_panel.visible = true
	if score > high_score:
		high_score = score
		save_high_score()

func update_score_label():
	score_label.text = " النقاط: %d  |  الأعلى: %d" % [score, high_score]

func _process(delta):
	if not game_running: return
	
	speed = min(max_speed, speed + delta * 0.1)
	player.velocity.z = -speed
	player.move_and_slide()
	
	camera.position.z = player.position.z + 8
	camera.position.x = lerp(camera.position.x, player.position.x, 0.1)
	
	if player.position.z < segments[0].position.z - segment_length:
		var old = segments.pop_front()
		old.queue_free()
		spawn_segment()
	
	if player.position.y < -2:
		game_over()

func _input(event):
	if not game_running: return
	if event is InputEventScreenDrag:
		player.position.x += event.relative.x * 0.02
		player.position.x = clamp(player.position.x, -lane_width * 1.5, lane_width * 1.5)

func save_high_score():
	var file = FileAccess.open("user://save.json", FileAccess.WRITE)
	var data = {"high_score": high_score}
	file.store_string(JSON.stringify(data))

func load_high_score():
	if FileAccess.file_exists("user://save.json"):
		var file = FileAccess.open("user://save.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data and data.has("high_score"):
			high_score = data["high_score"]
			update_score_label()
