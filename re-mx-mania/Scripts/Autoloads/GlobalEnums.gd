extends Node

####################################################
# FX Track is ID 0 because it will ALWAYS be there
# Regardless of TRACK_COUNT
####################################################
enum trackIDs {
	TRACKFX,
	TRACK1,
	TRACK2,
	TRACK3,
	TRACK4,
}

enum judgementEnum {
	OKLATE,
	GOODLATE,
	PERFECTLATE,
	PERFECT,
	PERFECTEARLY,
	GOODEARLY,
	OKEARLY,
	MISS
}

enum effectEnum {
	CHORUS,
	HIPASS,
	LOWPASS,
	PHASER,
	REVERB
}
