extends Node

var exitplace    = Vector2(0,0)
var playerplace  = Vector2(0,0)

var places = []
var cols = 12
var rows = 12

var playerlocs = [[6,1],   [6, 10], [1, 6], [10, 6], [1, 1],   [10, 10]]
var exitlocs   = [[6, 10], [6, 1],  [10, 6], [1, 6], [10, 10], [1, 1]]

var level = 0

class BoardMaker extends Node:
	var cols
	var rows
	var places
	
	var root
	var borderTiles = [7, 8, 10]
	var floorTiles = [14, 15, 16, 17, 18, 19, 20, 21]
	var foodTiles  = [0, 1]
	var wallTiles  = [3, 4, 5, 6, 9, 11, 12, 13]
	
	var exitplace    = Vector2(0,0)
	
	func _init(arootnode, mcols, mrows, someplaces, foodlow, foodhi, walllow, wallhi):
		root = arootnode
		cols = mcols
		rows = mrows
		places = someplaces
		randomize()
		createFloorAndOuterWalls()
#		createObjectsAtRandom(foodTiles, foodlow, foodhi, root.get_node("Dynamic"))
#		createObjectsAtRandom(wallTiles, walllow, wallhi, root.get_node("Dynamic"))
		pass

	func createFloorAndOuterWalls():
		var fts = root.get_node("Floor")
		var ots = root.get_node("Outer")
		
		for x in range(0, cols):
			for y in range (0, rows):
				var fl = randi() % self.floorTiles.size()
				fts.set_cell(x, y, floorTiles[fl])
				
				if x == 0 || y == 0 || x == cols - 1 || y == rows - 1:
					var ot = randi() % self.borderTiles.size()
					ots.set_cell(x, y, borderTiles[ot])
		pass

	func createExitAt(col, row):
		exitplace = Vector2(col, row)
		var dts = root.get_node("Dynamic")
		dts.set_cell(col, row, 2)

	func createExit():
		exitplace = getRandomPlace()
		var dts = root.get_node("Dynamic")
		dts.set_cell(exitplace.x, exitplace.y, 2)

	func createObjectsAtRandom(alist, min_no, max_no, where):
		var count = min_no + (randi() % (max_no - min_no + 1))
		
		for i in range(0, count):
			var place = getRandomPlace()
			var tile = randi() % alist.size()
			where .set_cell(place.x, place.y, alist[tile])
		
	func getRandomPlace():
		var index = randi() % places.size()
		var place = places[index]
		places.remove(index)
		return place

var Board
var enemyList
var food = 100
var scene
var tiles
var locs    = []
var playerFood = 100
var turnQueue = []

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	initializePlaces()
	pass

func getLevel():
	return level

func createMap(root):
	self.turnQueue = []
	self.scene = root
	self.tiles = root.get_node("Dynamic")
	if tiles == null:
		print("Can't find Dynamic tileset")
		
	self.Board = BoardMaker.new(root, cols, rows, places, 1, 5, 5, 9)
	self.initCollisionDetect()

	if level < 6:
		self.positionPlayerAt(playerlocs[level][0], playerlocs[level][1])
		Board.createExitAt(exitlocs[level][0], exitlocs[level][1])
		exitplace = Board.exitplace
		level = level + 1
	else:
		self.positionPlayer()
		Board.createExit()
		exitplace = Board.exitplace
		level = level + 1
#	self.positionEnemies(2)
	pass

func positionPlayerAt(col, row):
	var player = scene.get_node("Player")
	var vec = Vector2(col * 32 + 16, row * 32 + 16)
	player.set_pos (vec)
	player.actorPos = Vector2(col, row)
	locs[col][row] = player
	enqueueActor(player)

func positionPlayer():
	var player = scene.get_node("Player")
	playerplace = self.Board.getRandomPlace()
	var vec = Vector2(playerplace.x * 32 + 16, playerplace.y * 32 + 16)
	player.set_pos (vec)
	player.actorPos = playerplace
	locs[playerplace.x][playerplace.y] = player
	enqueueActor(player)
	
func positionEnemies(howmany):
	var enemy1 = load("res://Enemy1.tscn")
	var enemy2 = load("res://Enemy2.tscn")
	var enemies = scene.get_node("Enemies")
	var script = load("res://Enemy.gd")
	
	enemyList = []
		
	for i in range(0, howmany):
		var place = Board.getRandomPlace()
		var which = randi() % 2
		var enemy
		if which == 0:
			enemy = enemy1.instance()
		else:
			enemy = enemy2.instance()

		enemy.set_pos(Vector2(place.x * 32 + 16, place.y * 32 + 16))
		locs[place.x][place.y] = enemy
		enemies.add_child(enemy)
		enqueueActor(enemy)

func initializePlaces():
	for x in range(1, cols-1):
		for y in range(1, rows-1):
			if (x != 1 && y != 1) && (x != cols-1 && y != rows-1):
				places.push_back(Vector2(x, y))

func initCollisionDetect():
	locs = []
	for x in range(0, Board.cols):
		locs.append([])
		for y in range(0, Board.rows):
			locs[x].append(null)

func hasFoodAt(x,y):
	return tiles.get_cell(x,y) == 0

func hasSodaAt(x,y):
	return tiles.get_cell(x,y) == 1

func hasExitAt(x,y):
	return tiles.get_cell(x,y) == 2

func hasBreakableWallAt(x,y):
	var cell = tiles.get_cell(x,y)
	return cell == 3 || cell == 4 || cell == 5 || cell == 6 || cell == 9 || cell == 11 || cell == 12 || cell == 13

func hasBarrierAt(x,y):
	var cell = scene.get_node("Outer").get_cell(x,y)
	return cell == 7 || cell == 8 || cell == 10
	
func hasActorAt(x,y):
	return locs[x][y] != null

func getActorAt(x, y):
	return locs[x][y]

func removeActorAt(x, y):
	locs[x][y].queue_free()
	locs[x][y]= null

func removeFoodAt(x, y):
	tiles.set_cell(x, y, -1)
	
func removeSodaAt(x,y):
	tiles.set_cell(x, y, -1)
	
func removeWallAt(x,y):
	tiles.set_cell(x, y, -1)

func increasePlayerFood(amount):
	playerFood += amount

func decreasePlayerFood(amount):
	playerFood -= amount

func updateActor(actor, from, to):
	locs[from.x][from.y] = null
	locs[to.x][to.y] = actor

func enqueueActor(actor):
	turnQueue.push_back(actor)
	
func dequeueActor():
	turnQueue.pop_front()
	
func isActorTurnReady(actor):
	return turnQueue.front() == actor

func finishTurn(actor):
	if turnQueue.front() != actor:
		print("Problem! Actor finished moving is on top of queue")
	else:
		dequeueActor()
		if actor.isDefeated():
			pass
		else:
			enqueueActor(actor)
