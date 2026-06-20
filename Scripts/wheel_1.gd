extends RigidBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var wheel_collider: CollisionShape2D = $WheelCollider
@onready var wheel_hitbox: Area2D = $WheelHitbox
@onready var dummy: AnimatedSprite2D = $Dummy
@onready var marker: Sprite2D = $Marker
@onready var floor_detector: ShapeCast2D = $FloorDetector
@onready var dust: GPUParticles2D = $Dust
@onready var start_dust: AnimatedSprite2D = $Dust/StartDust
@onready var sfx: AudioStreamPlayer2D = $SFX

@onready var suspension: Node2D = $Suspension
@onready var spring_joint: DampedSpringJoint2D = $Suspension/SpringJoint

const STIFFNESS = 2900
const DAMPING = 50
const SPEED = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spring_joint.stiffness = STIFFNESS
	spring_joint.damping = DAMPING

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if sprite.is_playing():
		if not sfx.playing:
			sfx.play()
	else:
		if sfx.playing:
			sfx.stop()

const floor_stick_factor : float = 0.1
func drive():
	self.physics_material_override.friction = 0.15
	var normal = floor_detector.get_collision_normal(0)
	var forward = Vector2(get_parent().get_parent().direction, 0)	
	var slope_dir = forward.lerp(forward.slide(normal), floor_stick_factor).normalized()
	self.apply_central_force(slope_dir * SPEED * 1500)

# Passthroughs to accomodate old central wheel control system
func is_playing():
	return sprite.is_playing()

func stop():
	sprite.stop()

func play(anim_name):
	sprite.play(anim_name)

func brake():
	var brake_tween = create_tween()
	brake_tween.tween_property(
		physics_material_override,
		"friction",
		0.15,
		0.7
	)
