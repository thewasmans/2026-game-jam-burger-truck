extends Node

var sounds: Dictionary[String, AudioStream]
var _music_players:Array[AudioStreamPlayer] = []
var _active_sfx: Dictionary[String, AudioStreamPlayer] = {}
var muted: bool

func initialize(_sounds:Dictionary[String, AudioStream], _stream_player_sfx: AudioStreamPlayer):
	sounds = _sounds
	muted = false

func play_sfx(sound_name: String, volume_db: float = -15.0):
	if sounds.has(sound_name) and not muted:
		var asp = AudioStreamPlayer.new()
		asp.stream = sounds[sound_name]
		asp.volume_db = volume_db
		asp.bus = "SFX"
		
		add_child(asp)
		asp.play()
		
		_active_sfx[sound_name] = asp
		
		asp.finished.connect(func():
			if _active_sfx.has(sound_name):
				_active_sfx.erase(sound_name)
			asp.queue_free()
		)
	else:
		push_error("Le son '" + sound_name + "' n'existe pas dans AudioManager")

func play_sfx_random(sound_names: Array[String], volume_db: float = -15.0):
	if sound_names.is_empty():
		return
	play_sfx(sound_names.pick_random(), volume_db)

func stop_sfx(sound_name: String):
	if _active_sfx.has(sound_name):
		_active_sfx[sound_name].stop()
		_active_sfx[sound_name].queue_free()
		_active_sfx.erase(sound_name)

func play_music(music_path: String, volume_db: float = -10.0):
	var music_player := AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	_music_players.append(music_player)
	
	music_player.stream = sounds[music_path]
	music_player.volume_db = volume_db
	music_player.play()

func mute_all_sounds():
	for player in _music_players:
		player.stop()
	for key in _active_sfx:
		_active_sfx[key].stop()
	muted = true
	
func resume_all_sounds():
	for player in _music_players:
		player.play()
	for key in _active_sfx:
		_active_sfx[key].play()
	muted = false
