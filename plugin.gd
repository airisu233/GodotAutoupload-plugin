@tool
extends EditorPlugin

const BACKUP_BAT := "res://addons/GithubAutoUPload/github.bat"
const BACKUP_COOLDOWN := 30.0

var last_backup_time := 0

func _enter_tree() -> void:
	resource_saved.connect(_on_resource_saved)

func _exit_tree() -> void:
	resource_saved.disconnect(_on_resource_saved)

func _on_resource_saved(resource: Resource) -> void:
	var path := resource.resource_path
	
	if not (path.ends_with(".tscn") or path.ends_with(".gd") or path.ends_with(".tres")):
		return
	
	var current_time := Time.get_ticks_msec() / 1000
	if current_time - last_backup_time < BACKUP_COOLDOWN:
		return
	
	last_backup_time = current_time
	_run_backup()

func _run_backup() -> void:
	var bat_path := ProjectSettings.globalize_path(BACKUP_BAT)
	var pid := OS.create_process("cmd", ["/c", bat_path])
	
	if pid == -1:
		print("Backup failed")
	else:
		print("Backup started, PID: ", pid)
