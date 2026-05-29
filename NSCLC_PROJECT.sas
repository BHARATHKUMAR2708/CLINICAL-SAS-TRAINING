proc import
	datafile='//home/u64526829/NSCLC_CLINICAL_DATA.xlsx'
	out=work.NSCLC_raw
	dbms=xlsx
	replace;
	getnames=yes;
run;

proc contents data=work.nsclc_raw varnum;
	title "NSCLC_raw data Overview";
run;

proc print data=work.NSCLC_raw (obs=5);
	title 'NSCLC_raw first five OBS';
run;

PROC means data=work.nsclc_raw n mean  min max nmiss;
	title 'NSCLC_raw Numeric summary';
run;

proc freq data=work.NSCLC_raw;
	tables Sex Smoker 'Treatment Type'n

      				 'Progression Free Status'n

      			 	'Cancer Type Detailed'n;
	title "NSCLC_raw Key Variables";
run;

proc sql;
	select count(*) as total,
	count (distinct 'Patient ID'n ) as dublicate
	from work.NSCLC_raw;
quit;

proc sort data=work.NSCLC_raw out= work.NSCLC_clean nodupkey;
by "Patient ID"n;
run;



proc freq data=work.NSCLC_clean;
tables _character_ / 
       missing     
       nocum;
title "All Character Variables — Missing Check";
run;
/************************************************************************************
  							SDTM DM DOMAIN CREATION 
*************************************************************************************/

data work.dm_Domain;
	set work.NSCLC_clean (rename= (sex=sex_raw)); 

	attrib
	
    	STUDYID length=$20  label="Study Identifier"
   		DOMAIN  length=$2   label="Domain Abbreviation"
   		USUBJID length=$30  label="Unique Subject Identifier"
    	SUBJID  length=$15  label="Subject Identifier"
    	AGE     length=8    label="Age"
    	AGEU    length=$5   label="Age Units"
   		SEX     length=$1   label="Sex"
    	RACE    length=$20  label="Race"
    	ETHNIC  length=$30  label="Ethnicity"
    	COUNTRY length=$3   label="Country"
    	ARM     length=$40  label="Description of Planned Arm"
    	ARMCD   length=$20  label="Planned Arm Code"
    	DTHFL   length=$1   label="Subject Death Flag"
		RFSTDTC length=$10  label="Subject Reference start date/time" 
		RFENDTC length=$10  label="Subject Reference end date/time";


	STUDYID = "NSCLC-2018";
	DOMAIN  = "DM";
	COUNTRY = "USA";
	RACE    = "NOTREPOTED";
	AGEU    = "YEARS";
	ETHNIC = 'NOT REPOTED';
	SUBJID  = strip('Patient ID'n);
	USUBJID = cats(STUDYID,"-",SUBJID);
	AGE = 'Diagnosis Age'n;
	RFSTDTC = "2018-01-01";
	RFENDTC = "2023-12-31";
	
	if upcase(strip(Sex_Raw)) = "MALE"
		then SEX = "M";
	else if upcase(strip(Sex_raw)) = "FEMALE"
		then SEX = "F";
	else SEX = "U";

	if strip('Treatment Type'n) = "Monotherapy"
		then do;
        ARMCD = "MONO";
        ARM   = "Monotherapy";
   		end;
	else if strip('Treatment Type'n) = "Combination"
    	then do;
        ARMCD  = "COMBO";
        ARM    = "Combination";
    	end;
	else do;
    	ARMCD = "UNKN";
    	ARM   = "Unknown";
	end;


	if strip('Progression Free Status'n)  = "1:Progressed"
		then DTHFL = "Y";
	else DTHFL = "N";



	keep STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC
     	AGE AGEU SEX RACE ETHNIC COUNTRY ARM ARMCD 
     	DTHFL;

run;
/******************************************************************
						QC VALIDATION 
********************************************************************/

proc contents data=work.dm_domain varnum;
	title "DM DOMAIN — OVERVIEW";
