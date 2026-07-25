extends Node

####################################################
# FX Track is ID 0 and Scratch Track is ID 1
# because they will ALWAYS be there
# Regardless of TRACK_COUNT
####################################################
enum trackIDs {
	TRACKFX,
	SCRATCH_TRACK,
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

enum scratchEnum {
	COMBINATION,
	UP,
	DOWN
}

enum effectEnum {
	CHORUS,
	HIPASS,
	LOWPASS,
	PHASER,
	REVERB
}
