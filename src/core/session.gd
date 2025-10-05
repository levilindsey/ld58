class_name Session
extends RefCounted


const INITIAL_COLLECTION_CAPACITY := 3
const INITIAL_HEALTH := 3


# Dictionary<Enemy.Type, int>
var enemies_collected_by_type := {}

# Dictionary<Enemy.Type, int>
var enemies_splatted_by_type := {}

# Dictionary<Enemy.Type, int>
var enemies_that_have_detected_you_by_type := {}

# Dictionary<Enemy.Type, int>
var current_enemies_collected_by_type := {}

var current_enemies_collected_count := 0

var excursion_count := 0

var collection_capacity := 0

var health := 0

var detection_score := 0

var active_quests: Array[Quest] = []

var failed_quests: Array[Quest] = []

var fulfilled_quests: Array[Quest] = []


func _init() -> void:
    reset()


func reset() -> void:
    enemies_collected_by_type.clear()
    enemies_splatted_by_type.clear()
    enemies_that_have_detected_you_by_type.clear()
    current_enemies_collected_by_type.clear()

    # Initialize map entries with zero counts.
    for type in Enemy.Type.values():
        enemies_collected_by_type[type] = 0
        enemies_splatted_by_type[type] = 0
        enemies_that_have_detected_you_by_type[type] = 0
        current_enemies_collected_by_type[type] = 0

    current_enemies_collected_count = 0
    collection_capacity = INITIAL_COLLECTION_CAPACITY
    health = INITIAL_HEALTH
    detection_score = 0

    active_quests.clear()
    failed_quests.clear()
    fulfilled_quests.clear()


func start_new_excursion() -> void:
    for type in Enemy.Type.values():
        current_enemies_collected_by_type[type] = 0
    current_enemies_collected_count = 0
    health = INITIAL_HEALTH
    detection_score = 0
    excursion_count += 1


func add_collected_enemy(type: Enemy.Type) -> void:
    current_enemies_collected_by_type[type] += 1
    current_enemies_collected_count += 1
