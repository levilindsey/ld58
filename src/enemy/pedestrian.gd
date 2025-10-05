class_name Pedestrian
extends Enemy


const WALKING_SPEED := 60
const RUNNING_SPEED := 240
const JUMP_VELOCITY_BOOST := 200
const STILL_SCARED_AFTER_DETECTION_ENDED_DELAY := 8


var last_player_sighting_time := -INF
var is_player_visible := false
var was_player_recently_visible := false
var is_facing_right := true


func _physics_process(_delta: float) -> void:
    super._physics_process(_delta)

    if is_dead():
        return

    var is_past_scared_cut_off := (
        last_player_sighting_time + STILL_SCARED_AFTER_DETECTION_ENDED_DELAY <
                Time.get_ticks_msec() / 1000.0
    )
    if was_player_recently_visible and is_past_scared_cut_off:
        was_player_recently_visible = false
        if state == State.RETREATING:
            state = State.IDLE


func _get_horizontal_velocity() -> float:
    var direction_multiplier := 1 if is_facing_right else -1
    match state:
        State.STARTING:
            return 0
        State.DEAD:
            return 0
        State.IDLE:
            # Preserve whichever direction they were facing.
            return WALKING_SPEED * direction_multiplier
        State.RETREATING, \
        State.APPROACHING:
            # Preserve whichever direction they were facing.
            return RUNNING_SPEED * direction_multiplier
        State.FALLING:
            return velocity.x
        State.BEING_BEAMED:
            return 0
        _:
            G.utils.ensure(false)
            return 0

func set_is_facing_right(is_facing_right: bool) -> void:
    self.is_facing_right = is_facing_right
    scale.x = 1 if is_facing_right else -1


func on_beam_start() -> void:
    if is_dead():
        return
    state = State.BEING_BEAMED

    # TODO: Alden: ABDUCTION

    # Trigger detection on any other enemy that can currently see this pedestrian.
    for enemy in G.enemies:
        if enemy == self:
            continue
        if enemy.visible_enemies.has(self):
            enemy._on_ufo_or_beamed_player_detection_start()


func on_beam_end() -> void:
    if is_dead():
        return
    state = State.FALLING


func _on_landed(landed_hard: bool) -> void:
    if is_dead():
        return

    if landed_hard and state != State.STARTING:
        _on_killed()
        return

    if was_player_recently_visible:
        state = State.RETREATING
    else:
        state = State.IDLE


func _on_killed() -> void:
    state = State.DEAD
    # TODO
    pass

    # TODO: Alden: SPLAT


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

    if state == State.IDLE or state == State.FALLING or state == State.RETREATING:
        # Face away from the player.
        set_is_facing_right(position.x >= G.player.position.x)

    if state == State.IDLE:
        state = State.FALLING

        # Jump in fear.
        velocity.x = 0
        velocity.y = -JUMP_VELOCITY_BOOST

        # TODO: Alden: SCREAM


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
