# WeSave Backend Challenge - iSave
## Requirements

- `ruby` version 3.3.1
- `sqlite3`



## Setup Instructions

1. Clone the repository
2. Install the required Ruby version (~>3.3.1)
3. Install dependencies: `bundle install`
4. Set up the database: `rake db:create db:migrate`
5. Seed the data base: `rake db:seed`





## Technical Documentation (Levels 1 and 2)

### Domain model (DB-backed)
- Customer: `first_name`, `last_name`
- Portfolio: `customer:ref`, `name` (aka label), `kind` ("CTO"|"PEA"|"Assurance Vie"|"Livret A"), `total_amount`
- Instrument: `isin` (unique), `kind` ("stock"|"bond"|"euro_fund"), `name`, `price`, `sri`
- Investment: join `portfolio`×`instrument`, `amount` (money on that line), `weight` (share within portfolio)
- Constraints
  - Unique index on `investments(portfolio_id, instrument_id)` (one investment per instrument per portfolio)
  - Only `CTO`, `PEA`, `Assurance Vie` may have investments; enforced at model level

### Seeding
- Seeds mirror `data/level_1/portfolios.json` and skip unsupported portfolio kinds (e.g., "Compte dépôt").

### API versioning and routing
- All endpoints are under `/api/v1`.
- Unknown API routes return a JSON 404 via `ErrorsController`.

### Errors (JSON)
- Shape: `{ error: { code, message, status } }`
- Codes used: `not_found`, `validation_error`, `bad_request`, `not_eligible`.

### Level 1 – List portfolios datas for a customer
- Route: `GET /api/v1/customers/:customer_id/portfolios`
- Response shape mirrors the input file but is DB-backed.
- Example
```bash
curl -s http://127.0.0.1:3000/api/v1/customers/1/portfolios | jq
```
- Response (excerpt)
```json
{
  "contracts": [
    {
      "label": "PEA - Portefeuille Équilibré",
      "type": "PEA",
      "amount": 30000.0,
      "lines": [
        {
          "type": "stock",
          "isin": "FR0012345678",
          "label": "iShares Core MSCI World ETF",
          "price": 50.0,
          "share": 0.34,
          "amount": 20000.0,
          "srri": 6
        }
      ]
    }
  ]
}
```

### Level 2 – Portfolio transactions (eligible kinds: CTO, PEA)
- Operations are atomic (DB transactions) and delegated to PORO services under `app/services/transactions`.
- Eligibility is enforced via the `Eligibility` controller concern.

#### Deposit money into an existing investment
- Route: `POST /api/v1/customers/:customer_id/portfolios/:portfolio_id/investments/:id/deposit`
- Body: `{ "amount": <number> }`
- Effects: increases the investment `amount` and the portfolio `total_amount`.
- Codes: `204` on success; `400` invalid amount; `404` missing resources; `422 not_eligible`.

#### Withdraw money from an existing investment
- Route: `POST /api/v1/customers/:customer_id/portfolios/:portfolio_id/investments/:id/withdraw`
- Body: `{ "amount": <number> }`
- Effects: decreases the investment `amount` and the portfolio `total_amount`.
- Guards: `amount` must be ≤ current investment `amount`.
- Codes: `204` success; `400` invalid amount; `404`; `422` on insufficient funds or not eligible.

#### Transfer money between investments (same portfolio)
- Route: `POST /api/v1/customers/:customer_id/portfolios/:portfolio_id/transfer`
- Body: `{ "from_instrument_id": <id>, "to_instrument_id": <id>, "amount": <number> }`
- Effects: moves `amount` from source investment to destination; portfolio total unchanged.
- Codes: `204` success; `400` invalid amount or same `from`/`to`; `404`; `422` insufficient funds or not eligible.

#### Examples
```bash
# Deposit 100
curl -X POST http://127.0.0.1:3000/api/v1/customers/1/portfolios/1/investments/2/deposit \
  -H "Content-Type: application/json" -d '{"amount":100}' -i

# Withdraw 50
curl -X POST http://127.0.0.1:3000/api/v1/customers/1/portfolios/1/investments/2/withdraw \
  -H "Content-Type: application/json" -d '{"amount":50}' -i

# Transfer 75 from instrument 2 to 3
curl -X POST http://127.0.0.1:3000/api/v1/customers/1/portfolios/1/transfer \
  -H "Content-Type: application/json" \
  -d '{"from_instrument_id":2,"to_instrument_id":3,"amount":75}' -i
```

### Design notes
- Controllers are skinny; business rules live in services (`Transactions::Deposit/Withdraw/Transfer`).
- Eligibility is shared with `Eligibility` concern (`require_transaction_eligibility!`).
- Request specs cover success and error cases; service specs cover unit-level rules.
