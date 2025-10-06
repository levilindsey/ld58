class_name EnemySpawner extends Node


# Dictionary<Enemy.Type, int>
var enemy_counts_by_type := {}

# Dictionary<Enemy.Type, int>
var extra_security_enemies_by_type := {}


# FIXME: LEFT OFF HERE: Update extra_security_enemies_by_type dynamically to match the current G.session.detection_score.


func _ready() -> void:
    _record_enemy_counts_by_type()
    _populate_enemies()


func _record_enemy_counts_by_type() -> void:
    var total_population_weight := 0
    for type in Enemy.Type.values():
        total_population_weight += Settings.ENEMY_CONFIGS[type].population_weight

    for type in Enemy.Type.values():
        var ratio: float = float(Settings.ENEMY_CONFIGS[type].population_weight) / total_population_weight
        var count := roundi(ratio * G.settings.total_enemy_count)
        enemy_counts_by_type[type] = count


func _populate_enemies() -> void:
    for type in Enemy.Type.values():
        for i in enemy_counts_by_type[type]:
            spawn_enemy(type)


func spawn_enemy(type: Enemy.Type):
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

    G.game_panel.get_enemy_container().add_child(enemy)
