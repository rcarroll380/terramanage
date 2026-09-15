# terramanage Accounting and Data Specification

Status: Proposed foundation for the MVP

## 1. Accounting model

terramanage uses double-entry accounting internally and a landlord-oriented interface externally. Users see actions such as “record rent,” “split mortgage payment,” and “add repair.” The system creates balanced journal entries behind those actions.

The MVP supports U.S. residential, long-term rentals and defaults to cash-basis reporting. Each book belongs to one reporting owner or entity and contains one or more properties.

### Decisions for the MVP

- U.S. dollars only
- Calendar-year books by default, with a configurable fiscal year start
- Cash basis is the supported reporting basis
- One property belongs to one book
- A book may contain multiple properties owned by the same reporting owner or entity
- Rent charges and tenant balances live in a tenant subledger
- A rent charge does not create a general-ledger entry on cash-basis books
- Receiving rent creates the income entry in the general ledger
- Posted entries are reversed or voided with an audit event, not silently deleted
- Reports use journal lines as their financial source of truth
- Tax mappings are report metadata, not tax advice or a substitute for an accountant's adjustments

### Book boundary

A book is the accounting and authorization boundary. Examples are “Ryan's Rentals” and “Oak Street Properties LLC.” Every record belongs to exactly one book. A user may switch between books, but transactions, accounts, properties, tenants, imports, documents, and reports never cross the book boundary.

The application should use a shared database initially with mandatory `book_id` scoping. The data-access layer must make unscoped queries difficult or impossible, and authorization tests must prove that one book cannot read or mutate another book's data.

## 2. Account taxonomy

Each ledger account has one of these types:

| Type | Normal balance | Appears on |
| --- | --- | --- |
| Asset | Debit | Balance sheet |
| Liability | Credit | Balance sheet |
| Equity | Credit | Balance sheet |
| Income | Credit | Profit and loss |
| Expense | Debit | Profit and loss |

Accounts may be system-controlled, user-created, or user-editable defaults. An account can be archived only when it is no longer used for new entries; historical entries retain it.

### Required account fields

| Field | Purpose |
| --- | --- |
| `id` | Stable internal identifier |
| `book_id` | Isolation boundary |
| `code` | Sortable account number unique within a book |
| `name` | User-visible account name |
| `type` | Asset, liability, equity, income, or expense |
| `subtype` | More precise behavior, such as bank, mortgage, or rental income |
| `parent_account_id` | Optional hierarchy |
| `system_role` | Optional stable behavior key used by workflows |
| `tax_mapping_id` | Optional mapping to a versioned tax-report category |
| `property_tracking` | Required, optional, or prohibited on journal lines |
| `is_system` | Prevents unsafe type or role changes |
| `is_active` | Controls availability for new entries |

Account codes are defaults for organization, not hard-coded business logic. Workflows use `system_role` and account type.

## 3. Default chart of accounts

The setup flow creates the accounts marked **Core**. Accounts marked **Optional** appear as suggested additions or are created when the related feature is enabled.

### Assets

| Code | Account | Availability | Use |
| --- | --- | --- | --- |
| 1000 | Cash and bank accounts | Header | Parent for connected or manually tracked cash accounts |
| 1010 | Operating checking | Core | Primary rental operating account; user may rename it |
| 1020 | Reserve savings | Optional | Cash reserves |
| 1030 | Security deposit bank account | Optional | Cash held separately for tenant deposits |
| 1100 | Accounts receivable | Future | General-ledger receivables when accrual accounting is supported |
| 1200 | Prepaid expenses | Optional | Costs paid before the covered period |
| 1300 | Mortgage escrow | Optional | Amount held by a lender for future tax and insurance payments |
| 1400 | Rental property assets | Header | Parent for property basis accounts |
| 1410 | Land | Core | Non-depreciable land basis |
| 1420 | Buildings | Core | Building basis |
| 1430 | Capital improvements | Core | Capitalized improvements by property |
| 1440 | Appliances, furniture, and equipment | Optional | Separately tracked depreciable property |
| 1450 | Financing and acquisition costs | Optional | Capitalized costs pending accountant treatment |
| 1490 | Accumulated depreciation | Core | Contra-asset for recorded depreciation |
| 1500 | Other assets and deposits | Optional | Utility deposits and similar recoverable amounts |

