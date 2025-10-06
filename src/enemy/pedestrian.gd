class_name Pedestrian
extends Enemy


const SPLATTER_VFX_SCENE := preload("res://src/enemy/splatter_vfx.tscn")


var abducting_audio_player: AudioStreamPlayer2D
var falling_audio_player: AudioStreamPlayer2D
var splat_audio_player: AudioStreamPlayer
var detect_audio_player: AudioStreamPlayer2D
var running_audio_player: AudioStreamPlayer2D
var gunshot_audio_player: AudioStreamPlayer2D

var splatter_vfx: CPUParticles2D


func _ready() -> void:
    super._ready()
    splatter_vfx = SPLATTER_VFX_SCENE.instantiate()
    add_child(splatter_vfx)


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
            enemy._on_ufo_or_beamed_player_detection_start()

    # Mark player as seen so that if dropped the pedestrian will run.
    was_player_recently_visible = true
    last_player_sighting_time = Time.get_ticks_msec() / 1000.0


func on_beam_end() -> void:
    if is_dead():
        return

    state = get_alerted_state()

    # AUDIO: Falling
    if abducting_audio_player.playing:
        abducting_audio_player.stop()

    if not falling_audio_player.playing:
        falling_audio_player.play()


func _on_landed(landed_hard: bool) -> void:
    super._on_landed(landed_hard)

    if is_dead():
        return

    # Sanitize some transform garbage...
    global_rotation = 0
    global_scale = Vector2.ONE
    rotation = 0
    scale = Vector2.ONE
    if not is_facing_right:
        scale.x = -1

    if landed_hard and state != State.STARTING:
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


func _on_alerted() -> void:
    super._on_alerted()

    # Jump in fear.
    velocity.x = 0
    velocity.y = -get_jump_boost()
    was_on_floor = false

    # AUDIO: SCREAM
    if not detect_audio_player.playing:
        detect_audio_player.play()

    await get_tree().create_timer(.5).timeout

    if state == State.FLEEING:
        if not running_audio_player.playing:
            running_audio_player.play()
    elif state == State.CHASING:
        # TODO(ALDEN): Sound me up, baby
        pass
