class_name Settings
extends Resource


@export var dev_mode := true
@export var draw_annotations := false

@export var total_enemy_count := 40

@export var start_in_zookeeper_screen := true
@export var full_screen := false
# TODO: Hook this up.
@export var mute_music := false
@export var pauses_on_focus_out := true
@export var is_screenshot_hotkey_enabled := true

@export var show_hud := true

@export var farmer_scene: PackedScene
@export var kid_scene: PackedScene
@export var homeless_person_scene: PackedScene
@export var elderly_scene: PackedScene
@export var cat_scene: PackedScene
@export var business_person_scene: PackedScene
@export var police_officer_scene: PackedScene

@export var enemy_sound_scene: PackedScene

const ENEMY_CONFIGS := {
    Enemy.Type.FARMER: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        chases = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.KID: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        chases = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.OLD_PERSON: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        chases = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.CAT: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        chases = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.HOMELESS_PERSON: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        chases = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.BUSINESS_PERSON: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        chases = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.POLICE_OFFICER: {
        walking_speed = [55, 65],
        running_speed = [200, 240],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [10, 12],
        chases = true,
        regions = [Region.Type.SUBURBS, Region.Type.CITY],
        population_weight = 10,
    },
}


func instantiate_enemy(enemyType: Enemy.Type):
    match enemyType:
        Enemy.Type.FARMER:
            return farmer_scene.instantiate()
        Enemy.Type.KID:
            return kid_scene.instantiate()
        Enemy.Type.POLICE_OFFICER:
            return police_officer_scene.instantiate()
        Enemy.Type.OLD_PERSON:
            return elderly_scene.instantiate()
        Enemy.Type.HOMELESS_PERSON:
            return homeless_person_scene.instantiate()
        Enemy.Type.CAT:
            return cat_scene.instantiate()
        Enemy.Type.BUSINESS_PERSON:
            return business_person_scene.instantiate()
        _:
            G.utils.ensure(false)
            return

# TODO: Configure initial screen/level to open.
