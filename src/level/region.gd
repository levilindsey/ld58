class_name Region
extends RefCounted


enum Type {
    RURAL,
    SUBURBS,
    CITY,
}

var chunk: LevelChunk
var type: Region.Type = Region.Type.RURAL
var local_start_x := 0.0
var local_end_x := 0.0

var global_start_x: float:
    get:
        return chunk.global_position.x + local_start_x
var global_end_x: float:
    get:
        return chunk.global_position.x + local_end_x

var width: float:
    get:
        return local_end_x - local_start_x


func _init(p_chunk: LevelChunk, p_type: Region.Type, p_local_start_x: float, p_local_end_x: float) -> void:
    chunk = p_chunk
    type = p_type
    local_start_x = p_local_start_x
    local_end_x = p_local_end_x
