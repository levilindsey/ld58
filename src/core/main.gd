class_name Main
extends Node2D


enum ScreenType {
    MAIN_MENU,
    GAME_OVER,
    WIN,
    ZOO_KEEPER,
    GAME,
}


@export var settings: Settings
@onready var click_audio_player: AudioStreamPlayer = $ClickStreamPlayer
@onready var theme_audio_player: AudioStreamPlayer = $ThemeStreamPlayer
@onready var zoo_audio_player: AudioStreamPlayer = $ZooThemeStreamPlayer

var current_screen := ScreenType.MAIN_MENU


var is_paused := true:
    get:
        return is_paused
    set(value):
        is_paused = value


func _ready() -> void:
    print("main._ready")

    randomize()

    G.main = self
    G.settings = settings

    get_tree().paused = true

    await get_tree().process_frame

    # TODO: Open first screen/level based on manifest settings.

    if G.settings.full_screen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

    start_game()


func start_game() -> void:
    var screen_type := ScreenType.GAME if G.settings.start_in_game else ScreenType.MAIN_MENU
    G.session.is_game_ended = not G.settings.start_in_game
    open_screen(screen_type)


func open_screen(screen_type: ScreenType) -> void:
    current_screen = screen_type

    get_tree().paused = true

    G.main_menu_screen.visible = false
    G.game_over_screen.visible = false
    G.win_screen.visible = false
    G.zoo_keeper_screen.visible = false

    match screen_type:
        ScreenType.MAIN_MENU:
            G.game_panel.reset()
            G.main_menu_screen.visible = true
            G.main_menu_screen.on_open()
        ScreenType.GAME_OVER:
            G.game_panel.reset()
            G.game_over_screen.visible = true
            G.game_over_screen.on_open()
        ScreenType.WIN:
            G.game_panel.reset()
            G.win_screen.visible = true
            G.win_screen.on_open()
        ScreenType.ZOO_KEEPER:
            G.zoo_keeper_screen.visible = true
            G.zoo_keeper_screen.on_return_to_zoo()
            # AUDIO: Music Switch
            G.main.fade_to_zoo_theme()
        ScreenType.GAME:
            G.game_panel.return_from_screen()

    G.hud.update_visibility()


func _notification(notification_type: int) -> void:
    match notification_type:
        NOTIFICATION_WM_GO_BACK_REQUEST:
            # Handle the Android back button to navigate within the app instead of
            # quitting the app.
            if false:
                close_app()
            else:
                # TODO: Close the current screen/context.
                pass
        NOTIFICATION_WM_CLOSE_REQUEST:
            close_app()
        NOTIFICATION_WM_WINDOW_FOCUS_OUT:
            if G.settings.pauses_on_focus_out:
                is_paused = true
        _:
            pass


func _unhandled_input(event: InputEvent) -> void:
    if G.settings.dev_mode:
        if event is InputEventKey:
            match event.physical_keycode:
                KEY_P:
                    if G.settings.is_screenshot_hotkey_enabled:
                        G.utils.take_screenshot()
                KEY_O:
                    if is_instance_valid(G.hud):
                        G.hud.visible = not G.hud.visible
                        print(
                            "Toggled HUD visibility: %s" %
                            ("visible" if G.hud.visible else "hidden"))
                KEY_ESCAPE:
                    if G.settings.pauses_on_focus_out:
                        is_paused = true
                _:
                    pass

func click_sound() -> void:
    if not click_audio_player.playing:
        click_audio_player.play()


func close_app() -> void:
    if G.utils.were_screenshots_taken:
        G.utils.open_screenshot_folder()
    print("Shell.close_app")
    get_tree().call_deferred("quit")


func fade_to_zoo_theme() -> void:
    if theme_audio_player.playing:
        var tween := create_tween()
        tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
        tween.tween_property(theme_audio_player, "volume_db", -80.0, .2)

        await tween.step_finished
        theme_audio_player.stream_paused = true

    if not zoo_audio_player.playing:
        zoo_audio_player.play()

func fade_to_main_theme() -> void:
    zoo_audio_player.stop()

    theme_audio_player.stream_paused = false
    var tween := create_tween()
    tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
    tween.tween_property(theme_audio_player, "volume_db", -8.0, .2)

    if not theme_audio_player.playing:
        theme_audio_player.play()

func play_theme() -> void:
    if not theme_audio_player.playing:
        theme_audio_player.play()
