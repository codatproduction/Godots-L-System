extends Node2D


onready var line_container = $LineContainer
var lines = []

func _ready():
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var center = Vector2(get_viewport_rect().end.x / 2, get_viewport_rect().end.y / 2)
	var bottom_center = Vector2(get_viewport_rect().end.x / 2, get_viewport_rect().end.y)
	var bottom_right = Vector2(get_viewport_rect().end.x / 3 * 2, get_viewport_rect().end.y)
	
	lines = generate(bottom_center, 5, 0.6, Color(0.9, 0.6, 1.0, 0.7), 2.0, FractalTree.new())
	#lines = generate(center, 15, 0.8, Color(0.5, 1, 1, 1.0), 1, DragonCurve.new())
	#lines = generate(bottom_right, 6, 0.7, Color.red, 2.0, SierpinskiTriangle.new())
	#lines = generate(bottom_center, 7, 0.57, Color(0.2, 0.7, 1.0, 0.6), 1.0, FractalPlant.new())
	

	
func _process(delta):
	
	if lines.empty():
		return
	var lines_per_frame = 100000
	for index in lines_per_frame:
		line_container.add_child(lines.pop_front())	
		if lines.empty():
			break
			

func generate(start_position, iterations, length_reduction, color, width, rule):
	var length = -200
	var arrangement = rule.axiom
	for i in iterations:
		length *= length_reduction
		var new_arrangement = ""
		for character in arrangement:
			new_arrangement += rule.get_character(character)
		arrangement = new_arrangement

	
	var lines = []
	var from = start_position
	var rot = 0
	var cache_queue = []
	for index in arrangement:
		match rule.get_action(index):
			"draw_forward":
				var to = from + Vector2(0, length).rotated(deg2rad(rot))
				var line = Line2D.new()
				line.default_color = color
				line.width = width
				line.antialiased = true
				line.add_point(from)
				line.add_point(to)
				lines.push_back(line)
				from = to
			"rotate_right":
				rot += rule.angle
			"rotate_left":
				rot -= rule.angle
			"store":
				cache_queue.push_back([from, rot])
			"load":
				var cached_data = cache_queue.pop_back()
				from = cached_data[0]
				rot = cached_data[1]
	return lines


class Rule:
	var axiom
	var rules = {}
	var actions = {}
	var angle
	
	func get_character(character):
		if rules.has(character):
			return rules.get(character)
		return character
	
	func get_action(character):
		return actions.get(character)

class FractalTree extends Rule:
	
	func _init():
		self.axiom = "F"
		self.angle = 25
		self.rules = {
			"F" : "FF+[+F-F-F]-[-F+F+F]",
		}
		self.actions = {
			"F" : "draw_forward",
			"+" : "rotate_right",
			"-" : "rotate_left",
			"[" : "store",
			"]" : "load"
		}

class DragonCurve extends Rule:
	func _init():
		self.axiom = "FX"
		self.angle = 90
		self.rules = {
			"X" : "X+YF+",
			"Y" : "-FX-Y"
		}
		
		
		
		
		self.actions = {
			"F" : "draw_forward",
			"+" : "rotate_right",
			"-" : "rotate_left"
		}
		
		
		
		actions = {
			"A" : "draw_line",
			"B" : "rotate_random"
		}
	
	
	
	
	
class SierpinskiTriangle extends Rule:
	func _init():
		self.axiom = "F-G-G"
		self.angle = 120
		self.rules = {
			"F" : "F-G+F+G-F",
			"G" : "GG"
		}
		self.actions = {
			"F" : "draw_forward",
			"G" : "draw_forward",
			"+" : "rotate_right",
			"-" : "rotate_left"
		}
		
		
class FractalPlant extends Rule:
	func _init():
		self.axiom = "X"
		self.angle = 25
		self.rules = {
			"X" : "F+[[X]-X]-F[-FX]+X",
			"F" : "FF"
		}
		self.actions = {
			"F" : "draw_forward",
			"+" : "rotate_right",
			"-" : "rotate_left",
			"[" : "store",
			"]" : "load"
		}

	
	
	
		
	
