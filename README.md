# Rate

**Rate** is a currency converter API built with Elixir and Phoenix Framework. It provides real-time currency conversion using updated exchange rates from an external service and records each conversion transaction. 

## Features

- Convert between four currencies: BRL, USD, EUR, and JPY.
- Fetch conversion rates from [ExchangeRatesAPI](http://api.exchangeratesapi.io/latest?base=EUR).
- Record conversion transactions with details: user ID, source currency, target currency, source amount, target amount, conversion rate, and timestamp.
- Retrieve all conversion transactions performed by a specific user.
- Authentication via Bearer token.
- Comprehensive test coverage.

## Technologies Used

- Elixir
- Phoenix Framework
- Peri (custom schema validation library)
- Req (HTTP client)
- Ecto (database integration)
- Phoenix.Token (authentication)
- PostgreSQL (embedded database)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/rate.git
   cd rate
   ```

2. Install dependencies:
   ```bash
   mix deps.get
   ```

3. Set up the database:
   ```bash
   mix ecto.create
   mix ecto.migrate
   ```

4. Start the Phoenix server:
   ```bash
   mix phx.server
   ```

The application will be available at `http://localhost:4000`.

### Docker

You can also run this project with `docker` and `docker-compose`:

```sh
docker compose up
```

## Endpoints

### Convert Currency

- **URL:** `/api/v1/convert`
- **Method:** `POST`
- **Headers:** `Authorization: Bearer <token>`
- **Request Body:**
  ```json
  {
    "from_currency": "USD",
    "to_currency": "EUR",
    "amount": 42.42
  }
  ```
- **Response:**
  ```json
  {
    "data": {
      "id": 1,
      "user_id": 1,
      "from_currency": "USD",
      "to_currency": "EUR",
      "from_amount": 42.42,
      "to_amount": 85.0,
      "conversion_rate": 0.85,
      "timestamp": "2024-06-19T12:34:56Z"
    }
  }
  ```

In case of errors, besides the HTTP code, the body will be:
```json
{
  "status": "error",
  "message": "SOME ERROR MESSAGE"
}
```

### List User Transactions

- **URL:** `/api/v1/transactions`
- **Method:** `GET`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  {
    "data": [
      {
        "id": 1,
        "user_id": 1,
        "from_currency": "USD",
        "to_currency": "EUR",
        "from_amount": 100.0,
        "to_amount": 85.0,
        "conversion_rate": 0.85,
        "timestamp": "2024-06-19T12:34:56Z"
      }
    ]
  }
  ```

## Testing

Run the tests using the following command:
```bash
mix test
```

## Deployment

To deploy the application, you can use platforms like [fly.io](https://fly.io). Follow these general steps:

1. Create a new Heroku application:
   ```bash
   flyctl launch
   ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request with your changes.

## License

This project is licensed under the MIT License.

## Acknowledgements

- [ExchangeRatesAPI](http://api.exchangeratesapi.io/latest?base=EUR) for providing the exchange rates.
