class_name Enemy
extends CharacterBody2D


enum Type {
    FARMER,
    KID,
    OLD_PERSON,
    CAT,
    HOMELESS_PERSON,
    BUSINESS_PERSON,
    POLICE_OFFICER,
    # TODO: Add stuff here!
    #POLICE_CAR,
    #TANK,
    #HELICOPTER,
}

enum State {
    STARTING,
    WALKING,
    FLEEING,
    CHASING,
    BEING_BEAMED,
    DEAD,
}

const LANDED_HARD_SPEED_THRESHOLD := 270
const FADE_DELAY_AFTER_DEATH := 5


@export var type := Type.FARMER

# This should match the properties on Settings.ENEMY_CONFIGS.
var config: Dictionary

var home_region: Region

var state := State.STARTING
var was_on_floor := false
var previous_velocity := Vector2.ZERO
var death_time := -INF

var last_player_sighting_time := -INF
var is_player_visible := false
var was_player_recently_visible := false
var is_facing_right := true

# Dictionary<Enemy, bool>
var visible_enemies := {}

var sound_scene: Node2D


func _ready() -> void:
    # Ensure the enemy scene is set up correctly.
    if not G.utils.ensure(is_instance_valid(get_sprite())):
        return
    if not G.utils.ensure(is_instance_valid(get_collision_shape())):
        return

    G.enemies.push_back(self)

    assign_config()

    sound_scene = G.settings.enemy_sound_scene.instantiate()
    add_child(sound_scene)

    setup_sound()

    # Fade-in.
    var tween := create_tween()
    modulate.a = 0
    tween.tween_property(self, "modulate:a", 1, 0.5)


func setup_sound() -> void:
    pass


func _physics_process(delta: float) -> void:
    if not G.game_panel.has_fully_initialized:
        return

    # Hacky catch-all fix to prevent falling-through-the-world edge-cases.
    if global_position.y > 1:
        # Enemies get pushed under the floor when being beamed from an angle.
        if not state == State.BEING_BEAMED:
            push_warning("Enemy is below the floor")
        _hack_sanitize_weird_transform_state()
    if position.y > 1 and get_parent() == G.game_panel.get_enemy_container():
        # NOTE: This somehow happens a lot.
        #push_warning("Enemy is below the floor, AND GLOBAL_POSITION IS SOMEHOW BORKED!")
        _hack_sanitize_weird_transform_state()

    var time_since_dead := Time.get_ticks_msec() / 1000.0 - death_time
    if is_dead() and time_since_dead >= FADE_DELAY_AFTER_DEATH:
        _fade_out_death()

    var is_past_alerted_cut_off := (
        last_player_sighting_time + get_stop_alert_delay() <
                Time.get_ticks_msec() / 1000.0
    )
    if was_player_recently_visible and is_past_alerted_cut_off:
        _on_done_running_away()

    _fix_facing_direction_for_walking_back_to_home_region()

    previous_velocity = velocity

    velocity.x = _get_horizontal_velocity()

    if state == State.BEING_BEAMED:
        velocity.y = 0
    else:
        velocity.y += get_gravity().y * delta

    move_and_slide()

    # teleport the enemy if it is going to walk off the end of the map
    if not G.game_panel.is_shifting_chunks:
        if global_position.x < G.game_panel.combined_level_chunk_bounds.position.x + 2:
            global_position.x = G.game_panel.combined_level_chunk_bounds.end.x - 2
        if global_position.x > G.game_panel.combined_level_chunk_bounds.end.x - 2:
            global_position.x = G.game_panel.combined_level_chunk_bounds.position.x + 2

    # Detect when we start and stop contacting the floor.
    var next_is_on_floor = is_on_floor()
    if next_is_on_floor != was_on_floor:
        if next_is_on_floor:
            var landed_hard := previous_velocity.y > LANDED_HARD_SPEED_THRESHOLD
            _on_landed(landed_hard)
        else:
            _on_lifted_off()
    was_on_floor = next_is_on_floor


func _hack_sanitize_weird_transform_state() -> void:
    global_position.y = -10
    velocity = Vector2.ZERO
    await get_tree().process_frame
    global_position.y = -10
    velocity = Vector2.ZERO


func _on_done_running_away() -> void:
    was_player_recently_visible = false
    if is_alerted():
        state = State.WALKING


func set_is_facing_right(p_is_facing_right: bool) -> void:
    is_facing_right = p_is_facing_right
    rotation = 0
    scale = Vector2.ONE
    scale.x = 1 if is_facing_right else -1


func _fade_out_death() -> void:
    var tween = get_tree().create_tween()
    # Adjust the modulate property to an alpha of 0 (completely transparent)
    tween.tween_property(self, "modulate:a", 0, 1.0)
    await tween.finished # Wait for the tween to complete
    tween.kill() # Clean up the tween
    destroy()


func _exit_tree() -> void:
    # Hack to ensure we don't somehow deallocated enemies without cleaning up references first.
    if self.is_queued_for_deletion() or not is_instance_valid(self):
        destroy()


func destroy() -> void:
    print("Critter destroyed")
    # Remove references to this enemy.
    for enemy in G.enemies:
        if not is_instance_valid(enemy):
            continue
        enemy.visible_enemies.erase(self)
    G.player.pedestrians_in_beam.erase(self)
    G.enemies.erase(self)
    if not self.is_queued_for_deletion():
        queue_free()


func _on_landed(_landed_hard: bool) -> void:
    if state == State.STARTING:
        state = State.WALKING


func _on_lifted_off() -> void:
    pass


func _on_detection_start() -> void:
    if is_dead():
        return

    is_player_visible = true
    _on_ufo_or_beamed_player_detection_start()


