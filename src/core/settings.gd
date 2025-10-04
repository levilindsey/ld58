class_name Settings
extends Resource


@export var dev_mode := true

@export var full_screen := false
# TODO: Hook this up.
@export var mute_music := false
@export var pauses_on_focus_out := true
@export var is_screenshot_hotkey_enabled := true

@export var show_hud := true

@export var farmer_scene : PackedScene

func getEnemyScene(enemyType: Enemy.Type):
    match enemyType:
        Enemy.Type.FARMER:
            return farmer_scene.instantiate()
        _:
            G.utils.ensure(false)
            return

# TODO: Configure initial screen/level to open.
