# =============================================
# SUPPLY CHAIN MEDALLION ARCHITECTURE
# Microsoft Fabric | PySpark
# Author: Sandip Pokhrel
# Dataset: DataCo Supply Chain (180,519 rows)
# =============================================

# Import all PySpark functions
from pyspark.sql.functions import *
from pyspark.sql.types import *

# =============================================
# BRONZE LAYER — Raw data in OneLake
# Files/Rawdata/DataCoSupplyChainDataset.csv
# =============================================

df = spark.read.option("header", "true") \
               .option("inferSchema", "true") \
               .csv("Files/Rawdata/DataCoSupplyChainDataset.csv")

print(f"Bronze — Total rows: {df.count()}")
print(f"Bronze — Total columns: {len(df.columns)}")

# =============================================
# SILVER LAYER — Clean and Transform
# =============================================

# Step 1: Clean column names (remove spaces and special characters)
def clean_column_name(name):
    return name.replace(" ", "_") \
               .replace("(", "") \
               .replace(")", "") \
               .replace("/", "_")

for col_name in df.columns:
    df = df.withColumnRenamed(col_name, clean_column_name(col_name))

# Step 2: Fix date columns to proper timestamps
df = df.withColumn("Order_Date", to_timestamp("order_date_DateOrders", "M/d/yyyy H:mm")) \
       .withColumn("Shipping_Date", to_timestamp("shipping_date_DateOrders", "M/d/yyyy H:mm"))

# Step 3: Drop unnecessary columns
df = df.drop("Customer_Password", "Product_Description", "Product_Image",
             "order_date_DateOrders", "shipping_date_DateOrders")

print(f"Silver — Total rows: {df.count()}")
print(f"Silver — Total columns: {len(df.columns)}")

# Step 4: Save as Silver Delta table
df.write.format("delta") \
        .mode("overwrite") \
        .saveAsTable("silver_supply_chain")

print("Silver table saved successfully!")

# =============================================
# GOLD LAYER — Business Ready Aggregations
# =============================================

# Gold Table 1: Sales and Profit by Market
gold_sales_market = df.groupBy("Market") \
    .agg(
        count("Order_Id").alias("Total_Orders"),
        round(sum("Sales"), 2).alias("Total_Sales"),
        round(sum("Order_Profit_Per_Order"), 2).alias("Total_Profit"),
        round(avg("Order_Profit_Per_Order"), 2).alias("Avg_Profit_Per_Order")
    ).orderBy("Total_Sales", ascending=False)

gold_sales_market.write.format("delta") \
                 .mode("overwrite") \
                 .saveAsTable("gold_sales_by_market")

# Gold Table 2: Late Delivery Analysis by Shipping Mode
gold_delivery = df.groupBy("Shipping_Mode") \
    .agg(
        count("Order_Id").alias("Total_Orders"),
        count(when(col("Delivery_Status") == "Late delivery", 1)).alias("Late_Orders"),
        round(avg("Days_for_shipping_real"), 2).alias("Avg_Actual_Days"),
        round(avg("Days_for_shipment_scheduled"), 2).alias("Avg_Scheduled_Days")
    ).orderBy("Late_Orders", ascending=False)

gold_delivery.write.format("delta") \
             .mode("overwrite") \
             .saveAsTable("gold_delivery_by_shipping")

print("Gold tables saved successfully!")

# =============================================
# RESULTS SUMMARY
# =============================================
print("\n--- Gold Table 1: Sales by Market ---")
gold_sales_market.show()

print("\n--- Gold Table 2: Delivery by Shipping Mode ---")
gold_delivery.show()
