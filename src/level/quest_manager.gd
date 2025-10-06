class_name QuestManager
extends Node


var quest_schedule: Array[Quest] = [
    Quest.new({
        Enemy.Type.FARMER: 3,
    }, 5),
     Quest.new({
        Enemy.Type.CAT: 2,
        Enemy.Type.KID: 2
    }, 5),
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
        G.session.fulfilled_quests.push_back(G.session.active_quest)
        G.session.money += G.session.active_quest.money_reward
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
    G.main.open_screen(G.main.ScreenType.WIN)
