class_name GamePanel
extends Node2D


const CHUNK_EDGE_DISTANCE_THRESHOLD_FOR_CHUNK_REPOSITIONING := 128
const ZOO_KEEPER_SPACE_HEIGHT_THRESHOLD := 1024

var player_start_position := Vector2.ZERO

var chunk_a_bounds: Rect2
var chunk_b_bounds: Rect2
var chunk_c_bounds: Rect2
var combined_level_chunk_bounds: Rect2

var is_shifting_chunks := false


func _ready() -> void:
    G.game_panel = self
    player_start_position = G.player.global_position

    is_shifting_chunks = true

    %LevelChunkA.global_position.x = 0

    await get_tree().process_frame
    _update_bounds()

    %LevelChunkB.global_position.x = chunk_a_bounds.size.x

    await get_tree().process_frame
    _update_bounds()

    %LevelChunkC.global_position.x = chunk_a_bounds.size.x + chunk_b_bounds.size.x

    await get_tree().process_frame
    _update_bounds()

    is_shifting_chunks = false


func _physics_process(_delta: float) -> void:
    if is_shifting_chunks:
        return

    # Handle swapping level chunk positions to support infinite scroll.
    var left_threshold := combined_level_chunk_bounds.position.x + CHUNK_EDGE_DISTANCE_THRESHOLD_FOR_CHUNK_REPOSITIONING
    var right_threshold := combined_level_chunk_bounds.end.x - CHUNK_EDGE_DISTANCE_THRESHOLD_FOR_CHUNK_REPOSITIONING
    if G.player.global_position.x < left_threshold:
        is_shifting_chunks = true
        var right_chunk := _get_right_most_level_chunk()
        var right_chunk_bounds := right_chunk.get_bounds()
        right_chunk.global_position.x = combined_level_chunk_bounds.position.x - right_chunk_bounds.size.x
        await get_tree().process_frame
        _update_bounds()
        is_shifting_chunks = false
    elif G.player.global_position.x > right_threshold:
        is_shifting_chunks = true
        var left_chunk := _get_left_most_level_chunk()
        left_chunk.global_position.x = combined_level_chunk_bounds.end.x
        await get_tree().process_frame
        _update_bounds()
        is_shifting_chunks = false

    # Check for player reaching space for zookeeper updates.
    if G.player.global_position.y < -ZOO_KEEPER_SPACE_HEIGHT_THRESHOLD:
        _show_zoo_keeper_screen()


func _show_zoo_keeper_screen() -> void:
    # TODO
    pass


func _return_from_zoo_keeper_screen() -> void:
    G.player.global_position = player_start_position
    # TODO
    pass


func _update_bounds() -> void:
    chunk_a_bounds = %LevelChunkA.get_bounds()
    chunk_b_bounds = %LevelChunkB.get_bounds()
    chunk_c_bounds = %LevelChunkC.get_bounds()
    combined_level_chunk_bounds = chunk_a_bounds.merge(chunk_b_bounds).merge(chunk_c_bounds)
    %LevelChunkA.queue_redraw()
    %LevelChunkB.queue_redraw()
    %LevelChunkC.queue_redraw()


func _get_left_most_level_chunk() -> LevelChunk:
    if chunk_a_bounds.position.x < chunk_b_bounds.position.x:
        if chunk_a_bounds.position.x < chunk_c_bounds.position.x:
            return %LevelChunkA
        else:
            return %LevelChunkC
    else:
        if chunk_b_bounds.position.x < chunk_c_bounds.position.x:
            return %LevelChunkB
        else:
            return %LevelChunkC


func _get_right_most_level_chunk() -> LevelChunk:
    if chunk_a_bounds.end.x > chunk_b_bounds.end.x:
        if chunk_a_bounds.end.x > chunk_c_bounds.end.x:
            return %LevelChunkA
        else:
            return %LevelChunkC
    else:
        if chunk_b_bounds.end.x > chunk_c_bounds.end.x:
            return %LevelChunkB
        else:
            return %LevelChunkC
