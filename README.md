# Polarization_noIV
polarization project with IVs.
(names in parentheses are local file names)
The files are used to generate the results in Yawen's job market paper and thesis chapter.


Project Created on July 2nd, 2016
To run the regressions with no IV's
Bartik form variables are treated as exogeneous, tariff changes are used as independent variables directy rather than IVs.

Initial code 1: dataclean.do (dataclean_16Jul02.do)
This code is the starting part of "Bartik_15Oct17.do"(saved in local computer) , which was used to clean the data.

Initial code 2: regressions.do (regressionsYawen_15Oct28.do)
This code was used to generate the results in my JMP, where tariff changes are used as IVs.

Initial code 3: Bartik.do (Bartik_15Oct26.do)
Generate regional trade shocks using bartik format.

Initial code 4: Bartik_cntries.do (Bartik_15Oct26_CHN.do)
Generate regional trade shocks using bartik format. Trade values by trading countries.

Initial code 5: Delta.do (Delta_15Oct26.do)
Compute the regional "delta_omega" (share of tasks being used by foreign countries).

Initial code 6: counterfactual.do (counterfactual_15Dec18.do)
Compute the total trade effect after getting the regression estimates.
