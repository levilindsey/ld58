class_name EnemySpawner extends Node


# Dictionary<Enemy.Type, int>
var enemy_counts_by_type := {}

var extra_security_enemies: Array[Enemy] = []

var security_enemy_types: Array[Enemy.Type] = []


func _ready() -> void:
    for type in Settings.ENEMY_CONFIGS:
        var config: Dictionary = Settings.ENEMY_CONFIGS[type]
        if config.is_security:
            security_enemy_types.push_back(type)

    _record_enemy_counts_by_type()


func spawn() -> void:
    _populate_enemies()


func _physics_process(_delta: float) -> void:
    var target_extra_security_count := ceili(lerpf(
        G.settings.extra_security_enemies_count_min,
        G.settings.extra_security_enemies_count_max,
        G.session.detection_score))
    if extra_security_enemies.size() < target_extra_security_count:
        spawn_extra_security()
    if extra_security_enemies.size() > target_extra_security_count:
        var undismissed_extras: Array[Enemy] = []
        for enemy in extra_security_enemies:
            if not enemy.is_extra_security_dismissal_queued:
                undismissed_extras.push_back(enemy)
        var count_to_dismiss := undismissed_extras.size() - target_extra_security_count
        if count_to_dismiss > 0:
            for i in count_to_dismiss:
                undismissed_extras[i].queue_extra_security_dismissed()


func _record_enemy_counts_by_type() -> void:
    var total_population_weight := 0
    for type in Enemy.Type.values():
        total_population_weight += Settings.ENEMY_CONFIGS[type].population_weight

    for type in Enemy.Type.values():
        var ratio: float = float(Settings.ENEMY_CONFIGS[type].population_weight) / total_population_weight
        var count := roundi(ratio * G.settings.total_enemy_count)
        enemy_counts_by_type[type] = count

    # The golden chicken is special and should always be unique.
    enemy_counts_by_type[Enemy.Type.GOLDEN_CHICKEN] = 1


func _populate_enemies() -> void:
    for type in Enemy.Type.values():
        # Only spawn a golden chicken if the active quest needs it.
        if type == Enemy.Type.GOLDEN_CHICKEN:
            if not G.session.active_quest.enemy_type_to_count.has(type):
                continue
        for i in enemy_counts_by_type[type]:
            spawn_enemy(type)


func spawn_enemy(type: Enemy.Type):
    var enemy := _instantiate_enemy(type)
    await get_tree().process_frame
    G.game_panel.get_enemy_container().add_child(enemy)


func spawn_extra_security() -> void:
    var index := randi_range(0, security_enemy_types.size() - 1)
    var type := security_enemy_types[index]
    var enemy := _instantiate_enemy(type)
    enemy.is_extra_security = true
    G.game_panel.get_enemy_container().add_child(enemy)
    extra_security_enemies.push_back(enemy)


func _instantiate_enemy(type: Enemy.Type) -> Enemy:
    var enemy = G.settings.instantiate_enemy(type)

    # Assign a random region.
    var possible_regions: Array[Region.Type]
    possible_regions.assign(Settings.ENEMY_CONFIGS[type].regions)
    var region := G.game_panel.get_random_region(possible_regions)
    enemy.home_region = region

    # Assign a random position within the region.
    var offset := randf() * region.width
    enemy.global_position.x = region.global_start_x + offset
    enemy.global_position.y = -0.1

    # Assign a random start direction.
    enemy.set_is_facing_right(int(offset) % 2 == 0)

    return enemy
