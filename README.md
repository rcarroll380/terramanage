# terramanage

terramanage is lightweight bookkeeping software for small U.S. landlords who
manage their own long-term rental properties. It is designed to keep books
separate by owner or legal entity, track activity by property, reconcile
financial accounts, and prepare clear reports for tax professionals.

The project is in early development. The first working slice provides a
book-scoped chart-of-accounts editor with main accounts and subaccounts.

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

## Project plans

- [Product plan](./plan/PRODUCT_PLAN.md)
- [Accounting and data specification](./plan/ACCOUNTING_SPEC.md)
