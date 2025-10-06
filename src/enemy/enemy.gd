class_name Enemy
extends CharacterBody2D


enum Type {
    FARMER,
    KID,
    ELDERLY,
    CAT,
    HOMELESS_PERSON,
    BUSINESS_MAN,
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

var state := State.STARTING
var was_on_floor := false
var previous_velocity := Vector2.ZERO
var death_time := -INF

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

    sound_scene = G.settings.enemy_sound_scene.instantiate()
    add_child(sound_scene)

    setup_sound()


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
        global_position.y = -0.01

    var time_since_dead := Time.get_ticks_msec() / 1000.0 - death_time
    if is_dead() and time_since_dead >= FADE_DELAY_AFTER_DEATH:
        _fade_out_death()

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


func _get_horizontal_velocity() -> float:
    G.utils.ensure(false, "_get_horizontal_velocity is abstract and must be overridden.")
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


func chases_when_alerted():
    match type:
        Type.FARMER, \
        Type.KID, \
        Type.ELDERLY, \
        Type.CAT, \
        Type.HOMELESS_PERSON, \
        Type.BUSINESS_MAN:
            return false
        Type.POLICE_OFFICER:
            return true
        _:
            G.utils.ensure(false)
            return false
