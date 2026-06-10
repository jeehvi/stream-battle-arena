extends Node

var _players := {}
var _session_winners: Array = []
var _battle_counter := 0


func reset_session():
	_players.clear()
	_session_winners.clear()
	_battle_counter = 0


func record_battle(players: Array, winner):
	_battle_counter += 1

	for p in players:
		var username = p.username
		if not _players.has(username):
			_players[username] = {
				session_points = 0,
				session_kills = 0,
				session_wins = 0,
				session_games_played = 0,
			}
		var entry = _players[username]
		entry.session_kills += p.kills
		entry.session_points += p.kills
		entry.session_games_played += 1

	if winner != null:
		var username = winner.username
		if not _players.has(username):
			_players[username] = {
				session_points = 0,
				session_kills = 0,
				session_wins = 0,
				session_games_played = 0,
			}
		var entry = _players[username]
		entry.session_points += 10
		entry.session_wins += 1

		_session_winners.append({
			battle_number = _battle_counter,
			username = username
		})


func get_top_points(limit: int) -> Array:
	var list: Array = []
	for username in _players:
		list.append({ username = username, entry = _players[username] })
	list.sort_custom(func(a, b): return a.entry.session_points > b.entry.session_points)
	return list.slice(0, limit)


func get_top_wins(limit: int) -> Array:
	var list: Array = []
	for username in _players:
		list.append({ username = username, entry = _players[username] })
	list.sort_custom(func(a, b): return a.entry.session_wins > b.entry.session_wins)
	return list.slice(0, limit)


func get_top_kills(limit: int) -> Array:
	var list: Array = []
	for username in _players:
		list.append({ username = username, entry = _players[username] })
	list.sort_custom(func(a, b): return a.entry.session_kills > b.entry.session_kills)
	return list.slice(0, limit)


func get_session_winners() -> Array:
	return _session_winners.duplicate()

