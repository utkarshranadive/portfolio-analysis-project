Portfolio Risk & Returns Analysis Queries
Real-world wealth management SQL analysis for client portfolio dashboard

1.Total AUM across all client portfolios
SELECT 
    ROUND(SUM(Amount), 2) AS Total_Portfolio_AUM
FROM portfolio;

2. Unique client count
SELECT 
    COUNT(DISTINCT Client_ID) AS Active_Clients
FROM portfolio;

3. Portfolio performance benchmark
SELECT 
    ROUND(AVG(Returns), 2) AS Portfolio_Avg_Return
FROM portfolio;

4. Risk-adjusted performance analysis
SELECT 
    Risk_Level,
    COUNT(*) as Holdings_Count,
    ROUND(AVG(Returns), 2) AS Avg_Return,
    ROUND(STDDEV(Returns), 2) AS Return_Volatility
FROM portfolio
GROUP BY Risk_Level
ORDER BY Avg_Return DESC;

5. Risk concentration by AUM exposure
SELECT 
    Risk_Level,
    ROUND(SUM(Amount), 2) AS Risk_AUM,
    ROUND(100.0 * SUM(Amount) / (SELECT SUM(Amount) FROM portfolio), 2) AS AUM_Percentage
FROM portfolio
GROUP BY Risk_Level
ORDER BY Risk_AUM DESC;

6. Client risk appetite distribution
SELECT 
    Risk_Level,
    COUNT(DISTINCT Client_ID) AS Client_Count,
    ROUND(100.0 * COUNT(DISTINCT Client_ID) / (SELECT COUNT(DISTINCT Client_ID) FROM portfolio), 2) AS Client_Percentage
FROM portfolio
GROUP BY Risk_Level
ORDER BY Client_Count DESC;

7. High-risk portfolio concentration alert
SELECT 
    CONCAT(
        ROUND(100.0 * COUNT(CASE WHEN Risk_Level = 'High' THEN 1 END) / COUNT(*), 2), 
        '% High Risk Exposure'
    ) AS Risk_Alert
FROM portfolio;

8. Whale clients (Top 5 by AUM)
SELECT 
    Client_ID,
    ROUND(SUM(Amount), 2) AS Client_AUM,
    ROUND(100.0 * SUM(Amount) / (SELECT SUM(Amount) FROM portfolio), 2) AS Portfolio_Share
FROM portfolio
GROUP BY Client_ID
ORDER BY Client_AUM DESC
LIMIT 5;

9. Scale vs performance relationship (negative correlation expected)
SELECT 
    CASE 
        WHEN Amount < 100 THEN 'Micro'
        WHEN Amount < 500 THEN 'Small' 
        WHEN Amount < 1000 THEN 'Medium'
        ELSE 'Whale'
    END as Investment_Size,
    COUNT(*) as Holdings,
    ROUND(AVG(Returns), 2) AS Avg_Return,
    ROUND(STDDEV(Returns), 2) AS Volatility
FROM portfolio
GROUP BY 
    CASE 
        WHEN Amount < 100 THEN 'Micro'
        WHEN Amount < 500 THEN 'Small'
        WHEN Amount < 1000 THEN 'Medium'
        ELSE 'Whale'
    END
ORDER BY Investment_Size;

10. Asset class allocation breakdown
SELECT 
    Investment_Type,
    COUNT(*) AS Holdings,
    ROUND(SUM(Amount), 2) AS Type_AUM,
    ROUND(100.0 * SUM(Amount) / SUM(SUM(Amount)) OVER(), 2) AS Allocation_Pct,
    ROUND(AVG(Returns), 2) AS Type_Return
FROM portfolio
GROUP BY Investment_Type;

11. Risk-return efficiency (Sharpe ratio proxy)
SELECT 
    Risk_Level,
    ROUND(AVG(Returns), 2) AS Avg_Return,
    ROUND(STDDEV(Returns), 2) AS Volatility,
    ROUND(AVG(Returns) / NULLIF(STDDEV(Returns), 0), 2) AS Sharpe_Ratio_Proxy
FROM portfolio
GROUP BY Risk_Level;

12. Portfolio health summary dashboard query
SELECT 
    'PORTFOLIO OVERVIEW' as Metric,
    CONCAT(
        COUNT(DISTINCT Client_ID), ' clients | $',
        ROUND(SUM(Amount)/1000000, 1), 'M AUM | ',
        ROUND(AVG(Returns), 1), '% return'
    ) AS Value
FROM portfolio
UNION ALL
SELECT 
    'RISK CONCENTRATION' as Metric,
    CONCAT(
        ROUND(100.0 * SUM(CASE WHEN Risk_Level = 'High' THEN 1 ELSE 0 END)/COUNT(*), 1), 
        '% HIGH RISK'
    ) AS Value
FROM portfolio;

