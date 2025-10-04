class_name Player
extends CharacterBody2D

const ACCELERATION = 1000
const MAX_ROTATION = PI / 8
const DAMPING_FACTOR_HORIZONTAL = 0.95
const DAMPING_FACTOR_VERTICAL = 0.8
var max_speed = 400
var gravity = 0
var pedestrians_in_beam = {}
var pedestrians_collected = {}
var is_beaming = false

func _ready() -> void:
    G.player = self

func _physics_process(delta):
    var previous_pos = position
    handle_movement(delta)
    handle_beam()
    abduct_pedestrians(previous_pos)
    
func handle_beam():
    var beam = get_node("TractorBeam")
    var beamCollisionArea = %TractorBeamCollisionPolygon
    if Input.is_action_pressed("ui_select"):
        is_beaming = true
        beam.visible = true
        beamCollisionArea.set_deferred("disabled", false)
        max_speed = 50
    if Input.is_action_just_released("ui_select"):
        is_beaming = false
        beam.visible = false
        beamCollisionArea.set_deferred("disabled", true)
        max_speed = 400
        for ped in pedestrians_in_beam:
            ped.on_beam_end()
        pedestrians_in_beam.clear()

func abduct_pedestrians(previous_pos):
    var player_x_delta = position.x - previous_pos.x
    var player_bottom_edge = %PlayerBodyCollisionShape.shape.get_height() / 2.0 + global_position.y
    for ped in pedestrians_in_beam.duplicate_deep():
        var ped_height_offset = ped.get_node("CollisionShape2D").shape.get_height() / 2
        ped.position.x = move_toward(ped.position.x, position.x, 0.1) + player_x_delta
        ped.position.y = move_toward(ped.position.y, player_bottom_edge + ped_height_offset, 0.5)
        if ped.position.y == player_bottom_edge + ped_height_offset:
            # The pedestrian has been collected
            pedestrians_collected[ped] = true
            ped.visible = false
            pedestrians_in_beam.erase(ped)

func handle_movement(delta):
    if Input.is_action_pressed("ui_left"):
        velocity.x = clamp(velocity.x + ACCELERATION * delta * -1, max_speed * -1, max_speed)
        rotation = clamp(velocity.x / max_speed * MAX_ROTATION, MAX_ROTATION * -1, max_speed)
    if Input.is_action_pressed("ui_right"):
        velocity.x = clamp(velocity.x + ACCELERATION * delta, max_speed * -1, max_speed)
        rotation = clamp(velocity.x / max_speed * MAX_ROTATION, MAX_ROTATION * -1, MAX_ROTATION)
    if Input.is_action_pressed("ui_up") and not is_beaming:
        velocity.y = clamp(velocity.y + ACCELERATION * delta * -1, max_speed * -1, max_speed)
    if Input.is_action_pressed("ui_down") and not is_beaming:
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

    velocity.y += gravity * delta
    move_and_collide(velocity * delta)

func is_movement_action_pressed():
    return Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")


func _on_tractor_beam_area_body_entered(body: Node2D) -> void:
    if body is Pedestrian:
        body.on_beam_start()
        # Add pedestrian to dictionary to keep them unique. Value is meaningless
        pedestrians_in_beam[body] = true
    else:
        return
    pass # Replace with function body.
