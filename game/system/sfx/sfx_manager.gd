class_name SfxManager extends Node



@export var SfxTracks: Dictionary[ Enums.SfxTrack, AudioStream ]
## Keeps track of all currently playing SFX players.
var _active_sfx_players: Array[AudioStreamPlayer] = []


func _ready() -> void:
	Event.play_sfx_signal.connect(_on_play_sfx_signal)


func _on_play_sfx_signal(track: Enums.SfxTrack) -> void:

	var sfx_player := AudioStreamPlayer.new()
	
	if track == Enums.SfxTrack.TOWER_SHOOT or track == Enums.SfxTrack.GHOST_DEATH:
		sfx_player.volume_db -= 6.0
	
	sfx_player.set_bus("SFX")
	sfx_player.stream = SfxTracks[track]
	sfx_player.finished.connect(_on_sfx_finished.bind(sfx_player))

	_active_sfx_players.append(sfx_player)
	add_child(sfx_player)

	sfx_player.play()


func _on_sfx_finished(sfx_player: AudioStreamPlayer) -> void:

	_active_sfx_players.erase(sfx_player)
	sfx_player.queue_free()
