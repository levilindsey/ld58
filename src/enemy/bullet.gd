class_name Bullet
extends Node2D


func _on_area_2d_body_entered(body: Node2D) -> void:
    if body is Player:
        pass
