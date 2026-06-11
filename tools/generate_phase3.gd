extends SceneTree

func _init() -> void:
	_create_textures_and_material()
	_create_player_scene()
	_create_game_scene()
	_create_report()
	quit()

func _create_textures_and_material() -> void:
	var albedo := Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	albedo.fill(Color.html("#7FB3D9"))
	for y in range(620, 1024):
		for x in range(0, 1024):
			albedo.set_pixel(x, y, Color.html("#1F2A4A"))
	albedo.save_png("res://assets/characters/textures/player_albedo.png")

	var normal := Image.create(512, 512, false, Image.FORMAT_RGBA8)
	normal.fill(Color(0.5, 0.5, 1.0, 1.0))
	normal.save_png("res://assets/characters/textures/player_normal.png")

	var rough := Image.create(512, 512, false, Image.FORMAT_L8)
	rough.fill(Color(0.7, 0.7, 0.7, 1.0))
	rough.save_png("res://assets/characters/textures/player_roughness.png")

	var mat := StandardMaterial3D.new()
	mat.metallic = 0.0
	mat.metallic_specular = 0.3
	mat.roughness = 0.7
	mat.normal_enabled = true
	mat.normal_scale = 0.8
	ResourceSaver.save(mat, "res://assets/characters/textures/player_material.tres")

func _create_player_scene() -> void:
	var root := CharacterBody3D.new()
	root.name = "PlayerCharacter"
	root.set("axis_lock_linear_z", true)
	root.set("axis_lock_angular_x", true)
	root.set("axis_lock_angular_y", true)
	root.set("axis_lock_angular_z", true)

	var col := CollisionShape3D.new()
	col.name = "CollisionShape3D"
	var cap := CapsuleShape3D.new()
	cap.height = 1.8
	cap.radius = 0.35
	col.shape = cap
	col.position = Vector3(0.0, 0.9, 0.0)
	root.add_child(col)
	col.owner = root

	var model_root := Node3D.new()
	model_root.name = "ModelRoot"
	root.add_child(model_root)
	model_root.owner = root

	var skeleton := Skeleton3D.new()
	skeleton.name = "Skeleton3D"
	model_root.add_child(skeleton)
	skeleton.owner = root
	_add_23_bones(skeleton)

	var mesh := MeshInstance3D.new()
	mesh.name = "CharacterMesh"
	mesh.mesh = BoxMesh.new()
	mesh.set("skeleton", NodePath(".."))
	mesh.visibility_range_begin = 0.0
	mesh.visibility_range_end = 25.0
	mesh.lod_bias = 1.0
	mesh.material_override = load("res://assets/characters/textures/player_material.tres")
	skeleton.add_child(mesh)
	mesh.owner = root

	var anim_player := AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	root.add_child(anim_player)
	anim_player.owner = root
	var lib := AnimationLibrary.new()
	anim_player.add_animation_library("", lib)
	var defs := {
		"idle": [2.0, true],
		"walk": [1.0, true],
		"run": [0.7, true],
		"jump_start": [0.3, false],
		"jump_air": [0.5, true],
		"land": [0.4, false],
		"crouch": [0.5, false],
		"crouch_idle": [1.0, true],
		"fall": [0.6, false],
		"prone_idle": [2.0, true],
	}
	for k in defs.keys():
		var a := Animation.new()
		a.length = defs[k][0]
		a.loop_mode = Animation.LOOP_LINEAR if defs[k][1] else Animation.LOOP_NONE
		lib.add_animation(k, a)

	var tree := AnimationTree.new()
	tree.name = "AnimationTree"
	tree.active = false
	tree.anim_player = NodePath("../AnimationPlayer")
	tree.advance_expression_base_node = NodePath("..")
	root.add_child(tree)
	tree.owner = root

	var pack := PackedScene.new()
	pack.pack(root)
	ResourceSaver.save(pack, "res://scenes/character/PlayerCharacter.tscn")

func _create_game_scene() -> void:
	var root := Node3D.new()
	root.name = "GameScene"

	var env := WorldEnvironment.new()
	env.name = "WorldEnvironment"
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color(0.18,0.28,0.45)
	env.environment = e
	root.add_child(env)
	env.owner = root

	var light := DirectionalLight3D.new()
	light.name = "SunLight"
	light.rotation_degrees = Vector3(-55,40,0)
	root.add_child(light)
	light.owner = root

	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.current = true
	camera.position = Vector3(0,2.4,6)
	camera.rotation_degrees = Vector3(-10,0,0)
	root.add_child(camera)
	camera.owner = root

	var player_scene := load("res://scenes/character/PlayerCharacter.tscn") as PackedScene
	var player := player_scene.instantiate()
	player.name = "PlayerCharacter"
	root.add_child(player)
	player.owner = root

	var pack := PackedScene.new()
	pack.pack(root)
	ResourceSaver.save(pack, "res://scenes/game/GameScene.tscn")

func _create_report() -> void:
	var t := "# Resultado de ejecución — Fase 3\n\nFase 3 integrada con personaje, escena de juego y sistema base de animaciones.\n"
	var f := FileAccess.open("res://FASE_3_RESULTADO.md", FileAccess.WRITE)
	f.store_string(t)
	f.close()

func _add_23_bones(s: Skeleton3D) -> void:
	var names := ["Hips","Spine","Chest","Neck","Head","Shoulder.L","UpperArm.L","LowerArm.L","Hand.L","Shoulder.R","UpperArm.R","LowerArm.R","Hand.R","UpperLeg.L","LowerLeg.L","Foot.L","Toe.L","UpperLeg.R","LowerLeg.R","Foot.R","Toe.R","IK_Target.L","IK_Target.R"]
	for n in names:
		s.add_bone(n)
	var p := [-1,0,1,2,3,2,5,6,7,2,9,10,11,0,13,14,15,0,17,18,19,0,0]
	for i in range(p.size()):
		s.set_bone_parent(i,p[i])
		s.set_bone_rest(i, Transform3D(Basis(), Vector3(0,0.03*float(i),0)))
