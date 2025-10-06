class_name Pedestrian
extends Enemy


const SPLATTER_VFX_SCENE := preload("res://src/enemy/splatter_vfx.tscn")

const FLASHLIGHT_ROTATION_MIN := 15.0
const FLASHLIGHT_ROTATION_MAX := 48.0

const FLASHLIGHT_ROTATION_PERIOD_MIN := 6.0
const FLASHLIGHT_ROTATION_PERIOD_MAX := 9.0


var abducting_audio_player: AudioStreamPlayer2D
var falling_audio_player: AudioStreamPlayer2D
var splat_audio_player: AudioStreamPlayer
var detect_audio_player: AudioStreamPlayer2D
var running_audio_player: AudioStreamPlayer2D
var gunshot_audio_player: AudioStreamPlayer2D

var splatter_vfx: CPUParticles2D

var flashlight_rotation_period := FLASHLIGHT_ROTATION_PERIOD_MAX
var flashlight_rotation_elapsed_time := 0.0


func _ready() -> void:
    super._ready()
    splatter_vfx = SPLATTER_VFX_SCENE.instantiate()
    add_child(splatter_vfx)


func _physics_process(delta: float) -> void:
    super._physics_process(delta)

    if is_searching and type == Type.POLICE_OFFICER:
        flashlight_rotation_elapsed_time += delta
        var flashlight_rotation_progress := fmod(
            flashlight_rotation_elapsed_time,
            flashlight_rotation_period) / flashlight_rotation_period
        flashlight_rotation_progress = sin(TAU * flashlight_rotation_progress)
        var flashlight_rotation := lerpf(
            FLASHLIGHT_ROTATION_MIN,
            FLASHLIGHT_ROTATION_MAX,
            flashlight_rotation_progress)
        get_flashlight_wrapper().rotation = flashlight_rotation / 180.0 * PI


func setup_sound() -> void:
    abducting_audio_player = sound_scene.get_node("AbductingAudioStream")
    falling_audio_player = sound_scene.get_node("FallingStreamPlayer")
    splat_audio_player = sound_scene.get_node("SplatStreamPlayer")
    detect_audio_player = sound_scene.get_node("DetectStreamPlayer2D")
    running_audio_player = sound_scene.get_node("RunningStreamPlayer2D")
    gunshot_audio_player = sound_scene.get_node("GunshotStreamPlayer2D")


func _on_done_running_away() -> void:
    super._on_done_running_away()
    if running_audio_player.playing:
        running_audio_player.stop()


func on_beam_start() -> void:
    if is_dead():
        return

    # Beaming enemies don't count toward the detection score.
    if is_alerted():
        G.game_panel.remove_alerted_enemy(self)

    state = State.BEING_BEAMED

    # AUDIO: Abduction
    if running_audio_player.playing:
        running_audio_player.stop()

    if not abducting_audio_player.playing:
        abducting_audio_player.play()

    # Trigger detection on any other enemy that can currently see this pedestrian.
    for enemy in G.enemies:
        if enemy == self:
            continue
        if not is_instance_valid(enemy):
            continue
        if enemy.visible_enemies.has(self):
            enemy._on_ufo_detected()

    # Mark player as seen so that if dropped the pedestrian will run.
    was_player_recently_detected = true
    last_player_sighting_time = Time.get_ticks_msec() / 1000.0


func on_beam_end() -> void:
    if is_dead():
        return

    state = get_alerted_state()

    was_dropped_from_lethal_height = abs(global_position.y) > LETHAL_DROP_HEIGHT

    # If they are going to survive the fall, they count toward the detection score.
    if not was_dropped_from_lethal_height:
        _on_alerted()

    # AUDIO: Falling
    if abducting_audio_player.playing:
        abducting_audio_player.stop()

    if not falling_audio_player.playing:
        falling_audio_player.play()


func _on_landed() -> void:
    var dropped_from_lethal_height := was_dropped_from_lethal_height
    super._on_landed()

    if is_dead():
        return

    # Sanitize some transform garbage...
    global_rotation = 0
    global_scale = Vector2.ONE
    rotation = 0
    scale = Vector2.ONE
    if not is_facing_right:
        scale.x = -1

    if dropped_from_lethal_height:
        _on_killed()
        return

    if falling_audio_player.playing:
        falling_audio_player.stop()


func _on_killed() -> void:
    super._on_killed()

    splatter_vfx.emitting = true

    # AUDIO: Splat
    if falling_audio_player.playing:
        falling_audio_player.stop()

    if not splat_audio_player.playing:
        splat_audio_player.play()


func on_collected() -> void:
    # AUDIO: Capture
    if abducting_audio_player.playing:
        abducting_audio_player.stop()
    destroy()
    G.game_panel.enemy_spawner.spawn_enemy(type)


func _on_alerted() -> void:
    super._on_alerted()

    # Jump in fear.
    velocity.x = 0
    velocity.y = - get_jump_boost()
    was_on_floor = false

    # AUDIO: SCREAM
    if not detect_audio_player.playing:
        detect_audio_player.play()

    await get_tree().create_timer(0.5).timeout

    if state == State.FLEEING:
        if not running_audio_player.playing:
            running_audio_player.play()
    elif state == State.CHASING:
        # TODO(ALDEN): Sound me up, baby
        pass


func assign_config() -> void:
    super.assign_config()
    flashlight_rotation_period = randf_range(FLASHLIGHT_ROTATION_PERIOD_MIN, FLASHLIGHT_ROTATION_PERIOD_MAX)
    flashlight_rotation_elapsed_time = randf() * flashlight_rotation_period


func get_flashlight_wrapper() -> Node2D:
    return get_node("Light")


func get_flashlight_area_wrapper() -> Area2D:
    return get_node("Light/LightArea")


func _set_is_searching(value: bool) -> void:
    super._set_is_searching(value)
    get_flashlight_wrapper().visible = value
    get_flashlight_area_wrapper().monitoring = value


func _on_light_area_body_entered(body: Node2D) -> void:
    if body is Player:
        _on_ufo_detected()


func _on_light_area_body_exited(body: Node2D) -> void:
    if body is Player:
        _on_ufo_detected()
