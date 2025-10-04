class_name Player
extends CharacterBody2D

const MAX_SPEED = 400
const ACCELERATION = 1000
const MAX_ROTATION = PI / 8
const DAMPING_FACTOR = 0.95
var gravity = 0
var pedestrians_in_beam = {}

func _ready() -> void:
    G.player = self

func _physics_process(delta):
    var previous_pos = position
    handle_movement(delta)
    
    var beam = get_node("TractorBeam")
    var beamCollisionArea = %TractorBeamCollisionPolygon
    if Input.is_action_pressed("ui_select"):
        beam.visible = true
        beamCollisionArea.set_deferred("disabled", false)
    if Input.is_action_just_released("ui_select"):
        beam.visible = false
        beamCollisionArea.set_deferred("disabled", true)
        
    var player_x_delta = position.x - previous_pos.x
    for ped in pedestrians_in_beam:
        ped.position.x = move_toward(ped.position.x, position.x, 0.1) + player_x_delta
        ped.position.y = move_toward(ped.position.y, position.y, 0.5)
        

func handle_movement(delta):
    if Input.is_action_pressed("ui_left"):
        velocity.x = clamp(velocity.x + ACCELERATION * delta * -1, MAX_SPEED * -1, MAX_SPEED)
        rotation = clamp(velocity.x / MAX_SPEED * MAX_ROTATION, MAX_ROTATION * -1, MAX_SPEED)
    if Input.is_action_pressed("ui_right"):
        velocity.x = clamp(velocity.x + ACCELERATION * delta, MAX_SPEED * -1, MAX_SPEED)
        rotation = clamp(velocity.x / MAX_SPEED * MAX_ROTATION, MAX_ROTATION * -1, MAX_ROTATION)
    if Input.is_action_pressed("ui_up"):
        velocity.y = clamp(velocity.y + ACCELERATION * delta * -1, MAX_SPEED * -1, MAX_SPEED)
    if Input.is_action_pressed("ui_down"):
        velocity.y = clamp(velocity.y + ACCELERATION * delta, MAX_SPEED * -1, MAX_SPEED)

    if not is_movement_action_pressed():
        velocity.x = velocity.x * DAMPING_FACTOR
        velocity.y = velocity.y * DAMPING_FACTOR
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
