extends Node
@onready var score_label: Label = $ScoreLabel

var tries = 3
#when tries is equal to 0, it should go back to the menu and increment your homunc's stats depending on how well you did
#all 3 landed = +40% cleanliness.
#2 landed = +30% cleanliness
#1 landed = +15% cleanliness
#0 landed = +5% cleanliness
var score = 0

func add_score():
	score +=1
	score_label.text = "Tries: " + str(tries) + "\nScore: " + str(score)

func lose_life():
	tries -=1
	score_label.text = "Tries: " + str(tries) + "\nScore: " + str(score)
	
	if tries == 0:
		GameManager.add_hygine(20)
		GameManager.report_minigame_finished()
