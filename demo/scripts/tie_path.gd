extends Path2D

func _draw():
	var points = curve.get_baked_points()
	if points:
		draw_polyline(points, Color.WHITE, 5, true)