run;

proc print data=work.dm_domain (obs=10) label;
title "DM DOMAIN — FIRST 10 RECORDS";
run;

proc freq data=work.dm_domain ;
	tables SEX ETHNIC ARM DTHFL;
	title "DM DOMAIN — FREQUENCY CHECK";
run;

proc means data=work.dm_domain n mean min max nmiss;
var AGE;
title "DM DOMAIN — AGE SUMMARY";
run;

/************************************************************************************
  							SDTM DS DOMAIN CREATION 
*************************************************************************************/

data work.ds;

	set work.NSCLC_clean;

	attrib
	
  		STUDYID  length=$20  label="Study Identifier"
    	DOMAIN   length=$2   label="Domain Abbreviation"
    	USUBJID  length=$30  label="Unique Subject Identifier"
    	SUBJID   length=$15  label="Subject Identifier"
    	DSSEQ    length=8    label="Sequence Number"
    	DSTERM   length=$50  label="Reported Term for Disposition"
    	DSDECOD  length=$50  label="Standardized Disposition Term"
    	DSCAT    length=$50  label="Category for Disposition"
    	DSSCAT   length=$50  label="Subcategory for Disposition";


		STUDYID = "NSCLC-2018";
		DOMAIN  = "DS";
		DSCAT   = "DISPOSITION EVENT";
		DSSEQ   = 1;
		SUBJID  = strip('Patient ID'n);
		USUBJID = cats(STUDYID,"-",SUBJID);

					/* DISPOSITION TERM MAPPING */

	if strip('Progression Free Status'n) = "1:Progressed" then do;
   		DSTERM  = "PROGRESSIVE DISEASE";
    	DSDECOD = "PROGRESSIVE DISEASE";
    	DSSCAT  = "DISEASE PROGRESSION";
	end;

	else if strip('Progression Free Status'n)= "0:Not Progressed" then do;
    	DSTERM  = "COMPLETED STUDY";
    	DSDECOD = "COMPLETED STUDY";
    	DSSCAT  = "COMPLETED STUDY";
	end;

	else do;
    	DSTERM  = "UNKNOWN";
    	DSDECOD = "UNKNOWN";
    	DSSCAT  = "UNKNOWN";
	end;



	keep STUDYID DOMAIN USUBJID SUBJID DSSEQ DSTERM DSDECOD
     	 DSCAT DSSCAT;

run;

						
/******************************************************************
						QC VALIDATION 
********************************************************************/

proc contents data=work.ds;
title "DS DOMAIN — OVERVIEW";
run;

proc print data=work.ds (obs=10) label;
title "DS DOMAIN — FIRST 10 RECORDS";
run;

proc freq data=work.ds;
tables DSDECOD DSSCAT;
title "DS DOMAIN — DISPOSITION SUMMARY";
run;

/************************************************************************************
  							SDTM SC DOMAIN CREATION 
*************************************************************************************/

