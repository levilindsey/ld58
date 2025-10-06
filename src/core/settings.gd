class_name Settings
extends Resource


@export var dev_mode := true

@export var start_in_zookeeper_screen := true
@export var full_screen := false
# TODO: Hook this up.
@export var mute_music := false
@export var pauses_on_focus_out := true
@export var is_screenshot_hotkey_enabled := true

@export var show_hud := true

@export var farmer_scene : PackedScene
@export var kid_scene : PackedScene
@export var homeless_person_scene : PackedScene
@export var elderly_scene : PackedScene
@export var cat_scene : PackedScene
@export var business_person_scene : PackedScene
@export var police_officer_scene : PackedScene

@export var enemy_sound_scene: PackedScene


func getEnemyScene(enemyType: Enemy.Type):
    match enemyType:
        Enemy.Type.FARMER:
            return farmer_scene.instantiate()
        Enemy.Type.KID:
            return kid_scene.instantiate()
        Enemy.Type.POLICE_OFFICER:
            return police_officer_scene.instantiate()
        Enemy.Type.ELDERLY:
            return elderly_scene.instantiate()
        Enemy.Type.HOMELESS_PERSON:
            return homeless_person_scene.instantiate()
        Enemy.Type.CAT:
            return cat_scene.instantiate()
        Enemy.Type.BUSINESS_MAN:
            return business_person_scene.instantiate()
        _:
            G.utils.ensure(false)
            return

# TODO: Configure initial screen/level to open.
