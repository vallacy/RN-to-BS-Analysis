# Online RN to BS in Nursing Analysis
## Time-to-Event (Survival) Analysis in SAS

### Background
While working at the Office of Online Education, I completed a survival analysis to evaluate if there were statistically significant differences in dropout rates per semester between students in an online RN to BS nursing program based on two available demographic characteristics: race/ethnicity and age.

### Analysis
I used a repeated measures survival analysis, also called Cox proportional hazards regression, using a marginal model with robust sandwich estimation. In a marginal model each 'event' (in this case, semester) is modeled separately, so a student is considered at risk for dropping out during any semester, regardless of how many semsters a student has been in school.

```SAS
proc phreg data=marginal covs(aggregate) covm plots(cl overlay=byrow)=(survival cumhaz);
	class Ethnic_Grp_Desc(ref='White');
	model (zero_time semester_time)*mini_semester_pass(0) = Age_at_Admission Ethnic_Grp_Desc /risklimits ties=efron;
	strata semester_count;
	id id;
run;
```

### Results
Students in the program who were older were less likely to drop out of the program, compared to younger students. The hazard of a student dropping out in any given semester decreases 2% with every 1 year increase in age.

There was no statistically significant difference in dropout rates among students of different races/ethnicities, though this finding could be due to having so few students of color in the sample, which was 78% white.
