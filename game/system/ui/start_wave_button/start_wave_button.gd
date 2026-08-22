class_name StartWaveButton
extends Control

signal pressed

@onready var button : Button = $VBoxContainer/Button
@onready var wave_label :Label = %WaveLabel
@onready var reward_label: Label = %ValueLabel
@onready var reward_container : HBoxContainer = %RewardContainer

func set_wave_text(wave_text:String):
	wave_label.text = wave_text

func set_reward(reward:int):
	if (reward >0):
		reward_label.text = "%d" % reward
		reward_container.visible = true
	else:
		reward_container.visible = false

func toggle_enable(is_enabled: bool):
	button.disabled = not is_enabled

func _on_button_pressed() -> void:
	pressed.emit()
	pass # Replace with function body.
