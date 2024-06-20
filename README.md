# Rate

Rate is a currency converter API built with Elixir and Phoenix. It provides functionality to convert between multiple currencies and keeps track of the conversion transactions.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Running the Tests](#running-the-tests)
- [Deployment](#deployment)
- [Endpoints](#endpoints)
- [Contributing](#contributing)
- [License](#license)

## Features

- Fetches the latest conversion rates from a third-party service
- Records and stores each transaction with detailed information
- Provides endpoints to list all transactions for a user
- Passwordless authentication using magic links

## Getting Started

### Prerequisites

- Elixir and Phoenix installed
- PostgreSQL database
- Maybe Docker and docker compose

### Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/yourusername/rate.git
    cd rate
    ```

2. Install dependencies:
    ```sh
    mix deps.get
    ```

3. Set up the database:
    ```sh
    mix ecto.setup
    ```

4. Start the server:
    ```sh
    mix phx.server
    ```

### Docker

Or just run with docker

First you need to login to GHCR:

```sh
echo <gh_pat> | docker login ghcr.io --username <gh_user> --password-stdin
```

```sh
docker compose up
```

## Configuration

Set up the following environment variables in your configuration file or `.env` file:

- `EXCHANGE_RATES_API_KEY`: Your API key for the currency conversion service
- `AUTHENTICATION_TOKEN_SALT`: A secret key for generating authentication tokens
- `OWN_EMAIL`: The email address from which magic link emails will be sent

## Running the Tests

To run the tests, use the following command:

```sh
mix test
```

### Test Coverage

- **Rate.Accounts.Login**
- **Rate.Accounts.RequestMagicLink**
- **Rate.Xchange**
- **Rate.Transactions.RegisterTransaction**
- **RateWeb.AuthController**
- **RateWeb.TransactionController**

## Deployment

This project uses Fly.io for deployment. Follow these steps to deploy your application:

1. Install Fly CLI:
    ```sh
    curl -L https://fly.io/install.sh | sh
    ```

2. Sign in to Fly.io:
    ```sh
    fly auth login
    ```

3. Create and configure a new Fly.io application:
    ```sh
    fly launch
    ```

4. Deploy your application:
    ```sh
    fly deploy
    ```

## Endpoints

### Authentication

- **Request Magic Link**
  - **POST** `/api/auth/request_magic_link`
  - **Parameters**: `email`
  - **Description**: Sends a magic link to the specified email address for passwordless login.

- **Login**
  - **POST** `/api/auth/login`
  - **Parameters**: `token`
  - **Description**: Logs in the user using the provided token.

### Transactions

- **Register Transaction**
  - **POST** `/api/transactions/register`
  - **Parameters**: `from_currency`, `from_amount`, `to_currency`, `fetch_latest`
  - **Description**: Registers a new currency conversion transaction.

- **List Transactions**
  - **GET** `/api/transactions`
  - **Description**: Lists all transactions for the current user.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Create a new Pull Request

## API Request collection

There's a requests collection exported from [Insomnia](https://insomnia.rest/download). You can try the dev and the prod environments.

## Note for test of production environement

Note that i'm using the free tier of the ExchangeRates API and also for the Resend API to send emails. They have low api rate limits so maybe they're unavaiable

## License

This project is licensed under the MIT License.
