extends Control

@onready var credit_panel = $CreditPanel
@onready var show_options: Button = $"../Options/ShowOptions"
@onready var option_panel: Panel = $"../Options/OptionPanel"
@onready var show_credits: Button = $ShowCredits
@onready var crd: RichTextLabel = $CreditPanel/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_show_credits_toggled(toggled_on: bool) -> void:
	if toggled_on:
		credit_panel.show()
		if option_panel:
			option_panel.hide()
			show_options.button_pressed = false
	else:
		credit_panel.hide()
