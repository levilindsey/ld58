class_name Quest
extends RefCounted


# Dictionary<Enemy.Type, int>
var enemy_type_to_count := {}

var money_reward := 0


# p_enemy_type_to_count: Dictionary<Enemy.Type, int>
func _init(p_enemy_type_to_count: Dictionary, p_money_reward: int) -> void:
    enemy_type_to_count = p_enemy_type_to_count
    money_reward = p_money_reward
