class_name MobSfxPlayer extends AudioStreamPlayer

enum SfxTrack {  DEATH  }

@export var sfx_track: Dictionary [ SfxTrack, AudioStream ]


func play_sfx(track: SfxTrack) -> void:
	if not sfx_track.has(track):
		push_warning("No SFX assigned for track: %s" % SfxTrack.keys()[track])
		return

	stream = sfx_track[track]
	play()
