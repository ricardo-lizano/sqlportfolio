
--Optimized ABC Classification: Enhance Product Management with SQL
--Author: Ricardo Lizano Monge https://lizano.live/
--Based in ContosoRetailDW dabatese from Microsoft Corporatiion: https://www.microsoft.com/en-us/download/details.aspx?id=18279

WITH ProductSales AS
(
	SELECT
		YEAR(DateKey) AS YEAR,
		MONTH(DateKey) AS MONTH,
		1 AS CompanyKey,
		StoreKey,
		ProductKey,
		SUM(SalesAmount) AS SalesAmount,
		SUM(SalesAmount) - SUM(TotalCost) AS ProfitAmount,
		SUM(SalesQuantity) AS UnitsSold
	FROM FactSales
	GROUP BY
		YEAR(DateKey),
		MONTH(DateKey),
		StoreKey,
		ProductKey
)

SELECT
	'Sales' AS Criteria,
	StoreKey,
	ProductKey,
	SUM(ps.SalesAmount) AS SalesAmount,
	SUM(ps.ProfitAmount) AS ProfitAmount, 
	SUM(ps.UnitsSold) AS UnitsSold, 
	SUM(ps.SalesAmount) OVER (partition by ps.StoreKey ORDER BY ps.SalesAmount DESC) / SUM(NULLIF(ps.SalesAmount,0)) OVER (partition by ps.StoreKey) AS PorcetajeAcumulado,
	CASE
		WHEN SUM(ps.SalesAmount) OVER (partition by ps.StoreKey ORDER BY ps.SalesAmount DESC) / SUM(NULLIF(ps.SalesAmount,0)) OVER (partition by ps.StoreKey) <= 0.8 THEN 'A'
		WHEN SUM(ps.SalesAmount) OVER (partition by ps.StoreKey ORDER BY ps.SalesAmount DESC) / SUM(NULLIF(ps.SalesAmount,0)) OVER (partition by ps.StoreKey) <= 0.95 THEN 'B'
		ELSE 'C'
	END AS ABC
FROM ProductSales ps
GROUP BY
	StoreKey,
	ProductKey,
	SalesAmount

UNION ALL

SELECT
	'Porfit' AS Criteria,
	StoreKey,
	ProductKey,
	SUM(ps.SalesAmount) AS SalesAmount,
	SUM(ps.ProfitAmount) AS ProfitAmount,
	SUM(ps.UnitsSold) AS UnitsSold,
	SUM(ps.ProfitAmount) OVER (partition by ps.StoreKey ORDER BY ps.ProfitAmount DESC) / SUM(NULLIF(ps.ProfitAmount,0)) OVER (partition by ps.StoreKey) AS PorcetajeAcumulado,
	CASE
		WHEN SUM(ps.ProfitAmount) OVER (partition by ps.StoreKey ORDER BY ps.ProfitAmount DESC) / SUM(NULLIF(ps.ProfitAmount,0)) OVER (partition by ps.StoreKey) <= 0.8 THEN 'A'
		WHEN SUM(ps.ProfitAmount) OVER (partition by ps.StoreKey ORDER BY ps.ProfitAmount DESC) / SUM(NULLIF(ps.ProfitAmount,0)) OVER (partition by ps.StoreKey) <= 0.95 THEN 'B'
		ELSE 'C'
	END AS ABC
FROM ProductSales ps
GROUP BY
	StoreKey,
	ProductKey,
	ProfitAmount

UNION ALL

SELECT
	'Sold Units' AS Criteria,
	StoreKey,
	ProductKey,
	SUM(ps.SalesAmount) AS SalesAmount,
	SUM(ps.ProfitAmount) AS ProfitAmount,
	SUM(ps.UnitsSold) AS UnitsSold,
	SUM(ps.UnitsSold) OVER (partition by ps.StoreKey ORDER BY ps.UnitsSold DESC) / SUM(NULLIF(ps.UnitsSold,0)) OVER (partition by ps.StoreKey) AS PorcetajeAcumulado,
	CASE
		WHEN SUM(ps.UnitsSold) OVER (partition by ps.StoreKey ORDER BY ps.UnitsSold DESC) / SUM(NULLIF(ps.UnitsSold,0)) OVER (partition by ps.StoreKey) <= 0.8 THEN 'A'
		WHEN SUM(ps.UnitsSold) OVER (partition by ps.StoreKey ORDER BY ps.UnitsSold DESC) / SUM(NULLIF(ps.UnitsSold,0)) OVER (partition by ps.StoreKey) <= 0.95 THEN 'B'
		ELSE 'C'
	END AS ABC
FROM ProductSales ps
GROUP BY
	StoreKey,
	ProductKey,
	UnitsSold

GO
