class_name Enemy
extends CharacterBody2D


enum Type {
    FARMER,
    KID,
    BUSINESS_MAN,
    ELDERLY,
    HOMELESS_PERSON,
    CAT,
    POLICE_OFFICER,
    # TODO: Add stuff here!
    POLICE_CAR,
    TANK,
    HELICOPTER,
}

enum State {
    STARTING,
    DEAD,
    IDLE,
    RETREATING,
    APPROACHING,
    ATTACKING,
    FALLING,
    BEING_BEAMED,
}


const LANDED_HARD_SPEED_THRESHOLD := 200


@export var type := Type.FARMER

var state := State.STARTING
var was_on_floor := false
var previous_velocity := Vector2.ZERO

# Dictionary<Enemy, bool>
var visible_enemies := {}


func _ready() -> void:
    G.enemies.push_back(self)


func _physics_process(delta: float) -> void:
    if state == State.BEING_BEAMED:
        return

    previous_velocity = velocity

    velocity.x = _get_horizontal_velocity()

    velocity.y += get_gravity().y * delta

    move_and_slide()

    # Detect when we start and stop contacting the floor.
    var next_is_on_floor = is_on_floor()
    if next_is_on_floor != was_on_floor:
        if next_is_on_floor:
            var landed_hard := previous_velocity.y > LANDED_HARD_SPEED_THRESHOLD
            _on_landed(landed_hard)
        else:
            _on_lifted_off()
    was_on_floor = next_is_on_floor


func _on_landed(_landed_hard: bool) -> void:
    pass


func _on_lifted_off() -> void:
    pass


func _get_horizontal_velocity() -> float:
    G.utils.ensure(false, "_get_horizontal_velocity is abstract and must be overridden.")
    return 0


func is_dead() -> bool:
    return state == State.DEAD
