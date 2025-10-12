class_name Hud
extends PanelContainer


const DETECTION_MEDIUM_THRESHOLD := 0.25
const DETECTION_HIGH_THRESHOLD := 0.5

const HEALTH_MEDIUM_THRESHOLD := 0.67
const HEALTH_LOW_THRESHOLD := 0.33

@export var normal_color := Color(1.0, 1.0, 1.0, 1.0)
@export var ship_full_color := Color(0.976, 0.529, 0.439, 1.0)

@export var high_health_color := Color(0.553, 0.788, 0.318, 1.0)
@export var medium_health_color := Color(1.0, 0.992, 0.639, 1.0)
@export var low_health_color := Color(0.976, 0.529, 0.439, 1.0)

@export var low_detection_color := Color(0.553, 0.788, 0.318, 1.0)
@export var medium_detection_color := Color(1.0, 0.992, 0.639, 1.0)
@export var high_detection_color := Color(0.976, 0.529, 0.439, 1.0)

var health_bar_stylebox: StyleBoxFlat = StyleBoxFlat.new()
var detection_bar_stylebox: StyleBoxFlat = StyleBoxFlat.new()

var jet_count_down_start_time := 0.0


func _ready() -> void:
    G.hud = self

    # Wait for G.settings to be assigned.
    await get_tree().process_frame

    self.visible = G.settings.show_hud

    %HealthBar.add_theme_stylebox_override("fill", health_bar_stylebox)
    %DetectionBar.add_theme_stylebox_override("fill", detection_bar_stylebox)


func _physics_process(_delta: float) -> void:
    if jet_count_down_start_time > 0:
        var current_time := Time.get_ticks_msec() / 1000.0
        if current_time > jet_count_down_start_time + G.settings.jet_delay:
            end_count_down()
            G.game_panel.spawn_jet()
        else:
            %JetCountDown.text = "%d" % [G.settings.jet_delay - int(current_time - jet_count_down_start_time)]


func update_visibility() -> void:
    match G.main.current_screen:
        Main.ScreenType.MAIN_MENU, \
        Main.ScreenType.GAME_OVER, \
        Main.ScreenType.WIN:
            %LeftContent.visible = false
            %ShipCapacityWrapper.visible = false
            %QuestEnemyList.visible = false
        Main.ScreenType.ZOO_KEEPER:
            %LeftContent.visible = false
            %ShipCapacityWrapper.visible = false
            %QuestEnemyList.visible = true
        Main.ScreenType.GAME:
            %LeftContent.visible = true
            %ShipCapacityWrapper.visible = true
            %QuestEnemyList.visible = true
        _:
            G.utils.ensure(false)


func update_health() -> void:
    var health_progress := float(G.session.health) / G.session.max_health
    %HealthBar.value = health_progress
    var color := (
        low_health_color if
        health_progress < HEALTH_LOW_THRESHOLD else
        medium_health_color if
        health_progress < HEALTH_MEDIUM_THRESHOLD else
        high_health_color
    )
    health_bar_stylebox.bg_color = color


func update_detection() -> void:
    var detection_progress := G.session.detection_score
    %DetectionBar.value = detection_progress
    var color := (
        high_detection_color if
        detection_progress > DETECTION_HIGH_THRESHOLD else
        medium_detection_color if
        detection_progress > DETECTION_MEDIUM_THRESHOLD else
        low_detection_color
    )
    detection_bar_stylebox.bg_color = color


func update_quest() -> void:
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

    %ReturnMessage.visible = G.session.is_ship_full()


func start_count_down() -> void:
    jet_count_down_start_time = Time.get_ticks_msec() / 1000.0
    %JetCountDown.visible = true
    %JetCountDown.text = "%d" % int(G.settings.jet_delay)


func end_count_down() -> void:
    jet_count_down_start_time = 0
    %JetCountDown.visible = false
