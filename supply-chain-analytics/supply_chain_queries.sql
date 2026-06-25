

SELECT 
    [Type],
    [Market],
    [Order Status],
    [Sales],
    [Order Profit Per Order]
FROM Staging_SupplyChain
WHERE [Order Status] = 'COMPLETE'

-- 2. GROUP BY with aggregates
SELECT 
    [Market],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales,
    SUM(CAST([Order Profit Per Order] AS FLOAT)) AS Total_Profit
FROM Staging_SupplyChain
WHERE [Order Status] = 'COMPLETE'
GROUP BY [Market]
ORDER BY Total_Sales DESC

-- 3. AVG profit per order by market
SELECT 
    [Market],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales,
    SUM(CAST([Order Profit Per Order] AS FLOAT)) AS Total_Profit,
    AVG(CAST([Order Profit Per Order] AS FLOAT)) AS Avg_Profit_Per_Order
FROM Staging_SupplyChain
GROUP BY [Market]
ORDER BY Avg_Profit_Per_Order DESC

-- 4. CASE statement
SELECT 
    [Market],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales,
    CASE 
        WHEN SUM(CAST([Sales] AS FLOAT)) > 10000000 THEN 'High'
        WHEN SUM(CAST([Sales] AS FLOAT)) > 5000000 THEN 'Medium'
        ELSE 'Low'
    END AS Sales_Category
FROM Staging_SupplyChain
GROUP BY [Market]
ORDER BY Total_Sales DESC

-- 5. CTE with JOIN
WITH OrderSummary AS (
    SELECT 
        [Order Id],
        [Market],
        [Order Status],
        SUM(CAST([Sales] AS FLOAT)) AS Total_Sales
    FROM Staging_SupplyChain
    GROUP BY [Order Id], [Market], [Order Status]
),
ProfitSummary AS (
    SELECT 
        [Order Id],
        SUM(CAST([Order Profit Per Order] AS FLOAT)) AS Total_Profit
    FROM Staging_SupplyChain
    GROUP BY [Order Id]
)
SELECT 
    o.[Order Id],
    o.[Market],
    o.[Order Status],
    o.Total_Sales,
    p.Total_Profit
FROM OrderSummary o
JOIN ProfitSummary p ON o.[Order Id] = p.[Order Id]
ORDER BY Total_Sales DESC

-- 6. Window functions
SELECT 
    [Market],
    [Order Id],
    CAST([Sales] AS FLOAT) AS Sales,
    SUM(CAST([Sales] AS FLOAT)) OVER (PARTITION BY [Market]) AS Market_Total_Sales,
    RANK() OVER (PARTITION BY [Market] ORDER BY CAST([Sales] AS FLOAT) DESC) AS Sales_Rank
FROM Staging_SupplyChain
ORDER BY [Market], Sales_Rank

-- =============================================
-- DELIVERY ANALYSIS
-- =============================================

-- 7. Delivery Status Distribution
SELECT 
    [Delivery Status],
    COUNT(*) AS Total_Orders
FROM Staging_SupplyChain
GROUP BY [Delivery Status]
ORDER BY Total_Orders DESC

-- 8. Late Delivery Rate by Market
SELECT 
    [Market],
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN [Delivery Status] = 'Late delivery' THEN 1 ELSE 0 END) AS Late_Orders,
    ROUND(100.0 * SUM(CASE WHEN [Delivery Status] = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Late_Delivery_Pct
FROM Staging_SupplyChain
GROUP BY [Market]
ORDER BY Late_Delivery_Pct DESC

-- 9. Late Delivery Rate by Shipping Mode
SELECT 
    [Shipping Mode],
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN [Delivery Status] = 'Late delivery' THEN 1 ELSE 0 END) AS Late_Orders,
    ROUND(100.0 * SUM(CASE WHEN [Delivery Status] = 'Late delivery' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Late_Delivery_Pct
FROM Staging_SupplyChain
GROUP BY [Shipping Mode]
ORDER BY Late_Delivery_Pct DESC

-- 10. Actual vs Scheduled Days by Shipping Mode
SELECT 
    [Shipping Mode],
    AVG(CAST([Days for shipping (real)] AS FLOAT)) AS Avg_Actual_Days,
    AVG(CAST([Days for shipment (scheduled)] AS FLOAT)) AS Avg_Scheduled_Days,
    AVG(CAST([Days for shipping (real)] AS FLOAT) - CAST([Days for shipment (scheduled)] AS FLOAT)) AS Avg_Delay_Days
FROM Staging_SupplyChain
GROUP BY [Shipping Mode]
ORDER BY Avg_Delay_Days DESC

-- =============================================
-- SALES ANALYSIS
-- =============================================

-- 11. Total Sales and Profit by Market
SELECT 
    [Market],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales,
    SUM(CAST([Order Profit Per Order] AS FLOAT)) AS Total_Profit,
    AVG(CAST([Order Profit Per Order] AS FLOAT)) AS Avg_Profit_Per_Order
FROM Staging_SupplyChain
GROUP BY [Market]
ORDER BY Total_Sales DESC

-- 12. Sales by Customer Segment
SELECT 
    [Customer Segment],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales,
    ROUND(100.0 * SUM(CAST([Sales] AS FLOAT)) / SUM(SUM(CAST([Sales] AS FLOAT))) OVER(), 2) AS Sales_Pct
FROM Staging_SupplyChain
GROUP BY [Customer Segment]
ORDER BY Total_Sales DESC

-- 13. Sales by Category
SELECT 
    [Category Name],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales,
    SUM(CAST([Order Profit Per Order] AS FLOAT)) AS Total_Profit
FROM Staging_SupplyChain
GROUP BY [Category Name]
ORDER BY Total_Sales DESC

-- =============================================
-- CUSTOMER ANALYSIS
-- =============================================

-- 14. Orders by Customer Segment
SELECT 
    [Customer Segment],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales,
    AVG(CAST([Sales] AS FLOAT)) AS Avg_Order_Value
FROM Staging_SupplyChain
GROUP BY [Customer Segment]
ORDER BY Total_Orders DESC

-- 15. Top 10 Customers by Sales
SELECT TOP 10
    [Customer Fname] + ' ' + [Customer Lname] AS Customer_Name,
    [Customer Segment],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales
FROM Staging_SupplyChain
GROUP BY [Customer Fname], [Customer Lname], [Customer Segment]
ORDER BY Total_Sales DESC

-- =============================================
-- PRODUCT ANALYSIS
-- =============================================

-- 16. Top 10 Products by Sales
SELECT TOP 10
    [Product Name],
    [Category Name],
    COUNT(*) AS Total_Orders,
    SUM(CAST([Sales] AS FLOAT)) AS Total_Sales,
    SUM(CAST([Order Profit Per Order] AS FLOAT)) AS Total_Profit
FROM Staging_SupplyChain
GROUP BY [Product Name], [Category Name]
ORDER BY Total_Sales DESC

-- 17. Profit by Category
SELECT 
    [Category Name],
    SUM(CAST([Order Profit Per Order] AS FLOAT)) AS Total_Profit,
    AVG(CAST([Order Profit Per Order] AS FLOAT)) AS Avg_Profit,
    COUNT(*) AS Total_Orders
FROM Staging_SupplyChain
GROUP BY [Category Name]
ORDER BY Total_Profit DESC