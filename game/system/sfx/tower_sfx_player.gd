class_name TowerSfxPlayer extends AudioStreamPlayer


enum SfxTrack { CHARGE, SHOOT, SUPERCHARGE }

@export var sfx_track: Dictionary [ SfxTrack, AudioStream ]
var _curent_track: SfxTrack

func play_sfx(track: SfxTrack) -> void:
	if not sfx_track.has(track):
		push_warning("No SFX assigned for track: %s" % SfxTrack.keys()[track])
		return

	stream = sfx_track[track]
	play()
