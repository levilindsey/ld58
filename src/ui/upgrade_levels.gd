class_name UpgradeLevels extends HBoxContainer

enum UpgradeTypes {
    SPEED,
    BEAM,
    CAPACITY,
    STEALTH
}

@export var type := UpgradeTypes.SPEED
@export var filled_style_box : StyleBoxTexture
@export var empty_style_box : StyleBoxTexture

func set_level(level: int) -> void:
    G.session.ship_upgrade_levels[type] = level
    var updated_ability_value = G.settings.SHIP_UPGRADE_VALUES[type][level]
    match type:
        UpgradeTypes.CAPACITY:
            G.session.collection_capacity = updated_ability_value
        UpgradeTypes.SPEED:
            G.session.max_speed = updated_ability_value[0]
            G.session.max_speed_beaming = updated_ability_value[1]
            G.session.gravity_per_enemy = updated_ability_value[2]
        UpgradeTypes.BEAM:
            G.session.beam_scale = updated_ability_value
            G.player.update_beam_scale()
        UpgradeTypes.STEALTH:
            G.session.alert_enemies_count_for_max_detection = updated_ability_value
        _:
            G.utils.ensure(false)

func get_level() -> int:
     return G.session.ship_upgrade_levels[type]

func get_upgrade_cost() -> int:
    var current_level = G.session.ship_upgrade_levels[type]
    if current_level < 3:
        return G.settings.SHIP_UPGRADE_COSTS[type][current_level + 1]
    else:
        return INF

func update_levels_ui() -> void:
    var level = get_level()
    match level:
        3:
            %UpgradeL3.add_theme_stylebox_override("panel", filled_style_box)
            %UpgradeL2.add_theme_stylebox_override("panel", filled_style_box)
            %UpgradeL1.add_theme_stylebox_override("panel", filled_style_box)
        2:
            %UpgradeL3.add_theme_stylebox_override("panel", empty_style_box)
            %UpgradeL2.add_theme_stylebox_override("panel", filled_style_box)
            %UpgradeL1.add_theme_stylebox_override("panel", filled_style_box)
        1:
            %UpgradeL3.add_theme_stylebox_override("panel", empty_style_box)
            %UpgradeL2.add_theme_stylebox_override("panel", empty_style_box)
            %UpgradeL1.add_theme_stylebox_override("panel", filled_style_box)
        0:
            %UpgradeL3.add_theme_stylebox_override("panel", empty_style_box)
            %UpgradeL2.add_theme_stylebox_override("panel", empty_style_box)
            %UpgradeL1.add_theme_stylebox_override("panel", empty_style_box)
        _:
            G.utils.ensure(false)
