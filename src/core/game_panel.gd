class_name GamePanel
extends Node2D


const ZOO_KEEPER_SPACE_HEIGHT_THRESHOLD := -900

var player_start_position := Vector2.ZERO
var chunk_edge_distance_threshold_for_chunk_repositioning: int

var chunk_a_bounds: Rect2
var chunk_b_bounds: Rect2
var chunk_c_bounds: Rect2
var combined_level_chunk_bounds: Rect2
@onready var chunks: Array[LevelChunk] = [
    %LevelChunkA,
    %LevelChunkB,
    %LevelChunkC,
]

var is_shifting_chunks := false
var has_fully_initialized := false
var enemy_spawner : EnemySpawner
var quest_manager : QuestManager

# Dictionary<Region.Type, float>
var total_width_per_region_type := {}

# Dictionary<Enemy, bool>
var current_alerted_enemies := {}


func _enter_tree() -> void:
    G.session = Session.new()


func _ready() -> void:
    G.game_panel = self
    player_start_position = G.player.global_position

    # Calculate the cumulative width for each region type across the world.
    for type in Region.Type.values():
        total_width_per_region_type[type] = 0
    for chunk in chunks:
        for type in chunk.total_width_per_region_type:
            total_width_per_region_type[type] += chunk.total_width_per_region_type[type]

    start_level()


func start_level() -> void:
    G.player.global_position = player_start_position
    G.session.start_new_excursion()

    is_shifting_chunks = true

    has_fully_initialized = false

    %LevelChunkA.global_position.x = 0

    await get_tree().process_frame
    _update_bounds()

    %LevelChunkB.global_position.x = chunk_a_bounds.size.x

    await get_tree().process_frame
    _update_bounds()

    %LevelChunkC.global_position.x = chunk_a_bounds.size.x + chunk_b_bounds.size.x

    await get_tree().process_frame
    _update_bounds()

    is_shifting_chunks = false

    if is_instance_valid(enemy_spawner):
        enemy_spawner.queue_free()
    enemy_spawner = EnemySpawner.new()
    add_child(enemy_spawner)

    if is_instance_valid(quest_manager):
        quest_manager.queue_free()
    quest_manager = QuestManager.new()
    add_child(quest_manager)

    chunk_edge_distance_threshold_for_chunk_repositioning = get_viewport().size.x / get_viewport().get_camera_2d().zoom.x / 2 + 50

    has_fully_initialized = true


func reset() -> void:
    G.session.reset()
    G.zoo_keeper_screen.reset()
    clear_level_entities()
    start_level()


func clear_level_entities() -> void:
    G.player.reset()
    current_alerted_enemies.clear()
    if is_instance_valid(enemy_spawner):
        enemy_spawner.extra_security_enemies.clear()
    G.enemies.clear()
    for child in get_enemy_container().get_children():
        child.queue_free()
    for child in get_projectile_container().get_children():
        child.queue_free()


func _physics_process(_delta: float) -> void:
    if is_shifting_chunks:
        return

    # Handle swapping level chunk positions to support infinite scroll.
    var left_threshold := combined_level_chunk_bounds.position.x + chunk_edge_distance_threshold_for_chunk_repositioning
    var right_threshold := combined_level_chunk_bounds.end.x - chunk_edge_distance_threshold_for_chunk_repositioning
    if G.player.global_position.x < left_threshold:
        is_shifting_chunks = true
        var right_chunk := _get_right_most_level_chunk()
        var right_chunk_bounds := right_chunk.get_bounds()
        var right_chunk_enemies = _get_enemies_in_right_most_level_chunk()
        right_chunk.global_position.x = combined_level_chunk_bounds.position.x - right_chunk_bounds.size.x
        for enemy in right_chunk_enemies:
            enemy.global_position.x -= combined_level_chunk_bounds.size.x
            # reset the y position and velocity in case the enemy fell through
            # the level for some unknown reason
            enemy.global_position.y = -1
            enemy.velocity.y = 0
        await get_tree().process_frame
        _update_bounds()
        is_shifting_chunks = false
    elif G.player.global_position.x > right_threshold:
        is_shifting_chunks = true
        var left_chunk := _get_left_most_level_chunk()
        var left_chunk_enemies = _get_enemies_in_left_most_level_chunk()
        left_chunk.global_position.x = combined_level_chunk_bounds.end.x
        for enemy in left_chunk_enemies:
            enemy.global_position.x += combined_level_chunk_bounds.size.x
            # reset the y position and velocity in case the enemy fell through
            # the level for some unknown reason
            enemy.global_position.y = -1
            enemy.velocity.y = 0
        await get_tree().process_frame
        _update_bounds()
        is_shifting_chunks = false

    # Check for player reaching space for zookeeper updates.
    if G.player.global_position.y < ZOO_KEEPER_SPACE_HEIGHT_THRESHOLD:
        show_zoo_keeper_screen()


