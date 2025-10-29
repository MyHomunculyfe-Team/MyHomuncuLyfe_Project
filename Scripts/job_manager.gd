extends Node
@onready var score_label: Label = $ScoreLabel
@onready var timer: Timer = $Timer

var score = 0
var time_left = 30
##when timer reaches 0 it should return you back to the menu and increment the homunc's hunger based on how well you did
#done in 1 second = +40% hunger
#done in 2-3 seconds = +30% hunger
#done in 4-5 seconds = +15% hunger
#not done = +5% hunger

func _ready() -> void:
	timer.start()

func _process(delta: float) -> void:
	score_label.text = "Score: " + str(score) + "Time: " + str(time_left)

func add_score():
	score +=1


func _on_timer_timeout() -> void:
		time_left -=1
		if time_left > 0:
			timer.start()
		else:
			pass #end game here
