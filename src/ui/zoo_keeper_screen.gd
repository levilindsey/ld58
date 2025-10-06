class_name ZooKeeperScreen
extends PanelContainer

const ZOOKEEPER_GREETING = "I am the Zookeeper. Hear me roar. I would like you to collect earthlings for me."

const UPGRADE_BEAM_TEXT = "Enlarge tractor beam"
const UPGRADE_CAPACITY_TEXT = "Add ship capacity"
const UPGRADE_STEALTH_TEXT = "Upgrade stealth"
const UPGRADE_SPEED_TEXT = "Improve speed"

@onready var zoo_speech_audio_player: AudioStreamPlayer = $"../ZooSpeechStreamPlayer"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    G.zoo_keeper = self
    _update_upgrades_ui()

func _update_zookeeper_text(text: String) -> void:
    zoo_speech_audio_player.play()
    %ZooKeeperText.text = text
    %ZooKeeperText.visible_characters = 0
    var tween = create_tween()
    tween.tween_property(%ZooKeeperText, "visible_characters", text.length(), 3)
    await tween.finished # Wait for the tween to complete
    tween.kill() # Clean up the tween
    zoo_speech_audio_player.stop()

func focus_first_enabled_button() -> void:
    if not %UpgradeBeam.disabled:
        %UpgradeBeam.grab_focus.call_deferred()
    elif not %UpgradeCapacity.disabled:
        %UpgradeCapacity.grab_focus.call_deferred()
    elif not %UpgradeStealth.disabled:
        %UpgradeStealth.grab_focus.call_deferred()
    elif not %UpgradeSpeed.disabled:
        %UpgradeSpeed.grab_focus.call_deferred()
    elif not %EarthButton.disabled:
        %EarthButton.grab_focus.call_deferred()
    else:
        G.utils.ensure(false)


func zookeeper_welcome() ->    void:
    focus_first_enabled_button()
    _update_zookeeper_text(ZOOKEEPER_GREETING)
    
func _update_wallet_text() -> void:
    if G.session.money == 1:
        %Wallet.text = "You have " + str(G.session.money) + " alien bucks."
    else:
        %Wallet.text = "You have " + str(G.session.money) + " alien buck."
    
func _update_upgrades_ui() -> void:
    for widget in [%BeamLevels, %CapacityLevels, %StealthLevels, %SpeedLevels]:
        widget.update_levels_ui()
    _update_upgrade_buttons_ui()
    _update_wallet_text()

func _update_upgrade_buttons_ui() -> void:
    _update_upgrade_button_ui(%UpgradeBeam, %BeamLevels, UPGRADE_BEAM_TEXT)
    _update_upgrade_button_ui(%UpgradeCapacity, %CapacityLevels, UPGRADE_CAPACITY_TEXT)
    _update_upgrade_button_ui(%UpgradeStealth, %StealthLevels, UPGRADE_STEALTH_TEXT)
    _update_upgrade_button_ui(%UpgradeSpeed, %SpeedLevels, UPGRADE_SPEED_TEXT)

func _update_upgrade_button_ui(button: Button, upgrade_levels: UpgradeLevels, text: String) -> void:
    var upgrade_level = upgrade_levels.get_level()
    var upgrade_cost = upgrade_levels.get_upgrade_cost()
    if upgrade_level == 3:
        button.text = text + "  (max)"
    else:
        button.text = text + "  ($" + str(upgrade_cost) + ")"
    
    if upgrade_level == 3 or upgrade_cost > G.session.money:
        button.disabled = true
        button.focus_mode = Control.FOCUS_NONE
    else:
        button.disabled = false
        button.focus_mode = Control.FOCUS_ALL
 
func _on_earth_button_pressed() -> void:
    G.main.click_sound()
    G.game_panel.return_from_zoo_keeper_screen()

func _on_upgrade_speed_pressed() -> void:
    G.main.click_sound()
    %SpeedLevels.set_level(%SpeedLevels.get_level() + 1)
    _update_upgrades_ui()

func _on_upgrade_stealth_pressed() -> void:
    G.main.click_sound()
    %StealthLevels.set_level(%StealthLevels.get_level() + 1)
    _update_upgrades_ui()

func _on_upgrade_capacity_pressed() -> void:
    G.main.click_sound()
    %CapacityLevels.set_level(%CapacityLevels.get_level() + 1)
    _update_upgrades_ui()

func _on_upgrade_beam_pressed() -> void:
    G.main.click_sound()
    %BeamLevels.set_level(%BeamLevels.get_level() + 1)
    _update_upgrades_ui()
