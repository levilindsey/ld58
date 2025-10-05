class_name QuestList
extends PanelContainer


var listed_quests: Array[Quest] = []


func _process(_delta: float) -> void:

    G.session.active_quests
