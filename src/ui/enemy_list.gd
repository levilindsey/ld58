class_name EnemyList
extends PanelContainer


@export var row_scene: PackedScene
@export var is_enemy_name_shown := false


func set_up(type_to_count: Dictionary) -> void:
    # Clear old rows.
    for row in %VBoxContainer.get_children():
        row.queue_free()

    # Add new rows.
    for type in Enemy.Type.values():
        if not type_to_count.has(type):
            continue
        var row: EnemyCountRow = row_scene.instantiate()
        row.set_up(type, type_to_count[type], is_enemy_name_shown)
        %VBoxContainer.add_child(row)


func set_up_with_denominators(
        type_to_numerator: Dictionary, type_to_denominator: Dictionary) -> void:
    # Clear old rows.
    for row in %VBoxContainer.get_children():
        row.queue_free()

    # Add rows for each denominator.
    var unconsumed_numerators := type_to_numerator.duplicate()
    for type in Enemy.Type.values():
        if not type_to_denominator.has(type):
            continue
        var row: EnemyCountRow = row_scene.instantiate()
        var numerator: int = type_to_numerator[type]
        var denominator: int = type_to_denominator[type]
        row.set_up_with_denominator(type, numerator, denominator, is_enemy_name_shown)
        %VBoxContainer.add_child(row)
        unconsumed_numerators.erase(type)

    # Add rows for numerators that lack corresponding denominators.
    for type in Enemy.Type.values():
        if not unconsumed_numerators.has(type):
            continue
        var row: EnemyCountRow = row_scene.instantiate()
        var numerator: int = unconsumed_numerators[type]
        if numerator == 0:
            continue
        row.set_up_with_denominator(type, numerator, 0, is_enemy_name_shown)
        %VBoxContainer.add_child(row)
