class_name Hud
extends PanelContainer


func _ready() -> void:
    G.hud = self

    # Wait for G.settings to be assigned.
    await get_tree().process_frame

    self.visible = G.settings.show_hud


# FIXME(levilindsey): LEFT OFF HERE: -------------------------------------
#G.game_panel.active_quest
#G.session.detection_score
#G.session.health
#G.session.max_health
#G.session.money
#G.session.collection_capacity
#G.session.current_enemies_collected_by_type
#G.session.current_enemies_collected_count
#G.session.current_enemies_deposited_by_type
#G.session.current_enemies_deposited_count
#G.session.current_quest_excursion_count


func update() -> void:
    if not is_instance_valid(G.session.active_quest):
        return
    %QuestEnemyList.set_up_with_denominators(
        G.session.current_enemies_collected_by_type,
        G.session.active_quest.enemy_type_to_count)
