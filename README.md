# Market Risk Management Projects

This repo contains three projects in market risk management. For each project, there is a report illustrates the methodology, data processing, charts&figures and conclusion.

- Copula
- Backtesting
- GDP Forecasting

## Copula

- Estimate the Clayton copula between two companies (Verizon -- AT&T). 
- Use the estimated theta param, which is based on 12-month daily returns, to simulate 10-day forward assets' prices.

## Backtesting

- Select a 500-day estimation window; and a 757-day test window. (1257 returns/1258 trading days/5 years data)
- Estimate ARMA/GARCH; simulate 1-day VaR; Compute 95% VaR/ES for each test.
- Find violations; Compute VR, Std ES, Ave Std ES.
- Test the significance of VR.

## GDP Forecasting

- Decide three factors that will reflect the GDP growth rate 
  - Private domestic investment growth; 
  - Real output per hour of all persons; 
  - Total dwellings and residential buildings by stage of construction)
- Run 3-variable linear regression with t-test