data work.sc;
	set work.NSCLC_clean;

	attrib

  		STUDYID  length=$20  label="Study Identifier"
    	DOMAIN   length=$2   label="Domain Abbreviation"
    	USUBJID  length=$30  label="Unique Subject Identifier"
    	SUBJID   length=$15  label="Subject Identifier"
    	SCSEQ    length=8    label="Sequence Number"
    	SCTESTCD length=$12   label="Subject Characteristic Test Code"
    	SCTEST   length=$50  label="Subject Characteristic Test Name"
    	SCORRES  length=$50  label="Result in Original Units";

	STUDYID = "NSCLC-2018";
	DOMAIN  = "SC";
	SUBJID  = strip('Patient ID'n);
	USUBJID = cats(STUDYID,"-",SUBJID);

					/*   RECORD 1: SMOKING STATUS */
	SCSEQ    = 1;
	SCTESTCD = "SMOKSTAT";
	SCTEST   = "Smoking Status";



	if upcase(strip(Smoker)) = "EVER"
    	then SCORRES = "EVER SMOKER";

	else if upcase(strip(Smoker)) = "NEVER"
    	then SCORRES = "NEVER SMOKER";

	else SCORRES = "UNKNOWN";

	output;

				/* RECORD 2: LINES OF TREATMENT */

	SCSEQ    = 2;
	SCTESTCD = "LNSTRT";
	SCTEST   = "Lines of Treatment";
	SCORRES  = strip(put('Lines of treatment'n, best.));
	output;

				/*     RECORD 3: TREATMENT TYPE */

	SCSEQ    = 3;
	SCTESTCD = "TRTTYPE";
	SCTEST   = "Treatment Type";
	SCORRES  = strip('Treatment Type'n);
	output;

				/*RECORD 4: CANCER TYPE */

	SCSEQ    = 4;
	SCTESTCD = "CANCTYPE";
	SCTEST   = "Cancer Type";
	SCORRES  = strip('Cancer Type'n);
	output;

	keep STUDYID DOMAIN USUBJID SUBJID SCSEQ SCTESTCD SCTEST

     SCORRES ;

run;

/******************************************************************
						QC VALIDATION 
********************************************************************/

proc contents data=work.sc;
	title "SC DOMAIN —OVERVIVEW";
run;

proc print data=work.sc (obs=20) ;
	title "SC DOMAIN — FIRST 20 RECORDS";
run;

proc freq data=work.sc;
	tables SCTESTCD * SCORRES / list nocum;
	title "SC DOMAIN — ALL CHARACTERISTICS";
run;

/************************************************************************************
  							SDTM TU DOMAIN CREATION 
*************************************************************************************/

data work.tu;
	set work.NSCLC_CLEAN;

attrib

   		STUDYID  length=$20  label="Study Identifier"
    	DOMAIN   length=$2   label="Domain Abbreviation"
    	USUBJID  length=$30  label="Unique Subject Identifier"
    	SUBJID   length=$15  label="Subject Identifier"
    	TULNKID   length=$20  label="Tumor Link Identifier"
    	TUSEQ    length=8    label="Sequence Number"
    	TUTESTCD length=$12  label="Tumor Test Short Name"
    	TUTEST   length=$50  label="Tumor Test Name"
    	TUORRES  length=$50  label="Result in Original Units"
    	TULOC    length=$50  label="Location of Tumor"
    	TUCAT    length=$50  label="Category of Tumor";

	STUDYID = "NSCLC-2018";
	DOMAIN  = "TU";
	TUCAT   = "TUMOR";
	SUBJID  = strip('Patient ID'n);
	USUBJID = cats(STUDYID,"-",SUBJID);
	TULNKID = cats("TUMOR-", SUBJID);

				/*RECORD 1: CANCER TYPE */

	TUSEQ    = 1;
	TUTESTCD = "CANCTYPE";
	TUTEST   = "Cancer Type";
	TUORRES  = strip('Cancer Type'n);
	TULOC    = "LUNG";
	output;

				/*RECORD 2: CANCER TYPE DETAILED */

	TUSEQ    = 2;
	TUTESTCD = "CANCTYPD";
	TUTEST   = "Cancer Type Detailed";
	TUORRES  = strip('Cancer Type Detailed'n);
	TULOC    = "LUNG";
	output;

				/*RECORD 3: HISTOLOGY */
	
	TUSEQ    = 3;
	TUTESTCD = "HISTOL";
	TUTEST   = "Histology";

	if upcase (strip('Cancer Type Detailed'n)) =  "LUNG ADENOCARCINOMA"
    	then TUORRES = "ADENOCARCINOMA";

	else if upcase(strip('Cancer Type Detailed'n)) ="LUNG SQUAMOUS CELL CARCINOMA"
    	then TUORRES = "SQUAMOUS CELL";

	else TUORRES = upcase(strip('Cancer Type Detailed'n));

	TULOC = "LUNG";

	output;

						/*RECORD 4: SAMPLE COUNT */

	TUSEQ    = 4;
	TUTESTCD = "SAMPCNT";
	TUTEST   = "Number of Samples Per Patient";
	TUORRES  = strip(put('Number of Samples Per Patient'n,best.));
	TULOC    = "LUNG";
	output;

