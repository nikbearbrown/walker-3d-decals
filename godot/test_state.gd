extends SceneTree

var failures := 0
func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func key(code: Key) -> void:
	for down in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = down
		root.push_input(event, true)
		await process_frame

func run() -> void:
	root.size = Vector2i(1280, 720)
	var demo: Node = load("res://test.tscn").instantiate()
	root.add_child(demo)
	await process_frame
	await process_frame
	for index in demo.testers.get_child_count():
		check(demo.tester_index == index and demo.get_node("TestName").text == str(demo.testers.get_child(index).name).capitalize(), "navigation " + str(index))
		await key(KEY_RIGHT)
	check(demo.get_node("Next").disabled, "last navigation clamped")
	for index in demo.testers.get_child_count():
		await key(KEY_LEFT)
	check(demo.tester_index == 0 and demo.get_node("Previous").disabled, "first navigation clamped")
	var yaw: float = demo.rot_y
	var motion := InputEventMouseMotion.new()
	motion.position = Vector2(640, 360)
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT
	motion.screen_relative = Vector2(50, 20)
	root.push_input(motion, true)
	await process_frame
	check(absf(demo.rot_y - (yaw - 0.15)) < 0.0001, "drag rotates camera")
	for button in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_UP]:
		for step in 30:
			var wheel := InputEventMouseButton.new()
			wheel.position = Vector2(640, 360)
			wheel.button_index = button
			wheel.pressed = true
			root.push_input(wheel, true)
		await process_frame
		check(is_equal_approx(demo.zoom, 4.0 if button == MOUSE_BUTTON_WHEEL_DOWN else 1.5), "zoom limit " + str(button))
	var option: OptionButton = demo.get_node("DecalFilterMode/OptionButton")
	var selections: Array[int] = []
	option.item_selected.connect(func(index: int): selections.append(index))
	for target in [0, 1, 2, 3, 4, 5]:
		option.grab_focus()
		await key(KEY_SPACE)
		var popup := option.get_popup()
		var steps := posmod(target - popup.get_focused_item(), option.item_count)
		for step in steps:
			await key(KEY_DOWN)
		await key(KEY_ENTER)
		check(option.selected == target and not selections.is_empty() and selections.back() == target, "filter input selection " + str(target))
	option.release_focus()
	await create_timer(0.6).timeout
	var pointer := InputEventMouseMotion.new()
	pointer.position = Vector2(640, 480)
	pointer.global_position = pointer.position
	Input.parse_input_event(pointer)
	await physics_frame
	await process_frame
	var children_before: int = demo.get_child_count()
	print("RAY pointer=", root.get_mouse_position(), " camera=", demo.camera.global_position)
	var ray := PhysicsRayQueryParameters3D.create(demo.camera.global_position, demo.camera.project_position(root.get_mouse_position(), 100))
	print("RAY hit=", demo.camera.get_world_3d().direct_space_state.intersect_ray(ray))
	await key(KEY_P)
	check(demo.get_child_count() == children_before + 1, "P-key ray places decal")
	# Separate instantiated animation fixture: no claim of ray placement.
	var holder: Node3D = load("res://decal.tscn").instantiate()
	demo.add_child(holder)
	var decal: Decal = holder.get_node("Decal")
	await create_timer(0.3).timeout
	print("OBSERVED decal size ", decal.size)
	check(decal.size.x > 0.5, "decal growth animation affects size")
	await create_timer(2.3).timeout
	check(decal.modulate.a < 0.6 and decal.modulate.a > 0.2, "decal fades over time")
	await create_timer(2.6).timeout
	check(not is_instance_valid(holder), "decal expires after five seconds")
	print("RESULT failures=", failures, "; headless state, not GPU appearance")
	quit(1 if failures else 0)
