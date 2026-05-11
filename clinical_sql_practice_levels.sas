/* AUTHOR: BHARATH KUMAR S
PURPOSE: SQL Practice - Clinical Data Manipulation 
CONCEPTS: Filtering, Aggregation, and Calculated Variables
*/

DATA work.patients;
    INPUT usubjid $ age sex $ trt $ weight height;
    DATALINES;
SUBJ-001 25 M Test 70 170
SUBJ-002 34 F Placebo 55 160
SUBJ-003 45 M Test 80 175
SUBJ-004 28 F Test 60 162
SUBJ-005 52 M Placebo 90 180
SUBJ-006 61 F Placebo 65 158
SUBJ-007 19 M Test 72 172
SUBJ-008 47 F Placebo 58 165
SUBJ-009 38 M Test 85 178
SUBJ-010 55 F Test 62 163
;
RUN;

proc sql;
    /* Task: Basic Selection of colums */
    select usubjid, age, weight 
    from work.patients;

    /* Task: Filtering Specific Subgroups */
    select * 
    from work.patients 
    where sex = 'F';

    /* Task: Complex Filtering */
    select * 
    from work.patients 
    where weight > 70 and sex = 'M';

    /* Task: Treatment Group Statistics */
    select trt, count(*) as count 
    from work.patients 
    group by trt;

    /* Task: Deriving BMI and Categorization */
    select *, 
    weight / (height/100)**2 as BMI,    
    case
        when calculated BMI < 18.5 then 'Underweight'
        when calculated BMI between 18.5 and 24.9 then 'Normal'
        else 'Overweight'
    end as WEIGHT_CATEGORY
    from work.patients;
quit;
