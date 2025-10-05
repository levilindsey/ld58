class_name Quest
extends RefCounted


# Dictionary<Enemy.Type, int>
var enemy_type_to_count := {}


# p_enemy_type_to_count: Dictionary<Enemy.Type, int>
func _init(p_enemy_type_to_count: Dictionary) -> void:
    enemy_type_to_count = p_enemy_type_to_count
