# class_name G
extends Node

# TODO: Add global state here for easy access.

var main: Main
var settings: Settings
var hud: Hud
var zoo_keeper: PanelContainer
var game_panel: GamePanel
var utils := Utils.new()
var geometry := Geometry.new()
var player: Player
var enemies: Array[Enemy] = []
var session: Session
