/* AUTHOR: BHARATH KUMAR S */
/* TOPIC: SQL JOINS IN CLINICAL TRIALS */
/* DESCRIPTION: Combining Demographics (DM) and Adverse Events (AE) domains */
/*              using Inner, Left, Right, and Full Joins. */
             
                                   /* JOIN */
                                  
/* JOIN IS USED TO COMBINE TWO OR MORE TABLES BASED ON A COMMON COLUMN BETWEEN THEM. */

DATA work.patients;
    INPUT usubjid $ age sex $ trt $ weight height;
    DATALINES;
P001 25 M DrugA 70 170
P002 34 F DrugB 55 160
P003 45 M DrugA 80 175
P004 28 F DrugA 60 162
P005 52 M DrugB 90 180
P006 61 F DrugB 65 158
P007 19 M DrugA 72 172
P008 47 F DrugB 58 165
P009 38 M DrugA 85 178
P010 55 F DrugA 62 163
P011 29 M DrugB 75 171
P012 43 F DrugA 68 164
P013 31 M DrugB 88 177
P014 50 F DrugA 57 159
P015 22 M DrugB 73 173
P016 48 F DrugB 66 161
P017 36 M DrugA 82 176
P018 41 F DrugA 59 162
P019 27 M DrugB 77 174
P020 58 F DrugB 63 160
;
RUN;


DATA work.ae;
    INPUT usubjid $ ae_term $ severity $ ae_day;
    DATALINES;
P001 Headache Mild 3
P003 Nausea Moderate 7
P005 Fever Mild 2
P007 Rash Severe 10
P009 Dizziness Mild 5
P011 Vomiting Moderate 8
P013 Fatigue Mild 4
P015 Headache Moderate 6
P017 Nausea Mild 9
P019 Fever Severe 11
P002 Rash Mild 3
P006 Dizziness Moderate 7
P010 Vomiting Mild 5
P021 Headache Mild 2
P022 Fatigue Moderate 6
;
RUN;

                                  /* PRACTICE CODES */
                                 

/* INNER JOIN */
proc sql;
select a.usubjid, 
a.age, 
a.trt,
b.ae_term
from work.patients as a
inner join work.ae as b
on a.usubjid=b.usubjid;
quit;

/* LEFT JOIN */
proc sql;
select coalesce(a.usubjid, b.usubjid) as usubjid,
b.ae_term, b.severity, b.ae_day
from work.patients as a
left join work.ae as b
on  a.usubjid=b.usubjid;
quit;

/* RIGHT JOIN */
proc sql;
select coalesce(a.usubjid, b.usubjid) as usubjid,
a.age,
a.trt,
b.ae_term, b.severity, b.ae_day
from work.patients as a
right join work.ae as b
on  a.usubjid=b.usubjid;
quit;


/* FULL JOIN */
proc sql;
select coalesce(a.usubjid, b.usubjid) as usubjid,
a.age,
a.sex,
a.trt,
b.ae_term, b.severity, b.ae_day
from work.patients as a
full join work.ae as b
on  a.usubjid=b.usubjid;
quit;
