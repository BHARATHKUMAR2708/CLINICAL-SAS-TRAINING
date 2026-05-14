# CLINICAL-SAS-TRAINING
This respiratory contains my clinical SAS programming codes, including Base SAS, Advance SAS, and SQL queries for clinical data management.
								/* MERGE */
								
data dm;
input SUBJID $ AGE SEX $ TRT $;
datalines;
101 23 M A
102 45 F B
104 29 F B
105 40 M A
106 38 F B
108 27 F B
109 31 M A
110 36 F B
;
run;


data lab;
input SUBJID $ HGB WBC;
datalines;
101 13.5 7000
102 12.8 6500
103 14.2 7200
104 11.9 6000
105 13.8 7100
106 12.5 6800
109 13.9 7050
110 12.4 6400
;
run;


proc sort data=dm;
by SUBJID;

proc sort data=lab;
by SUBJID;

						/* FULL JOIN */

data full_join;
merge dm
	  lab;
by SUBJID;
run;
	  
title "FULL JOIN OUTPUT";

proc print data=full_join;
run;










<img width="1366" height="702" alt="FULL JOIN" src="https://github.com/user-attachments/assets/e4d38271-5181-4720-b644-ce7a034c35ad" />










						/* LEFT JOIN */

data left_join;
merge	dm (in=a)
		lab(in=b);
by SUBJID;
if a;
run;

title "LEFT JOIN OUTPUT";

proc print data=left_join;
run;

<img width="1366" height="623" alt="LEFT JION " src="https://github.com/user-attachments/assets/4caf9227-6da9-4e47-a2ed-64cb8bd89458" />



						/* RIGHT JOIN */

data right_join;
merge	dm(in=a)
		lab(in=b);
by SUBJID;
if b;
run;

title "RIGHT JOIN OUTPUT";

proc print data=right_join;
run;
<img width="1361" height="601" alt="RIGHT JOIN" src="https://github.com/user-attachments/assets/73c6e359-d62d-4249-9d29-1028f4d2a81d" />


						/* INNER JOIN */


DATA inner_join;
merge	dm(in=a)
		lab(in=b);
by SUBJID;
if a and b;
RUN;

title "INNER JOIN OUTPUT";

PROC print data=inner_join;
run;
<img width="1366" height="612" alt="INNER JOIN" src="https://github.com/user-attachments/assets/68183d44-e80d-4e83-aff9-d92a19b2475f" />

