class_name Quest
extends RefCounted


var enemy_type := Enemy.Type.FARMER
var enemy_count := 3
var start_time := -INF
var duration := INF


func _init(p_enemy_type: Enemy.Type, p_enemy_count: int, p_start_time: float, p_duration: float) -> void:
    enemy_type = p_enemy_type
    enemy_count = p_enemy_count
    start_time = p_start_time
    duration = p_duration
