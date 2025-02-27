extends Node2D

# History of pitch values over time.
var pitch_history = []
# Maximum number of samples to display in the chart.
var max_history = 100

# Screen and chart configuration.
var ball_x = 50       # Fixed x position for the ball.
var chart_start = Vector2(100, 300)  # Starting point (bottom left) of the chart.
var chart_width = 3000
var chart_height = 1000

# Define the expected pitch range (adjust these values to your needs).
var min_pitch = 50
var max_pitch = 1000

var pitch: float

@onready var pitch_detector: PitchDetector = $PitchDetector

func _process(delta):
	# Update the pitch history.
	pitch_history.append(pitch)
	if pitch_history.size() > max_history:
		pitch_history.pop_front()
	
	queue_redraw()
	
func _draw():
	# Map the current pitch to a vertical position for the ball.
	# Higher pitch moves the ball higher on the screen.
	var current_pitch = pitch_history[pitch_history.size()-1] if pitch_history.size() > 0 else min_pitch
	var ball_y = lerp(400, 0, clamp((current_pitch - min_pitch) / float(max_pitch - min_pitch), 0, 1))
	var ball_pos = Vector2(ball_x, ball_y)
	
	# Draw the ball.
	draw_circle(ball_pos, 10, Color.RED)
	
	# Prepare points for the line chart.
	var points = []
	for i in range(pitch_history.size()):
		var p = pitch_history[i]
		# Calculate x position across the chart.
		var x = chart_start.x + (chart_width * i / float(max_history))
		# Map the pitch to the chart's vertical space.
		var y = chart_start.y - ( (p - min_pitch) / float(max_pitch - min_pitch) ) * chart_height
		points.append(Vector2(x, y))
	
	# Draw the line chart if we have enough points.
	if points.size() > 1:
		draw_polyline(points, Color.GREEN, 2)
	
	# Optional: Draw chart boundaries.
	draw_rect(Rect2(chart_start.x, chart_start.y - chart_height, chart_width, chart_height), Color(1,1,1,0.2), false, 1)

func _on_pitch_detector__pitch_updated(new_pitch: float) -> void:
	pitch = new_pitch
