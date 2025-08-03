extends TextureButton

# Taille originale du bouton
var original_scale: Vector2
# Facteur d'agrandissement au survol
var hover_scale_factor: float = 1.2
# Durée de l'animation en secondes
var animation_duration: float = 0.2
# Type d'interpolation pour l'animation
var tween_ease: Tween.EaseType = Tween.EASE_OUT
var tween_trans: Tween.TransitionType = Tween.TRANS_BACK

func _ready():
	# Stocker la taille originale
	original_scale = scale
	
	# Définir le point de pivot au centre pour que le scaling se fasse depuis le centre
	pivot_offset = size / 2
	
	# Connecter les signaux de survol
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	# Animation d'agrandissement au survol
	animate_scale(original_scale * hover_scale_factor)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited():
	# Animation de retour à la taille originale
	animate_scale(original_scale)
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func animate_scale(target_scale: Vector2):
	# Créer un nouveau Tween
	var tween = create_tween()
	
	# Configurer l'animation
	tween.set_ease(tween_ease)
	tween.set_trans(tween_trans)
	
	# Animer vers la taille cible
	tween.tween_property(self, "scale", target_scale, animation_duration)

# Méthode optionnelle pour personnaliser l'animation
func set_hover_animation(scale_factor: float, duration: float, ease_type: Tween.EaseType = Tween.EASE_OUT, trans_type: Tween.TransitionType = Tween.TRANS_BACK):
	hover_scale_factor = scale_factor
	animation_duration = duration
	tween_ease = ease_type
	tween_trans = trans_type
