class_name Session
extends RefCounted


const DEFAULT_COLLECTION_CAPACITY := 3
const DEFAULT_MAX_HEALTH := 3


# FIXME(levilindsey): Update these other counts.


# Dictionary<Enemy.Type, int>
var total_enemies_deposited_by_type := {}
# Dictionary<Enemy.Type, int>
var total_enemies_splatted_by_type := {}
# Dictionary<Enemy.Type, int>
var total_enemies_that_have_detected_you_by_type := {}

# Dictionary<Enemy.Type, int>
var current_enemies_deposited_by_type := {}
var current_enemies_deposited_count := 0

# Dictionary<Enemy.Type, int>
var current_enemies_collected_by_type := {}
var current_enemies_collected_count := 0

var total_excursion_count := 0
var current_quest_excursion_count := 0

var collection_capacity := 0

var health := 0
var max_health := 0

var money := 0

var detection_score := 0

var active_quest: Quest

var fulfilled_quests: Array[Quest] = []


func _init() -> void:
    reset()


func reset() -> void:
    total_enemies_deposited_by_type.clear()
    total_enemies_splatted_by_type.clear()
    total_enemies_that_have_detected_you_by_type.clear()
    current_enemies_deposited_by_type.clear()
    current_enemies_collected_by_type.clear()

    # Initialize map entries with zero counts.
    for type in Enemy.Type.values():
        total_enemies_deposited_by_type[type] = 0
        total_enemies_splatted_by_type[type] = 0
        total_enemies_that_have_detected_you_by_type[type] = 0
        current_enemies_deposited_by_type[type] = 0
        current_enemies_collected_by_type[type] = 0

    current_enemies_deposited_count = 0
    current_enemies_collected_count = 0
    total_excursion_count = 0
    current_quest_excursion_count = 0
    collection_capacity = DEFAULT_COLLECTION_CAPACITY
    health = DEFAULT_MAX_HEALTH
    max_health = DEFAULT_MAX_HEALTH
    money = 0
    detection_score = 0

    active_quest = null
    fulfilled_quests.clear()


func start_new_quest(next_quest: Quest) -> void:
    if is_instance_valid(active_quest):
        fulfilled_quests.push_back(active_quest)
    active_quest = next_quest
    health = DEFAULT_MAX_HEALTH
    detection_score = 0
    G.hud.update()


func start_new_excursion() -> void:
    for type in Enemy.Type.values():
        current_enemies_collected_by_type[type] = 0
    current_enemies_collected_count = 0
    total_excursion_count += 1
    current_quest_excursion_count += 1
    G.hud.update()


func deposit_enemies() -> void:
    for type in current_enemies_collected_by_type:
        var type_count: int = current_enemies_collected_by_type[type].size()
        total_enemies_deposited_by_type[type] += type_count
        current_enemies_deposited_by_type[type] += type_count
        current_enemies_deposited_count += type_count
    G.hud.update()


func add_collected_enemy(type: Enemy.Type) -> void:
    current_enemies_collected_by_type[type] += 1
    current_enemies_collected_count += 1
    G.hud.update()


func add_splatted_enemy(type: Enemy.Type) -> void:
    total_enemies_splatted_by_type[type] += 1


func add_enemy_that_has_detected_you(type: Enemy.Type) -> void:
    total_enemies_that_have_detected_you_by_type[type] += 1