func show_zoo_keeper_screen() -> void:
    G.session.deposit_enemies()
    quest_manager.on_return_to_zoo()
    # zoo_keeper_screen.on_return_to_zoo must come after deposit enemies
    # and quest_manager.on_return_to_zoo for proper behavior.
    G.main.open_screen(Main.ScreenType.ZOO_KEEPER)
    clear_level_entities()


func return_from_screen() -> void:
    G.zoo_keeper_screen.visible = false
    G.main_menu_screen.visible = false
    G.game_over_screen.visible = false
    G.win_screen.visible = false

    get_tree().paused = false
    G.player.global_position = player_start_position
    G.session.start_new_excursion()
    # AUDIO: Music Switch
    G.main.fade_to_main_theme()

    enemy_spawner.spawn()

    # Fade-in ship.
    G.player.modulate.a = 0
    await get_tree().create_timer(0.2).timeout
    var tween := create_tween()
    tween.tween_property(G.player, "modulate:a", 1, 1.0)



func add_alerted_enemy(enemy: Enemy) -> void:
    current_alerted_enemies[enemy] = true
    G.session.record_alerted_enemy(enemy.type)
    _update_detection_score()


func remove_alerted_enemy(enemy: Enemy) -> void:
    current_alerted_enemies.erase(enemy)
    _update_detection_score()


func _update_detection_score() -> void:
    var scaled_alerted_enemy_count := 0.0
    for enemy in current_alerted_enemies:
        var multiplier := Enemy.get_alerted_enemy_multiplier_by_type(enemy.type)
        scaled_alerted_enemy_count += multiplier

    scaled_alerted_enemy_count = clamp(
        scaled_alerted_enemy_count, 0, G.session.alert_enemies_count_for_max_detection)

    var detection_score := (
        float(scaled_alerted_enemy_count) / G.session.alert_enemies_count_for_max_detection)

    G.session.set_detection_score(detection_score)
    G.hud.update_detection()


func get_enemy_container() -> Node2D:
    return %Enemies


func get_projectile_container() -> Node2D:
    return %Projectiles


func _update_bounds() -> void:
    chunk_a_bounds = %LevelChunkA.get_bounds()
    chunk_b_bounds = %LevelChunkB.get_bounds()
    chunk_c_bounds = %LevelChunkC.get_bounds()
    combined_level_chunk_bounds = chunk_a_bounds.merge(chunk_b_bounds).merge(chunk_c_bounds)
    %LevelChunkA.queue_redraw()
    %LevelChunkB.queue_redraw()
    %LevelChunkC.queue_redraw()


func _get_left_most_level_chunk() -> LevelChunk:
    if chunk_a_bounds.position.x < chunk_b_bounds.position.x:
        if chunk_a_bounds.position.x < chunk_c_bounds.position.x:
            return %LevelChunkA
        else:
            return %LevelChunkC
    else:
        if chunk_b_bounds.position.x < chunk_c_bounds.position.x:
            return %LevelChunkB
        else:
            return %LevelChunkC


func _get_right_most_level_chunk() -> LevelChunk:
    if chunk_a_bounds.end.x > chunk_b_bounds.end.x:
        if chunk_a_bounds.end.x > chunk_c_bounds.end.x:
            return %LevelChunkA
        else:
            return %LevelChunkC
    else:
        if chunk_b_bounds.end.x > chunk_c_bounds.end.x:
            return %LevelChunkB
        else:
            return %LevelChunkC


func _get_enemies_in_right_most_level_chunk() -> Array:
    var filtered_enemies = []
    for enemy in G.enemies:
        var right_chunk_left_boundary = _get_right_most_level_chunk().get_bounds().position.x
        if enemy.global_position.x > right_chunk_left_boundary:
            filtered_enemies.append(enemy)
    return filtered_enemies


func _get_enemies_in_left_most_level_chunk() -> Array:
    var filtered_enemies = []
    for enemy in G.enemies:
        var left_chunk_right_boundary = _get_left_most_level_chunk().get_bounds().end.x
        if enemy.global_position.x < left_chunk_right_boundary:
            filtered_enemies.append(enemy)
    return filtered_enemies


func get_random_region(types: Array[Region.Type]) -> Region:
    var types_set := {}
    var total_width := 0
    for type in types:
        types_set[type] = true
        total_width += total_width_per_region_type[type]

    var offset := randf() * total_width - 0.1

    var current_width := 0.0
    for chunk in chunks:
        for region in chunk.regions:
            if not types_set.has(region.type):
                continue
            current_width += region.width
            if current_width > offset:
                return region

    G.utils.ensure(false)

    return chunks[0].regions[0]
