class_name Player
extends CharacterBody2D


var speed = 400


func _ready() -> void:
    G.player = self


func _physics_process(delta):
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_dir * speed
    var collision = move_and_collide(velocity * delta)
