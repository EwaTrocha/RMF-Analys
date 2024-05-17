# Recency Frequency Monetary Analysis 
Dashboard created for this analys can be found here [Tableu Dashboard](https://public.tableau.com/views/RMF_Analys/Dashboard1?:language=en-GB&:sid=&:display_count=n&:origin=viz_share_link)

This project involves conducting RFM (Recency, Frequency, Monetary) analysis and customer segmentation based on the provided dataset.

The dataset contains information on customer transactions, including their ID, purchase dates, quantity, and monetary value. The goal is to analyze customer behavior and segment them based on RFM metrics.

## Steps

### Step 1: Data Preparation and RFM Analysis

- Identified necessary columns for RFM Analysis.
- Filtered transactions for the time span from 2010-12-01 to 2011-12-01.
- Excluded transactions with null CustomerID, likely indicating purchases made without creating an account.
- Calculated RFM measures: Frequency, Monetary, and Recency.
- Validated the number of distinct customers.

### Step 2: Determining Quartiles

- Calculated quartiles for Recency, Frequency, and Monetary.
- Compared calculated quartiles with provided values, identifying discrepancies, especially in Monetary quartiles.

### Step 3: Assigning Scores for RFM Metrics

- Assigned scores from 1 to 4 for each RFM metric based on quartiles.
- Compared the number of customers for certain RFM scores with the provided table, acknowledging differences due to monetary values.

### Step 4: Segmenting Customers

- Segmented customers into 7 groups based on RFM scores.
- Created customer segments: Champions, Loyal Customers, Potential Loyalists, Recent Customers, Promising, Customers Needing Attention, Lost.

### Step 5: Final Data Selection

- Selected all relevant columns for the final analysis table.
- Added information on the latest country of purchase.

### Step 6: Visualization and Insights

- Connected the analysis table to Tableau for visualization.
- Derived insights for customer engagement and retention strategies based on RFM segments.
