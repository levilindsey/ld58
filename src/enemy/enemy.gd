class_name Enemy
extends CharacterBody2D


enum Type {
    FARMER,
    # TODO: Add stuff here!
    POLICE_OFFICER,
    POLICE_CAR,
    TANK,
    HELICOPTER,
}

enum State {
    IDLE,
    RETREATING,
    APPROACHING,
    ATTACKING,
    FALLING,
    BEING_BEAMED,
}


@export var type := Type.FARMER

var state := State.IDLE


func _physics_process(delta: float) -> void:
    if state == State.BEING_BEAMED:
        return

    velocity.y += get_gravity().y * delta

    move_and_slide()


func _get_horizontal_velocity() -> float:
    G.utils.ensure(false, "_get_horizontal_velocity is abstract and must be overridden.")
    return 0
