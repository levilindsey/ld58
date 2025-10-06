class_name Hud
extends PanelContainer


@export var normal_color := Color(1.0, 1.0, 1.0, 1.0)
@export var ship_full_color := Color(0.976, 0.529, 0.439, 1.0)


func _ready() -> void:
    G.hud = self

    # Wait for G.settings to be assigned.
    await get_tree().process_frame

    self.visible = G.settings.show_hud


# TODO: Show health and detection score.
# G.session.detection_score
# G.session.health
# G.session.max_health


func update() -> void:
    if not is_instance_valid(G.session.active_quest):
        return

    %CurrentCollectionCount.text = str(G.session.current_enemies_collected_count)
    %CollectionCapacity.text = str(G.session.collection_capacity)

    var ship_capacity_color := ship_full_color if G.session.is_ship_full() else normal_color
    %CurrentCollectionCount.add_theme_color_override("font_color", ship_capacity_color)
    %ShipCapacitySlash.add_theme_color_override("font_color", ship_capacity_color)
    %CollectionCapacity.add_theme_color_override("font_color", ship_capacity_color)

    %QuestEnemyList.set_up_with_denominators(
        G.session.get_combined_counts_of_collected_and_deposited(),
        G.session.active_quest.enemy_type_to_count)
