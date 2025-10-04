class_name Player
extends CharacterBody2D

var max_speed = 400
var acceleration = 1000
var max_rotation = PI / 8
var damping_factor = 0.95
var gravity = 0

func _physics_process(delta):
    if Input.is_action_pressed("ui_left"):
        velocity.x = clamp(velocity.x + acceleration * delta * -1, max_speed * -1, max_speed)
        rotation = clamp(velocity.x / max_speed * max_rotation, max_rotation * -1, max_rotation)
    if Input.is_action_pressed("ui_right"):
        velocity.x = clamp(velocity.x + acceleration * delta, max_speed * -1, max_speed)
        rotation = clamp(velocity.x / max_speed * max_rotation, max_rotation * -1, max_rotation)
    if Input.is_action_pressed("ui_up"):
        velocity.y = clamp(velocity.y + acceleration * delta * -1, max_speed * -1, max_speed)
    if Input.is_action_pressed("ui_down"):
        velocity.y = clamp(velocity.y + acceleration * delta, max_speed * -1, max_speed)

    if not is_movement_action_pressed():
        velocity.x = velocity.x * damping_factor
        velocity.y = velocity.y * damping_factor
        # TODO: revisit and add wobbling when decelerating?
        rotation = 0
        
    if abs(velocity.x) < 1:
        velocity.x = 0
    
    if abs(velocity.y) < 1:
        velocity.y = 0
        
    velocity.y += gravity * delta
    var collision = move_and_collide(velocity * delta)

func is_movement_action_pressed():
    return Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down")
