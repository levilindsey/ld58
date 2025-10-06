class_name Jet
extends Node2D


const VERTICAL_OFFSET_FROM_PLAYER := -128.0
const MISSILE_SPAWN_HORIZONTAL_DISTANCE := 64.0
const SPEED := 400.0

var velocity := Vector2.ZERO

var has_shot := false


func _ready() -> void:
    var offset_x := G.game_panel.chunk_edge_distance_threshold_for_chunk_repositioning + 40
    velocity = Vector2.RIGHT * SPEED
    if randf() < 0.5:
        offset_x *= -1
    else:
        velocity.x *= -1
        %AnimatedSprite2D.scale.x = -1
    global_position.x = G.player.global_position.x + offset_x
    global_position.y = G.player.global_position.y + VERTICAL_OFFSET_FROM_PLAYER


func _physics_process(delta: float) -> void:
    position += velocity * delta

    if absf(G.player.global_position.x - global_position.x) < \
            MISSILE_SPAWN_HORIZONTAL_DISTANCE and not has_shot:
        shoot()



func shoot() -> void:
    has_shot = true

    var projectile_scene := G.settings.missile_scene
    var projectile_speed := G.settings.missile_speed
    var projectile_scale := G.settings.missile_scale

    var spawn_position := get_projectile_spawn_position()
    var direction := (G.player.global_position - spawn_position).normalized()
    var spawn_rotation := direction.angle()
    var spawn_velocity := direction * projectile_speed
    var spawn_scale := Vector2.ONE * projectile_scale

    var missile: Missile = projectile_scene.instantiate()
    missile.position = spawn_position
    missile.velocity = spawn_velocity
    missile.rotation = spawn_rotation
    missile.scale = spawn_scale
    missile.damage = G.settings.missile_damage
    G.game_panel.get_projectile_container().add_child(missile)


func get_projectile_spawn_position() -> Vector2:
    return %MissileSpawnPosition.global_position