The MVP records asset cost, basis-related facts, and accountant-provided depreciation entries. It does not calculate tax depreciation.

### Liabilities

| Code | Account | Availability | Use |
| --- | --- | --- | --- |
| 2000 | Credit cards | Optional | Parent for each card account |
| 2100 | Accounts payable | Future | Vendor obligations when accrual accounting is supported |
| 2200 | Tenant security deposits held | Core | Refundable deposits owed to tenants |
| 2300 | Prepaid or unearned rent | Optional | Financial-reporting treatment when specifically directed; cash-basis tax reports still require the appropriate income adjustment |
| 2400 | Mortgage loans payable | Core | Parent for each property loan's principal balance |
| 2500 | Other loans payable | Optional | Lines of credit and non-mortgage debt |
| 2600 | Due to owner | Optional | Owner-paid business costs to be reimbursed |

### Equity

| Code | Account | Availability | Use |
| --- | --- | --- | --- |
| 3000 | Opening balance equity | Core | Setup entries; should be reviewed and cleared when appropriate |
| 3100 | Owner contributions | Core | Cash or assets contributed by the owner |
| 3200 | Owner draws and distributions | Core | Contra-equity for cash or property taken out by the owner |
| 3300 | Retained earnings | System | Prior-period cumulative earnings |
| 3400 | Current-year earnings | System | Report-calculated current-period result; users do not post directly |

### Income

Schedule E reports rents and related rental income together on line 3, but separate ledger accounts preserve useful detail.

| Code | Account | Tax mapping | Availability |
| --- | --- | --- | --- |
| 4000 | Rental income | Schedule E line 3 | Header |
| 4010 | Base rent | Schedule E line 3 | Core |
| 4020 | Late fees | Schedule E line 3 | Core |
| 4030 | Lease termination and cancellation fees | Schedule E line 3 | Optional |
| 4040 | Tenant-paid owner expenses | Schedule E line 3 | Optional |
| 4050 | Retained security deposits | Schedule E line 3 | Core |
| 4060 | Parking, laundry, pet, and amenity income | Schedule E line 3 | Optional |
| 4070 | Tenant reimbursements | Schedule E line 3 | Core |
| 4090 | Other rental income | Schedule E line 3 | Core |

Refundable security deposits initially credit the liability account, not income. A retained portion becomes income only when the facts support retention, with any related repair expense recorded separately.

### Expenses

The primary expense accounts follow the Schedule E categories so a landlord can recognize them and produce a useful tax-organizer report. Subaccounts add operational detail without changing the Schedule E rollup.

| Code | Account | Suggested subaccounts | Tax mapping | Availability |
| --- | --- | --- | --- | --- |
| 5000 | Advertising | Listings, signs, photography | Line 5 | Core |
| 5100 | Auto and travel | Mileage, parking and tolls, lodging | Line 6 | Core |
| 5200 | Cleaning and maintenance | Cleaning, lawn care, pest control, snow removal, routine servicing | Line 7 | Core |
| 5300 | Commissions | Leasing and referral commissions | Line 8 | Core |
| 5400 | Insurance | Landlord policy, liability, flood, umbrella allocation | Line 9 | Core |
| 5500 | Legal and professional fees | Legal, accounting, bookkeeping | Line 10 | Core |
| 5600 | Management fees | Property management fees | Line 11 | Core |
| 5700 | Mortgage interest paid to financial institutions | Interest from lender statements | Line 12 | Core |
| 5800 | Other interest | Private loans and other rental debt | Line 13 | Core |
| 5900 | Repairs | Plumbing, electrical, locks, patching, minor repairs | Line 14 | Core |
| 6000 | Supplies | Hardware, consumables, small operating supplies | Line 15 | Core |
| 6100 | Taxes | Real estate and other deductible rental taxes | Line 16 | Core |
| 6200 | Utilities | Electricity, gas, water and sewer, trash, rental-related phone or internet | Line 17 | Core |
| 6300 | Depreciation expense | Accountant-provided building, improvement, appliance, and equipment depreciation | Line 18 | Core |
| 6400 | Other rental expenses | Schedule E line 19 detail | Header |
| 6410 | HOA and condominium dues | HOA and condo dues | Line 19 | Core |
| 6420 | Bank and payment fees | Account and processing fees | Line 19 | Core |
| 6430 | Licenses and permits | Rental registration and inspection fees | Line 19 | Core |
| 6440 | Office and software | Postage, software, and allocable office costs | Line 19 | Optional |
| 6450 | Education and memberships | Rental-related education and associations | Line 19 | Optional |
| 6460 | Eviction and court costs | Filing and service costs distinct from legal fees | Line 19 | Optional |
| 6490 | Other rental expense | Uncommon items requiring a clear memo | Line 19 | Core |

