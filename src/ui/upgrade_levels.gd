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
        UpgradeTypes.BEAM:
            G.session.beam_scale = updated_ability_value
            G.player.update_beam_scale()
        UpgradeTypes.STEALTH:
            pass
        _:
            G.utils.ensure(false)

func get_level() -> int:
     return G.session.ship_upgrade_levels[type]

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
