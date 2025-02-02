extends Node2D

signal player_died
signal can_shoot
signal cannot_shoot

var cooldown = false
var _is_chainsawing = false
var _chainsaw_mode = false
export var chainsaw_unit_speed = 0.07
export var chainsaw_unit_speed_variance = 0.02
export var cooldown_timer = 0.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var PlayerBullet = preload("res://player/PlayerBullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_chainsawing:
		var follow = $ChainsawPath/ChainsawFollow
		var variance = chainsaw_unit_speed + rand_range(-chainsaw_unit_speed_variance, chainsaw_unit_speed_variance)
		var new_offset = follow.unit_offset + variance
		if new_offset >= 1:
			_is_chainsawing = false
			new_offset = 0
		follow.unit_offset = new_offset
	if cooldown == false:
		emit_signal("can_shoot")
	elif cooldown:
		emit_signal("cannot_shoot")

func _input(event):
	if event.is_action("shoot_offense"):
		shoot_offense()
	if event.is_action("shoot_defense"):
		shoot_defense()

func shoot_offense():
	if _chainsaw_mode:
		_is_chainsawing = true
		$ChainsawSound.play()
	elif cooldown == false:
		_spawn_bullet(true)
		$AttackSound.play()
		cooldown = true
		yield(get_tree().create_timer(cooldown_timer), 'timeout')
		cooldown = false
			
func _spawn_bullet(is_offense):
	var bullet = PlayerBullet.instance()
	bullet.is_offense = is_offense
	bullet.position = position
	get_parent().add_child(bullet)
	bullet.connect("bullet_collision", self, "_on_bullet_collision")
	
func _on_bullet_collision():
	$BulletCollisionSound.play()

func shoot_defense():
	if _chainsaw_mode:
		_is_chainsawing = true
		$ChainsawSound.play()
	elif cooldown == false:
		_spawn_bullet(false)
		$DefenseSound.play()
		cooldown = true
		yield(get_tree().create_timer(cooldown_timer), 'timeout')
		cooldown = false

func damage():
	$HitSound.play()
	$HealthTracker.reduce_health()

func _on_death():
	emit_signal("player_died")
	queue_free()

func equip_chainsaw():
	_chainsaw_mode = true
	$ChainsawPath/ChainsawFollow/Chainsaw.visible = true


func _shoot_offense():
	pass # Replace with function body.
