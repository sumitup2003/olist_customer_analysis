import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

url = URL.create(
    drivername="mysql+pymysql",
    username="root",
    password="Sumit@2907",
    host="localhost",
    port=3306,
    database="olist_ecommerce"
)

engine = create_engine(url)

# folder where all your CSVs live
folder = r"C:\Users\sumit\olist_ecommerce\\"

# map: csv filename -> table name (must match tables already created in MySQL)
files_to_load = {
    "olist_customers_dataset.csv": "olist_customers_dataset",
    "olist_orders_dataset.csv": "olist_orders_dataset",
    "olist_order_items_dataset.csv": "olist_order_items_dataset",
    "olist_order_payments_dataset.csv": "olist_order_payments_dataset",
    "olist_order_reviews_dataset.csv": "olist_order_reviews_dataset",
    "olist_products_dataset.csv": "olist_products_dataset",
    "olist_sellers_dataset.csv": "olist_sellers_dataset",
    "olist_geolocation_dataset.csv": "olist_geolocation_dataset",
    "product_category_name_translation.csv": "product_category_name_translation",
}

for csv_file, table_name in files_to_load.items():
    if table_name == "olist_customers_dataset":
        print(f"Skipping {table_name} — already loaded")
        continue

    print(f"Loading {csv_file} -> {table_name} ...")
    df = pd.read_csv(folder + csv_file)

    # geolocation is ~1M rows — load it in chunks so it doesn't choke
    if table_name == "olist_geolocation_dataset":
        df.to_sql(name=table_name, con=engine, if_exists="append", index=False, chunksize=50000)
    else:
        df.to_sql(name=table_name, con=engine, if_exists="append", index=False)

    print(f"  Done: {len(df):,} rows loaded")

print("\nAll files processed.")