# terramanage Product Plan

The detailed chart of accounts, tracked fields, posting rules, and report definitions are specified in the [accounting and data specification](./ACCOUNTING_SPEC.md).

## Product definition

terramanage is lightweight bookkeeping software for U.S. landlords who manage their own long-term rental properties. It helps an owner record income and expenses, keep each property and legal entity separate, reconcile accounts, and produce useful financial reports without requiring accounting expertise.

terramanage does not collect rent. Payments are entered manually or imported as transaction data.

### Initial customer

- A self-managing landlord with roughly 1–25 units
- Owns properties personally, through one or more LLCs, or both
- Currently uses spreadsheets, bank statements, or a general accounting product
- Wants accurate books by property and a clean year-end package for a tax professional
- Does not need a full property-management suite

### Product promise

An owner can finish the books for a month and answer:

- What did each property earn and cost?
- Which rent payments are missing or late?
- Which transactions still need attention?
- Do the books agree with the bank statement?
- What should I give my accountant at tax time?

## Core product model

### Account and books

A user account can access one or more **books**. Each book is an isolated bookkeeping data set, such as “Personal Rentals” or “Carroll Property LLC.” The user can switch books from the application shell.

For the first release, isolation should be a domain and authorization boundary. The implementation may use separate physical databases or a shared database with strict tenant keys, but application code must never assume that records from different books can be joined.

Each book contains:

- Owners and ownership entity details
- Properties and units
- Tenants and leases
- Financial accounts
- Chart of accounts
- Transactions and journal entries
- Documents and receipts
- Reconciliations
- Reports and exports

### Accounting foundation

Use double-entry accounting internally. The interface should speak in familiar landlord terms while the ledger preserves accounting integrity.

Every posted transaction must:

- Balance debits and credits
- Belong to exactly one book
- Preserve an audit trail for creation, edits, voids, and reconciliation
- Allow property and unit attribution where relevant
- Support transaction splits across properties or expense categories

The system should distinguish these common cases from ordinary income or expenses:

- Security deposits held as liabilities
- Mortgage principal, interest, and escrow
- Owner contributions and draws
- Transfers between financial accounts
- Capital improvements versus repairs
- Refunds, reimbursements, and returned payments
- Closing costs and property acquisition basis adjustments

Cash-basis reporting is the initial default. The ledger design should leave room for accrual reporting later.

## MVP scope

The MVP is complete when a landlord can set up a book, enter or import one month of activity, reconcile a bank account, and produce accurate property-level reports.

### 1. Book setup

- Create, rename, and switch books
- Configure owner or LLC name, tax year, currency, and reporting basis
- Create properties and optional units
- Create financial accounts such as checking, savings, credit card, mortgage, cash, and security-deposit accounts
- Start from a rental-specific chart of accounts
- Enter opening balances through a guided workflow

### 2. Tenants and leases

- Store tenants and contact information
- Record lease dates, unit, recurring rent amount, due day, and security deposit
- Track lease status: upcoming, active, ended
- Create monthly rent charges from an active lease
- Record payments and apply them to charges
- Show tenant balances and payment history
- Record concessions, credits, late fees, and write-offs manually

This is a receivables ledger for bookkeeping. It does not include payment collection, tenant login, lease signing, or automated messaging.

### 3. Transactions

- Record income, expenses, transfers, contributions, draws, and journal entries
- Assign a transaction to a property and optionally a unit
- Split a transaction across categories or properties
- Divide mortgage payments into principal, interest, and escrow components
- Attach notes and receipt files
- Use reusable categories and payees
- Search and filter by date, account, property, category, payee, amount, and review status
- Edit, void, or reverse entries with an audit history

### 4. Imports

- Import bank and credit-card transactions from CSV
- Map unfamiliar CSV columns and save a mapping per financial institution
- Preview imported rows before committing them
- Detect likely duplicates using account, date, amount, and description
- Match imported rows to transactions already entered
- Categorize and assign imported transactions in a review queue
- Support bulk edits and simple categorization rules

Direct bank connections are a later milestone. CSV import proves the matching, categorization, and reconciliation model first.

### 5. Reconciliation

