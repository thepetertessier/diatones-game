extends Node2D

@onready var outer_parts: CPUParticles2D = $OuterParts

func set_particle_amount(percentage: float):
	#print("%:", percentage)
	const max := 50.0
	const min := 10.0
	outer_parts.emission_sphere_radius = lerp(min, max, percentage)
