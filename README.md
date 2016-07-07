# Polarization_noIVs
polarization project with no IVs. 
(names in parentheses are local file names)

This projects start from Polarization_IVs, which was used to generate the results in Yawen's JMP. Following David's suggestion, trade shocks should not be instrumented, as they are exogenous by construction (Bartik form with initial labor shares). This projects modify the Polarization_IVs so that trade shocks and tariff changes are used as exogenous regressors directly. 

Project created: July 7th, 2016.
Written by: Yawen Liang

Initial Files:

Initial code 1: dataclean.do (dataclean_16Jul02.do)
This code is the starting part of "Bartik_15Oct17.do"(saved in local computer) , which was used to clean the data.

Initial code 2: regressions_noagct.do (regressionsYawen_15Oct28.do)
This code was used to generate the results in my JMP, where tariff changes are used as IVs. (exclude agriculture sector)

Initial code 3: regressions_agct.do (regressionsYawen_15Nov22.do)
This code was used to generate the results in my JMP, where tariff changes are used as IVs. (include agriculture sector)

Initial code 4: Bartik.do (Bartik_15Oct26.do)
Generate regional trade shocks using bartik format.

Initial code 5: Bartik_cntries.do (Bartik_15Oct26_CHN.do)
Generate regional trade shocks using bartik format. Trade values by trading countries.

Initial code 6: Delta.do (Delta_15Oct26.do)
Compute the regional "delta_omega" (share of tasks being used by foreign countries).

Initial code 7: counterfactual.do (counterfactual_15Dec18.do)
Compute the total trade effect after getting the regression estimates.

Pull Requests:

