class_name WinScreen
extends PanelContainer


func _ready() -> void:
    G.win_screen = self


func _on_button_pressed() -> void:
    G.main.click_sound()
    G.main.open_screen(Main.ScreenType.MAIN_MENU)
