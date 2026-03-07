extends Control

@onready var credit_panel = $CreditPanel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_rich_text_label_meta_clicked(meta):
	OS.shell_open(str(meta))

func _on_show_credits_toggled(toggled_on: bool) -> void:
	if toggled_on:
		credit_panel.show()
	else:
		credit_panel.hide()
