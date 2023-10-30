extends Node2D

var database := PostgreSQLClient.new()
onready var show_data = $ShowData


const USER = "fpfocwja"
const PASSWORD = "qJdztZ36Nw9EHdM-_QGOLfyBPcn0mJAI"
const HOST = "snuffleupagus.db.elephantsql.com"
const PORT = 5432 # Default postgres port
const DATABASE = "fpfocwja" # Database name

enum sql_types {
	INSERT,
	SELECT,
	UPDATE,
	DELETE,	
}

var sql_type = -1


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
		sql_types.INSERT:
			_execInsert()
		sql_types.SELECT:
			_execSelect()
		sql_types.UPDATE:
			_execUpdate()
		sql_types.DELETE:
			_execDelete()
			

#Insert, Select, Update & Delete : setup data & SQL
func _execInsert():
	var data = [[str($Username.get_text()), $Password.get_text()], $Mail.get_text()]
	insertToDB("BEGIN; INSERT INTO users (Username, Email, Password) VALUES ('%s',%s,%s); COMMIT;", data)
	_on_ButtonSelect_pressed()

func _execSelect():
	
	var data = selectFromDB("BEGIN; SELECT * FROM users; COMMIT;")
	var return_data = ""
	
	for d in data:
		for n in d.size():
			return_data += str(d[n]) + "\t"
			print(d[n])
		return_data += "\n"
		
	show_data.set_text(return_data)

func _execUpdate():
	var data = [[str($Username.get_text()), $Password.get_text(), $Mail.get_text(),$ID.get_text()]]
	updateToDB("BEGIN; UPDATE users SET Username = '%s', Password = %s, Email = %s WHERE id = %s; COMMIT;", data)
	_on_ButtonSelect_pressed()
	
func _execDelete():
	var data = [[$ID.get_text()]]
	deleteFromDB("BEGIN; DELETE FROM users WHERE id = %s; COMMIT;", data)
	_on_ButtonSelect_pressed()


#Insert, Select, Update & Delete executes
func insertToDB(sql: String, data: Array):
	var _sql
	
	for d in data:
		_sql = sql % d
		database.execute(_sql)
		print(_sql)

	database.close()

func selectFromDB(sql:String) -> Array:
	
	var datas := database.execute(sql)
	var rows = datas[1].data_row
	
	database.close()
	
	return rows

func updateToDB(sql: String, data: Array):
	var _sql
	
	for d in data:
		_sql = sql % d
		database.execute(_sql)
		print(_sql)

	database.close()

func deleteFromDB(sql: String, data: Array):
	#var datas
	var _sql
	
	for d in data:
		_sql = sql % d
		database.execute(_sql)
		print(_sql)

	database.close()


#Button event handlers
func _on_ButtonInsert_pressed():
	sql_type = sql_types.INSERT
	connectDB()

func _on_ButtonSelect_pressed():
	sql_type = sql_types.SELECT
	connectDB()

func _on_ButtonUpdate_pressed():
	sql_type = sql_types.UPDATE
	connectDB()

func _on_ButtonDelete_pressed():
	sql_type = sql_types.DELETE
	connectDB()
