class_name Pedestrian
extends Enemy


# TODO: Add support for detecting when falling, and when colliding. If too fast, DEATH

const WALKING_SPEED := 100
const RUNNING_SPEED := 300


func _get_horizontal_velocity() -> float:
    match state:
        State.IDLE:
            # Preserve whichever direction they were facing.
            return WALKING_SPEED * scale.x
        State.RETREATING, \
        State.APPROACHING:
            # Preserve whichever direction they were facing.
            return RUNNING_SPEED * scale.x
        State.FALLING:
            return velocity.x
        State.BEING_BEAMED:
            return 0
        _:
            G.utils.ensure(false)
            return 0


func on_beam_start() -> void:
    state = State.BEING_BEAMED


func on_beam_end() -> void:
    state = State.FALLING


func _on_detection_start() -> void:
    state = State.RETREATING


func _on_detection_end() -> void:
    state = State.IDLE


func _on_detection_area_body_entered(body: Node2D) -> void:
    if not body is Player:
        G.utils.ensure(false, "Pedestrian._on_detection_area_body_entered with non-Player")
        return
    _on_detection_start()


func _on_detection_area_body_exited(body: Node2D) -> void:
    if not body is Player:
        G.utils.ensure(false, "Pedestrian._on_detection_area_body_exited with non-Player")
        return


func _on_detection_stop_area_body_entered(body: Node2D) -> void:
    if not body is Player:
        G.utils.ensure(false, "Pedestrian._on_detection_stop_area_body_entered with non-Player")
        return


func _on_detection_stop_area_body_exited(body: Node2D) -> void:
    if not body is Player:
        G.utils.ensure(false, "Pedestrian._on_detection_stop_area_body_exited with non-Player")
        return
    _on_detection_end()
