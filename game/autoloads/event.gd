## Event Autoload (Event Bus)
extends Node

signal next_wave_trigered_signal( current_wave: int )
signal wave_ended_signal
signal ectoplasm_collected_signal(ectoplasm_value)
signal play_sfx_signal( sfx_track: Enums.SfxTrack )
signal reset_engine_speed_signal

func next_wave_trigered( current_wave: int )->void:
	next_wave_trigered_signal.emit(current_wave)
	
func wave_ended()->void:
	wave_ended_signal.emit()


func ectoplasm_collected( ectoplasm_value: int )->void:
	ectoplasm_collected_signal.emit(ectoplasm_value)


func play_sfx( sfx_track: Enums.SfxTrack )->void:
	play_sfx_signal.emit(sfx_track)


func reset_engine_speed()->void:
	reset_engine_speed_signal.emit()
