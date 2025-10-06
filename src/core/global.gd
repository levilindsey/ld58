# class_name G
extends Node

# TODO: Add global state here for easy access.

var main: Main
var settings: Settings
var hud: Hud
var main_menu_screen: PanelContainer
var game_over_screen: PanelContainer
var win_screen: PanelContainer
var zoo_keeper_screen: PanelContainer
var game_panel: GamePanel
var utils := Utils.new()
var geometry := Geometry.new()
var player: Player
var enemies: Array[Enemy] = []
var session: Session
