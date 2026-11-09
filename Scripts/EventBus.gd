extends Node

signal player_joined(player_id: int)
signal player_died(player_id: int)
signal coins_changed(total: int)
signal combo_changed(player_id: int, count: int)
signal level_up(player_id: int, new_level: int)

# NEW for Phase 5:
signal big_hit(position: Vector2, damage: int, source_id: int)
