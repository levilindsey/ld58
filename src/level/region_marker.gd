@tool
class_name RegionMarker
extends Node2D


const DEBUG_ANNOTATION_LINE_LENGTH := 500


@export var type: Region.Type = Region.Type.RURAL


func _draw() -> void:
    if not Engine.is_editor_hint() and not G.settings.draw_annotations:
        return

    var end_offset := Vector2.UP * DEBUG_ANNOTATION_LINE_LENGTH / 2

    draw_line(
        end_offset,
        -end_offset,
        Color(1.0, 0.622, 0.869, 0.4),
        4)
