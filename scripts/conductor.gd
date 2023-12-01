extends AudioStreamPlayer2D

@export var bpm = 100.0
@export var measures = 4

# beat and song position
var song_position = 0.0
var song_position_in_beats = 1
var sec_per_beat = 60.0 / bpm
var last_reported_beat = 0
var beats_before_start = 0
var cur_measure = 1

# determine how close to the beat an event is
var closest = 0
var time_off_beat = 0.0
signal beat(position)
signal measure(position)


func _ready():
	sec_per_beat = 60.0 / bpm


func _process(_delta):
	if playing:
		song_position = get_playback_position() + AudioServer.get_time_since_last_mix()
		song_position -= AudioServer.get_output_latency()
		song_position_in_beats = int(floor(song_position / sec_per_beat)) + beats_before_start
		_report_beat()
		print("Current measure: " + str(cur_measure) + ", Current beat: " + str(last_reported_beat))


func _report_beat():
	if last_reported_beat < song_position_in_beats:
		if cur_measure > measures:
			cur_measure = 1
		emit_signal("beat", song_position_in_beats)
		emit_signal("measure", cur_measure)
		last_reported_beat = song_position_in_beats
		cur_measure += 1


func play_with_beat_offset(num_beats):
	beats_before_start = num_beats
	$StartTimer.wait_time = sec_per_beat
	$StartTimer.start()


func closest_beat(nth):
	closest = int(round((song_position / sec_per_beat) / nth) * nth)
	time_off_beat = abs(closest * sec_per_beat - song_position)
	return Vector2(closest, time_off_beat)


func play_from_beat(desired_beat, offset):
	play()
	seek(desired_beat * sec_per_beat)
	beats_before_start = offset
	cur_measure = desired_beat % measures


func _on_start_timer_timeout():
	song_position_in_beats += 1
	if song_position_in_beats < beats_before_start:
		$StartTimer.start()
	elif song_position_in_beats == beats_before_start - 1:
		$StartTimer.wait_time = $StartTimer.wait_time - (AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency())
		$StartTimer.start()
	else:
		play()
		$StartTimer.stop()
	_report_beat()