- Start a reconciliation with statement start date, end date, and ending balance
- Mark cleared transactions
- Show the difference in real time
- Finish only when the difference is zero, with an explicit override reserved for corrections
- Lock completed reconciliation periods against casual edits
- Reopen a reconciliation with an audit event
- Produce a reconciliation summary

### 6. Reports and exports

- Profit and loss for the whole book
- Profit and loss by property, with side-by-side comparison
- Income and expense detail
- General ledger
- Balance sheet
- Rent roll and tenant balances
- Security-deposit liability detail
- Account reconciliation report
- Schedule E-oriented income and expense summary
- CSV export of transactions and report tables
- Year-end package containing reports plus a receipt index

Reports must make the reporting period, accounting basis, book, and property filters visible.

## Explicitly deferred

- Rent or security-deposit collection
- Tenant portal or mobile tenant app
- Listing syndication, applications, and tenant screening
- Lease generation or electronic signatures
- Maintenance requests and vendor dispatch
- Payroll and contractor tax-form filing
- Tax return preparation or filing
- Depreciation schedules and fixed-asset tax calculations
- Live bank feeds
- Automated receipt extraction
- Multi-currency accounting
- Full property-management trust accounting
- Property managers operating funds for unrelated owners

## Primary workflows

### First-time setup

1. Create a book and identify its owner or LLC.
2. Add properties, units, and financial accounts.
3. Confirm the suggested rental chart of accounts.
4. Add active leases and opening tenant balances.
5. Enter opening account balances.
6. Review a setup checklist before posting normal activity.

### Monthly close

1. Enter rent payments and other known activity.
2. Import bank and credit-card CSV files.
3. Match duplicates and existing entries.
4. Categorize uncategorized activity and assign properties.
5. Split mortgage and mixed-property transactions.
6. Reconcile each account to its statement.
7. Review missing rent and unresolved transactions.
8. Run and export monthly reports.

### Year-end handoff

1. Resolve uncategorized and unreconciled activity.
2. Review property assignments and capital improvements.
3. Confirm security-deposit balances.
4. Generate a Schedule E-oriented summary and detailed ledgers.
5. Export the year-end package for the tax professional.

## Information architecture

The main navigation within a selected book should be:

- Overview
- Transactions
- Rent
- Properties
- Reconcile
- Reports
- Documents
- Settings

The current book must always be visible. Switching books should require no sign-out, and every data screen should reset its filters after a switch so information from the prior book is not visually carried over.

The overview should prioritize work that needs attention:

- Rent expected, received, and overdue this month
- Uncategorized imported transactions
- Transactions missing a property
- Accounts awaiting reconciliation
- Monthly income, expenses, and net cash flow

## Suggested domain model

Every domain record includes `book_id`, creation and update timestamps, and an audit actor where applicable.

| Domain | Main records |
| --- | --- |
| Identity | User, Book, BookMembership |
| Rentals | Property, Unit, Tenant, Lease, RentCharge, TenantPayment, PaymentApplication |
| Accounting | Account, Category, JournalEntry, JournalLine, Payee, Transfer |
| Banking | ImportBatch, ImportedTransaction, Match, CategorizationRule, Reconciliation, ReconciliationLine |
| Files | Document, DocumentLink |
| Operations | AuditEvent, SavedReport, ExportJob |

`JournalEntry` and `JournalLine` are the financial source of truth. Tenant payments, transfers, and categorized imported transactions create or reference journal entries rather than maintaining independent financial totals.

### Book isolation options

| Approach | Strength | Cost | Recommendation |
| --- | --- | --- | --- |
| Shared database with `book_id` | Simple operations and efficient switching | Requires excellent authorization and query discipline | Good for the first release |
| Schema per book | Stronger logical separation | More migrations and operational complexity | Consider if customer isolation demands grow |
| Database per book | Strongest isolation and portable books | Highest provisioning, migration, and reporting cost | Keep behind a storage interface; do not start here |

Use a shared database initially, enforce `book_id` in the data-access layer, and add database-level row security when supported. Treat a future physical database switch as an infrastructure change rather than a product-level distinction.

## Non-functional requirements

### Financial correctness

