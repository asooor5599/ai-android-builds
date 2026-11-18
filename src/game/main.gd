extends Node2D

var bird: CharacterBody2D
var pipes: Node2D
var score_label: Label
var high_score_label: Label
var start_screen: Control
var game_over_screen: Control
var score: int = 0
var high_score: int = 0
var game_active: bool = false
var pipe_scene_timer: float = 0.0
var spawn_interval: float = 2.0

const GRAVITY = 1200.0
const FLAP_FORCE = -400.0
const PIPE_SPEED = 200.0
const SAVE_PATH = "user://highscore.json"

func _ready():
	load_high_score()
	setup_ui()
	setup_game_world()
	show_start_screen()

func setup_game_world():
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.4, 0.7, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = get_viewport_rect().size
	add_child(bg)

	# Pipes Container
	pipes = Node2D.new()
	add_child(pipes)

	# Bird
	bird = CharacterBody2D.new()
	var bird_poly = Polygon2D.new()
	bird_poly.polygon = PackedVector2Array([Vector2(-20, -15), Vector2(20, 0), Vector2(-20, 15)])
	bird_poly.color = Color.YELLOW
	bird.add_child(bird_poly)
	
	var bird_col = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 15.0
	bird_col.shape = shape
	bird.add_child(bird_col)
	
	bird.position = Vector2(150, get_viewport_rect().size.y / 2)
	bird.visible = false
	add_child(bird)

func setup_ui():
	var canvas = CanvasLayer.new()
	add_child(canvas)

	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 64)
	score_label.text = "0"
	score_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	score_label.position.y = 50
	canvas.add_child(score_label)

	# Start Screen
	start_screen = Control.new()
	start_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(start_screen)
	
	var start_btn = Button.new()
	start_btn.text = "ابدأ اللعبة"
	start_btn.add_theme_font_size_override("font_size", 48)
	start_btn.custom_minimum_size = Vector2(250, 100)
	start_btn.set_anchors_preset(Control.PRESET_CENTER)
	start_btn.pressed.connect(start_game)
	start_screen.add_child(start_btn)

	# Game Over Screen
	game_over_screen = Control.new()
	game_over_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	game_over_screen.visible = false
	canvas.add_child(game_over_screen)

	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(400, 300)
	game_over_screen.add_child(panel)

	var go_label = Label.new()
	go_label.text = "انتهت اللعبة"
	go_label.add_theme_font_size_override("font_size", 40)
	go_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	go_label.position.y = 20
	panel.add_child(go_label)

	high_score_label = Label.new()
	high_score_label.add_theme_font_size_override("font_size", 24)
	high_score_label.set_anchors_preset(Control.PRESET_CENTER)
	high_score_label.position.y = -20
	panel.add_child(high_score_label)

	var restart_btn = Button.new()
	restart_btn.text = "إعادة المحاولة"
	restart_btn.add_theme_font_size_override("font_size", 32)
	restart_btn.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	restart_btn.position.y = -40
	restart_btn.pressed.connect(get_tree().reload_current_scene)
	panel.add_child(restart_btn)

func start_game():
	game_active = true
	bird.visible = true
	start_screen.visible = false
	score = 0
	score_label.text = "0"

func _physics_process(delta):
	if not game_active: return

	bird.velocity.y += GRAVITY * delta
	var collision = bird.move_and_collide(bird.velocity * delta)
	if collision or bird.position.y > get_viewport_rect().size.y or bird.position.y < 0:
		game_over()

	pipe_scene_timer += delta
	if pipe_scene_timer >= spawn_interval:
		spawn_pipe()
		pipe_scene_timer = 0

	for pipe in pipes.get_children():
		pipe.position.x -= PIPE_SPEED * delta
		if pipe.position.x < -100:
			pipe.queue_free()
		elif not pipe.get_meta("passed") and pipe.position.x < bird.position.x:
			pipe.set_meta("passed", true)
			score += 1
			score_label.text = str(score)

func _input(event):
	if game_active and (event is InputEventScreenTouch or event is InputEventMouseButton):
		if event.pressed:
			bird.velocity.y = FLAP_FORCE

func spawn_pipe():
	var pipe_node = Node2D.new()
	pipe_node.position = Vector2(get_viewport_rect().size.x + 100, randf_range(200, get_viewport_rect().size.y - 200))
	pipe_node.set_meta("passed", false)
	pipes.add_child(pipe_node)

	var gap = 200
	var pipe_width = 80
	var screen_height = get_viewport_rect().size.y

	# Top Pipe
	var top_pipe = StaticBody2D.new()
	var top_rect = ColorRect.new()
	top_rect.color = Color.GREEN
	top_rect.size = Vector2(pipe_width, screen_height)
	top_rect.position = Vector2(-pipe_width/2, -screen_height - gap/2)
	top_pipe.add_child(top_rect)
	var top_col = CollisionShape2D.new()
	var top_shape = RectangleShape2D.new()
	top_shape.size = Vector2(pipe_width, screen_height)
	top_col.shape = top_shape
	top_col.position = Vector2(0, -screen_height/2 - gap/2)
	top_pipe.add_child(top_col)
	pipe_node.add_child(top_pipe)

	# Bottom Pipe
	var bot_pipe = StaticBody2D.new()
	var bot_rect = ColorRect.new()
	bot_rect.color = Color.GREEN
	bot_rect.size = Vector2(pipe_width, screen_height)
	bot_rect.position = Vector2(-pipe_width/2, gap/2)
	bot_pipe.add_child(bot_rect)
	var bot_col = CollisionShape2D.new()
	var bot_shape = RectangleShape2D.new()
	bot_shape.size = Vector2(pipe_width, screen_height)
	bot_col.shape = bot_shape
	bot_col.position = Vector2(0, screen_height/2 + gap/2)
	bot_pipe.add_child(bot_col)
	pipe_node.add_child(bot_pipe)

func game_over():
	game_active = false
	if score > high_score:
		high_score = score
		save_high_score()
	high_score_label.text = "أعلى نتيجة: " + str(high_score)
	game_over_screen.visible = true

func show_start_screen():
	start_screen.visible = true
	game_over_screen.visible = false

func save_high_score():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {"high_score": high_score}
	file.store_string(JSON.stringify(data))

func load_high_score():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		if data and data.has("high_score"):
			high_score = data["high_score"]
