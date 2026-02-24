extends Node

var bpm: float
var songSPB: float # The seconds per beat of the song
var songMSPB: float # The milliseconds per beat of the song
var songPosInBeats: float

signal rhythmUpdate(timeStampInBeats: float, secondsPerBeat: float)

func _onChartCreation(chart):
	bpm = chart.bpm
	songSPB = 60 / bpm
	songMSPB = 60 / bpm * 1000

func _onSongUpdate(timeStamp):
	songPosInBeats = timeStamp / songSPB
	rhythmUpdate.emit(songPosInBeats, songSPB)
