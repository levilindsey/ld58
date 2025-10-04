@tool
class_name LevelChunk
extends Node2D


const DRAW_DEBUG_BOUNDS_IN_GAME := false


func _draw() -> void:
    if not Engine.is_editor_hint() and not DRAW_DEBUG_BOUNDS_IN_GAME:
        return

    var bounds := _get_bounds_local()
    var points := PackedVector2Array([
        bounds.position,
        bounds.position + bounds.size.x * Vector2.RIGHT,
        bounds.end,
        bounds.position + bounds.size.y * Vector2.DOWN,
        bounds.position,
    ])
    draw_polyline(points, Color(1, .7, .1, 0.4), 4)


func get_bounds() -> Rect2:
    var used_rect_in_tiles: Rect2i = %TerrainTileMap.get_used_rect()
    var top_left_tile_center_local_position: Vector2 = %TerrainTileMap.map_to_local(used_rect_in_tiles.position)
    var bottom_right_tile_center_local_position: Vector2 = %TerrainTileMap.map_to_local(used_rect_in_tiles.end)
    var tile_size: Vector2i = %TerrainTileMap.tile_set.tile_size
    var half_tile_size := Vector2(tile_size / 2)
    var tile_map_global_transform: Transform2D = %TerrainTileMap.global_transform
    var top_left := (top_left_tile_center_local_position - half_tile_size) * tile_map_global_transform.inverse()
    var bottom_right := (bottom_right_tile_center_local_position - half_tile_size) * tile_map_global_transform.inverse()
    return Rect2(top_left, bottom_right - top_left)


func _get_bounds_local() -> Rect2:
    var bounds_global := get_bounds()
    var tile_map_global_transform: Transform2D = %TerrainTileMap.global_transform
    return Rect2(bounds_global.position * tile_map_global_transform, bounds_global.size)
