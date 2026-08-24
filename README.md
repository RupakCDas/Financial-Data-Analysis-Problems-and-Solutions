# Financial/Business-Data Analysis Problems and Solutions
- PROBLEM 1: Transaction Fraud Detection
- PROBLEM 2:  Customer Churn & Revenue Retention Tracking
- PROBLEM 3: E-Commerce Customer Churn Analysis.
- PROBLEM 4: Making Snowflake Schema Data Model.
- PROBLEM 5: E-Commerce Cart Abandonment Analysis.
- PROBLEM 6: Airbnb Data Analysis Using Python.
## PROBLEM 1 : Transaction Fraud Detection

Fraud Detection is used daily by every bank and FinTech. Data analysts collect transactional data from credit card records, account history, user behavior, and device information to build fraud detection systems. 
The SQL covers 5 distinct rule types: velocity attacks (bots test cards in rapid bursts), geographic anomalies, statistical outliers via Z-score, dormant account reactivation, and AML structuring. 

Real-world context: Banks & FinTechs (Wells Fargo, Stripe, PayPal) lose billions annually to fraudulent transactions.

### Task to Solution: Identify suspicious patterns from raw transaction data.

#### PATTERN 1: Velocity check — 5+ transactions within 10 minutes.
Real-world use: Card testing attacks; bots run small transactions quickly. Assuming 5+ transactions in 10 minutes.

#### PATTERN 2: Geographic anomaly — transaction outside home country. 
Real-world case: Account always transacts in US, suddenly appears in other country. 

#### PATTERN 3: Amount Z-score > 2 . Standard Deviation above average.
Real-world: Single large unauthorized transaction after account compromise. Assuming Z score > 2 are suspicious.

#### PATTERN 4: Dormant account suddenly active.
Real-world: Stolen credentials. Assuming account dormant 90+ days, then big purchase.

#### PATTERN 5: Non round-number structuring.
Real-world: Deposits just below $10K to avoid bank reporting threshold. And assuming transaction type 'deposit' or'transfer'.

#### FRAUD MEASURING SCORE: Combine all rules.
Approach: union all rule flags into a risk score per account or transaction.


## PROBLEM 2 :  Customer Churn & Revenue Retention Tracking
The SQL builds cohort retention tables, MRR movement (new/expansion/contraction/churn), and a churn early-warning system. 

#### TASK 1: MRR Movement — New / Expansion / Contraction / Churn 
Real-world: Company tracks this every month to understand revenue health


## PROBLEM 3: E-Commerce Customer Churn Analysis.

Losing customers means losing revenue, and it's less expensive to retain existing customers than acquiring new ones.

BUSINESS COMPLAINT:

16.8% of our customers churned last quarter. We don't know who will churn next, or why they're leaving.

#### TASK 1: Confirm churn rate & segment by profile
Which customer types are churning most? Which customers to target with retention offers BEFORE they churn?

#### TASK 2: RFM Segmentation to find at-risk customers
Recency + Frequency + Monetary — the classic retention model.

## PROBLEM 4: Making Snowflake Schema Data Model.

This is a well-structured Snowflake Schema designed for a  banking  services data warehouse. It separates descriptive context (Dimension tables, prefixed with dim_) from quantitative measurements (Fact tables, prefixed with fact_).

#### Requirements Gathering & Business Understanding
Before touching any data, I had to define what the business needs to track. In this model, the business objectives are clear:

Core Entities: Customers, accounts, branches, employees, loans, and credit cards.

Key Activities (Facts): Financial transactions, card purchases, loan payments, and customer support interactions.

#### Defining Dimension Tables:
These tables contain descriptive, textual attributes used for filtering and slicing data.

customers, branches, employees, loans, cards, and accounts are defined here as dimension tables.

#### Defining Fact Tables:
These tables contain quantitative metrics (numerical values that can aggregate) and foreign keys connecting back to the dimensions. Usually very large in size.

transactions, card_transactions, loan_payments, and support_tickets are defined here as dimension tables.

<img width="683" height="328" alt="5" src="https://github.com/user-attachments/assets/82a3f150-010e-402d-bc1a-73471ef6c261" />


## PROBLEM 5: E-Commerce Cart Abandonment Analysis.


