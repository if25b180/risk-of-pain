extends Node

@onready var background_music: AudioStreamPlayer = $BackgroundMusic
@onready var boss_music: AudioStreamPlayer = $BossMusic

func play_background():
	if boss_music.playing:
		boss_music.stop()

	if !background_music.playing:
		background_music.play()

func play_boss():
	if background_music.playing:
		background_music.stop()

	if !boss_music.playing:
		boss_music.play()
