extends Node3D

var player: MeshInstance3D
var obstacles: Array[MeshInstance3D] = []
var lane := 0
var speed := 12.0
var score := 0.0
var alive := true
var label: Label

func _ready() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	e.sky = sky
	env.environment = e
	add_child(env)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-50, 30, 0)
	light.shadow_enabled = true
	add_child(light)
	var ground := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(9, 400)
	ground.mesh = pm
	var gm := StandardMaterial3D.new()
	gm.albedo_color = Color(0.2, 0.25, 0.3)
	ground.material_override = gm
	ground.position = Vector3(0, 0, -180)
	add_child(ground)
	player = MeshInstance3D.new()
	player.mesh = BoxMesh.new()
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.1, 0.8, 0.5)
	player.material_override = mat
	player.position = Vector3(0, 0.5, 0)
	add_child(player)
	var cam := Camera3D.new()
	cam.position = Vector3(0, 4, 6)
	cam.rotation_degrees = Vector3(-25, 0, 0)
	add_child(cam)
	for i in 12:
		_spawn(-20.0 - i * 12.0)
	var hud := CanvasLayer.new()
	add_child(hud)
	label = Label.new()
	label.position = Vector2(20, 20)
	label.add_theme_font_size_override("font_size", 48)
	hud.add_child(label)

func _spawn(z: float) -> void:
	var o := MeshInstance3D.new()
	o.mesh = BoxMesh.new()
	var m := StandardMaterial3D.new()
	m.albedo_color = Color(0.9, 0.3, 0.2)
	o.material_override = m
	o.position = Vector3((randi() % 3 - 1) * 3.0, 0.5, z)
	add_child(o)
	obstacles.append(o)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag and abs(event.relative.x) > 20:
		lane = clamp(lane + (1 if event.relative.x > 0 else -1), -1, 1)
	elif event is InputEventScreenTouch and event.pressed and not alive:
		get_tree().reload_current_scene()

func _process(delta: float) -> void:
	if not alive:
		return
	score += delta * 10.0
	label.text = "النقاط: %d" % int(score)
	player.position.x = lerp(player.position.x, lane * 3.0, 10.0 * delta)
	for o in obstacles:
		o.position.z += speed * delta
		if o.position.z > 8.0:
			o.position.z -= 144.0
			o.position.x = (randi() % 3 - 1) * 3.0
		if abs(o.position.z - player.position.z) < 0.9 and abs(o.position.x - player.position.x) < 0.9:
			alive = false
			label.text = "انتهت اللعبة — النقاط: %d\nالمس للإعادة" % int(score)