keep STUDYID DOMAIN USUBJID SUBJID TULNKID TUSEQ TUTESTCD TUTEST
	 TUORRES TULOC TUCAT ;

run;


/******************************************************************
						QC VALIDATION 
********************************************************************/

proc contents data=work.tu;
	title "TU Domain — OVERVIEW";
run;

proc print data=work.tu (obs=20) ;
	title "TU DOMAIN — FIRST 20 RECORDS";
run;

proc freq data=work.tu;
	tables TUTESTCD * TUORRES /
    list nocum;
	title "TU DOMAIN — TUMOR SUMMARY";
run;

/************************************************************************************
  							SDTM RS DOMAIN CREATION 
*************************************************************************************/

data work.rs;
	set work.nsclc_clean;

attrib
    	STUDYID  length=$20  label="Study Identifier"
    	DOMAIN   length=$2   label="Domain Abbreviation"
    	USUBJID  length=$30  label="Unique Subject Identifier"
    	SUBJID   length=$15  label="Subject Identifier"
    	RSSEQ    length=8    label="Sequence Number"
    	RSTESTCD length=$12  label="Response Test Short Name"
   		RSTEST   length=$50  label="Response Test Name"
    	RSORRES  length=$50  label="Result in Original Units"
    	RSSTRESC length=$50  label="Result in Standard Format"
    	RSCAT    length=$50  label="Category of Response"
    	RSSCAT   length=$50  label="Subcategory of Response";

	STUDYID = "NSCLC-2018";
	DOMAIN  = "RS";
	RSCAT   = "OVERALL RESPONSE";
	SUBJID  = strip('Patient ID'n);
	USUBJID = cats(STUDYID,"-",SUBJID);

					/*RECORD 1: PROGRESSION STATUS */

	RSSEQ    = 1;
	RSTESTCD = "PROGSTAT";
	RSTEST   = "Progression Free Status";
	RSSCAT   = "PROGRESSION STATUS";

	if strip('Progression Free Status'n) ="1:Progressed" then do;
    	RSORRES  = "PROGRESSED";
    	RSSTRESC = "PD";
		end;

	else if strip('Progression Free Status'n) ="0:Not Progressed" then do;
    	RSORRES  = "NOT PROGRESSED";
    	RSSTRESC = "SD";
	end;

	else do;
   		RSORRES  = "UNKNOWN";
    	RSSTRESC = "NE";
	end;
	output;

				/*RECORD 2: DURABLE CLINICAL BENEFIT */

	RSSEQ    = 2;
	RSTESTCD = "DCB";
	RSTEST   = "Durable Clinical Benefit";
	RSSCAT   = "CLINICAL BENEFIT";



	if strip('Durable Clinical Benefit'n) ="DCB" then do;
    	RSORRES  = "DURABLE CLINICAL BENEFIT";
    	RSSTRESC = "DCB";
	end;

	else if strip('Durable Clinical Benefit'n) ="NDB" then do;
    	RSORRES  = "NO DURABLE BENEFIT";
   		RSSTRESC = "NDB";
	end;

	else do;
    	RSORRES  = "UNKNOWN";
    	RSSTRESC = "NE";
	end;
	output;

						/*RECORD 3: OVERALL RESPONSE */

	RSSEQ    = 3;
	RSTESTCD = "OVRLRESP";
	RSTEST   = "Overall Response";
	RSSCAT   = "OVERALL RESPONSE";

						/* Combine Progression + DCB */

	if strip('Progression Free Status'n) ="0:Not Progressed" and strip('Durable Clinical Benefit'n) ="DCB" 
	then do;	
    	RSORRES  = "COMPLETE/PARTIAL RESPONSE";
    	RSSTRESC = "CLINICAL BENEFIT";
	end;

	else if strip('Progression Free Status'n) ="0:Not Progressed" then do;
		 RSORRES  = "STABLE DISEASE";
    	RSSTRESC = "SD";
	end;

	else do;
    	RSORRES  = "PROGRESSIVE DISEASE";
    	RSSTRESC = "PD";
	end;
	output;


	keep STUDYID DOMAIN USUBJID SUBJID RSSEQ RSTESTCD RSTEST
     	RSORRES RSSTRESC RSCAT RSSCAT ;

