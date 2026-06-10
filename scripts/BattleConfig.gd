class_name BattleConfig

static func get_config(player_count: int) -> Dictionary:
	if player_count <= 20:
		return {
			max_health = 300,
			damage = 6,
			attack_cooldown = 2.0,
		}
	elif player_count <= 100:
		return {
			max_health = 250,
			damage = 7,
			attack_cooldown = 1.8,
		}
	elif player_count <= 500:
		return {
			max_health = 220,
			damage = 8,
			attack_cooldown = 1.6,
		}
	else:
		return {
			max_health = 180,
			damage = 10,
			attack_cooldown = 1.4,
		}
