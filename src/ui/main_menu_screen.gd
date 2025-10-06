class_name MainMenuScreen
extends PanelContainer


func _ready() -> void:
    G.main_menu_screen = self


func _on_button_pressed() -> void:
    G.main.click_sound()
    G.main.open_screen("zoo_keeper_screen")
    G.zoo_keeper_screen.zookeeper_welcome()
