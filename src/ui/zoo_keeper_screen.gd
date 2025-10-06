class_name ZooKeeperScreen
extends PanelContainer

const ZOOKEEPER_GREETING = "I am the Zookeeper. Hear me roar. I would like you to collect earthlings for me."

@onready var zoo_speech_audio_player: AudioStreamPlayer = $"../ZooSpeechStreamPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    G.zoo_keeper = self

func _update_zookeeper_text(text: String) -> void:
    %ZooKeeperText.text = text
    %ZooKeeperText.visible_characters = 0
    var tween = create_tween()
    tween.tween_property(%ZooKeeperText, "visible_characters", text.length(), 3)
    await tween.finished # Wait for the tween to complete
    tween.kill() # Clean up the tween

func zookeeper_welcome() ->    void:
    %DropEarthlings.grab_focus.call_deferred()
    _update_zookeeper_text(ZOOKEEPER_GREETING)

func _on_earth_button_pressed() -> void:
    G.game_panel.return_from_zoo_keeper_screen()

func _on_upgrade_speed_pressed() -> void:
    G.player.max_speed *= 1.1

func _on_upgrade_stealth_pressed() -> void:
    pass # Replace with function body.

func _on_upgrade_capacity_pressed() -> void:
    G.session.collection_capacity += 1

func _on_drop_earthlings_pressed() -> void:
    pass # Replace with function body.
