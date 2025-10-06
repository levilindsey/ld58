class_name Session
extends RefCounted


const DEFAULT_MAX_HEALTH := 3


# Dictionary<Enemy.Type, int>
var total_enemies_deposited_by_type := {}
# Dictionary<Enemy.Type, int>
var total_enemies_splatted_by_type := {}
# Dictionary<Enemy.Type, int>
var total_alerted_enemies_by_type := {}

# Dictionary<UpgradeType, int>
var ship_upgrade_levels := {}

# Dictionary<Enemy.Type, int>
var current_enemies_deposited_by_type := {}
var current_enemies_deposited_count := 0

# Dictionary<Enemy.Type, int>
var current_enemies_collected_by_type := {}
var current_enemies_collected_count := 0

var total_excursion_count := 0
var current_quest_excursion_count := 0

# Upgradeable attributes
var collection_capacity := 0
var beam_scale := 0.0
var max_speed := 0
var max_speed_beaming := 0
var gravity_per_enemy := 0
var alert_enemies_count_for_max_detection := 0

var health := 0
var max_health := 0

var money := 0

# [0,1]
var detection_score := 0.0

var active_quest: Quest

var fulfilled_quests: Array[Quest] = []


func _init() -> void:
    reset()


func reset() -> void:
    total_enemies_deposited_by_type.clear()
    total_enemies_splatted_by_type.clear()
    total_alerted_enemies_by_type.clear()
    current_enemies_deposited_by_type.clear()
    current_enemies_collected_by_type.clear()
    ship_upgrade_levels.clear()


    # Initialize map entries with zero counts.
    for type in Enemy.Type.values():
        total_enemies_deposited_by_type[type] = 0
        total_enemies_splatted_by_type[type] = 0
        total_alerted_enemies_by_type[type] = 0
        current_enemies_deposited_by_type[type] = 0
        current_enemies_collected_by_type[type] = 0

    for type in UpgradeLevels.UpgradeTypes.values():
        ship_upgrade_levels[type] = 0

    current_enemies_deposited_count = 0
    current_enemies_collected_count = 0
    total_excursion_count = 0
    current_quest_excursion_count = 0
    collection_capacity = Settings.SHIP_UPGRADE_VALUES[UpgradeLevels.UpgradeTypes.CAPACITY][0]
    beam_scale = Settings.SHIP_UPGRADE_VALUES[UpgradeLevels.UpgradeTypes.BEAM][0]
    max_speed = Settings.SHIP_UPGRADE_VALUES[UpgradeLevels.UpgradeTypes.SPEED][0][0]
    max_speed_beaming = Settings.SHIP_UPGRADE_VALUES[UpgradeLevels.UpgradeTypes.SPEED][0][1]
    gravity_per_enemy = Settings.SHIP_UPGRADE_VALUES[UpgradeLevels.UpgradeTypes.SPEED][0][2]
    alert_enemies_count_for_max_detection = Settings.SHIP_UPGRADE_VALUES[UpgradeLevels.UpgradeTypes.STEALTH][0]
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
    for type in Enemy.Type.values():
        current_enemies_deposited_by_type[type] = 0
    current_enemies_deposited_count = 0
    G.hud.update_quest()


func start_new_excursion() -> void:
    for type in Enemy.Type.values():
        current_enemies_collected_by_type[type] = 0
    current_enemies_collected_count = 0
    total_excursion_count += 1
    current_quest_excursion_count += 1
    G.hud.update_quest()
    G.hud.update_health()
    G.hud.update_detection()


func deposit_enemies() -> void:
    for type in current_enemies_collected_by_type:
        var type_count: int = current_enemies_collected_by_type[type]
        total_enemies_deposited_by_type[type] += type_count
        current_enemies_deposited_by_type[type] += type_count
        current_enemies_deposited_count += type_count
    G.hud.update_quest()


func add_collected_enemy(type: Enemy.Type) -> void:
    current_enemies_collected_by_type[type] += 1
    current_enemies_collected_count += 1
    G.hud.update_quest()


func add_splatted_enemy(type: Enemy.Type) -> void:
    total_enemies_splatted_by_type[type] += 1


func is_ship_full() -> bool:
    return current_enemies_collected_count >= collection_capacity


func get_combined_counts_of_collected_and_deposited() -> Dictionary:
    var counts := {}
    for type in Enemy.Type.values():
        counts[type] = (
            current_enemies_collected_by_type[type] +
            current_enemies_deposited_by_type[type]
        )
    return counts


func set_health(value: int) -> void:
    health = value
    G.hud.update_health()


func record_alerted_enemy(type: Enemy.Type) -> void:
    total_alerted_enemies_by_type[type] += 1


func set_detection_score(score: float) -> void:
    detection_score = score
