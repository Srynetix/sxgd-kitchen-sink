extends Control

@onready var background := $Background as Node2D
@onready var effect_selection := $UI/Margin/Margin/HBox/EffectType/Value as OptionButton
@onready var params := $UI/Margin/Margin/HBox/Params as VBoxContainer
@onready var vignette := $Effects/SxFxVignette as SxFxVignette
@onready var shockwave := $Effects/SxFxShockwave as SxFxShockwave
@onready var motion_blur := $Effects/SxFxMotionBlur as SxFxMotionBlur
@onready var better_blur := $Effects/SxFxBetterBlur as SxFxBetterBlur
@onready var dissolve := $Effects/SxFxDissolve as SxFxDissolve
@onready var grayscale := $Effects/SxFxGrayscale as SxFxGrayscale
@onready var chroma := $Effects/SxFxChromaticAberration as SxFxChromaticAberration
@onready var texture := load("res://addons/sxgd/assets/textures/icon.png") as Texture2D

var _sprites := Array()
var _touched := false
var _last_touched_position := Vector2()

class FloatParamOptions:
    var step := 0.01
    var min_value := 0.0
    var max_value := 9999.0
    var min_size_x := 50.0

    func with_step(value: float) -> FloatParamOptions:
        self.step = value
        return self

    func with_min_value(value: float) -> FloatParamOptions:
        self.min_value = value
        return self

    func with_max_value(value: float) -> FloatParamOptions:
        self.max_value = value
        return self


func _ready() -> void:
    var viewport_size := get_viewport_rect().size

    var sprite_count := 50
    for _i in range(sprite_count):
        var sprite := Sprite2D.new()
        sprite.texture = texture
        sprite.scale = Vector2(randf_range(0.5, 2), randf_range(0.5, 2))
        sprite.position = Vector2(randf_range(0, viewport_size.x), randf_range(0, viewport_size.y))
        sprite.modulate = SxColor.rand()
        sprite.rotation_degrees = randf_range(0, 360)

        _sprites.append(sprite)
        background.add_child(sprite)

    effect_selection.add_item("Vignette")
    effect_selection.add_item("Shockwave")
    effect_selection.add_item("MotionBlur")
    effect_selection.add_item("BetterBlur")
    effect_selection.add_item("Dissolve")
    effect_selection.add_item("Grayscale")
    effect_selection.add_item("ChromaticAberration")
    effect_selection.item_selected.connect(_on_item_selected)

    _on_item_selected(0)

func _process(delta: float) -> void:
    var viewport_size := get_viewport_rect().size

    for spr in _sprites:
        var sprite := spr as Sprite2D
        var sprite_position := sprite.position
        var sprite_rotation := sprite.rotation_degrees
        var texture_size := sprite.texture.get_size()
        var total_size := sprite.scale * texture_size

        sprite_position.x -= sprite.scale.x * 100 * delta
        sprite_rotation += sprite.scale.y * 10 * delta

        while sprite_rotation > 360:
            sprite_rotation -= 360

        if sprite_position.x < -total_size.x:
            sprite_position.x = viewport_size.x + total_size.x
        elif sprite_position.x > viewport_size.x + total_size.x:
            sprite_position.x = -total_size.x

        sprite.rotation_degrees = sprite_rotation
        sprite.position = sprite_position

    var selected_idx := effect_selection.selected
    var selected_effect := effect_selection.get_item_text(selected_idx)
    _update_params(selected_effect)

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        var mouse_btn_event := event as InputEventMouseButton
        _touched = mouse_btn_event.pressed
        if mouse_btn_event.pressed:
            _last_touched_position = mouse_btn_event.position
            _on_touch_position_update()

    elif event is InputEventMouseMotion:
        var mouse_mot_event := event as InputEventMouseMotion
        if _touched:
            _last_touched_position = mouse_mot_event.position
            _on_touch_position_update()

    elif event is InputEventScreenTouch:
        var touch_event := event as InputEventScreenTouch
        if _touched:
            _last_touched_position = touch_event.position
            _on_touch_position_update()

