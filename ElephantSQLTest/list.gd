extends Node2D

var database := PostgreSQLClient.new()


const USER = "fpfocwja"
const PASSWORD = "qJdztZ36Nw9EHdM-_QGOLfyBPcn0mJAI"
const HOST = "cornelius.db.elephantsql.com"
const PORT = 5432 # Default postgres port
const DATABASE = "fpfocwja" # Database name

enum sql_types {
	INSERT,
	SELECT,
	UPDATE,
	DELETE,	
}

var sql_type = -1
func _ready():
	sql_type = sql_types.SELECT
	connectDB()

func connectDB():
	var _error := database.connect("connection_established", self, "_execAll")
	_error = database.connect("authentication_error", self, "_authentication_error")
	_error = database.connect("connection_closed", self, "_close")	
	#Connection to the database
	_error = database.connect_to_host("postgresql://%s:%s@%s:%d/%s" % [USER, PASSWORD, HOST, PORT, DATABASE])


func _authentication_error(error_object: Dictionary) -> void:
	prints("Error connection to database:", error_object["message"])
	
func _close(clean_closure := true) -> void:
	prints("DB CLOSE,", "Clean closure:", clean_closure)
	
func _physics_process(_delta: float) -> void:
	database.poll()

func _exit_tree() -> void:
	database.close()

#Call database function
func _execAll():
	
	match sql_type:
		sql_types.SELECT:
			_execSelect()
	

#Insert, Select, Update & Delete : setup data & SQL

func _execSelect():
	var query="BEGIN; SELECT * FROM users ; COMMIT;"
	var data = selectFromDB(query)
	var return_data = ""
	
	for d in data:
		for n in d.size():
			return_data += str(d[n]) + "\t"
			print(d[n])
		return_data += "\n"
	$ShowData.text=return_data
	$ButtonSelect.text=" RREFRESH "
#Insert, Select, Update & Delete executes

func selectFromDB(sql:String) -> Array:
	
	var datas := database.execute(sql)
	var rows = datas[1].data_row
	
	database.close()
	
	return rows


func _on_ButtonSelect_pressed():
	$ButtonSelect.text=" LOADING... "
	sql_type = sql_types.SELECT
	connectDB()




func _on_return_pressed():
	get_tree().change_scene("res://choice_scene.tscn")