run;

/******************************************************************
						QC VALIDATION 
********************************************************************/

proc contents data=work.rs;
	title "RS DOMAIN — OVERVIEW";
run;

proc print data=work.rs (obs=15);
	title "RS DOMAIN — FIRST 15 RECORDS";
run;

proc freq data=work.rs;
	tables RSTESTCD * RSSTRESC /
    list nocum;
	title "RS Domain — Response Summary";
run;

/************************************************************************************
  							SDTM FA DOMAIN CREATION 
*************************************************************************************/

data work.fa;
	set work.nsclc_clean;

	attrib
    	STUDYID  length=$20  label="Study Identifier"
    	DOMAIN   length=$2   label="Domain Abbreviation"
    	USUBJID  length=$30  label="Unique Subject Identifier"
    	SUBJID   length=$15  label="Subject Identifier"
    	FASEQ    length=8    label="Sequence Number"
    	FATESTCD length=$8   label="Findings About Test Code"
    	FATEST   length=$50  label="Findings About Test Name"
    	FAORRES  length=$50  label="Result in Original Units"
    	FASTRESC length=$50  label="Result in Standard Format"
    	FASTNRLO length=8    label="Standard Low Range"
    	FASTNRHI length=8    label="Standard High Range"
    	FACAT    length=$50  label="Category of Finding"
    	FASCAT   length=$50  label="Subcategory of Finding"
    	FAOBJ    length=$50  label="Object of Finding";


	STUDYID = "NSCLC-2018";
	DOMAIN  = "FA";
	FACAT   = "BIOMARKER";
	FAOBJ   = "TUMOR";
	SUBJID  = strip('Patient ID'n);
	USUBJID = cats(STUDYID,"-",SUBJID);
			
					/*RECORD 1: PD-L1 SCORE */

	FASEQ    = 1;
	FATESTCD = "PDL1";
	FATEST   = "PD-L1 Score (%)";
	FASCAT   = "IMMUNE CHECKPOINT";
	FASTNRLO = 0;
	FASTNRHI = 100;



				/* PD-L1 Missing flag handle */

	if missing('PD-L1 Score (%)'n) then do;
    	FAORRES  = "";
    	FASTRESC = "MISSING";
	end;

	else do;
    	FAORRES  = strip(put('PD-L1 Score (%)'n,best.));

   				 /* High vs Low classification */

    if 'PD-L1 Score (%)'n >= 50
        then FASTRESC = "HIGH";

    else if 'PD-L1 Score (%)'n >= 1
        then FASTRESC = "LOW";

    else FASTRESC = "NEGATIVE";
	end;
	output;

					/*RECORD 2: TMB */
	FASEQ    = 2;
	FATESTCD = "TMB";
	FATEST   = "Tumor Mutational Burden";
	FASCAT   = "GENOMIC BIOMARKER";
	FASTNRLO = 0;
	FASTNRHI = .;
	FAORRES  = strip(put('TMB (nonsynonymous)'n,best.));



						/* TMB HIGH VS LOW */

	if 'TMB (nonsynonymous)'n >= 10
    	then FASTRESC = "HIGH";
	else FASTRESC = "LOW";

	output;

						/*RECORD 3: MUTATION COUNT */

	FASEQ    = 3;
	FATESTCD = "MUTCNT";
	FATEST   = "Mutation Count";
	FASCAT   = "GENOMIC BIOMARKER";
	FASTNRLO = 0;
	FASTNRHI = .;
	FAORRES  = strip(put('Mutation Count'n,best.));
	FASTRESC = strip(put('Mutation Count'n,best.));

