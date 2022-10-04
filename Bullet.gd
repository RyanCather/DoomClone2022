extends Area

var speed : float = 30.0
var damage : int = 1

func _process (delta):
	# move the bullet forwards
	translation -= global_transform.basis.z * speed * delta

#	print(translation)
	pass

func _on_Bullet_body_entered(body):
	if body.has_method("take_damage"):
		print("hit")
		body.take_damage(damage)
		destroy()

func destroy ():
	# destroys the bullet
	queue_free()