### Review and non-reporting accounts

| Code | Account | Type | Use |
| --- | --- | --- | --- |
| 7000 | Personal or nondeductible expense | Expense | Keeps non-rental spending out of Schedule E reports while preserving reconciliation |
| 7900 | Ask my accountant | Expense | Temporary classification that is excluded from tax-ready status |
| 9990 | Opening balance differences | Equity | Temporary setup difference requiring resolution |

Imported rows remain unposted until categorized, so terramanage does not need a permanent “uncategorized expense” account. Reports show unposted imported rows as unresolved work rather than financial activity.

## 4. Tax mapping model

The chart of accounts and tax form are related but must not be the same data structure. Tax forms change over time, custom accounts need mappings, and accountant adjustments may differ from the bookkeeping presentation.

Track these records:

### `tax_form_version`

- Form family, initially `US_SCHEDULE_E`
- Tax year
- Effective dates
- Source URL
- Publication status

### `tax_category`

- Stable internal key, such as `schedule_e_repairs`
- Form version
- Line identifier and label
- Income or expense classification
- Display order
- Whether property-level reporting is required

### `account_tax_mapping`

- Account
- Tax category
- Effective tax year range
- Optional accountant note
- Mapping status: default, user-confirmed, or accountant-confirmed

Tax-oriented reports should flag transactions in `Ask my accountant`, missing property assignments, personal-use allocations, and unmapped accounts as unresolved instead of silently including them.

## 5. Dimensions carried on financial activity

An account answers **what** the transaction is. Dimensions answer **where and for whom** it occurred.

| Dimension | Rule |
| --- | --- |
| Book | Required on every record and inherited by all relationships |
| Property | Required for rental income, rental expenses, fixed assets, depreciation, and property debt activity |
| Unit | Optional; available only when it belongs to the selected property |
| Lease | Optional on journal lines; required on rent payments and deposit activity tied to a lease |
| Tenant | Derived through the lease for rent activity; avoid duplicating it inconsistently on ledger lines |
| Payee | Optional on an entry and import; useful for search and rules |
| Vendor | A party role attached to a payee; needed for later 1099 workflows |
| Loan | Required for mortgage principal and loan-specific interest workflows |
| Capital asset | Required when posting to a depreciable asset account |

Property is stored at journal-line level so one payment can be split across several properties. A unit is never allowed without a property.

## 6. Core data to track

### Identity and book

#### `user`

- ID, email, display name, authentication identity, status, timestamps

#### `book`

- ID, display name, legal or reporting name
- Entity type: individual, single-member LLC, partnership, corporation, trust, or other
- Default time zone and fiscal-year start
- Currency fixed to USD for the MVP
- Accounting basis fixed to cash for the MVP
- Tax profile flags: Schedule E expected, qualified joint venture if applicable
- Status and timestamps

Do not require an SSN or EIN for the MVP. It is unnecessary for bookkeeping and increases security risk.

#### `book_membership`

- User, book, role, invitation state, created date
- MVP roles: owner and read-only accountant

### Property and unit

#### `property`

