extends Node2D

func flip():
	var first_out = $TiePath.curve.get_point_out(0)
	$TiePath.curve.set_point_out(0, Vector2(first_out.x, -first_out.y))
	$TiePath.position.y *= -1
	$TiePath.queue_redraw()
