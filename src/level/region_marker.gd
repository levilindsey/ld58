@tool
class_name RegionMarker
extends Node2D


const DEBUG_ANNOTATION_LINE_LENGTH := 500

const RURAL_COLOR := Color(1.0, 0.622, 0.869, 0.4)
const SUBURBS_COLOR := Color(0.92, 0.746, 0.0, 0.4)
const CITY_COLOR := Color(0.0, 0.87, 0.899, 0.4)


@export var type: Region.Type = Region.Type.RURAL


func _draw() -> void:
    if not Engine.is_editor_hint() and not G.settings.draw_annotations:
        return

    var end_offset := Vector2.UP * DEBUG_ANNOTATION_LINE_LENGTH / 2

    var color: Color
    match type:
        Region.Type.RURAL:
            color = RURAL_COLOR
        Region.Type.SUBURBS:
            color = SUBURBS_COLOR
        Region.Type.CITY:
            color = CITY_COLOR
        _:
            G.utils.ensure(false)

    draw_line(
        end_offset,
        -end_offset,
        color,
        4)
