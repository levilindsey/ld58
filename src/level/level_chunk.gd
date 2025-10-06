@tool
class_name LevelChunk
extends Node2D


var size := Vector2.ZERO

# Sorted on x position.
var regions: Array[Region] = []

# Dictionary<Region.Type, float>
var total_width_per_region_type := {}


func _ready() -> void:
    var start_bounds := get_bounds()
    size = start_bounds.size

    _record_regions()


func _record_regions() -> void:
    var markers: Array[RegionMarker] = []

    for child in get_children():
        if not child is RegionMarker:
            continue
        markers.push_back(child)

    markers.sort_custom(
        func (a: RegionMarker, b: RegionMarker):
            return a.position.x < b.position.x)

    if not Engine.is_editor_hint():
        G.utils.ensure(markers.size() >= 2)

    regions.clear()

    var synthetic_end_marker := RegionMarker.new()
    synthetic_end_marker.position.x = size.x
    markers.push_back(synthetic_end_marker)

    for i in range(1, markers.size()):
        var start_marker := markers[i - 1]
        var end_marker := markers[i]
        var region := Region.new(
            self,
            start_marker.type,
            start_marker.position.x,
            end_marker.position.x)
        regions.push_back(region)

    # Calculate the cumulative width for each region type in this chunk.
    for type in Region.Type.values():
        total_width_per_region_type[type] = 0
    for region in regions:
        total_width_per_region_type[region.type] += region.width


func _draw() -> void:
    if not Engine.is_editor_hint() and not G.settings.draw_annotations:
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
