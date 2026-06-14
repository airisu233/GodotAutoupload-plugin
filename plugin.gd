@tool
extends EditorPlugin

const BACKUP_BAT := "res://addons/GithubAutoUPload/github.bat"
const BACKUP_COOLDOWN := 60.0
var is_exiting := false
var last_backup_time := 0

func _enter_tree() -> void:
	resource_saved.connect(_on_resource_saved)
	print("GithubAutoUpload plugin loaded")

func _exit_tree() -> void:
	is_exiting = true
	resource_saved.disconnect(_on_resource_saved)
	print("Plugin unloaded")
		# 退出前强制备份一次
	_run_backup()
	print("Plugin unloaded")

func _on_resource_saved(resource: Resource) -> void:
	var path := resource.resource_path
	print("Resource saved: ", path)
	
	var current_time := Time.get_ticks_msec() / 1000
	var time_diff := current_time - last_backup_time
	
	print("Time since last backup: ", time_diff, "s")
	
	if not is_exiting and time_diff < BACKUP_COOLDOWN:
		print("Backup skipped, cooldown: ", BACKUP_COOLDOWN - time_diff, "s remaining")
		return
	
	last_backup_time = current_time
	
	print("Starting backup for: ", path)
	_run_backup()

func _run_backup() -> void:
	var bat_path := ProjectSettings.globalize_path(BACKUP_BAT)
	print("Executing: ", bat_path)
	
	# 用 create_process 真正异步，不阻塞
	var pid := OS.create_process("cmd", ["/c", bat_path])
	
	if pid == -1:
		print("Failed to start backup process")
	else:
		print("Backup process started, PID: ", pid)
