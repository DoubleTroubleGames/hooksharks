extends Control

const WAVE_LENGTH = 0.8
const SPEED = 5

func _ready():
	set_process(true)
	set_process_input(false)


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		Transition.transition_to("MainMenu")


func _on_transition_in() -> void:
	set_process_input(false)
	$ArenaButton.disabled = true
	$RacingButton.disabled = true
	$OptionsButton.disabled = true
	$RacingButton.disabled = true


func _on_transition_out() -> void:
	PauseManager.set_pause(false)
	set_process_input(true)
	$ArenaButton.disabled = false
	$RacingButton.disabled = false
	$OptionsButton.disabled = false
	$CreditsButton.disabled = false
	$ArenaButton.grab_focus()


func _on_ArenaButton_pressed():
	RoundManager.gamemode = "Arena"
	$Sounds/ConfirmSFX.play()
	Transition.transition_to("CharacterSelect")


func _on_RacingButton_pressed():
	RoundManager.gamemode = "Race"
	$Sounds/ConfirmSFX.play()
	Transition.transition_to("CharacterSelect")

func _on_OptionsButton_pressed():
	$Sounds/ConfirmSFX.play()
	Transition.transition_to("OptionsMenu")


func _on_CreditsButton_pressed():
	$Sounds/ConfirmSFX.play()
	Transition.transition_to("Credits")

func _on_ArenaButton_focus_entered():
	fadeWaveIn($ArenaButton)
	
	fadeWaveOut($RacingButton)
	fadeWaveOut($CreditsButton)
	fadeWaveOut($OptionsButton)
	
	$Tween.start()
	$Sounds/SelectSFX.play()

func _on_RacingButton_focus_entered():
	fadeWaveIn($RacingButton)
	
	fadeWaveOut($ArenaButton)
	fadeWaveOut($CreditsButton)
	fadeWaveOut($OptionsButton)
	
	$Tween.start()
	$Sounds/SelectSFX.play()

func _on_OptionsButton_focus_entered():
	fadeWaveIn($OptionsButton)
	
	fadeWaveOut($ArenaButton)
	fadeWaveOut($RacingButton)
	fadeWaveOut($CreditsButton)
	
	$Tween.start()
	$Sounds/SelectSFX.play()


func _on_CreditsButton_focus_entered():
	fadeWaveIn($CreditsButton)
	
	fadeWaveOut($ArenaButton)
	fadeWaveOut($RacingButton)
	fadeWaveOut($OptionsButton)
	
	$Tween.start()
	$Sounds/SelectSFX.play()
	
func fadeWaveIn(button):
	var cur = button.get_material().get_shader_param("wave_length")
	if cur < WAVE_LENGTH:
		$Tween.interpolate_property(button.get_material(),
				"shader_param/wave_length",
				cur, WAVE_LENGTH, (WAVE_LENGTH-cur)/SPEED,
				Tween.TRANS_LINEAR, Tween.EASE_OUT)
func fadeWaveOut(button):
	var cur = button.get_material().get_shader_param("wave_length")
	if cur > 0:
		$Tween.interpolate_property(button.get_material(), 
			"shader_param/wave_length",
			cur, 0, cur/SPEED,
			Tween.TRANS_LINEAR, Tween.EASE_OUT)
