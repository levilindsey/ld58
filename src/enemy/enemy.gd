class_name Enemy
extends CharacterBody2D


enum Type {
    FARMER,
    KID,
    OLD_PERSON,
    CAT,
    BUSINESS_PERSON,
    HOMELESS_PERSON,
    POLICE_OFFICER,
    COW,
    CHICKEN,
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

const LETHAL_DROP_HEIGHT := 50.0
const FADE_DELAY_AFTER_DEATH := 5.0
const EXTRA_SECURITY_DISMISSED_DELAY := 8.0


@export var type := Type.FARMER

# This should match the properties on Settings.ENEMY_CONFIGS.
var config: Dictionary

var home_region: Region

var is_searching := false
var is_searching_start_time := -INF

var is_viewing_ship := false
var is_viewing_ship_start_time := -INF

var last_shoot_time := -INF

var state := State.STARTING
var was_on_floor := false
var previous_velocity := Vector2.ZERO
var death_time := -INF
var was_dropped_from_lethal_height := false
var is_fading := false

var last_player_sighting_time := -INF
var was_player_recently_detected := false
var is_facing_right := true

var is_extra_security := false
var is_extra_security_dismissal_queued := false
var extra_security_dismissal_time := INF

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

    if get_is_security() and is_extra_security:
        _set_is_searching(true)

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

    var current_time := Time.get_ticks_msec() / 1000.0
    var time_since_dead := current_time - death_time
    if is_dead() and time_since_dead >= FADE_DELAY_AFTER_DEATH:
        _fade_out()

    if (is_extra_security and
            is_extra_security_dismissal_queued and
            extra_security_dismissal_time < current_time):
        _fade_out()

    var is_past_alerted_cut_off := (
        last_player_sighting_time + get_stop_alert_delay() <
                Time.get_ticks_msec() / 1000.0
    )
    if was_player_recently_detected and is_past_alerted_cut_off:
        _on_done_running_away()

    if get_is_security() and is_viewing_ship:
        var have_recovered_since_first_noticing_ship:  bool = \
            current_time > is_searching_start_time + config.initial_shoot_delay and \
            current_time > is_viewing_ship_start_time + config.initial_shoot_delay
        var have_shot_recently: bool = \
            current_time < last_shoot_time + config.shoot_period
        if have_recovered_since_first_noticing_ship and not have_shot_recently:
            _shoot()

    _fix_facing_direction_for_target()

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
            _on_landed()
        else:
            _on_lifted_off()
    was_on_floor = next_is_on_floor


func _hack_sanitize_weird_transform_state() -> void:
    global_position.y = -10
    velocity = Vector2.ZERO
    await get_tree().process_frame
    global_position.y = -10
    velocity = Vector2.ZERO


func _shoot() -> void:
    last_shoot_time = Time.get_ticks_msec() / 1000.0

    var projectile_scene: PackedScene
    var projectile_speed: float
    var projectile_scale: float
    match type:
        Type.POLICE_OFFICER:
            projectile_scene = G.settings.bullet_scene
            projectile_speed = G.settings.bullet_speed
            projectile_scale = G.settings.bullet_scale
        _:
            G.utils.ensure(false)
            return

    var spawn_position := get_projectile_spawn_position().global_position
    var direction := (G.player.global_position - spawn_position).normalized()
    var spawn_rotation := direction.angle()
    var spawn_velocity := direction * projectile_speed
    var spawn_scale := Vector2.ONE * projectile_scale

    var bullet: Bullet = projectile_scene.instantiate()
    bullet.position = spawn_position
    bullet.velocity = spawn_velocity
    bullet.rotation = spawn_rotation
    bullet.scale = spawn_scale
    bullet.damage = G.settings.bullet_damage
    G.game_panel.get_projectile_container().add_child(bullet)

    # TODO(Alden): Shot bullet


func queue_extra_security_dismissed() -> void:
    G.utils.ensure(is_extra_security)
    is_extra_security_dismissal_queued = true
    update_extra_security_dismissal_time()


func update_extra_security_dismissal_time() -> void:
    extra_security_dismissal_time = Time.get_ticks_msec() / 1000.0 + EXTRA_SECURITY_DISMISSED_DELAY


func _on_done_running_away() -> void:
    was_player_recently_detected = false
    if is_alerted():
        G.game_panel.remove_alerted_enemy(self)
        state = State.WALKING
        if get_is_security() and not is_extra_security:
            _set_is_searching(false)


func set_is_facing_right(p_is_facing_right: bool) -> void:
    is_facing_right = p_is_facing_right
    rotation = 0
    scale = Vector2.ONE
    scale.x = 1 if is_facing_right else -1


func _fade_out() -> void:
    is_fading = true
    remove_references_to_this_enemy()
    disable_collision_monitoring()

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
    remove_references_to_this_enemy()
    if not self.is_queued_for_deletion():
        queue_free()


func remove_references_to_this_enemy() -> void:
    for enemy in G.enemies:
        if not is_instance_valid(enemy):
            continue
        enemy.visible_enemies.erase(self)
    G.player.pedestrians_in_beam.erase(self)
    G.game_panel.current_alerted_enemies.erase(self)
    G.game_panel.enemy_spawner.extra_security_enemies.erase(self)
    G.enemies.erase(self)


func disable_collision_monitoring() -> void:
    get_detection_area().monitoring = false
    get_detection_area().monitorable = false
    #get_collision_shape().disabled = true


func _on_landed() -> void:
    was_dropped_from_lethal_height = false
    if state == State.STARTING:
        state = State.WALKING


func _on_lifted_off() -> void:
    pass


func _on_ufo_detected() -> void:
    if is_dead():
        return