- Store monetary values as integer cents or fixed-precision decimals, never binary floating point
- Post balanced journal entries in one database transaction
- Make finalized reconciliation and audit records append-oriented
- Use explicit dates and the book's configured time zone
- Test edge cases involving negative values, splits, voids, transfers, and duplicate imports

### Security and privacy

- Enforce book membership on every request and background job
- Encrypt traffic and stored secrets
- Use private object storage for receipts and time-limited download URLs
- Keep sensitive data out of logs
- Record security-relevant and financial mutations in the audit log
- Provide export and deletion workflows for a book

### Reliability

- Automatic database backups with tested restoration
- Idempotent CSV import commits and background jobs
- Observable failures for imports, exports, and file processing
- A documented recovery path for a partially completed operation

## Delivery plan

### Phase 0: validation and accounting design

Deliverables:

- Interview 5–8 target landlords using anonymized statements and spreadsheets
- Collect representative examples: rent, mortgage, deposit, transfer, repair, improvement, refund, contribution, and draw
- Write posting rules for each example
- Prototype the monthly-close workflow
- Validate report outputs with a U.S. rental-property accountant or bookkeeper

Exit criterion: the team can reproduce one landlord's completed month and explain every balance.

### Phase 1: ledger and setup

Deliverables:

- Authentication, books, membership, and book switching
- Properties, units, financial accounts, and chart of accounts
- Double-entry ledger and audit events
- Manual transaction entry, splits, and transfers
- Basic profit-and-loss and ledger reports

Exit criterion: a user can enter a month manually and produce balanced reports by property.

### Phase 2: rent and imports

Deliverables:

- Tenants, leases, rent charges, payments, and balances
- CSV import mapping, preview, duplicate detection, and matching
- Transaction review queue and categorization rules
- Receipt upload and linking

Exit criterion: a user can import a real statement without duplicating manually recorded rent.

### Phase 3: close and accountant handoff

Deliverables:

- Bank and credit-card reconciliation
- Period protections and correction workflow
- Balance sheet, rent roll, security-deposit, and Schedule E-oriented reports
- CSV and year-end package exports
- Onboarding and monthly-close checklists

Exit criterion: pilot users close two consecutive months and their existing records agree within explained differences.

### Phase 4: pilot hardening

Deliverables:

- Fix workflow and accounting gaps found by pilot users
- Improve import mappings and rules
- Backup restoration test, privacy controls, and operational monitoring
- Product analytics for setup and monthly-close completion

Exit criterion: at least five pilot users independently finish setup and a monthly close.

## Success measures

Early success should measure whether the product helps users finish their books correctly:

- Percentage of new books that add a property and financial account
- Percentage that post or import their first transaction
- Percentage that complete a reconciliation within 30 days
- Median unresolved transactions at monthly close
- Median time to categorize and reconcile 100 statement rows
- Percentage of active books producing a monthly property report
- Number and severity of unexplained differences found during pilot comparisons

Avoid optimizing sign-ups or transaction volume before monthly-close completion and financial accuracy are healthy.

## Key product decisions to resolve

1. **Book meaning:** Confirm that a book represents an independently reported owner or legal entity, rather than merely a visual portfolio folder.
2. **Shared ownership:** Decide whether one property can have ownership percentages across entities in the first release; the recommended MVP answer is no.
3. **Security deposits:** Decide whether to support state-specific deposit rules or only bookkeeping liability tracking; the recommended MVP scope is liability tracking.
4. **Rent accounting:** Decide whether partial payments apply oldest-first automatically or are allocated manually; oldest-first with editable allocation is the recommended default.
5. **Accountant access:** Decide whether the first release needs read-only collaborator accounts or relies on exports; exports are sufficient for the initial pilot.
6. **Opening balances:** Define how much historical detail is required; the recommended workflow starts on a chosen date with validated opening balances.

## First implementation slice

Build one narrow, end-to-end path before expanding screens:

1. Create and switch between two books.
2. Add one property and one checking account to each book.
3. Enter rent income and a repair expense.
4. Verify that balanced journal entries are created.
5. Show a profit-and-loss report filtered to the property.
6. Prove through automated authorization tests that neither book can access the other's data.

This slice tests the product's two highest-risk foundations: understandable rental bookkeeping and strict book isolation.
