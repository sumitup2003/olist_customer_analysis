Olist E-Commerce Analytics: Revenue & Seller Performance

An end-to-end data analytics project analyzing 110K+ orders from Olist, a Brazilian e-commerce marketplace, to uncover revenue concentration risk, customer retention gaps, and the business impact of delivery performance.

Tools used: MySQL · Excel · Python · Groq LLM (AI) · Power BI

Business Problem

Olist connects small sellers to major online marketplaces. Leadership needs to understand two things: which sellers the business is financially dependent on (and whether that's risky), and which customers are at risk of churning. This project answers both, using revenue, seller performance, and customer segmentation as the analytical spine, with delivery reliability investigated as a likely driver of both.

Architecture

Each tool plays a distinct role in one continuous pipeline — not five disconnected exercises:

Stage	Tool	Role
Data ingestion & modeling	MySQL	Loaded 9 raw CSVs (~1.5M rows) via a Python/SQLAlchemy ETL script, cleaned data types, added primary/foreign keys, wrote advanced queries (CTEs, window functions) for revenue trends, RFM segmentation, and seller scoring
Quick-look reporting	Excel	Pivot tables and formula-driven KPI summary sheet, replicating SQL segmentation logic independently for cross-validation
Deeper analysis	Python (pandas, scipy, seaborn)	EDA, delivery-delay distribution analysis, and a statistical t-test quantifying the link between delivery lateness and review scores
Insight generation	Groq LLM (Llama 3.3 70B)	Generated a natural-language executive summary grounded strictly in validated findings (not raw data), reducing hallucination risk
Executive dashboard	Power BI	Star-schema data model (fact/dimension tables, custom date dimension) powering three interactive report pages
Key Findings
41% of total revenue is concentrated in "High Revenue – At Risk" sellers — top-quartile revenue sellers with weak reviews or poor on-time delivery. The business is financially dependent on sellers who could churn or underperform with little warning.
39% of customers fall into "Lost" or "At Risk" RFM segments, against 21% "Champions" — signaling a real retention problem, not just an acquisition one.
Late deliveries are associated with a 1.66-point drop in average review score (4.21 vs 2.55 out of 5, p < 0.0001, n = 110,013) — statistically significant, not random noise.
Actual delivery times run ~12 days earlier than estimated, on average, across every top product category — Olist's delivery estimates appear conservatively padded, which may understate the platform's real speed to customers.
7.9% of delivered orders arrive after the estimated date — a relatively small share, but one with an outsized effect on satisfaction.
Data Quality Decisions

Documented explicitly, since they shape every downstream number:

Revenue is standardized to "delivered orders only" across every tool (SQL, Excel, Python, Power BI). Cancelled/unfulfilled order value is excluded. This was enforced after a real bug was found and fixed mid-project — see below.
Pilot-phase data (Sep 2016–Jan 2017) is excluded from trend analysis. These months contain fewer than 10 orders total and produce misleading growth percentages (one month showed 1,000,000%+ "growth").
The final partial month (Sep 2018) is excluded from trend charts, since Olist's data collection tapers off mid-month, creating an artificial cliff in revenue.
"Profitability" is a documented proxy, not a real figure. The public dataset has no seller cost-of-goods or Olist's actual commission schedule, so an assumed 16–18% platform take rate is used and explicitly labeled as an assumption, not fact.
customer_unique_id is used for all customer-level analysis, not customer_id. In this dataset, customer_id is generated per order, not per person — using it directly would make every repeat customer look like a one-time buyer.

A real bug worth mentioning: during development, seller-level revenue (13.59M) and order-level revenue (13.22M) disagreed by ~370K, traced to one query missing the delivered-only filter that every other query already had. Fixing it and standardizing the filter across all five tools is the kind of consistency check that's easy to skip under time pressure — documenting it here on purpose.

Dashboard Preview

(Add screenshots here: Executive Overview, Seller Performance, Customer Segmentation pages)

How to Run This Project
Database: Install MySQL, create a database, run the loader script (python/load_to_mysql.py) to ingest the 9 raw CSVs, then run the ALTER TABLE scripts to set correct types/keys.
SQL: Run the queries in sql/ for revenue trends, seller performance, and RFM segmentation. Export results to CSV.
Excel: Open excel/olist_ecommerce_analysis.xlsx — raw sheets, pivot tables, and Summary dashboard are pre-built from the SQL exports above.
Python: Open python/analysis.ipynb in a virtual environment (pip install pandas sqlalchemy pymysql matplotlib seaborn scipy). Update the MySQL connection string and run all cells.
AI Summary: Set a GROQ_API_KEY environment variable (or .env file), run the summary-generation cell in the notebook.
Power BI: Open powerbi/olist_dashboard.pbix, update the MySQL data source credentials under Transform Data, refresh.
What I'd Improve With More Time
Formal cohort retention analysis (do customers who bought in month N return in month N+1, N+2...)
Sentiment analysis on review text (NLP) to complement the star-rating analysis
Seller-level forecasting for revenue trend projection
