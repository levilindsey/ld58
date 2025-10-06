class_name QuestManager
extends Node


var quest_schedule: Array[Quest] = [
    Quest.new({
        Enemy.Type.FARMER: 3,
    }),
]

var end_game_quests: Array[Quest] = [
    Quest.new({
        Enemy.Type.FARMER: 10,
    }),
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
        schedule_index += 1
        var next_quest: Quest
        if schedule_index < quest_schedule.size():
            next_quest = quest_schedule[schedule_index]
        else:
            var index := randi_range(0, end_game_quests.size() - 1)
            next_quest = end_game_quests[index]

        G.session.start_new_quest(next_quest)
