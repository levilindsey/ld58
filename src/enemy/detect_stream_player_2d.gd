extends AudioStreamPlayer2D


func _on_finished() -> void:
    pass
    #if not $"../RunningStreamPlayer2D".playing:
        #$"../RunningStreamPlayer2D".play()