func _build_params(effect: String) -> void:
    for node in params.get_children():
        node.queue_free()
        params.remove_child(node)

    match effect:
        "Vignette":
            _pr_visible(vignette)
            _pr_float(vignette, "vignette_size")
            _pr_float(vignette, "vignette_ratio")

        "Shockwave":
            _pr_visible(shockwave)
            _pr_float(shockwave, "wave_size", FloatParamOptions.new().with_max_value(1))
            _pr_float(shockwave, "force", FloatParamOptions.new().with_max_value(1))
            _pr_float(shockwave, "thickness", FloatParamOptions.new().with_max_value(1))
            _pr_vector2(shockwave, "wave_center")

            var hbox := HBoxContainer.new()
            hbox.size_flags_horizontal = SIZE_EXPAND_FILL
            var btn := Button.new()
            btn.text = "Animate"
            btn.size_flags_horizontal = SIZE_EXPAND_FILL
            btn.pressed.connect(_animate_shockwave)
            hbox.add_child(btn)
            params.add_child(hbox)

        "MotionBlur":
            _pr_visible(motion_blur)
            _pr_float(motion_blur, "strength")
            _pr_float(motion_blur, "angle_degrees")

        "BetterBlur":
            _pr_visible(better_blur)
            _pr_float(better_blur, "strength")

        "Dissolve":
            _pr_visible(dissolve)
            _pr_float(dissolve, "ratio")
            _pr_color(dissolve, "replacement_color")
            _pr_float(
                dissolve,
                "noise_frequency",
                FloatParamOptions.new()\
                    .with_min_value(0.01)\
                    .with_max_value(1.0)
            )

        "Grayscale":
            _pr_visible(grayscale)
            _pr_float(grayscale, "ratio", FloatParamOptions.new().with_min_value(0.0).with_max_value(1.0))

        "ChromaticAberration":
            _pr_visible(chroma)
            _pr_float(chroma, "amount", FloatParamOptions.new().with_min_value(0.0).with_max_value(5.0))

func _update_params(effect: String) -> void:
    match effect:
        "Vignette":
            params.get_node("VignetteRatio/Value").value = vignette.vignette_ratio
            params.get_node("VignetteSize/Value").value = vignette.vignette_size

        "Shockwave":
            var center := shockwave.wave_center
            params.get_node("WaveCenter/VBox/X").value = center.x
            params.get_node("WaveCenter/VBox/Y").value = center.y
            params.get_node("Force/Value").value = shockwave.force
            params.get_node("Thickness/Value").value = shockwave.thickness
            params.get_node("WaveSize/Value").value = shockwave.wave_size

        "MotionBlur":
            params.get_node("Strength/Value").value = motion_blur.strength
            params.get_node("AngleDegrees/Value").value = motion_blur.angle_degrees

        "BetterBlur":
            params.get_node("Strength/Value").value = better_blur.strength

        "Dissolve":
            params.get_node("Ratio/Value").value = dissolve.ratio
            params.get_node("NoiseFrequency/Value").value = dissolve.noise_frequency
            params.get_node("ReplacementColor/Value").color = dissolve.replacement_color

        "Grayscale":
            params.get_node("Ratio/Value").value = grayscale.ratio

        "ChromaticAberration":
            params.get_node("Amount/Value").value = chroma.amount

func _set_effect_visibility(value: bool, obj: Control) -> void:
    match obj.name:
        "ChromaticAberration":
            chroma.enabled = value
    obj.visible = value

func _pr_visible(control: Control) -> void:
    var visible_hbox := HBoxContainer.new()
    visible_hbox.size_flags_horizontal = SIZE_EXPAND_FILL
    var visible_label := Label.new()
    visible_label.text = "Visible"
    visible_label.custom_minimum_size = Vector2(40, 0)
    var visible_checkbox := CheckBox.new()
    visible_checkbox.size_flags_horizontal = SIZE_EXPAND_FILL
    visible_checkbox.button_pressed = control.visible

    visible_checkbox.toggled.connect(_set_effect_visibility.bind(control))
    visible_hbox.add_child(visible_label)
    visible_hbox.add_child(visible_checkbox)
    params.add_child(visible_hbox)

func _pr_color(control: Control, pr_name: String) -> void:
    var cap_name = SxText.to_pascal_case(pr_name)
    var current := control.get(pr_name) as Color
    var hbox = HBoxContainer.new()
    hbox.name = cap_name
    hbox.size_flags_horizontal = SIZE_EXPAND_FILL
    var label_obj := Label.new()
    label_obj.name = "Label"
    label_obj.text = cap_name
    var input := ColorPickerButton.new()
    input.name = "Value"
    input.size_flags_horizontal = SIZE_EXPAND_FILL
    input.color = current

    input.color_changed.connect(_on_value_changed_color.bind(control, pr_name))
    hbox.add_child(label_obj)
    hbox.add_child(input)
    params.add_child(hbox)

