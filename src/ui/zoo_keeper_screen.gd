class_name ZooKeeperScreen
extends PanelContainer

const ZOOKEEPER_GREETING = """
I am the Zookeeper. I've always been interested in Earthlings and it's time to start a collection
of my own! If you collect them for me, I'll reward you handsomely in alien coins that you can
use to upgrade your ship. Who doesn't love home improvement?
"""
const ZOOKEEPER_QUEST_FULFILLED = """
Excellent. You are helping my dreams come true. Please take some money
as a token of my gratitude.
"""
const ZOOKEEPER_QUEST_FAILED = """
Hmmm. These earthlings don't quite match what I'm looking for. Mind going
down and trying again?
"""

const UPGRADE_BEAM_TEXT = "Enlarge tractor beam"
const UPGRADE_CAPACITY_TEXT = "Add ship capacity"
const UPGRADE_STEALTH_TEXT = "Upgrade stealth"
const UPGRADE_SPEED_TEXT = "Improve speed"

@onready var zoo_speech_audio_player: AudioStreamPlayer = $ZooSpeechStreamPlayer

var fulfilled_quests_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    G.zoo_keeper_screen = self
    _update_upgrades_ui()

func reset() -> void:
    fulfilled_quests_counter = 0

func _update_zookeeper_text(text: String) -> void:
    zoo_speech_audio_player.play()
    %ZooKeeperText.text = text
    %ZooKeeperText.visible_characters = 0
    var tween = create_tween()
    tween.tween_property(%ZooKeeperText, "visible_characters", text.length(), int(text.length() / 30.0))
    await tween.finished # Wait for the tween to complete
    tween.kill() # Clean up the tween
    stop_zookeeper_audio()

func stop_zookeeper_audio() -> void:
    if zoo_speech_audio_player.playing:
        zoo_speech_audio_player.stop()

func on_return_to_zoo() -> void:
    _focus_first_enabled_button()
    _update_upgrades_ui()
    if G.session.fulfilled_quests.size() > fulfilled_quests_counter:
        _update_zookeeper_text(ZOOKEEPER_QUEST_FULFILLED)
        G.utils.ensure(G.session.fulfilled_quests.size() - 1 == fulfilled_quests_counter)
        fulfilled_quests_counter += 1
    else:
        _update_zookeeper_text(ZOOKEEPER_QUEST_FAILED)

func _focus_first_enabled_button() -> void:
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
    _focus_first_enabled_button()
    _update_zookeeper_text(ZOOKEEPER_GREETING)

func _update_wallet_text() -> void:
    if G.session.money == 1:
        %Wallet.text = "You have " + str(G.session.money) + " alien buck."
    else:
        %Wallet.text = "You have " + str(G.session.money) + " alien bucks."

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
    G.main.open_screen(Main.ScreenType.GAME)

func _on_upgrade_speed_pressed() -> void:
     _on_upgrade_button_pressed(%SpeedLevels, %UpgradeSpeed)

func _on_upgrade_stealth_pressed() -> void:
     _on_upgrade_button_pressed(%StealthLevels, %UpgradeStealth)

func _on_upgrade_capacity_pressed() -> void:
     _on_upgrade_button_pressed(%CapacityLevels, %UpgradeCapacity)

func _on_upgrade_beam_pressed() -> void:
    _on_upgrade_button_pressed(%BeamLevels, %UpgradeBeam)

func _on_upgrade_button_pressed(upgradeLevels: UpgradeLevels, button: Button) -> void:
    G.main.click_sound()
    G.session.money -= upgradeLevels.get_upgrade_cost()
    upgradeLevels.set_level(upgradeLevels.get_level() + 1)
    _update_upgrades_ui()
    if button.disabled:
        _focus_first_enabled_button()


func _on_zoo_speech_stream_player_finished() -> void:
    # keep repeating alien voice until text is finished.
    zoo_speech_audio_player.play()