    was_player_recently_detected = true
    last_player_sighting_time = Time.get_ticks_msec() / 1000.0

    if state != State.DEAD and state != State.BEING_BEAMED:
        # Face away from the player.
        set_is_facing_right(global_position.x >= G.player.position.x)

    if state == State.WALKING:
        _on_alerted()


func _on_detection_end() -> void:
    if is_dead():
        return

    was_player_recently_detected = true
    last_player_sighting_time = Time.get_ticks_msec() / 1000.0

    if get_is_security() and not is_searching:
        _set_is_searching(true)

    if is_extra_security:
        update_extra_security_dismissal_time()


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
    G.game_panel.add_alerted_enemy(self)

    if get_is_security() and not is_searching:
        _set_is_searching(true)

    if is_extra_security:
        update_extra_security_dismissal_time()


func _set_is_searching(value: bool) -> void:
    var was_searching := is_searching
    is_searching = value
    if not was_searching and is_searching:
        is_searching_start_time = Time.get_ticks_msec() / 1000.0


func _set_is_viewing_ship(value: bool) -> void:
    var was_viewing_ship := is_viewing_ship
    is_viewing_ship = value
    if not was_viewing_ship and is_viewing_ship:
        is_viewing_ship_start_time = Time.get_ticks_msec() / 1000.0


func _on_detection_area_body_entered(body: Node2D) -> void:
    if is_dead():
        return

    if body is Player:
        _set_is_viewing_ship(true)
        _on_ufo_detected()
    elif body is Enemy:
        visible_enemies[body] = true
        if body.state == State.BEING_BEAMED:
            _on_ufo_detected()


func _on_detection_area_body_exited(body: Node2D) -> void:
    if is_dead():
        return

    if body is Player:
        _set_is_viewing_ship(false)
        _on_detection_end()
    elif body is Enemy:
        visible_enemies.erase(body)


func _fix_facing_direction_for_target() -> void:
    match state:
        State.WALKING:
            var is_in_home_region := (
                global_position.x >= home_region.global_start_x and
                global_position.x <= home_region.global_end_x
            )
            if is_in_home_region:
                return

            # Have them face back toward their home region.
            var is_left_closer := _get_is_target_leftward(global_position.x, home_region.global_center_x)
            set_is_facing_right(not is_left_closer)
        State.CHASING:
            var is_player_leftward_from_enemy = _get_is_target_leftward(
                global_position.x, G.player.global_position.x)
            set_is_facing_right(not is_player_leftward_from_enemy)
        _:
            # Do nothing.
            pass


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
            if horizontal_distance < get_approach_distance():
                return 0
            else:
                # Preserve whichever direction they were facing.
                return get_running_speed() * facing_direction_multiplier
        State.BEING_BEAMED:
            return 0
        _:
            G.utils.ensure(false)
            return 0


func _get_is_target_leftward(source_x: float, target_x: float) -> bool:
    var is_target_leftward := target_x < source_x
    var distance_leftward_to_target := (
        source_x - target_x if
        is_target_leftward else
        (
            (source_x - G.game_panel.combined_level_chunk_bounds.position.x) +
            (G.game_panel.combined_level_chunk_bounds.end.x - target_x)
        )
    )
    var distance_rightward_to_target := (
        (
            (G.game_panel.combined_level_chunk_bounds.end.x - source_x) +
            (target_x - G.game_panel.combined_level_chunk_bounds.position.x)
        ) if
        is_target_leftward else
        target_x - source_x
    )
    return distance_leftward_to_target < distance_rightward_to_target


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


func get_detection_area() -> Area2D:
    return get_node("DetectionArea")


func get_projectile_spawn_position() -> Node2D:
    return get_node("ProjectileSpawnPosition")


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
    return State.CHASING if get_is_security() else State.FLEEING


func assign_config() -> void:
    G.utils.ensure(G.settings.ENEMY_CONFIGS.has(type))
    var config_template: Dictionary = G.settings.ENEMY_CONFIGS[type]
    for key in [
        "walking_speed",
        "running_speed",
        "jump_boost",
        "approach_distance",
        "stop_alert_delay",
        "shoot_period",
        "initial_shoot_delay",
    ]:
        config[key] = randf_range(config_template[key][0], config_template[key][1])
    config.is_security = config_template.is_security


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
func get_is_security() -> bool:
    return config.is_security


static func get_is_security_enemy_by_type(p_type: Type) -> bool:
    return G.settings.ENEMY_CONFIGS[p_type].is_security


static func get_alerted_enemy_multiplier_by_type(p_type: Type) -> float:
    return (
        G.settings.count_multiplier_for_alert_security_enemy if
        get_is_security_enemy_by_type(p_type) else
        1
    )
