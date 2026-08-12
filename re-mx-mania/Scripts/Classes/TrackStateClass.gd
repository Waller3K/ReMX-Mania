class_name TrackState
extends Resource

var nextNoteIndex := 0
var ended := false
var isActive := false
var inputState := false
var lastNoteHit := false
var noteHeadMissed := false
var tickTimer := Timer.new()
