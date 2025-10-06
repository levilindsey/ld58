class_name Projectile
extends Node2D


var damage := 1
var velocity := Vector2.ZERO


func _physics_process(delta: float) -> void:
    position += velocity * delta


func _on_area_2d_body_entered(body: Node2D) -> void:
    if body is Player:
        body.damage(damage)
        queue_free()