- ID, book ID, display name
- Street, unit or suite, city, state, ZIP code, county
- Property type using Schedule E-compatible choices: single-family, multi-family, vacation or short-term, commercial, land, self-rental, other
- Acquisition date and price
- Land allocation and building allocation
- Placed-in-service date
- Disposal date and status
- Ownership percentage for reporting, default 100%
- Fair-rental days and personal-use days by tax year
- Default income and expense allocation settings
- Notes

The initial product is designed for long-term residential rentals, but compatible property-type values avoid a migration merely to render a Schedule E organizer.

#### `unit`

- ID, property ID, name or number
- Bedrooms and bathrooms as optional descriptive fields
- Active status

Operational property-management details such as amenities, listing copy, and access codes are outside the accounting MVP.

### Parties

Use one `party` model with roles so the same person or business can be a tenant, vendor, lender, or other payee.

#### `party`

- ID, book ID, party type: person or organization
- Display name and legal name
- Email, phone, and mailing address
- Roles: tenant, vendor, lender, payee, owner
- Tax information status only: not requested, requested, received, not required
- Optional notes and archived status

Do not store full taxpayer identification numbers in the MVP. A later 1099 feature requires a dedicated encrypted design and access policy.

### Leases and tenant subledger

#### `lease`

- ID, book ID, property ID, unit ID
- Lease status, start date, end date, move-in date, move-out date
- Rent amount, frequency, due day, first due date
- Security deposit required
- Late-fee terms as descriptive data; automatic assessment is deferred
- Tenant parties and optional responsibility percentages
- Notes and document links

#### `rent_charge`

- Lease, charge type, service period, due date
- Original amount, remaining amount, status
- Source: recurring schedule, manual charge, credit, or adjustment
- Description and timestamps

Charge types include base rent, late fee, utility reimbursement, pet or parking charge, other charge, credit, and write-off. On cash basis, these records do not post to the general ledger.

#### `tenant_payment`

- Lease, received date, amount, payment method, reference
- Deposit account
- Undeposited status if needed later
- Journal entry ID
- Reversal status and reason

#### `payment_application`

- Payment, charge, amount, application date
- Default allocation is oldest due charge first; the user can edit it

Tenant balance equals posted charges and credits less payment applications. General-ledger cash and income totals come from the payment's journal entry.

### General ledger

#### `journal_entry`

- ID, book ID, transaction date, status: draft, posted, voided, reversed
- Entry type: income, expense, transfer, contribution, draw, mortgage payment, deposit, refund, adjustment, opening balance
- Source type and source ID
- Payee, memo, reference number
- Created by, posted by, posted timestamp
- Reversal entry ID and audit reason

#### `journal_line`

- Journal entry, account
- Debit amount or credit amount in integer cents; exactly one is positive
- Property, unit, lease, loan, and capital asset dimensions as applicable
- Line memo

Posting constraints:

- Total debits equal total credits
- Posted entries have at least two lines
- All related records belong to the same book
- Property and unit rules are satisfied
- Posted monetary lines cannot be updated in place
- A void or correction produces an auditable reversal

### Banking and imports

#### `financial_account`

- Ledger account ID
- Institution and user-visible account name
- Account kind: checking, savings, credit card, cash, or other
- Last four digits only
- Opening balance and as-of date
- Active status

#### `import_batch`

- Financial account, source file name and checksum
- Imported by and timestamps
- CSV mapping version
- Counts by state: new, matched, excluded, posted, and error

#### `imported_transaction`

- Immutable raw row payload
- Normalized posted date, optional transaction date, amount, description, reference
- Stable fingerprint for duplicate detection
- State: pending, matched, excluded, or posted
- Match confidence and linked journal entry

#### `categorization_rule`

- Book, priority, active status
- Conditions on financial account, description, amount range, or transaction direction
- Suggested payee, account, property, unit, and split template
- Application mode: suggest only for the MVP

Rules should suggest classifications initially. Automatic posting can be added after confidence and undo behavior are proven.

### Reconciliation

#### `reconciliation`

- Financial account
- Statement start and end dates
- Starting and ending statement balances
- Status: in progress, completed, or reopened
- Calculated cleared balance and difference
- Completed by and completed timestamp
- Reopen reason and audit event

