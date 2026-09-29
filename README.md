# Superstore Retail Analytics

SQL + SQLite + Excel dashboard for retail sales, profitability, discounts and regional performance. The dataset is generated for portfolio demonstration.

## What is included

- `superstore_retail_data.csv` — retail orders dataset
- `superstore_retail.db` — SQLite database
- `retail_analises.sql` — analytical SQL queries
- `Superstore_Retail_Dashboard.xlsx` — Excel dashboard

## Skills demonstrated

Regional drill-down, Pareto analysis, discount impact on profitability, running totals, quarterly performance, shipping-time analysis and year-over-year growth.

## Quick start

1. Open the workbook in Excel.
2. Open `superstore_retail.db` with DB Browser for SQLite.
3. Execute the examples in `retail_analises.sql`.

> Portfolio note: the data is synthetic and intended for analytics demonstrations.

## Verificação

```bash
python checks/check_artifacts.py            # confere os artefatos contra o baseline
python checks/check_artifacts.py --update   # regrava o baseline após mudar os dados
```

O baseline em `checks/expected.json` é versionado: se um CSV esvaziar, um banco perder tabela ou uma aba do dashboard desaparecer, a checagem falha. Roda no CI a cada push.
