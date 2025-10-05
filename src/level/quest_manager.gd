class_name QuestManager
extends Node


var quest_schedule: Array[Quest] = [
    Quest.new(
        Enemy.Type.FARMER, # Enemy type
        3, # Collection count
        5, # Start time
        45, # Duration
    ),
]

var next_schedule_index := 0


func _ready() -> void:
    quest_schedule.sort_custom(
        func (a: Quest, b: Quest): return a.start_time < b.start_time)


func _physics_process(_delta: float) -> void:
    _check_for_next_quest()
    _check_for_expired_quests()


func _check_for_next_quest() -> void:
    if next_schedule_index >= quest_schedule.size():
        # There are no remaining quests.
        return

    var currentTime = Time.get_ticks_msec() / 1000.0
    var next_quest := quest_schedule[next_schedule_index]
    var next_quest_start_time := next_quest.start_time
    if currentTime >= next_quest_start_time:
        G.session.active_quests.push_back(next_quest)
        next_schedule_index += 1


func _check_for_expired_quests() -> void:
    var currentTime = Time.get_ticks_msec() / 1000.0
    var failed_quests := []
    for quest in G.session.active_quests:
        if currentTime >= quest.end_time:
            failed_quests.push_back(quest)
    for quest in failed_quests:
        G.session.active_quests.erase(quest)
        G.session.failed_quests.push_back(quest)