func _pr_float(control: Control, pr_name: String, opts: FloatParamOptions = null) -> void:
    if opts == null:
        opts = FloatParamOptions.new()

    var cap_name := SxText.to_pascal_case(pr_name)
    var current := control.get(pr_name) as float
    var hbox := HBoxContainer.new()
    hbox.name = cap_name
    hbox.size_flags_horizontal = SIZE_EXPAND_FILL
    var label_obj := Label.new()
    label_obj.name = "Label"
    label_obj.text = cap_name
    label_obj.custom_minimum_size = Vector2(opts.min_size_x, 0)
    var input := SpinBox.new()
    input.name = "Value"
    input.size_flags_horizontal = SIZE_EXPAND_FILL
    input.step = opts.step
    input.min_value = opts.min_value
    input.max_value = opts.max_value
    input.value = current

    input.value_changed.connect(_on_value_changed.bind(control, pr_name))
    hbox.add_child(label_obj)
    hbox.add_child(input)
    params.add_child(hbox)

func _pr_vector2(control: Control, pr_name: String, step: float = 0.01, min_size_x: float = 50) -> void:
    var cap_name := SxText.to_pascal_case(pr_name)
    var current := control.get(pr_name) as Vector2
    var hbox := HBoxContainer.new()
    hbox.name = cap_name
    hbox.size_flags_horizontal = SIZE_EXPAND_FILL
    var label_obj := Label.new()
    label_obj.name = "Label"
    label_obj.text = cap_name
    label_obj.custom_minimum_size = Vector2(min_size_x, 0)
    var vbox := VBoxContainer.new()
    vbox.name = "VBox"
    vbox.size_flags_horizontal = SIZE_EXPAND_FILL
    var input_x := SpinBox.new()
    input_x.name = "X"
    input_x.size_flags_horizontal = SIZE_EXPAND_FILL
    input_x.max_value = 9999
    input_x.step = step
    input_x.value = current.x
    var input_y := SpinBox.new()
    input_y.name = "Y"
    input_y.size_flags_horizontal = SIZE_EXPAND_FILL
    input_y.max_value = 9999
    input_y.step = step
    input_y.value = current.y

    input_x.value_changed.connect(_on_value_changed_vector2.bind("x", control, pr_name))
    input_y.value_changed.connect(_on_value_changed_vector2.bind("y", control, pr_name))
    vbox.add_child(input_x)
    vbox.add_child(input_y)
    hbox.add_child(label_obj)
    hbox.add_child(vbox)
    params.add_child(hbox)

func _update_shader(obj: Control, pr_name: String, value: Variant) -> void:
    obj.set(pr_name, value)

func _animate_shockwave():
    var x := params.get_node("WaveCenter/VBox/X") as SpinBox
    var y := params.get_node("WaveCenter/VBox/Y") as SpinBox
    shockwave.start_wave(Vector2(x.value, y.value))

func _on_value_changed(value: float, obj: Control, pr_name: String) -> void:
    _update_shader(obj, pr_name, value)

func _on_value_changed_color(value: Color, obj: Control, pr_name: String) -> void:
    _update_shader(obj, pr_name, value)

func _on_value_changed_vector2(value: float, coord: String, obj: Control, pr_name: String) -> void:
    var current := obj.get(pr_name) as Vector2

    if coord == "x":
        _update_shader(obj, pr_name, Vector2(value, current.y))
    else:
        _update_shader(obj, pr_name, Vector2(current.x, value))

func _on_touch_position_update() -> void:
    var viewport_size := get_viewport_rect().size
    var selected_idx := effect_selection.selected
    var effect_name := effect_selection.get_item_text(selected_idx)

    if effect_name == "Shockwave":
        var x := params.get_node("WaveCenter/VBox/X") as SpinBox
        var y := params.get_node("WaveCenter/VBox/Y") as SpinBox
        x.value = _last_touched_position.x / viewport_size.x
        y.value = 1 - _last_touched_position.y / viewport_size.y

func _on_item_selected(index: int) -> void:
    var effect := effect_selection.get_item_text(index)
    _build_params(effect)
