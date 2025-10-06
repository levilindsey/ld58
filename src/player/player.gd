class_name Player
extends CharacterBody2D


const ACCELERATION = 1000
const MAX_ROTATION = PI / 8
const DAMPING_FACTOR_HORIZONTAL = 0.95
const DAMPING_FACTOR_VERTICAL = 0.8
const SLIDE_ABDUCTEE_TOWARD_BEAM_CENTER_SPEED := 50
const SLIDE_ABDUCTEE_UP_BEAM_SPEED := 30

# Dictionary<Pedestrian, boolean>
var pedestrians_in_beam = {}
var is_beaming = false

@onready var beam_audio_player: AudioStreamPlayer = $TractorBeam/TractorBeamAudiostream
@onready var ufo_audio_player: AudioStreamPlayer = $UFOAudiostream
@onready var capture_audio_player: AudioStreamPlayer = $CaptureStreamPlayer
@onready var reject_audio_player: AudioStreamPlayer = $RejectStreamPlayer


func _ready() -> void:
    G.player = self
    update_beam_scale()
    reset()


func reset() -> void:
    pedestrians_in_beam.clear()
    is_beaming = false


func _process(_delta: float) -> void:
    if not G.game_panel.has_fully_initialized:
        return

    var speed = velocity.length()
    if not ufo_audio_player.playing:
        ufo_audio_player.play()

    # Map speed to pitch (1.0 = normal)
    var min_pitch = 0.4
    var max_pitch = 1.1
    ufo_audio_player.pitch_scale = lerp(min_pitch, max_pitch, clamp(speed / _get_max_speed(), 0.0, 1.0))

    # Map speed to volume in decibels
    var min_db = -32.0
    var max_db = -20.0
    ufo_audio_player.volume_db = lerp(min_db, max_db, clamp(speed / _get_max_speed(), 0.0, 1.0))


func _physics_process(delta):
    handle_movement(delta)
    handle_beam()
    if is_beaming:
        _slide_abductees_toward_beam_center(delta)
        _slide_abductees_up_beam(delta)
    $CapacityLabel.text = (
        str(G.session.current_enemies_collected_count) +
        "/" + str(G.session.collection_capacity)
    )


func _slide_abductees_toward_beam_center(delta: float) -> void:
    for ped in pedestrians_in_beam:
        if not G.utils.ensure(is_instance_valid(ped)):
            continue
        if abs(ped.position.x) < 4:
            # Close enough.
            continue
        var slide_direction := Vector2.LEFT if ped.position.x > 0 else Vector2.RIGHT
        ped.position += slide_direction * SLIDE_ABDUCTEE_TOWARD_BEAM_CENTER_SPEED * delta


func _slide_abductees_up_beam(delta: float) -> void:
    for ped in pedestrians_in_beam:
        if not G.utils.ensure(is_instance_valid(ped)):
            continue
        ped.position += Vector2.UP * SLIDE_ABDUCTEE_UP_BEAM_SPEED * delta


func handle_beam() -> void:
    if Input.is_action_just_pressed("Beam"):
        if not G.session.is_ship_full():
            _on_started_beam()
        else:
            # AUDIO: Reject
            if not reject_audio_player.playing:
                reject_audio_player.play()
                print("REJECT")
            pass
    if Input.is_action_just_released("Beam"):
        _on_stopped_beam()
        
func update_beam_scale() -> void:
    %TractorBeamArea.scale.x = G.session.beam_scale
    %TractorBeamArea.scale.y = G.session.beam_scale

func _on_started_beam() -> void:
    print("_on_started_beam")
    var beam = get_node("TractorBeam")
    var beamCollisionArea = %TractorBeamCollisionPolygon
    is_beaming = true
    beam.visible = true
    if not beam_audio_player.playing:
        beam_audio_player.play()
    beamCollisionArea.disabled = false

func _on_stopped_beam() -> void:
    print("_on_stopped_beam")
    var beam = get_node("TractorBeam")
    var beamCollisionArea = %TractorBeamCollisionPolygon
    is_beaming = false
    beam.visible = false
    beam_audio_player.stop()
    beamCollisionArea.disabled = true
    for ped in pedestrians_in_beam:
        ped.reparent(G.game_panel.get_enemy_container())
        ped.on_beam_end()
    pedestrians_in_beam.clear()


func handle_movement(delta):
    var max_speed = _get_max_speed()
    if Input.is_action_pressed("MoveLeft"):
        velocity.x = clamp(velocity.x + ACCELERATION * delta * -1, max_speed * -1, max_speed)
        rotation = clamp(velocity.x / max_speed * MAX_ROTATION, MAX_ROTATION * -1, max_speed)
    if Input.is_action_pressed("MoveRight"):
        velocity.x = clamp(velocity.x + ACCELERATION * delta, max_speed * -1, max_speed)
        rotation = clamp(velocity.x / max_speed * MAX_ROTATION, MAX_ROTATION * -1, MAX_ROTATION)
    if Input.is_action_pressed("MoveUp") and not is_beaming:
        velocity.y = clamp(velocity.y + ACCELERATION * delta * -1, max_speed * -1, max_speed)
    if Input.is_action_pressed("MoveDown") and not is_beaming:
        velocity.y = clamp(velocity.y + ACCELERATION * delta, max_speed * -1, max_speed)

    if not is_movement_action_pressed() or is_beaming:
        velocity.x = velocity.x * DAMPING_FACTOR_HORIZONTAL
        velocity.y = velocity.y * DAMPING_FACTOR_VERTICAL
        # TODO: revisit and add wobbling when decelerating?
        rotation = 0

    if abs(velocity.x) < 1:
        velocity.x = 0

    if abs(velocity.y) < 1:
        velocity.y = 0

    if not is_beaming:
        velocity.y += _get_gravity() * delta
    move_and_slide()

func _get_max_speed() -> int:
    if is_beaming:
        return G.session.max_speed_beaming
    else:
        return G.session.max_speed

func _get_gravity() -> float:
    return G.session.current_enemies_collected_count * G.session.gravity_per_enemy

func is_movement_action_pressed() -> bool:
    return (
        Input.is_action_pressed("MoveLeft") or
        Input.is_action_pressed("MoveRight") or
        Input.is_action_pressed("MoveUp") or
        Input.is_action_pressed("MoveDown")
    )


func _on_tractor_beam_area_body_entered(body: Node2D) -> void:
    if not G.utils.ensure(is_instance_valid(body)):
        return

    # Apparently reparenting a pedestrian can re-trigger on-area-entered
    # calculations, so we up re-attaching the pedestrian right after we detach
    # it, or trying to attach it again right after attaching it.
    if not is_beaming or pedestrians_in_beam.has(body):
        return

    if body is Pedestrian and not body.is_dead():
        # Add pedestrian to dictionary to keep them unique. Value is meaningless
        print("Critter entered beam ")
        pedestrians_in_beam[body] = true
        body.call_deferred("reparent", %EnemiesInBeam)
        body.on_beam_start()


func _on_abductee_collection_area_body_entered(body: Node2D) -> void:
    if (body is Pedestrian and
            pedestrians_in_beam.has(body) and
            not G.session.is_ship_full()):
        # The pedestrian has been collected
        print("Critter abducted")
        pedestrians_in_beam.erase(body)
        G.session.add_collected_enemy(body.type)
        body.on_collected()

        if G.session.is_ship_full():
            _on_stopped_beam()

        if not capture_audio_player.playing:
            capture_audio_player.play()