#### `reconciliation_line`

- Reconciliation and journal line
- Cleared amount and cleared status

A completed reconciliation requires a zero difference. Reopening requires a reason. Changes to reconciled entries show a visible warning and affect the reconciliation history.

### Loans

#### `loan`

- Property and liability account
- Lender party
- Original principal, origination date, maturity date
- Current interest rate as optional reference data
- Payment frequency and optional expected payment
- Optional escrow asset account
- Statement balance and as-of date

The MVP does not generate amortization schedules. The user splits each payment or saves a reusable split, then reconciles principal to the lender statement.

### Capital assets

#### `capital_asset`

- Property and optional unit
- Name, description, asset class
- Acquisition date, placed-in-service date, cost, and land portion if relevant
- Source journal lines
- Disposed date and proceeds when applicable
- Accountant-provided tax basis and accumulated depreciation
- Status and notes

Depreciation method, recovery period, convention, bonus depreciation, and Section 179 fields may be stored later when terramanage calculates depreciation. For the MVP, users record accountant-provided depreciation entries and preserve supporting documents.

### Files and audit

#### `document`

- Book, storage key, original file name, media type, byte size, checksum
- Uploaded by and timestamp
- Document type: receipt, invoice, bank statement, lease, closing statement, tax document, loan statement, or other
- Document date and optional note

Documents link to one or more properties, transactions, reconciliations, leases, loans, or capital assets through typed links.

#### `audit_event`

- Book, actor, timestamp
- Action and record type or ID
- Before and after summaries for material fields
- Reason when required
- Request or correlation ID

Audit events are required for posting, reversing, voiding, reconciliation completion or reopening, account mapping changes, role changes, and exports.

## 7. Posting rules for common landlord activity

The debit and credit columns below describe the entries created by user workflows.

| User action | Debit | Credit | Required context |
| --- | --- | --- | --- |
| Receive base rent | Operating bank | Base rent income | Property, lease, received date |
| Receive a refundable security deposit | Security deposit bank or operating bank | Tenant security deposits held | Property and lease |
| Refund a security deposit | Tenant security deposits held | Bank | Property and lease |
| Retain deposit for damage | Tenant security deposits held | Retained security deposits income | Property and lease; separate repair entry if paid |
| Pay a repair | Repairs expense | Bank or credit card | Property, payee |
| Buy supplies on a credit card | Supplies expense | Credit card liability | Property, payee |
| Pay credit-card bill | Credit card liability | Bank | No income or expense line |
| Make owner contribution | Bank or contributed asset | Owner contributions | Owner and optional property |
| Take owner draw | Owner draws | Bank | Owner |
| Transfer between bank accounts | Destination bank | Source bank | Transfer link; no income or expense |
| Pay mortgage | Mortgage principal, mortgage interest, mortgage escrow as applicable | Bank | Property and loan |
| Lender pays property tax from escrow | Taxes expense | Mortgage escrow | Property and loan statement |
| Purchase capital improvement | Capital improvements asset | Bank, card, or loan | Property and capital asset |
| Record depreciation supplied by accountant | Depreciation expense | Accumulated depreciation | Property and capital asset |
| Tenant reimburses a utility | Bank | Tenant reimbursements income | Property and lease |
| Pay the reimbursed utility bill | Utilities expense | Bank or card | Property and payee |
| Owner personally pays a rental expense | Relevant expense | Due to owner or owner contributions | Property, owner, payee |
| Refund rent to tenant | Relevant rental income as debit | Bank | Property and lease |

Mortgage payment entry is a guided split. Principal reduces the liability, interest records expense, escrow increases the escrow asset, and fees use their appropriate expense account. The entire payment must equal the bank withdrawal.

## 8. Report definitions

### Profit and loss

- Source: posted income and expense journal lines
- Filters: date range, property, unit, account, cash basis
- Grouping: chart hierarchy
- Comparative option: properties as columns
- Excludes balance-sheet transfers, contributions, draws, loan principal, and asset purchases

