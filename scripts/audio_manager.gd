extends Node

var sounds: Dictionary[String, AudioStream]
var _music_players:Array[AudioStreamPlayer] = []
var muted: bool

func initialize(_sounds:Dictionary[String, AudioStream], stream_player_sfx: AudioStreamPlayer):
	sounds = _sounds
	muted = false

func play_sfx(sound_name: String, volume_db: float = -15.0):
	if sounds.has(sound_name):
		var asp = AudioStreamPlayer.new()
		asp.stream = sounds[sound_name]
		asp.volume_db = volume_db
		asp.bus = "SFX"
		
		add_child(asp)
		_music_players.append(asp)
		asp.play()
		
		asp.finished.connect(asp.queue_free)
	else:
		push_error("Le son '" + sound_name + "' n'existe pas dans AudioManager")

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
	muted = true
	
func resume_all_sounds():
	for player in _music_players:
		player.play()
	muted = false
