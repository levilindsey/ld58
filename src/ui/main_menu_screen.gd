class_name MainMenuScreen
extends PanelContainer


func _ready() -> void:
    G.main_menu_screen = self


func on_open() -> void:
    %Button.grab_focus.call_deferred()


func _on_button_pressed() -> void:
    G.main.click_sound()
    G.session.is_game_ended = false
    G.main.open_screen(Main.ScreenType.ZOO_KEEPER)
    G.zoo_keeper_screen.zookeeper_welcome()
