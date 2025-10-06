class_name QuestManager
extends Node


var quest_schedule: Array[Quest] = [
    Quest.new({
        Enemy.Type.FARMER: 1,
    }, 10),
    Quest.new({
        Enemy.Type.OLD_PERSON: 1,
        Enemy.Type.KID: 1
    }, 10),
     Quest.new({
        Enemy.Type.CAT: 2,
        Enemy.Type.COW: 1,
        Enemy.Type.CHICKEN: 1,
    }, 10),
    Quest.new({
        Enemy.Type.HOMELESS_PERSON: 3,
        Enemy.Type.BUSINESS_PERSON: 3,
    }, 10),
    Quest.new({
        Enemy.Type.POLICE_OFFICER: 5
    }, 10),
    Quest.new({
        Enemy.Type.GOLDEN_CHICKEN: 1
    }, 10)
]

var schedule_index := 0


func _init() -> void:
    G.session.start_new_quest(quest_schedule[schedule_index])


func on_return_to_zoo() -> void:
    # Check if the quest is fulfilled.
    var is_quest_fulfilled := true
    for type in G.session.active_quest.enemy_type_to_count:
        var target_count: int = G.session.active_quest.enemy_type_to_count[type]
        var deposited_count: int = G.session.current_enemies_deposited_by_type[type]
        if deposited_count < target_count:
            is_quest_fulfilled = false
            break

    # Start the next quest.
    if is_quest_fulfilled:
        G.session.money += calculate_money_for_quest(G.session.active_quest)
        G.session.fulfilled_quests.push_back(G.session.active_quest)
        schedule_index += 1
        var next_quest: Quest
        if schedule_index < quest_schedule.size():
            next_quest = quest_schedule[schedule_index]
            G.session.start_new_quest(next_quest)
            G.session.total_quest_count += 1
        else:
            on_win()

func on_win() -> void:
    G.player.global_position = G.game_panel.player_start_position
    G.session.is_game_ended = true
    G.main.open_screen(G.main.ScreenType.WIN)
    
func calculate_money_for_quest(quest: Quest):
    var total_enemies_needed = 0
    for quota in quest.enemy_type_to_count.values():
        total_enemies_needed += quota
    var total_enemies_caught = 0
    for caught in G.session.current_enemies_deposited_by_type.values():
        total_enemies_caught += caught
    return quest.money_reward + total_enemies_caught - total_enemies_needed
