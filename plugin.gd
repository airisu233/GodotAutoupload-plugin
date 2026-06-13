@tool
extends EditorPlugin

const BACKUP_BAT := "res://addons/GithubAutoUPload/github.bat"
const BACKUP_COOLDOWN := 30.0

var last_backup_time := 0

func _enter_tree() -> void:
	resource_saved.connect(_on_resource_saved)

func _exit_tree() -> void:
	resource_saved.disconnect(_on_resource_saved)
	# 同步执行，阻塞等待完成
	var output: Array = []
	OS.execute("cmd", ["/c", ProjectSettings.globalize_path(BACKUP_BAT)], output, true)
	print("Final backup done")

func _on_resource_saved(resource: Resource) -> void:
	var current_time := Time.get_ticks_msec() / 1000
	if current_time - last_backup_time < BACKUP_COOLDOWN:
		return
	
	last_backup_time = current_time
	print("Auto backup: ", resource.resource_path)
	
	# 异步执行，不阻塞编辑器
	var pid := OS.create_process("cmd", ["/c", ProjectSettings.globalize_path(BACKUP_BAT)])
	if pid == -1:
		print("Failed to start backup")
	else:
		print("Backup started, PID: ", pid)
