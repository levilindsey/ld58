class_name Settings
extends Resource


@export var dev_mode := true
@export var draw_annotations := false

@export var total_enemy_count := 40
@export var count_multiplier_for_alert_security_enemy := 4

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

const SHIP_UPGRADE_VALUES := {
    # [max_speed, max_speed_while_beaming, gravity_per_enemy]
    UpgradeLevels.UpgradeTypes.SPEED: {
        0: [150, 50, 100],
        1: [200, 70, 80],
        2: [300, 100, 50],
        3: [450, 150, 0]
    },
    # Beam values are the scale factor of the beam.
    UpgradeLevels.UpgradeTypes.BEAM: {
        0: 0.3,
        1: 0.5,
        2: 0.7,
        3: 1.0
    },
    # Capacity values are the raw capcity values.
    UpgradeLevels.UpgradeTypes.CAPACITY: {
        0: 3,
        1: 4,
        2: 6,
        3: 10
    },
    # number of enemies to fill the detection bar
    UpgradeLevels.UpgradeTypes.STEALTH: {
        0: 4,
        1: 6,
        2: 10,
        3: 15
    }
}

const ENEMY_CONFIGS := {
    Enemy.Type.FARMER: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        is_security = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.KID: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        is_security = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.OLD_PERSON: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        is_security = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.CAT: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        is_security = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.HOMELESS_PERSON: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        is_security = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.BUSINESS_PERSON: {
        walking_speed = [45, 55],
        running_speed = [190, 220],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [6, 8],
        is_security = false,
        regions = [Region.Type.RURAL],
        population_weight = 10,
    },
    Enemy.Type.POLICE_OFFICER: {
        walking_speed = [55, 65],
        running_speed = [200, 240],
        jump_boost = [150, 170],
        approach_distance = [28, 36],
        stop_alert_delay = [10, 12],
        is_security = true,
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
