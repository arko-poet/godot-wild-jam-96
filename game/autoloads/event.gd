## Event Autoload (Event Bus)
extends Node

signal next_wave_trigered_signal( current_wave: int )
signal wave_ended_signal

func next_wave_trigered( current_wave: int )->void:
	next_wave_trigered_signal.emit(current_wave)
	
func wave_ended()->void:
	wave_ended_signal.emit()
