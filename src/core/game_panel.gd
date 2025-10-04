class_name GamePanel
extends Node2D


func _ready() -> void:
    G.game_panel = self

    get_viewport().size_changed.connect(_on_viewport_size_changed)
    _on_viewport_size_changed()


func _on_viewport_size_changed() -> void:
    var size := self.get_viewport().get_visible_rect().size
    # TODO
