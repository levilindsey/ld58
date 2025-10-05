class_name  EnemySpawner extends Node

const LEVEL_EDGE_MARGIN = 100
var mostRecentSpawnTime := -INF
var spawnRateSeconds := 1.0


func _ready() -> void:
    mostRecentSpawnTime = Time.get_ticks_msec() / 1000.0
    # spawn 1 farmer to start
    spawn_enemy(Enemy.Type.FARMER)


func _physics_process(_delta: float) -> void:
    var currentTime = Time.get_ticks_msec() / 1000.0
    if currentTime - mostRecentSpawnTime > spawnRateSeconds:
        spawn_enemy(Enemy.Type.FARMER)
        mostRecentSpawnTime = currentTime


func spawn_enemy(enemyType: Enemy.Type):
    var enemy = G.settings.getEnemyScene(enemyType)
    # always spawn player the opposite way of players direction
    enemy.position.y = 0
    var rng = RandomNumberGenerator.new()
    var level_left = G.game_panel.combined_level_chunk_bounds.position.x + LEVEL_EDGE_MARGIN
    var level_right = G.game_panel.combined_level_chunk_bounds.end.x - LEVEL_EDGE_MARGIN
    var random_x_position = rng.randi_range(level_left, level_right)

    var camera_width = get_viewport().size.x / get_viewport().get_camera_2d().zoom.x
    var no_spawn_width = camera_width / 2 + 50

    # If the random spawn position is inside of the viewport then bump it outside.
    if random_x_position > G.player.position.x - no_spawn_width and random_x_position <  G.player.position.x + no_spawn_width:
        if random_x_position < G.player.position.x:
            random_x_position -= camera_width
        else:
            random_x_position += camera_width

    enemy.position.x = int(random_x_position)
    # randomize starting direction
    enemy.set_is_facing_right(int(random_x_position) % 2 == 0)
    G.game_panel.get_enemy_container().add_child(enemy)
