# ZSSN API (Zoombie Survival Social Network)

API de gestão de suprimentos de sobreviventes de um apocalipse zumbi. Sobreviventes por enquanto...

-----------
### Ferramentas

* Ruby -v 2.3.1
* Rails -v 5.0.1
* SQLite -v 3.11
------

### Como executar  no seu computador:

#### 1. Clone este repositório 
```
git clone git@github.com:caiovitorsantos/zssn_api.git
```

#### 2. Instale as gems
```
bundle install
```

#### 3. Crie o banco e suas migrations
```
rake db:create db:migrate
```

#### 4. Execute os testes
```
rspec
```

#### 5. Execute o app
```
rails s
```

------

### Funcionalidades
(Exemplos usando CURL)

#### Usuario

* Cadastro: `POST /users`
```
curl -H "Content-Type: application/json" -X POST -d '{"user": {"name": "Catelyn Stark", "sex": "woman", "age": 35, "healthy": "true", "count_report": 0, "latitude": 39.02913, "longitude": 20.88344}}' http://localhost:3000/users
```
* Listar: `GET /users`
```
curl -H "Content-Type: application/json" -X GET http://localhost:3000/users
```
* Exibir um usuário: `GET /users/:id`
```
curl -H "Content-Type: application/json" -X GET http://localhost:3000/users/1
```
* Editando um usuário: `PUT /users/:id`
```
curl -H "Content-Type: application/json" -X PUT -d '{"user": {"name": "Catelyn Tully", "sex": "woman", "age": 42, "healthy": "true", "count_report": 2, "latitude": 39.02913, "longitude": 20.88344}}'  http://localhost:3000/users/1
```
* Deletando um usuário: `DELETE /users/:id`
```
curl -H "Content-Type: application/json" -X DELETE http://localhost:3000/users/1
```
* Alterando apenas a localização do usuário: `PUT /users/:id/set_location`
```
curl -H "Content-Type: application/json" -X PUT -d '{"user": {"latitude": 40.028922, "longitude": 55.550123}}'  http://localhost:3000/users/2/set_location
```
* Denunciando a infecção de um usuário: `GET /users/:id/complaint`
```
curl -H "Content-Type: application/json" -X GET  http://localhost:3000/users/2/complaint
```
* Exibindo o inventário do usuário: `GET /users/:id/inventory`
```
curl -H "Content-Type: application/json" -X GET http://localhost:3000/users/2/inventory
```
* Relatório Geral: `GET /reports`
```
curl -H "Content-Type: application/json" -X GET http://localhost:3000/reports
```

#### Inventário

* Cadastrando: `POST /inventories`
```
curl -H "Content-Type: application/json" -X POST -d '{"inventory": {"user_id": 3, "kind": "water", "amount": 5}}' http://localhost:3000/inventories
```
* Listando inventários por usuário: `GET /inventories`
```
curl -H "Content-Type: application/json" -X GET -d '{"user_id": 3}'  http://localhost:3000/inventories
```
* Exibindo um inventário do usuário: `GET /inventories/:id`
```
curl -H "Content-Type: application/json" -X GET -d '{"inventory": {"user_id": 3, "kind": "water"}}'  http://localhost:3000/inventories/1
```
* Editando um Inventário: `PUT /inventories/:id`
```
curl -H "Content-Type: application/json" -X PUT -d '{"inventory": {"user_id": 3, "kind": "water", "amount": 8}}'  http://localhost:3000/inventories/1
```
* Deletando um Inventário: `DELETE /inventories/:id`
```
curl -H "Content-Type: application/json" -X DELETE -d '{"inventory": {"user_id": 3, "kind": "water"}}' http://localhost:3000/inventories/1
```
* Adicionando itens em um inventário: `POST /inventories/:id/add`
```
curl -H "Content-Type: application/json" -X POST -d '{"inventory": {"user_id": 3, "kind": "food", "amount": 8}}'  http://localhost:3000/inventories/2/add
```
* Retirando itens em um inventário: `POST /inventories/:id/add`
```
curl -H "Content-Type: application/json" -X POST -d '{"inventory": {"user_id": 3, "kind": "food", "amount": 8}}'  http://localhost:3000/inventories/2/remove
```
* Realizando a troca de itens entre usuários: `POST /exchange` (Adicione mais Inventários ou mais quantidades de suprimentos caso o que tiver no momento não for suficiente)
```
curl -H "Content-Type: application/json" -X POST  -d '{"origin":{"user_id":3, "items":[{"kind": "water", "amount":3}]}, "destiny":{"user_id":2, "items":[{"kind": "food", "amount":4}]} }'  http://localhost:3000/exchange
```