output;

/*    RECORD 4: MUTATION RATE */
	FASEQ    = 4;
	FATESTCD = "MUTRATE";
	FATEST   = "Mutation Rate";
	FASCAT   = "GENOMIC BIOMARKER";
	FASTNRLO = 0;
	FASTNRHI = .;
	FAORRES  = strip(put('Mutation Rate'n,best.));
	FASTRESC = strip(put('Mutation Rate'n, best.));

	output;

				/* RECORD 5: FGA */
	FASEQ    = 5;
	FATESTCD = "FGA";
	FATEST   = "Fraction Genome Altered";
	FASCAT   = "GENOMIC BIOMARKER";
	FASTNRLO = 0;
	FASTNRHI = 1;
	FAORRES  = strip(put('Fraction Genome Altered'n, best.));



				/* FGA High vs Low */

	if 'Fraction Genome Altered'n >= 0.5
		then FASTRESC = "HIGH";
	else FASTRESC = "LOW";
	output;





keep STUDYID DOMAIN USUBJID SUBJID FASEQ FATESTCD FATEST FAORRES FASTRESC
	 FASTNRLO FASTNRHI FACAT FASCAT FAOBJ;

run;

/******************************************************************
						QC VALIDATION 
********************************************************************/

proc contents data=work.fa;
	title "FA Domain — Variable List";
run;

proc print data=work.fa (obs=20) label;
	title "FA Domain — First 20 Records";
run;

proc freq data=work.fa;
	tables FATESTCD * FASTRESC /
    list nocum;
	title "FA Domain — Biomarker Summary";
run;

proc means data=work.fa n mean min max nmiss;
	where FATESTCD in ("PDL1" "TMB" "MUTCNT" "MUTRATE" "FGA");
	var FASTNRLO FASTNRHI;
	title "FA Domain — Range Summary";

run;

/*====================================================

ADaM ADSL DATASET CREATION

====================================================*/

proc sort data=work.dm_domain;
	by USUBJID;
run;

proc sort data=work.rs;
	by USUBJID;
run;

proc sort data=work.fa;
	by USUBJID;
run;

/*----------------------------------------------------

RS DOMAIN DERIVATION

----------------------------------------------------*/

data rs_der;
	set work.rs;
	where RSTESTCD = "OVRLRESP";
	length BOR $30 CNSR $1;

			/* Best Overall Response */

	if RSSTRESC = "CLINICAL BENEFIT"
    	then BOR = "RESPONDER";

	else if RSSTRESC = "SD"
    	then BOR = "STABLE DISEASE";

	else if RSSTRESC = "PD"
    	then BOR = "PROGRESSIVE DISEASE";
    
	else BOR = "UNKNOWN";

				/* CENSOR FLAG */

	if RSSTRESC = "PD"
    	then CNSR = "0";
	else CNSR = "1";
	
	keep USUBJID BOR CNSR;

run;

/*----------------------------------------------------

FA DOMAIN DERIVATION

----------------------------------------------------*/

proc transpose data=work.fa out=fa_tran(drop=_NAME_);
	by USUBJID;
	id FATESTCD;
	var FASTRESC;
run;

/************************************************************
							CREATE ADSL
**************************************************************/

data adsl;
	merge work.dm_domain
      	  rs_der
      	  fa_tran;
	by USUBJID;

	attrib
    	STUDYID	length=$20 	label="Study Identifier"
   	 	USUBJID length=$30 	label="Unique Subject Identifier"
    	SUBJID	length=$15 	label="Subject Identifier"
    	TRT01P	length=$40 	label="Planned Treatment"
		TRT01PN length=8  	label="Planned Treatment Number"
    	SAFFL 	length=$1	label="Safety Population Flag"
    	ITTFL 	length=$1	label="Intent-To-Treat Population Flag"
   	 	EFFFL 	length=$1	label="Efficacy Population Flag"
    	BOR   	length=$30	label="Best Overall Response"
    	CNSR  	length=$1	label="Censor Flag"
    	PDL1  	length=$20	label="PD-L1 Classification"
    	TMB 	length=$20	label="Tumor Mutational Burden";

