class_name EnemyCountRow
extends HBoxContainer


@export var business_man_icon: Texture2D
@export var cat_icon: Texture2D
@export var elderly_icon: Texture2D
@export var farmer_icon: Texture2D
@export var homeless_person_icon: Texture2D
@export var kid_icon: Texture2D
@export var police_officer_icon: Texture2D
@export var cow_icon: Texture2D
@export var chicken_icon: Texture2D

@export var normal_color := Color(1, 1, 1, 1)
@export var unfulfilled_color := Color("fffda3ff")
@export var fulfilled_color := Color(0.553, 0.788, 0.318, 1.0)
@export var zero_denominator_color := Color(0.624, 0.235, 0.569, 1.0)


func set_up(type: Enemy.Type, count: int, is_name_shown: bool) -> void:
    %Icon.texture = get_icon_texture(type)
    %Type.text = get_label(type)
    %Type.visible = is_name_shown
    %Numerator.text = str(count)
    %Slash.visible = false
    %Denominator.visible = false
    %Numerator.add_theme_color_override("font_color", normal_color)
    %Slash.add_theme_color_override("font_color", normal_color)
    %Denominator.add_theme_color_override("font_color", normal_color)


func set_up_with_denominator(
        type: Enemy.Type, numerator: int, denominator: int, is_name_shown: bool) -> void:
    %Icon.texture = get_icon_texture(type)
    %Type.text = get_label(type)
    %Type.visible = is_name_shown
    %Numerator.text = str(numerator)
    %Slash.visible = true
    %Denominator.text = str(denominator)
    %Denominator.visible = true

    var count_color: Color
    if denominator == 0:
        count_color = zero_denominator_color
    elif numerator < denominator:
        count_color = unfulfilled_color
    else:
        count_color = fulfilled_color
    %Numerator.add_theme_color_override("font_color", count_color)
    %Slash.add_theme_color_override("font_color", count_color)
    %Denominator.add_theme_color_override("font_color", count_color)



func get_icon_texture(type: Enemy.Type) -> Texture2D:
    match type:
        Enemy.Type.FARMER:
            return farmer_icon
        Enemy.Type.KID:
            return kid_icon
        Enemy.Type.BUSINESS_PERSON:
            return business_man_icon
        Enemy.Type.OLD_PERSON:
            return elderly_icon
        Enemy.Type.HOMELESS_PERSON:
            return homeless_person_icon
        Enemy.Type.CAT:
            return cat_icon
        Enemy.Type.POLICE_OFFICER:
            return police_officer_icon
        Enemy.Type.COW:
            return cow_icon
        Enemy.Type.CHICKEN:
            return chicken_icon
        _:
            G.utils.ensure(false)
            return null


func get_label(type: Enemy.Type) -> String:
    match type:
        Enemy.Type.FARMER:
            return "Farmer"
        Enemy.Type.KID:
            return "Kid"
        Enemy.Type.BUSINESS_PERSON:
            return "Businessperson"
        Enemy.Type.OLD_PERSON:
            return "Old person"
        Enemy.Type.HOMELESS_PERSON:
            return "Houseless person"
        Enemy.Type.CAT:
            return "Cat"
        Enemy.Type.POLICE_OFFICER:
            return "Cop"
        Enemy.Type.COW:
            return "Cow"
        Enemy.Type.CHICKEN:
            return "Chicken"
        _:
            G.utils.ensure(false)
            return ""
