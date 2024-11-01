# TestTask - Mark Babich

## [Hub88 Developer Challenge](https://github.com/coingaming/hub88-jnr)

This project demonstrates the operator's "Wallet API" service, developed using the Elixir Phoenix framework. Below are instructions for setting up, running, and testing the program.
The implementation covers specific endpoints according to the requirements outlined in the [test-task description](https://github.com/coingaming/hub88-jnr)

## Features

- **User Balance Check**: Returns the user's balance and creates a new user with an initial balance of 1000 (100000000 in int representation) EUR if they do not exist.
- **Betting**: Deducts a specified amount from the user's balance after validating the request.
- **Winning**: Increases the user's balance based on winnings while ensuring the bet transaction is valid and not closed.
- **Idempotency**: Ensures that transactions can be processed multiple times without unintended side effects.
- Corresponding errors are sent when the API is used incorrectly
- All monetary values are stored in the int type, but multiplied by 100000 which ensures precision up to cents.

## Installation and testing

1. **Clone the Repository**
2. **Run `mix setup` to install and setup dependencies**
3. **Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`**
4. **Test API through Postman (use http://localhost:4000/ endpoint)**
5. **To run tests `mix test` in terminal**

## API Endpoints

### User Balance

- **Endpoint**: `/api/user/balance`
- **Method**: `POST`
- **Request Body**:
  ```json
  {
    "user": "username"
  }

### Transaction Bet

- **Endpoint**: `/api/transaction/bet`
- **Method**: `POST`
- **Request Body**:
  ```json
  {
    "user": "username",
    "amount": 30000000,
    "currency": "EUR",
    "transaction_uuid": "ef783666-ef15-46b2-a0fe-e9717f20f1e6",
  }

### Transaction Win

- **Endpoint**: `/api/transaction/win`
- **Method**: `POST`
- **Request Body**:
  ```json
  {
    "user": "username",
    "amount": 50000000,
    "currency": "EUR",
    "transaction_uuid": "a3b7a722-3d59-40ca-8015-0c6c3df99f45",
    "reference_transaction_uuid": "ef783666-ef15-46b2-a0fe-e9717f20f1e6"
  }