func _on_ufo_or_beamed_player_detection_start() -> void:
    if is_dead():
        return

    was_player_recently_visible = true
    last_player_sighting_time = Time.get_ticks_msec() / 1000.0

    if state != State.DEAD and state != State.BEING_BEAMED:
        # Face away from the player.
        set_is_facing_right(global_position.x >= G.player.position.x)

    if state == State.WALKING:
        _on_alerted()


func _on_killed() -> void:
    state = State.DEAD
    death_time = Time.get_ticks_msec() / 1000.0

    var sprite := get_sprite()
    var sprite_wrapper := get_sprite_wrapper()
    sprite.stop()
    sprite_wrapper.rotate(-PI / 2)
    sprite_wrapper.position.y = - get_min_radius()

    G.session.add_splatted_enemy(type)

    G.game_panel.enemy_spawner.spawn_enemy(type)


func _on_alerted() -> void:
    state = get_alerted_state()

    G.session.add_enemy_that_has_detected_you(type)


func _on_detection_end() -> void:
    if is_dead():
        return

    is_player_visible = false
    was_player_recently_visible = true
    last_player_sighting_time = Time.get_ticks_msec() / 1000.0


func _on_detection_area_body_entered(body: Node2D) -> void:
    if is_dead():
        return

    if body is Player:
        _on_detection_start()
    elif body is Enemy:
        visible_enemies[body] = true
        if body.state == State.BEING_BEAMED:
            _on_ufo_or_beamed_player_detection_start()


func _on_detection_area_body_exited(body: Node2D) -> void:
    if is_dead():
        return

    if body is Player:
        _on_detection_end()
    elif body is Enemy:
        visible_enemies.erase(body)


func _fix_facing_direction_for_walking_back_to_home_region() -> void:
    if state != State.WALKING:
        return

    var is_in_home_region := (
        global_position.x >= home_region.global_start_x and
        global_position.x <= home_region.global_end_x
    )
    if is_in_home_region:
        return

    # Have them face back toward their home region.
    var is_enemy_left_of_region := \
        global_position.x < home_region.global_start_x
    var distance_leftward_from_enemy_to_region := (
        (
            (global_position.x -
                G.game_panel.combined_level_chunk_bounds.position.x) +
            (G.game_panel.combined_level_chunk_bounds.end.x -
                home_region.global_end_x)
        ) if
        is_enemy_left_of_region else
        global_position.x - home_region.global_end_x
    )
    var distance_rightward_from_enemy_to_region := (
        home_region.global_start_x - global_position.x if
        is_enemy_left_of_region else
        (
            (G.game_panel.combined_level_chunk_bounds.end.x -
                global_position.x) +
            (home_region.global_start_x -
                G.game_panel.combined_level_chunk_bounds.position.x)
        )
    )
    var is_left_closer := distance_leftward_from_enemy_to_region < distance_rightward_from_enemy_to_region
    set_is_facing_right(not is_left_closer)


func _get_horizontal_velocity() -> float:
    if is_falling():
        return velocity.x

    var facing_direction_multiplier := 1 if is_facing_right else -1
    match state:
        State.STARTING:
            return 0
        State.DEAD:
            return 0
        State.WALKING:
            # Preserve whichever direction they were facing.
            return get_walking_speed() * facing_direction_multiplier
        State.FLEEING:
                # Preserve whichever direction they were facing.
                return get_running_speed() * facing_direction_multiplier
        State.CHASING:
            var horizontal_distance := absf(G.player.global_position.x - global_position.x)
            if get_approach_distance() < horizontal_distance:
                return 0
            else:
                # Preserve whichever direction they were facing.
                return get_running_speed() * facing_direction_multiplier
        State.BEING_BEAMED:
            return 0
        _:
            G.utils.ensure(false)
            return 0


func is_dead() -> bool:
    return state == State.DEAD


func is_falling() -> bool:
    return not was_on_floor and state != State.BEING_BEAMED


func get_sprite() -> AnimatedSprite2D:
    return get_node("SpriteWrapper/AnimatedSprite2D")


func get_sprite_wrapper() -> Node2D:
    return get_node("SpriteWrapper")


func get_collision_shape() -> CollisionShape2D:
    return get_node("CollisionShape2D")


func get_shape() -> Shape2D:
    return get_collision_shape().shape


func get_min_radius() -> float:
    var size := Geometry.calculate_half_width_height(get_shape(), false)
    return min(size.x, size.y)


func get_max_radius() -> float:
    var size := Geometry.calculate_half_width_height(get_shape(), false)
    return max(size.x, size.y)


func is_alerted() -> bool:
    return state == State.FLEEING or state == State.CHASING


func get_alerted_state() -> State:
    return State.CHASING if chases_when_alerted() else State.FLEEING


func assign_config() -> void:
    G.utils.ensure(Settings.ENEMY_CONFIGS.has(type))
    var config_template: Dictionary = Settings.ENEMY_CONFIGS[type]
    for key in [
        "walking_speed",
        "running_speed",
        "jump_boost",
        "approach_distance",
        "stop_alert_delay",
    ]:
        config[key] = randf_range(config_template[key][0], config_template[key][1])
    config.chases = config_template.chases


func get_walking_speed() -> float:
    return config.walking_speed
func get_running_speed() -> float:
    return config.running_speed
func get_jump_boost() -> float:
    return config.jump_boost
func get_approach_distance() -> float:
    return config.approach_distance
func get_stop_alert_delay() -> float:
    return config.stop_alert_delay
func chases_when_alerted() -> bool:
    return config.chases
