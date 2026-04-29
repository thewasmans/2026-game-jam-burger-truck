extends Node

var _clients: Array[HungryClient] = []
var _waiting_queue: Array[HungryClient] = []
var clients_feeded: int = 0

func initialize():
	_clients = []
	_waiting_queue = []

func feed_client(client:HungryClient, plate:CratePlate):
	client.give_food(plate._ingredients)
	MoneyManager.add_money(client._burger_request.price)
	plate.clear()
	clients_feeded += 1
	_clients.erase(client)
	_waiting_queue.erase(client)

func burger_match_with_client(burger: Array[IngredientData], plates:Dictionary) -> HungryClient:
	for client: HungryClient in _clients:
		if client.is_waiting and client in plates.values():
			var request_ingredients: Array[IngredientData] = client._burger_request.ingredients
			var is_match: bool = true
			
			if request_ingredients.size() != burger.size():
				is_match = false
			else:
				for i: int in range(burger.size()):
					if request_ingredients[i] != burger[i]:
						is_match = false
						break
						
			if is_match:
				return client
			
	return null

func release_client(client:HungryClient):
	_clients.erase(client)
	_waiting_queue.erase(client)
	