### Balance sheet

- Source: all posted asset, liability, and equity journal lines through an as-of date
- Scope: book, with optional property dimension where meaningful
- Current-year earnings calculated from income less expenses

### Schedule E organizer

- Groups posted activity by property and versioned Schedule E mapping
- Includes property address, property type, fair-rental days, personal-use days, and ownership percentage
- Flags unmapped accounts, personal-use allocations, unresolved review accounts, and missing property dimensions
- Is labeled as an organizer or draft report, not a filed tax form

### Rent roll and tenant balance

- Source: leases, rent charges, credits, payments, and applications
- Shows unit, tenant, lease dates, recurring rent, charges, paid amount, balance, and aging
- Reconciles payment totals to linked posted journal entries

### Security deposit detail

- Source: deposit-related tenant activity and journal entries
- Shows deposits received, amounts retained, refunds, and remaining liability by lease
- Total must reconcile to the security-deposit liability account

### Loan balance detail

- Source: loan principal journal lines
- Shows beginning balance, principal increases, principal payments, and ending book balance
- Compares against the most recent statement balance when entered

## 9. Data quality and close checks

A book is “ready to close” for a period only when:

- All imported rows are matched, posted, or explicitly excluded
- Posted entries are balanced
- Rental income and expense lines have a property
- Unit assignments belong to the selected property
- Tenant payments link to posted journal entries
- Tenant deposit detail reconciles to the deposit liability
- Financial accounts are reconciled or explicitly marked as not required
- `Ask my accountant` and opening-difference accounts have zero balance or acknowledged exceptions
- Tax-mapped reports have no unmapped activity
- Entries changed after reconciliation are reviewed

## 10. Data intentionally excluded from the MVP

- Bank login credentials or live bank tokens
- Rent collection credentials or payment instruments
- Tenant portals and tenant authentication
- Full SSNs, EINs, or vendor taxpayer identification numbers
- Tax return filing data beyond report mappings
- Automated depreciation calculations
- Formal trust-accounting ledgers for third-party property managers
- Property listing, maintenance ticket, inspection, and screening data

## 11. Recommended implementation order

1. Book, membership, and strict book-scoped data access
2. Chart of accounts and versioned default chart template
3. Property, unit, party, and financial account records
4. Journal entry and journal line posting engine
5. Manual income, expense, transfer, contribution, and draw workflows
6. Profit-and-loss, balance-sheet, and general-ledger reports
7. Lease, rent charge, payment, and payment application subledger
8. Security-deposit workflow and reconciliation report
9. CSV import, matching, categorization, and bank reconciliation
10. Loans, guided mortgage splits, capital assets, and tax-organizer reporting

## 12. Acceptance examples for the accounting engine

Before building broader UI, automated scenarios should prove that:

- A $1,500 rent receipt increases bank and rental income by $1,500
- A $1,500 unpaid rent charge changes the tenant balance but not cash-basis income
- A $2,000 refundable deposit increases bank and deposit liability without changing income
- Retaining $300 of a deposit reduces the liability and records $300 of rental income
- A $1,400 mortgage payment split into $500 principal, $700 interest, and $200 escrow reduces cash by exactly $1,400
- A credit-card expense affects profit when purchased; paying the card changes only balance-sheet accounts
- A bank transfer never appears as income or expense
- A $6,000 new HVAC system can be posted to a capital asset rather than repairs expense
- A split expense across two properties appears in each property's report and agrees to the bank amount
- Entries and reports from one book cannot be accessed with another book's membership

## Sources used for the tax-oriented structure

- [IRS 2025 Schedule E](https://www.irs.gov/pub/irs-pdf/f1040se.pdf)
- [IRS 2025 Instructions for Schedule E](https://www.irs.gov/instructions/i1040se)
- [IRS Publication 527 (2025), Residential Rental Property](https://www.irs.gov/publications/p527)

These sources inform the default categories and recordkeeping fields. terramanage should version tax mappings by tax year and present the Schedule E report as an organizer because a user's final tax treatment can depend on facts outside the bookkeeping system.