/*----------------------------------------------------
			TREATMENT VARIABLES
----------------------------------------------------*/

	TRT01P = ARM;
	if ARMCD = "MONO" then TRT01PN = 1;
	else if ARMCD = "COMBO"	then TRT01PN = 2;
	else TRT01PN = .;

/*----------------------------------------------------
				POPULATION FLAGS
----------------------------------------------------*/

	SAFFL = "Y";
	ITTFL = "Y";

	if BOR in ("RESPONDER","STABLE DISEASE","PROGRESSIVE DISEASE")
    	then EFFFL = "Y";
	else EFFFL = "N";

/*----------------------------------------------------
				BIOMARKER VARIABLES
----------------------------------------------------*/

	PDL1 = PDL1;
	TMB  = TMB;
	
run;

/******************************************************************
						 VALIDATION 
********************************************************************/

proc contents data=adsl varnum;
	title "ADSL OVERVIEW";
run;

proc print data=adsl(obs=10) label;

title "ADSL SAMPLE RECORDS";

run;

proc freq data=adsl;

tables TRT01P BOR CNSR

       SAFFL ITTFL EFFFL

       PDL1 TMB;

title "ADSL SUMMARY";

run;

proc means data=adsl

n mean std min max;

var AGE;

class TRT01P;

title "ADSL AGE SUMMARY";

run;

/******************************************************************
						 ADTTE DATASETS CREATION
********************************************************************/


data adtte;
	set adsl;

attrib

    PARAMCD 	length=$8	label="Parameter Code"
    PARAM 		length=$50	label="Parameter"
    AVAL 		length=8	label="Analysis Value"
    CNSR 		length=$1	label="Censor Flag"
    STARTDT	 	length=8	format=date9.		label="Start Date"
    ADT 		length=8	format=date9.	 	label="Analysis Date"
   	EVNTDESC 	length=$40	label="Event Description";

/*---------------------------------------------------
  						PARAMETER
----------------------------------------------------*/

	PARAMCD = "PFS";
	PARAM = "Progression Free Survival";

/*----------------------------------------------------
						START DATE
----------------------------------------------------*/

	STARTDT = "01JAN2018"d;

/*----------------------------------------------------
						SURVIVAL DAYS
----------------------------------------------------*/

	if CNSR = "0"
    	then AVAL = 200 + floor(ranuni(101)*300);
	else AVAL = 300 + floor(ranuni(202)*500);

/*----------------------------------------------------
						EVENT DATE
----------------------------------------------------*/

	ADT = STARTDT + AVAL;

/*----------------------------------------------------
					EVENT DESCRIPTION
----------------------------------------------------*/

	if CNSR = "0"
   	 then EVNTDESC = "Disease Progression";
	else EVNTDESC = "Censored";

run;

/*====================================================
                 QC VALIDATION
====================================================*/

proc contents data=adtte varnum;
	title "ADTTE VARIABLE STRUCTURE";
run;

proc print data=adtte(obs=15) label;
	title "ADTTE SAMPLE RECORDS";
run;

proc freq data=adtte;
	tables PARAMCD CNSR EVNTDESC;
title "ADTTE EVENT SUMMARY";
run;

proc means data=adtte n mean std min max;
	var AVAL;
	class TRT01P;
		title "ADTTE SURVIVAL SUMMARY";
run;

/*====================================================

KAPLAN-MEIER SURVIVAL ANALYSIS

====================================================*/

data adtte_num;
set adtte;
CNSR_NUM=input (CNSR,1.);
run;

