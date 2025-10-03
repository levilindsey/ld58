class_name Hud
extends PanelContainer


func _ready() -> void:
    G.hud = self

    # Wait for G.settings to be assigned.
    await get_tree().process_frame

    self.visible = G.settings.show_hud
