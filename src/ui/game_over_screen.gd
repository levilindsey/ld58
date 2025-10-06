class_name GameOverScreen
extends PanelContainer


func _ready() -> void:
    G.game_over_screen = self


func on_open() -> void:
    %Button.grab_focus.call_deferred()

    %SpecimensCollectedCount.text = str(G.session.total_enemies_deposited_count)
    %SpecimensSplattedCount.text = str(G.session.total_enemies_splatted_count)
    %QuestsCompletedCount.text = str(G.session.total_quest_count)


func _on_button_pressed() -> void:
    G.main.click_sound()
    G.main.open_screen(Main.ScreenType.ZOO_KEEPER)
