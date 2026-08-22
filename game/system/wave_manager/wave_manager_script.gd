class_name WaveManager extends Node

signal wave_limit_exceeded
signal generate_wave_rewards(ectoplasm:int)

@export var rewards_manager : RewardsManager

@onready var _wave_label: Label = %WaveLabel
var _current_wave: int = 0:
	set(value):
		_current_wave = value
		start_wave_button.set_wave_text( "%s/%s" % [_current_wave, level.get_number_of_waves()])
		
var _active_wave: bool = false

@onready var start_wave_button: StartWaveButton = $"../UILayer/UI/StartWaveButton"
@onready var level: Level = %Level

var current_time_estimate : float = 0.0
var time_passed : float = 0.0

func _ready() -> void:
	_current_wave = _current_wave
	start_wave_button.pressed.connect(_on_start_wave_button)
	Event.wave_ended_signal.connect(_on_wave_ended_signal)
	if rewards_manager == null:
		push_error("No Rewards Manager set for WaveManager. Make sure to set it from the Inspector")

func _process(delta) -> void:
	time_passed += delta
	update_button_visuals()


func update_button_visuals():
	var reward = rewards_manager.calculate_reward(current_time_estimate, current_time_estimate-time_passed,_current_wave)
	start_wave_button.set_reward(reward)
	
func _on_start_wave_button()->void:
	if _active_wave == false:
		_active_wave = true
		start_wave_button.toggle_enable(false)
		generate_wave_rewards.emit(rewards_manager.reward)
		time_passed = 0.0
		_next_wave()

func _on_wave_ended_signal()->void:
	_active_wave = false
	start_wave_button.toggle_enable(true)


func _next_wave()->void:
	_current_wave += 1
	
	if _current_wave > level.get_number_of_waves():
		wave_limit_exceeded.emit()
		return
	Event.next_wave_trigered(_current_wave)
	Event.play_sfx( Enums.SfxTrack.START_WAVE )
	
	# We don't need to wait to get the time_estimate.
	current_time_estimate = level.get_wave_time_estimate(_current_wave)

func trigger_next_wave()->void:
	_next_wave()