ods graphics on;
proc lifetest data=adtte_num
	plots=survival;
time AVAL * CNSR_NUM(1);
	strata TRT01P;
title "Kaplan-Meier Analysis";
title2 "Progression Free Survival by Treatment Arm";
run;
ods graphics off;

ods graphics on;
proc lifetest data=adtte_num
	plots=survival;
 	time AVAL * CNSR_NUM(1);
 	strata TRT01P / test=logrank;
title "Kaplan-Meier Analysis with Log-Rank Test";
run;
ods graphics off;


/******************************************************************
 					TLF (TABLE, LISTING, FIGURE)
******************************************************************/


/*========================================================
  						TABLE 1
  SUBJECT DEMOGRAPHICS AND BASELINE CHARACTERISTICS
========================================================*/

/*---------------------------------------------
  			AGE SUMMARY
---------------------------------------------*/

proc summary data=adsl nway;
    class TRT01P;
    var AGE;

    output out=age_stats
        n=AGE_N
        mean=AGE_MEAN
        std=AGE_STD
        median=AGE_MEDIAN
        min=AGE_MIN
        max=AGE_MAX;
run;


/*---------------------------------------------
  			SEX SUMMARY
---------------------------------------------*/

proc freq data=adsl noprint;
    tables TRT01P*SEX /
        out=sex_freq;
run;


/*========================================================
  				FINAL TLF OUTPUT
========================================================*/

ods pdf file="~/Demographic_Table_1.pdf"
    style=journal;

title1 j=center h=11pt
"TABLE 1 Subject Demographics and Baseline Characteristics";

title2 j=center h=10pt
"Safety Population";

footnote1 j=left
"Note: SD = Standard Deviation";

/*---------------------------------------------
     			AGE TABLE
---------------------------------------------*/

proc report data=age_stats nowd headline headskip;

    column TRT01P
           AGE_N
           AGE_MEAN
           AGE_STD
           AGE_MEDIAN
           AGE_MIN
           AGE_MAX;

    define TRT01P / display
        "Treatment Arm";

    define AGE_N / display
        "N";

    define AGE_MEAN / display format=8.2
        "Mean";

    define AGE_STD / display format=8.2
        "SD";

    define AGE_MEDIAN / display format=8.2
        "Median";

    define AGE_MIN / display format=8.2
        "Min";

    define AGE_MAX / display format=8.2
        "Max";

run;


/*---------------------------------------------
  				SEX TABLE
---------------------------------------------*/

title3 j=left
"Gender n (%)";

proc report data=sex_freq nowd;

    column TRT01P SEX COUNT PERCENT;

    define TRT01P / group
        "Treatment Arm";

    define SEX / group
        "Sex";

    define COUNT / analysis sum
        "Count";

    define PERCENT / analysis mean
        "Percent"
        format=8.1;

run;

footnote;
ods pdf close;


/*=============================================
		RESPONSE SUMMARY TLF
=============================================*/

ods pdf file="response_summary_tlf.pdf";

title1 "Table 2";
title2 "Overall Response Summary by Treatment Arm";

proc freq data=adsl;
	tables TRT01P * BOR / norow nocol nopercent;
run;

ods pdf close;



/**********************************************************
						LISTING
***********************************************************/
proc print data=adsl(obs=20);
title "Patient Listing";
	var USUBJID AGE SEX BOR TRT01P;
run;




/*=============================================
		KAPLAN-MEIER SURVIVAL FIGURE
=============================================*/

ods pdf file="~/km_survival_plot.pdf";

	ods graphics on;

title1 "Figure 1";
title2 "Kaplan-Meier Survival Curve";

proc lifetest data=adtte_num

		plots=survival;
		time AVAL * CNSR_NUM(1);
		strata TRT01P;
run;

	ods graphics off;

ods pdf close;

/***************************************************************************
 								END PROJECT 
 								
							NSCLC CLINICAL SAS PROJECT
**************************************************************************/








