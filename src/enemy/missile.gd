class_name Missile
extends Projectile


func _physics_process(delta: float) -> void:
    var direction := (G.player.global_position - global_position).normalized()
    velocity = direction * G.settings.missile_speed
    position += velocity * delta
