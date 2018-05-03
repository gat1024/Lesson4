extends "res://Actor.gd"

var commands = []


func _ready():
	pass
	
func script():
		
	pass
























func go(where):
#	commands .push_back(where)
	execute_go(where)
	
func think():
	if (isMoving == true):
		return
	
	script()
#	if commands.empty() == false:
#		var action = commands.front()
#		commands .pop_front()
#		execute_go(action)
#		
func execute_go(where):
	var horz = 0;
	var vert = 0;
	
	if where == "up":
		vert = -1
	elif where == "down":
		vert = 1
	elif where == "left":
		horz = -1
	elif where == "right":
		horz = 1

	if horz != 0:
		vert = 0;
	
	if horz != 0 || vert != 0:
		move(horz, vert)


func actorType():
	return "Player"

func get_player_position():
	return self.actorPos
	
func get_exit_position():
	return Game.exitplace

func think2():
	var horz = 0;
	var vert = 0;
	
	if Input.is_action_pressed("ui_down"):
		vert = 1
	elif Input.is_action_pressed("ui_up"):
		vert = -1
	elif Input.is_action_pressed("ui_left"):
		horz = -1
	elif Input.is_action_pressed("ui_right"):
		horz = 1

	if horz != 0:
		vert = 0;
	
	if horz != 0 || vert != 0:
		move(horz, vert)

func onHit(type, xpos, ypos):
	if type == FOOD:
		Game.increasePlayerFood(10)
		Game.removeFoodAt(xpos, ypos)
		return true
		
	if type == SODA:
		Game.increasePlayerFood(20)
		Game.removeSodaAt(xpos, ypos)
		return true
	
#	if type == WALL:
#		var anim = get_node("Sprite/Animations")
#		anim .connect("animation_changed", self, "afterAttack", [type, xpos, ypos], CONNECT_ONESHOT)
#		anim .play("Attack")
#		Game.finishTurn(self)
#		return false
		
	if type == ACTOR:
		var anim = get_node("Sprite/Animations")
		anim .connect("animation_changed", self, "afterAttack", [type, xpos, ypos], CONNECT_ONESHOT)
		anim .play("Attack")
		Game.finishTurn(self)
		return false

	if type == EXIT:
		if Game.getLevel() < 7:
			get_tree().change_scene("res://map.tscn")
		else:
			get_tree().change_scene("res://success.tscn")
		return true

	return false

func afterAttack(oldname, newname, type, xpos, ypos):
	if type == WALL:
		Game.removeWallAt(xpos, ypos)
	
	if type == ACTOR:
		Game.getActorAt(xpos, ypos).defeat()
		Game.removeActorAt(xpos, ypos)


#	var pl = get_player_position()
#	var ex = get_exit_position()
#	
#	var deltax = abs(pl.x - ex.x)
#	var deltay = abs(pl.y - ex.y)
#	
#	if deltay > deltax:
#		if pl.y > ex.y:
#			go("up")
#		
#		if pl.y < ex.y:
#			go("down")
#	else:
#		if pl.x < ex.x:
#			go("right")
#	
#		if pl.x > ex.x:
#			go("left")
