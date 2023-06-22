extends Node

signal resources_loaded

#export var i = 0
@export_file("*.json") var JSON_entities
@export_file("*.json") var JSON_resources
@export_file("*.json") var JSON_recipes
@export_file("*.json") var JSON_buildings

var entities     = {}
var resources    = {}
var recipes      = {}
var buildings    = {}
#var cards  = {}


func _ready():
	entities     = loadDB(JSON_entities)
	resources    = loadDB(JSON_resources)
	recipes      = loadDB(JSON_recipes)
	buildings    = loadDB(JSON_buildings)
#	prints(entities, resources)
	call_deferred("emit_signal", "resources_loaded")
	pass

func loadDB(path):
	var uploadedData = {}
	var data_file = FileAccess.open(path, FileAccess.READ)
	
	if data_file.get_open_error() != OK:
		prints("Error open file", path)
		return
		
	var data_text = data_file.get_as_text()
	data_file.close()
	var data_parse = JSON.new()
	var data = data_parse.parse_string(data_text)
#	data_parse.parse_string(data_text)
	
	if data_parse.get_error_line() != 0:
		prints("Error parse at line", data_parse.get_error_line())
		return
		
	uploadedData = data
	
	return uploadedData
	pass


#func loadTSV(path):
#	var uploadedData = {}
#	var data_file = File.new()
#
#	if data_file.open(path, File.READ) != OK:
#		prints("Error open file", path)
#		return
#
#	var data_arr = []
#
#	var line = data_file.get_line()
#	while (line.length() > 0):
#		data_arr.append(line)
#		line = data_file.get_line()
#	return data_arr
#	pass

# Поиск объекта
func get_obj_by_property_value_from_arr(property_name, value, arr):
	for obj in arr:
		if obj.has(property_name):
			if obj[property_name] == value:
				return Global.deep_copy(obj)
	print("I can't found value {val} or property {prop}".format({"val" : value, "prop" : property_name}))
	pass

func get_arr_by_property_value_from_arr(property_name, value, arr) -> Array:
	var final_arr = []
	for obj in arr:
		if obj.has(property_name):
			if obj[property_name] == value:
				final_arr.append(Global.deep_copy(obj))
	if final_arr.size() != 0:
		return final_arr
	else:
		print("I can't found value {val} or property {prop}".format({"val" : value, "prop" : property_name}))
		return []
	pass
