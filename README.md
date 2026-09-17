# terramanage

terramanage is lightweight bookkeeping software for small U.S. landlords who
manage their own long-term rental properties. It is designed to keep books
separate by owner or legal entity, track activity by property, reconcile
financial accounts, and prepare clear reports for tax professionals.

The project is in early development. The current working slice provides a
book-scoped chart of accounts, customer and vendor management, and a
spreadsheet-style transaction register.

## Current features

- UUID primary keys with book-scoped accounts and transactions
- Chart of accounts with main accounts, subaccounts, account status, and account-filtered transaction views
- Shared customer and vendor entities with optional U.S. address fields and active status
- Inline transaction entry with payee, payment, deposit, running balance, account categorization, and memo fields
- Currency-formatted amounts, memo-triggered autosave, and account-filtered redirects
- Active payees for new transactions while retaining inactive payees on existing records
- Ending balance display for the current transaction view

## Technology

- Ruby 4.0.7
- Rails 8.1
- SQLite
- Hotwire (Turbo and Stimulus)

## Local setup

Install the required Ruby version, then run:

```sh
bundle install
bin/rails db:prepare
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000).

## Development checks

Run the test suite:

```sh
bin/rails test
```

Run the full local CI suite, including style and security checks:

```sh
bin/ci
```

## Data imports

Import a CSV export by providing its path and import type. The supported types
are `account`, `vendor`, `customer`, and `transactions`:

```sh
bin/rails data:import FILE="/path/to/export.csv" TYPE=account
bin/rails data:import FILE="/path/to/export.csv" TYPE=vendor BOOK="My rentals"
```

Account imports accept the QuickBooks Account Listing layout. Entity and
transaction imports expect a header row with names such as `Name`, `Date`,
`Payee`, `Account`, `Category Account`, `Payment`, and `Deposit`.

## Project plans

- [Product plan](./plan/PRODUCT_PLAN.md)
- [Accounting and data specification](./plan/ACCOUNTING_SPEC.md)
