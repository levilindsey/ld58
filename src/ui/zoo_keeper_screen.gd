class_name ZooKeeperScreen
extends PanelContainer

const ZOOKEEPER_GREETING = "I am the Zookeeper. Hear me roar. I would like you to collect earthlings for me."

@onready var zoo_speech_audio_player: AudioStreamPlayer = $"../ZooSpeechStreamPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    G.zoo_keeper = self

func _update_zookeeper_text(text: String) -> void:
    zoo_speech_audio_player.play()
    %ZooKeeperText.text = text
    %ZooKeeperText.visible_characters = 0
    var tween = create_tween()
    tween.tween_property(%ZooKeeperText, "visible_characters", text.length(), 3)
    await tween.finished # Wait for the tween to complete
    tween.kill() # Clean up the tween
    zoo_speech_audio_player.stop()

func zookeeper_welcome() ->    void:
    %UpgradeBeam.grab_focus.call_deferred()
    _update_zookeeper_text(ZOOKEEPER_GREETING)
    
func update_upgrades_ui() -> void:
    for widget in [%BeamLevels, %CapacityLevels, %StealthLevels, %SpeedLevels]:
        widget.update_levels_ui()
 
func _on_earth_button_pressed() -> void:
    G.main.click_sound()
    G.game_panel.return_from_zoo_keeper_screen()

func _on_upgrade_speed_pressed() -> void:
    G.main.click_sound()
    %SpeedLevels.set_level(%SpeedLevels.get_level() + 1)
    update_upgrades_ui()

func _on_upgrade_stealth_pressed() -> void:
    G.main.click_sound()
    %StealthLevels.set_level(%StealthLevels.get_level() + 1)
    update_upgrades_ui()

func _on_upgrade_capacity_pressed() -> void:
    G.main.click_sound()
    %CapacityLevels.set_level(%CapacityLevels.get_level() + 1)
    update_upgrades_ui()

func _on_upgrade_beam_pressed() -> void:
    G.main.click_sound()
    %BeamLevels.set_level(%BeamLevels.get_level() + 1)
    update_upgrades_ui()
