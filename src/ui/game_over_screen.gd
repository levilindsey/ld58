class_name GameOverScreen
extends PanelContainer


func _ready() -> void:
    G.game_over_screen = self


func _on_button_pressed() -> void:
    G.main.click_sound()
    G.main.open_screen("zoo_keeper_screen")
