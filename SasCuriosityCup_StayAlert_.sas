/* Descripiton: 	SAS program for EDA and modelling
					by using on LOS dataset			 					*/
/* Purpose: 		SAS Curiosity Cup									*/
/* Written by:		Rehab Mahmoud, Daksh Mukhra,						*/
/*					Abhishek Wandhare, Manny Adachi						*/
/* Date written:	29 December 2021									*/

* === Preparation ===  
* Create a library to save later a dataset from the session.
  You will need to modify your user ID (uXXXXXXX) and folder name 
  ("/SasCuriCup/WIP" below) in path for SAS to work.;
  
* Set up library using macro;
%let Mypath = /home/u59413028/SasCuriCup/WIP;

libname CURICUP "&Mypath"; 


* Convert csv files to sas7bdat files.;
* 1. sample_sub.csv;
%web_drop_table(WORK.sample_sub);

FILENAME REFFILE '/home/u59413028/SasCuriCup/Original/sample_sub.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.sample_sub;
	GETNAMES=YES;
RUN;

%web_open_table(WORK.sample_sub);


* 2. test_data.csv;
%web_drop_table(WORK.test_data);

FILENAME REFFILE '/home/u59413028/SasCuriCup/Original/test_data.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.test_data;
	GETNAMES=YES;
RUN;

%web_open_table(WORK.test_data);


* 3. train_data.csv;
%web_drop_table(WORK.train_data);

FILENAME REFFILE '/home/u59413028/SasCuriCup/Original/train_data.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.train_data;
	GETNAMES=YES;
RUN;

%web_open_table(WORK.train_data);


* 4. train_data_dictionary.csv;
%web_drop_table(WORK.train_data_dictionary);

FILENAME REFFILE '/home/u59413028/SasCuriCup/Original/train_data_dictionary.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.train_data_dictionary;
	GETNAMES=YES;
RUN;

%web_open_table(WORK.train_data_dictionary);


* Then, save in a permanent folder.;
data CURICUP.sample_sub; set work.sample_sub; run;
data CURICUP.test_data; set work.test_data; run;
data CURICUP.train_data; set work.train_data; run;
data CURICUP.train_data_dictionary; set work.train_data_dictionary; run;

* Sanity check;
* - sample_sub;
title "sample_sub";
proc contents data=CURICUP.sample_sub;
run;
title;

* - test_data;
title "test_data";
proc contents data=CURICUP.test_data;
run;

PROC PRINT DATA = CURICUP.test_data (obs=20);
RUN;
title;

* - train_data;
title "train_data";
proc contents data=CURICUP.train_data;
run;

PROC PRINT DATA = CURICUP.train_data (obs=20);
RUN;
title;

* - train_data_dictionary;
title "train_data_dictionary";
proc contents data=CURICUP.train_data_dictionary;
run;
title;





* ===== Data Preparation =====;
* 1. Add a new sorting variables for all categorical variables;
*    1-1. Stay (LOS);
*         - First, define the format;
proc format;
value StyFmt 5     = '0-10'
             15.5  = '11-20'
		     25.5  = '21-30'
             35.5  = '31-40'
	         45.5  = '41-50'
             55.5  = '51-60'
	  	     65.5  = '61-70'
             75.5  = '71-80'
		     85.5  = '81-90'
             95.5  = '91-100'
             105.5 = 'More';
run;

*         - Next, create sorting variable;
data WORK.TRAIN_DATA;
format Stay_sort StyFmt.;
set WORK.TRAIN_DATA;
select (Stay);
	when ('0-10')	Stay_sort = 5;
	when ('11-20')	Stay_sort = 15.5;
	when ('21-30')	Stay_sort = 25.5;
	when ('31-40')	Stay_sort = 35.5;
	when ('41-50')	Stay_sort = 45.5;
	when ('51-60')	Stay_sort = 55.5;
	when ('61-70')	Stay_sort = 65.5;
	when ('71-80')	Stay_sort = 75.5;
	when ('81-90')	Stay_sort = 85.5;
	when ('91-10')	Stay_sort = 95.5;
	when ('More')	Stay_sort = 105.5;
otherwise;
end;
run;

*    1-2. Hospital_type_code;
*         - First, define the format;
proc format;
value HospTypFmt 1 = 'a'
             	 2 = 'b'
             	 3 = 'c'
             	 4 = 'd'
             	 5 = 'e'
             	 6 = 'f'
             	 7 = 'g';
run;

*         - Next, create sorting variable;
data WORK.TRAIN_DATA;
format HospTyp_sort HospTypFmt.;
set WORK.TRAIN_DATA;
select (Hospital_type_code);
	when ('a')	HospTyp_sort = 1;
	when ('b')	HospTyp_sort = 2;
	when ('c')	HospTyp_sort = 3;
	when ('d')	HospTyp_sort = 4;
	when ('e')	HospTyp_sort = 5;
	when ('f')	HospTyp_sort = 6;
	when ('g')	HospTyp_sort = 7;
otherwise;
end;
run;

*    1-3. Hospital_region_code;
*         - First, define the format;
proc format;
value HospRegFmt 1 = 'X'
             	 2 = 'Y'
             	 3 = 'Z';
run;

*         - Next, create sorting variable;
data WORK.TRAIN_DATA;
format HospReg_sort HospRegFmt.;
set WORK.TRAIN_DATA;
select (Hospital_region_code);
	when ('X')	HospReg_sort = 1;
	when ('Y')	HospReg_sort = 2;
	when ('Z')	HospReg_sort = 3;
otherwise;
end;
run;

*    1-4. Department;
*         - First, define the format;
proc format;
value DptmtFmt 1 = 'TB & Chest d'
               2 = 'anesthesia'
               3 = 'gynecology'
               4 = 'radiotherapy'
               5 = 'surgery';
run;

*         - Next, create sorting variable;
data WORK.TRAIN_DATA;
format Department_sort DptmtFmt.;
set WORK.TRAIN_DATA;
select (Department);
	when ('TB & Chest d')	Department_sort = 1;
	when ('anesthesia')		Department_sort = 2;
	when ('gynecology')		Department_sort = 3;
	when ('radiotherapy')	Department_sort = 4;
	when ('surgery')		Department_sort = 5;
otherwise;
end;
run;

*    1-5. Ward type;
*         - First, define the format;
proc format;
value WdtypFmt 1 = 'P'
               2 = 'Q'
               3 = 'R'
               4 = 'S'
               5 = 'T';
run;

*         - Next, create sorting variable;
data WORK.TRAIN_DATA;
format Ward_Type_sort WdtypFmt.;
set WORK.TRAIN_DATA;
select (Ward_Type);
	when ('P')	Ward_Type_sort = 1;
	when ('Q')	Ward_Type_sort = 2;
	when ('R')	Ward_Type_sort = 3;
	when ('S')	Ward_Type_sort = 4;
	when ('T')	Ward_Type_sort = 5;
otherwise;
end;
run;

*    1-6. Ward Facility Code;
*         - First, define the format;
proc format;
value WdfclFmt 1 = 'A'
               2 = 'B'
               3 = 'C'
               4 = 'D'
               5 = 'E'
               6 = 'F';
run;

*         - Next, create sorting variable;
data WORK.TRAIN_DATA;
format Ward_FclCd_sort WdfclFmt.;
set WORK.TRAIN_DATA;
select (Ward_Facility_Code);
	when ('A')	Ward_FclCd_sort = 1;
	when ('B')	Ward_FclCd_sort = 2;
	when ('C')	Ward_FclCd_sort = 3;
	when ('D')	Ward_FclCd_sort = 4;
	when ('E')	Ward_FclCd_sort = 5;
	when ('F')	Ward_FclCd_sort = 6;
otherwise;
end;
run;

*    1-7. Bed Grade;
*         - First, define the format;
proc format;
value BedGdFmt 1 = '1'
               2 = '2'
               3 = '3'
               4 = '4'
               5 = 'NA';
run;

*         - Next, modify the variable name to exclude any spaces;
data WORK.TRAIN_DATA;
	set WORK.TRAIN_DATA;
	rename 'Bed Grade'n = Bed_Grade;
run;

*         - Then, create sorting variable;
data WORK.TRAIN_DATA;
format Bed_Grade_sort BedGdFmt.;
set WORK.TRAIN_DATA;
select (Bed_Grade);
	when (1)	Bed_Grade_sort = 1;
	when (2)	Bed_Grade_sort = 2;
	when (3)	Bed_Grade_sort = 3;
	when (4)	Bed_Grade_sort = 4;
	when (.)	Bed_Grade_sort = 5;
otherwise;
end;
run;

*    1-8. City Code (Patient);
*         - First, define the format;
proc format;
value CtCdPtFmt 101 = '1'
                102 = '2'
                103 = '3'
                104 = '4'
                105 = '5'
                106 = '6'
                107 = '7'
                108 = '8'
                109 = '9'
                110 = '10'
                111 = '11'
                112 = '12'
                113 = '13'
                114 = '14'
                115 = '15'
                116 = '16'
                117 = '17'
                118 = '18'
                119 = '19'
                120 = '20'
                121 = '21'
                122 = '22'
                123 = '23'
                124 = '24'
                125 = '25'
                126 = '26'
                127 = '27'
                128 = '28'
                129 = '29'
                130 = '30'
                131 = '31'
                132 = '32'
                133 = '33'
                134 = '34'
                135 = '35'
                136 = '36'
                137 = '37'
                138 = '38';
run;

*         - Next, create sorting variable;
data WORK.TRAIN_DATA;
format CityCd_Pt_sort CtCdPtFmt.;
set WORK.TRAIN_DATA;
select (City_Code_Patient);
	when ('1')	CityCd_Pt_sort = 101;
	when ('2')	CityCd_Pt_sort = 102;
	when ('3')	CityCd_Pt_sort = 103;
	when ('4')	CityCd_Pt_sort = 104;
	when ('5')	CityCd_Pt_sort = 105;
	when ('6')	CityCd_Pt_sort = 106;
	when ('7')	CityCd_Pt_sort = 107;
	when ('8')	CityCd_Pt_sort = 108;
	when ('9')	CityCd_Pt_sort = 109;
	when ('10')	CityCd_Pt_sort = 110;
	when ('11')	CityCd_Pt_sort = 111;
	when ('12')	CityCd_Pt_sort = 112;
	when ('13')	CityCd_Pt_sort = 113;
	when ('14')	CityCd_Pt_sort = 114;
	when ('15')	CityCd_Pt_sort = 115;
	when ('16')	CityCd_Pt_sort = 116;
	when ('17')	CityCd_Pt_sort = 117;
	when ('18')	CityCd_Pt_sort = 118;
	when ('19')	CityCd_Pt_sort = 119;
	when ('20')	CityCd_Pt_sort = 120;
	when ('21')	CityCd_Pt_sort = 121;
	when ('22')	CityCd_Pt_sort = 122;
	when ('23')	CityCd_Pt_sort = 123;
	when ('24')	CityCd_Pt_sort = 124;
	when ('25')	CityCd_Pt_sort = 125;
	when ('26')	CityCd_Pt_sort = 126;
	when ('27')	CityCd_Pt_sort = 127;
	when ('28')	CityCd_Pt_sort = 128;
	when ('29')	CityCd_Pt_sort = 129;
	when ('30')	CityCd_Pt_sort = 130;
	when ('31')	CityCd_Pt_sort = 131;
	when ('32')	CityCd_Pt_sort = 132;
	when ('33')	CityCd_Pt_sort = 133;
	when ('34')	CityCd_Pt_sort = 134;
	when ('35')	CityCd_Pt_sort = 135;
	when ('36')	CityCd_Pt_sort = 136;
	when ('37')	CityCd_Pt_sort = 137;
	when ('38')	CityCd_Pt_sort = 138;
otherwise;
end;
run;

*    1-9. Type of Admission;
*         - First, define the format;
proc format;
value TypAdFmt 1 = 'Emergency'
               2 = 'Trauma'
               3 = 'Urgent';
run;

*         - Next, modify the variable name to exclude any spaces;
data WORK.TRAIN_DATA;
	set WORK.TRAIN_DATA;
	rename 'Type of Admission'n = Type_of_Admission;
run;

*         - Then, create sorting variable;
data WORK.TRAIN_DATA;
format Typ_Adm_sort TypAdFmt.;
set WORK.TRAIN_DATA;
select (Type_of_Admission);
	when ('Emergency')	Typ_Adm_sort = 1;
	when ('Trauma')		Typ_Adm_sort = 2;
	when ('Urgent')		Typ_Adm_sort = 3;
otherwise;
end;
run;

*    1-10. Severity of Illness;
*         - First, define the format;
proc format;
value SvrIlFmt 1 = 'Extreme'
               2 = 'Moderate'
               3 = 'Minor';
run;

*         - Next, modify the variable name to exclude any spaces;
data WORK.TRAIN_DATA;
	set WORK.TRAIN_DATA;
	rename 'Severity of Illness'n = Severity_of_Illness;
run;

*         - Then, create sorting variable;
data WORK.TRAIN_DATA;
format Svr_Illn_sort SvrIlFmt.;
set WORK.TRAIN_DATA;
select (Severity_of_Illness);
	when ('Extreme')	Svr_Illn_sort = 1;
	when ('Moderat')	Svr_Illn_sort = 2;
	when ('Minor')		Svr_Illn_sort = 3;
otherwise;
end;
run;

*    1-11. Age;
*         - First, define the format;
proc format;
value AgeFmt 5    = '0-10'
             15.5 = '11-20'
		     25.5 = '21-30'
             35.5 = '31-40'
	         45.5 = '41-50'
             55.5 = '51-60'
	  	     65.5 = '61-70'
             75.5 = '71-80'
		     85.5 = '81-90'
             95.5 = '91-100';
run;

*         - Next, create sorting variable;
data WORK.TRAIN_DATA;
format Age_sort AgeFmt.;
set WORK.TRAIN_DATA;
select (Age);
	when ('0-10')	Age_sort = 5;
	when ('11-20')	Age_sort = 15.5;
	when ('21-30')	Age_sort = 25.5;
	when ('31-40')	Age_sort = 35.5;
	when ('41-50')	Age_sort = 45.5;
	when ('51-60')	Age_sort = 55.5;
	when ('61-70')	Age_sort = 65.5;
	when ('71-80')	Age_sort = 75.5;
	when ('81-90')	Age_sort = 85.5;
	when ('91-10')	Age_sort = 95.5;
otherwise;
end;
run;



* 2. Check missing data;
ods noproctitle;
proc format;
	value _nmissprint low-high="Non-missing";
	value $_cmissprint " "=" " other="Non-missing";
run;

proc freq data=CURICUP.TRAIN_DATA;
	title3 "Missing Data Frequencies";
	title4 h=2 "Legend: ., A, B, etc = Missing";
	format case_id Hospital_code City_Code_Hospital 
		'Available Extra Rooms in Hospita'n 'Bed Grade'n patientid City_Code_Patient 
		'Visitors with Patient'n Admission_Deposit _nmissprint.;
	format Hospital_type_code Hospital_region_code Department Ward_Type 
		Ward_Facility_Code 'Type of Admission'n 'Severity of Illness'n Age 
		Stay $_cmissprint.;
	tables case_id Hospital_code Hospital_type_code City_Code_Hospital 
		Hospital_region_code 'Available Extra Rooms in Hospita'n Department Ward_Type 
		Ward_Facility_Code 'Bed Grade'n patientid City_Code_Patient 
		'Type of Admission'n 'Severity of Illness'n 'Visitors with Patient'n Age 
		Admission_Deposit Stay / missing nocum;
run;

proc freq data=CURICUP.TRAIN_DATA noprint;
	table case_id * Hospital_code * Hospital_type_code * City_Code_Hospital * 
		Hospital_region_code * 'Available Extra Rooms in Hospita'n * Department * 
		Ward_Type * Ward_Facility_Code * 'Bed Grade'n * patientid * City_Code_Patient 
		* 'Type of Admission'n * 'Severity of Illness'n * 'Visitors with Patient'n * 
		Age * Admission_Deposit * Stay / missing out=Work._MissingData_;
	format case_id Hospital_code City_Code_Hospital 
		'Available Extra Rooms in Hospita'n 'Bed Grade'n patientid City_Code_Patient 
		'Visitors with Patient'n Admission_Deposit _nmissprint.;
	format Hospital_type_code Hospital_region_code Department Ward_Type 
		Ward_Facility_Code 'Type of Admission'n 'Severity of Illness'n Age 
		Stay $_cmissprint.;
run;

proc print data=Work._MissingData_ noobs label;
	title3 "Missing Data Patterns across Variables";
	title4 h=2 "Legend: ., A, B, etc = Missing";
	format case_id Hospital_code City_Code_Hospital 
		'Available Extra Rooms in Hospita'n 'Bed Grade'n patientid City_Code_Patient 
		'Visitors with Patient'n Admission_Deposit _nmissprint.;
	format Hospital_type_code Hospital_region_code Department Ward_Type 
		Ward_Facility_Code 'Type of Admission'n 'Severity of Illness'n Age 
		Stay $_cmissprint.;
	label count="Frequency" percent="Percent";
run;
title3;

/* Clean up */
proc delete data=Work._MissingData_;
run;





* ===== EDA =====;
* 1. Univariate data visualization.;
ods graphics / reset width=6in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Length of Stay";
	vbar Stay_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Hospital Code";
	vbar Hospital_code;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Hospital Type Code";
	vbar HospTyp_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of City Code of the Hospital";
	vbar City_Code_Hospital;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Hospital Region";
	vbar HospReg_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Available Extra Rooms in Hospital";
	vbar 'Available Extra Rooms in Hospita'n;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Department";
	vbar Department_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Ward Type";
	vbar Ward_Type_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Ward Facility";
	vbar Ward_FclCd_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Bed Grade";
	vbar Bed_Grade_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of City Code of Patient";
	vbar CityCd_Pt_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Type of Admission";
	vbar Typ_Adm_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Severity of Illness";
	vbar Svr_Illn_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Visitors with Patient";
	vbar 'Visitors with Patient'n;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Distribution of Age (Group)";
	vbar Age_sort;
run;

proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Deposit Amount at Admission";
	hbox Admission_Deposit;
run;
ods graphics / reset;


* 2. Display heatmap of LOS by some categorical predictors (features);
ods graphics / reset width=8in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Heatmap of Length of Stay by Hospital";
	heatmap x=Hospital_code y=Stay_sort / name='HeatMap' XBINSIZE=0.5 YBINSIZE=5;
	xaxis grid values=(1 to 32 by 1) valueshint label="Hospital (Code)";	
	yaxis grid values=(5 15.5 to 105.5 by 10) valueshint label="Length of Stay";		
	gradlegend 'HeatMap';
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title height=14pt "Bar Chart of Length of Stay (panel: Hospital Type)";
	panelby HospTyp_sort / columns=4 rows=2 novarname;
	vbar Stay_sort / stat=freq nostatlabel;
	rowaxis label="Frequency";
	colaxis label="Length of Stay";
run;
ods graphics / reset;

ods graphics / reset width=6in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Heatmap of Length of Stay by City Code of the Hospital";
	heatmap x=City_Code_Hospital y=Stay_sort / name='HeatMap' XBINSIZE=0.5 YBINSIZE=5;
	xaxis grid values=(1 to 13 by 1) valueshint label="City Code of Hospital";	
	yaxis grid values=(5 15.5 to 105.5 by 10) valueshint label="Length of Stay";		
	gradlegend 'HeatMap';
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title height=14pt "Bar Chart of Length of Stay (panel: Hospital Region)";
	panelby HospReg_sort / columns=3 novarname;
	vbar Stay_sort / stat=freq nostatlabel;
	rowaxis label="Frequency";
	colaxis label="Length of Stay";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title height=14pt "Bar Chart of Length of Stay";
	title2 height=12pt " (panel: Department in Charge at Hospital)";
	panelby Department_sort / columns=3 rows=2 novarname;
	vbar Stay_sort / stat=freq nostatlabel;
	rowaxis label="Frequency";
	colaxis label="Length of Stay";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title height=14pt "Bar Chart of Length of Stay (panel: Ward Type)";
	panelby Ward_Type_sort / columns=3 rows=2 novarname;
	vbar Stay_sort / stat=freq nostatlabel;
	rowaxis label="Frequency";
	colaxis label="Length of Stay";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title  height=14pt "Bar Chart of Length of Stay";
	title2 height=12pt "(panel: Ward Facility)";
	panelby Ward_FclCd_sort / columns=3 rows=2 novarname;
	vbar Stay_sort / stat=freq nostatlabel;
	rowaxis label="Frequency";
	colaxis label="Length of Stay";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title height=14pt "Bar Chart of Length of Stay (panel: Bed Grade)";
	panelby Bed_Grade_sort / columns=3 rows=2 novarname;
	vbar Stay_sort / stat=freq nostatlabel;
	rowaxis label="Frequency";
	colaxis label="Length of Stay";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title  height=14pt "Heatmap of Length of Stay by City";
	title2 height=14pt "(Where Patients Are from)";
	heatmap x=CityCd_Pt_sort y=Stay_sort / name='HeatMap' XBINSIZE=0.5 YBINSIZE=5;
	xaxis grid values=(1 to 38 by 1) valueshint label="City Code of Patient";
	yaxis grid values=(5 15.5 to 105.5 by 10) valueshint label="Length of Stay";		
	gradlegend 'HeatMap';
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title  height=14pt "Bar Chart of Length of Stay";
	title2 height=12pt "(panel: Type of Admission)";
	panelby Typ_Adm_sort / columns=3 novarname;
	vbar Stay_sort / stat=freq nostatlabel;
	rowaxis label="Frequency";
	colaxis label="Length of Stay";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title  height=14pt "Bar Chart of Length of Stay";
	title2 height=12pt "(panel: Severity of Illness)";
	panelby Svr_Illn_sort / columns=3 novarname;
	vbar Stay_sort / stat=freq nostatlabel;
	rowaxis label="Frequency";
	colaxis label="Length of Stay";
run;
ods graphics / reset;

ods graphics / reset width=6.4in height=4.8in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Heatmap of Length of Stay by Age Group";
	heatmap x=Age_sort y=Stay_sort / name='HeatMap' XBINSIZE=5 YBINSIZE=5;
	xaxis grid values=(5 15.5 to 95.5 by 10) valueshint label="Age";	
	yaxis grid values=(5 15.5 to 105.5 by 10) valueshint label="Length of Stay";		
	gradlegend 'HeatMap';
run;
ods graphics / reset;



* 3. Graphs of LOS by some continuous predictors (features);
ods graphics / reset width=8in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title  height=14pt "Box Plot of Available Extra Rooms";
	title2 height=14pt "in Hospital by Length of Stay";
	vbox "Available Extra Rooms in Hospita"n / category=Stay_sort;
	xaxis label="Length of Stay";	
	yaxis label="Available Extra Rooms in Hospital";			
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title height=14pt "Box Plot of Visitors with a Patient by Length of Stay";
	vbox "Visitors with Patient"n / category=Stay_sort;
	xaxis label="Length of Stay";
	yaxis label="Visitors with Patient";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title  height=14pt "Box Plot of Deposit Amount at Admission";
	title2 height=14pt "by Length of Stay";
	vbox Admission_Deposit / category=Stay_sort;
	xaxis label="Length of Stay";
	yaxis label="Deposit Amount at Admission";
run;
ods graphics / reset;



* 4. Visualization only by multiple predictors;
ods graphics / reset width=8in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title  height=14pt "Box Plot of Available Extra Rooms";
	title2 height=14pt "in Hospital by Severity of Illness";
	vbox "Available Extra Rooms in Hospita"n / category=Svr_Illn_sort;
	xaxis label="Severity of Illness";
	yaxis label="Visitors with Patient";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title  height=14pt "Box Plot of Visitors with a Patient";
	title2 height=14pt "by Severity of Illness";
	vbox "Visitors with Patient"n / category=Svr_Illn_sort;
	xaxis label="Severity of Illness";
	yaxis label="Visitors with Patient";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title  height=14pt "Box Plot of Deposit Amount at Admission";
	title2 height=14pt "by Severity of Illness";
	vbox Admission_Deposit / category=Svr_Illn_sort;
	xaxis label="Severity of Illness";
	yaxis label="Deposit Amount at Admission";
run;
ods graphics / reset;



* 5. Visualization using more than 2 predictors (features);
ods graphics / reset width=8in height=7in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title  height=14pt "Heatmap of Length of Stay by Age Group";
	title2 height=12pt "(panel: Severity of Illness by Admission Type)";
	panelby Svr_Illn_sort Type_of_Admission / columns=3 novarname;
	heatmap x=Age_sort y=Stay_sort / name='HeatMap' XBINSIZE=5 YBINSIZE=5;
	rowaxis values=(5 15.5 to 105.5 by 10) label="Length of Stay";
	colaxis values=(5 15.5 to 95.5 by 9) label="Age Group";
	gradlegend 'HeatMap';
run;
ods graphics / reset;

ods graphics / reset width=8in height=13in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title  height=14pt "Box Plot of Length of Stay by Bed Grade";
	title2 height=12pt "(panel: Hospital Type)";
	panelby HospTyp_sort / columns=3 rows=3 novarname;
	vbox Stay_sort / category=Bed_Grade_sort;
	rowaxis label="Length of Stay";
	colaxis label="Bed Grade";
run;
ods graphics / reset;

ods graphics / reset width=8in height=13in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title  height=14pt "Box Plot of Available Extra Rooms in Hospital";
	title2 height=14pt "by Length of Stay";	
	title3 height=12pt "(panel: Hospital City by Hospital Region)";
	panelby HospReg_sort City_Code_Hospital / columns=3 rows=4 novarname;
	hbox "Available Extra Rooms in Hospita"n / category=Stay_sort;
	rowaxis label="Length of Stay";
	colaxis label="Available Extra Rooms in Hospital";
run;
ods graphics / reset;

ods graphics / reset width=8in height=5in imagemap;
proc sgpanel data=WORK.TRAIN_DATA;
	title  height=14pt "Box Plot of Visitors with Patient by Length of Stay";
	title2 height=12pt "(panel: Severity of Illness)";
	panelby Svr_Illn_sort / columns=3 novarname;
	hbox "Visitors with Patient"n / category=Stay_sort;
run;
title;
ods graphics / reset;



* 6. Save only the columns in use (within TRAIN_DATA);
data WORK.TRAIN_DATA 
	(keep=Hospital_code HospTyp_sort City_Code_Hospital HospReg_sort 
	'Available Extra Rooms in Hospita'n Department_sort Ward_Type_sort Ward_FclCd_sort 
	Bed_Grade_sort CityCd_Pt_sort Typ_Adm_sort Svr_Illn_sort 
	'Visitors with Patient'n Age_sort Admission_Deposit Stay_sort);
	
	retain Hospital_code HospTyp_sort City_Code_Hospital HospReg_sort 
	'Available Extra Rooms in Hospita'n Department_sort Ward_Type_sort Ward_FclCd_sort 
	Bed_Grade_sort CityCd_Pt_sort Typ_Adm_sort Svr_Illn_sort 
	'Visitors with Patient'n Age_sort Admission_Deposit Stay_sort;
	
	set WORK.TRAIN_DATA;
run;



* 7. Do all the data modification procedure above to TEST_DATA;
*   - Merge TEST_DATA and SAMPLE_SUB (outcome data for test data).;
data WORK.TEST_DATA_MERGED;
   merge WORK.TEST_DATA WORK.SAMPLE_SUB;
   by case_id;
run;

*   - Add sorting variable like done for TRAIN_DATA;
*     - 7-1. Stay (LOS);
data WORK.TEST_DATA_MERGED;
format Stay_sort StyFmt.;
set WORK.TEST_DATA_MERGED;
select (Stay);
	when ('0-10')	Stay_sort = 5;
	when ('11-20')	Stay_sort = 15.5;
	when ('21-30')	Stay_sort = 25.5;
	when ('31-40')	Stay_sort = 35.5;
	when ('41-50')	Stay_sort = 45.5;
	when ('51-60')	Stay_sort = 55.5;
	when ('61-70')	Stay_sort = 65.5;
	when ('71-80')	Stay_sort = 75.5;
	when ('81-90')	Stay_sort = 85.5;
	when ('91-10')	Stay_sort = 95.5;
	when ('More')	Stay_sort = 105.5;
otherwise;
end;
run;

*     - 7-2. Hospital_type_code;
data WORK.TEST_DATA_MERGED;
format HospTyp_sort HospTypFmt.;
set WORK.TEST_DATA_MERGED;
select (Hospital_type_code);
	when ('a')	HospTyp_sort = 1;
	when ('b')	HospTyp_sort = 2;
	when ('c')	HospTyp_sort = 3;
	when ('d')	HospTyp_sort = 4;
	when ('e')	HospTyp_sort = 5;
	when ('f')	HospTyp_sort = 6;
	when ('g')	HospTyp_sort = 7;
otherwise;
end;
run;

*     - 7-3. Hospital_region_code;
data WORK.TEST_DATA_MERGED;
format HospReg_sort HospRegFmt.;
set WORK.TEST_DATA_MERGED;
select (Hospital_region_code);
	when ('X')	HospReg_sort = 1;
	when ('Y')	HospReg_sort = 2;
	when ('Z')	HospReg_sort = 3;
otherwise;
end;
run;

*     - 7-4. Department;
data WORK.TEST_DATA_MERGED;
format Department_sort DptmtFmt.;
set WORK.TEST_DATA_MERGED;
select (Department);
	when ('TB & Chest d')	Department_sort = 1;
	when ('anesthesia')		Department_sort = 2;
	when ('gynecology')		Department_sort = 3;
	when ('radiotherapy')	Department_sort = 4;
	when ('surgery')		Department_sort = 5;
otherwise;
end;
run;

*     - 7-5. Ward type;
data WORK.TEST_DATA_MERGED;
format Ward_Type_sort WdtypFmt.;
set WORK.TEST_DATA_MERGED;
select (Ward_Type);
	when ('P')	Ward_Type_sort = 1;
	when ('Q')	Ward_Type_sort = 2;
	when ('R')	Ward_Type_sort = 3;
	when ('S')	Ward_Type_sort = 4;
	when ('T')	Ward_Type_sort = 5;
otherwise;
end;
run;

*     - 7-6. Ward Facility Code;
data WORK.TEST_DATA_MERGED;
format Ward_FclCd_sort WdfclFmt.;
set WORK.TEST_DATA_MERGED;
select (Ward_Facility_Code);
	when ('A')	Ward_FclCd_sort = 1;
	when ('B')	Ward_FclCd_sort = 2;
	when ('C')	Ward_FclCd_sort = 3;
	when ('D')	Ward_FclCd_sort = 4;
	when ('E')	Ward_FclCd_sort = 5;
	when ('F')	Ward_FclCd_sort = 6;
otherwise;
end;
run;

*     - 7-7. Bed Grade;
data WORK.TEST_DATA_MERGED; /* Modify the variable name to exclude any spaces */
	set WORK.TEST_DATA_MERGED;
	rename 'Bed Grade'n = Bed_Grade;
run;

data WORK.TEST_DATA_MERGED; /* Then, create sorting variable*/
format Bed_Grade_sort BedGdFmt.;
set WORK.TEST_DATA_MERGED;
select (Bed_Grade);
	when (1)	Bed_Grade_sort = 1;
	when (2)	Bed_Grade_sort = 2;
	when (3)	Bed_Grade_sort = 3;
	when (4)	Bed_Grade_sort = 4;
	when (.)	Bed_Grade_sort = 5;
otherwise;
end;
run;

*     - 7-8. City Code (Patient);
data WORK.TEST_DATA_MERGED;
format CityCd_Pt_sort CtCdPtFmt.;
set WORK.TEST_DATA_MERGED;
select (City_Code_Patient);
	when ('1')	CityCd_Pt_sort = 101;
	when ('2')	CityCd_Pt_sort = 102;
	when ('3')	CityCd_Pt_sort = 103;
	when ('4')	CityCd_Pt_sort = 104;
	when ('5')	CityCd_Pt_sort = 105;
	when ('6')	CityCd_Pt_sort = 106;
	when ('7')	CityCd_Pt_sort = 107;
	when ('8')	CityCd_Pt_sort = 108;
	when ('9')	CityCd_Pt_sort = 109;
	when ('10')	CityCd_Pt_sort = 110;
	when ('11')	CityCd_Pt_sort = 111;
	when ('12')	CityCd_Pt_sort = 112;
	when ('13')	CityCd_Pt_sort = 113;
	when ('14')	CityCd_Pt_sort = 114;
	when ('15')	CityCd_Pt_sort = 115;
	when ('16')	CityCd_Pt_sort = 116;
	when ('17')	CityCd_Pt_sort = 117;
	when ('18')	CityCd_Pt_sort = 118;
	when ('19')	CityCd_Pt_sort = 119;
	when ('20')	CityCd_Pt_sort = 120;
	when ('21')	CityCd_Pt_sort = 121;
	when ('22')	CityCd_Pt_sort = 122;
	when ('23')	CityCd_Pt_sort = 123;
	when ('24')	CityCd_Pt_sort = 124;
	when ('25')	CityCd_Pt_sort = 125;
	when ('26')	CityCd_Pt_sort = 126;
	when ('27')	CityCd_Pt_sort = 127;
	when ('28')	CityCd_Pt_sort = 128;
	when ('29')	CityCd_Pt_sort = 129;
	when ('30')	CityCd_Pt_sort = 130;
	when ('31')	CityCd_Pt_sort = 131;
	when ('32')	CityCd_Pt_sort = 132;
	when ('33')	CityCd_Pt_sort = 133;
	when ('34')	CityCd_Pt_sort = 134;
	when ('35')	CityCd_Pt_sort = 135;
	when ('36')	CityCd_Pt_sort = 136;
	when ('37')	CityCd_Pt_sort = 137;
	when ('38')	CityCd_Pt_sort = 138;
otherwise;
end;
run;

*     - 7-9. Type of Admission;
data WORK.TEST_DATA_MERGED; /* Next, modify the variable name to exclude any spaces*/
	set WORK.TEST_DATA_MERGED;
	rename 'Type of Admission'n = Type_of_Admission;
run;

data WORK.TEST_DATA_MERGED; /* Then, create sorting variable */
format Typ_Adm_sort TypAdFmt.;
set WORK.TEST_DATA_MERGED;
select (Type_of_Admission);
	when ('Emergency')	Typ_Adm_sort = 1;
	when ('Trauma')		Typ_Adm_sort = 2;
	when ('Urgent')		Typ_Adm_sort = 3;
otherwise;
end;
run;

*     - 7-10. Severity of Illness;
data WORK.TEST_DATA_MERGED; /* Next, modify the variable name to exclude any spaces*/
	set WORK.TEST_DATA_MERGED;
	rename 'Severity of Illness'n = Severity_of_Illness;
run;

data WORK.TEST_DATA_MERGED; /* Then, create sorting variable */
format Svr_Illn_sort SvrIlFmt.;
set WORK.TEST_DATA_MERGED;
select (Severity_of_Illness);
	when ('Extreme')	Svr_Illn_sort = 1;
	when ('Moderat')	Svr_Illn_sort = 2;
	when ('Minor')		Svr_Illn_sort = 3;
otherwise;
end;
run;

*     - 7-11. Age;
data WORK.TEST_DATA_MERGED;
format Age_sort StyFmt.;
set WORK.TEST_DATA_MERGED;
select (Age);
	when ('0-10')	Age_sort = 5;
	when ('11-20')	Age_sort = 15.5;
	when ('21-30')	Age_sort = 25.5;
	when ('31-40')	Age_sort = 35.5;
	when ('41-50')	Age_sort = 45.5;
	when ('51-60')	Age_sort = 55.5;
	when ('61-70')	Age_sort = 65.5;
	when ('71-80')	Age_sort = 75.5;
	when ('81-90')	Age_sort = 85.5;
	when ('91-10')	Age_sort = 95.5;
otherwise;
end;
run;

*     - 7-12. Save only the columns in use (TEST_DATA_MERGED);
data WORK.TEST_DATA_MERGED 
	(keep=Hospital_code HospTyp_sort City_Code_Hospital HospReg_sort 
	'Available Extra Rooms in Hospita'n Department_sort Ward_Type_sort Ward_FclCd_sort 
	Bed_Grade_sort CityCd_Pt_sort Typ_Adm_sort Svr_Illn_sort 
	'Visitors with Patient'n Age_sort Admission_Deposit Stay_sort);
	
	retain Hospital_code HospTyp_sort City_Code_Hospital HospReg_sort 
	'Available Extra Rooms in Hospita'n Department_sort Ward_Type_sort Ward_FclCd_sort 
	Bed_Grade_sort CityCd_Pt_sort Typ_Adm_sort Svr_Illn_sort 
	'Visitors with Patient'n Age_sort Admission_Deposit Stay_sort;
	
	set WORK.TEST_DATA_MERGED;
run;



* 8. Correlation check quantitatively (among predictors, TRAIN_DATA);
*    (Note: Correlation matrix is obtained as part of 
			summary of generalized linear model);
proc genmod data=WORK.TRAIN_DATA rorder=internal;
	model Stay_sort=
		Hospital_code HospTyp_sort City_Code_Hospital HospReg_sort 
		'Available Extra Rooms in Hospita'n Department_sort 
		Ward_Type_sort Ward_FclCd_sort Bed_Grade_sort CityCd_Pt_sort 
		Typ_Adm_sort Svr_Illn_sort 'Visitors with Patient'n Age_sort 
		Admission_Deposit 
		/ dist=multinomial 
		  aggregate=(Hospital_code HospTyp_sort 
		             City_Code_Hospital HospReg_sort 
		             Department_sort Ward_Type_sort 
		             Ward_FclCd_sort CityCd_Pt_sort 
		             Typ_Adm_sort) 
		  corrb;
run;
* [Comment] Abs(correlation coefficient) > 0.3 at following predictor combinations.
	- Ward_FclCd_sort vs HospReg_sort (0.48)
	- Ward_Type_sort vs 'Available Extra Rooms in Hospita'n (0.39)
	- Svr_Illn_sort vs Bed_Grade_sort (-0.302)





* ===== Modelling =====;
* 0. Sanity check on the outcome data (both train and test);
ods graphics / reset width=6in height=5in imagemap;
proc sgplot data=WORK.TRAIN_DATA;
	title  height=14pt "Distribution of Length of Stay";
	title2 height=12pt "Training Data";
	vbar Stay_sort;
run;

proc sgplot data=WORK.TEST_DATA_MERGED;
	title  height=14pt "Distribution of Length of Stay";
	title2 height=12pt "Testing Data";
	vbar Stay_sort;
run;
ods graphics / reset;

/* Since testing data shows significantly different distribution of 
   outcomes, all training / validating / testing will be done using only
   training data (WORK.TRAIN_DATA) */

/* Note: propTrain should be less than 1. */
%let propTrain = 0.7;         /* proportion of trainging data */
 
/* create a separate data set for each role */
data Train_Split Test_Split;
	array p[1] _temporary_ (&propTrain);
	set WORK.TRAIN_DATA;
	call streaminit(2022);         /* set random number seed */
	/* RAND("table") returns 1 or 2 with specified probabilities */
	_k = rand("Table", of p[*]);
	if   _k = 1 then output Train_Split;
	else output Test_Split;
drop _k;
run;



* 1. Logistic Regression (Multiordinal);
*   1-1. Procedure - hpgenselect, Selection Method - Stepwise;
title  "Multinomial Logistic Regression";
title2 "Procedure - hpgenselect, Selection Method - LASSO";
proc hpgenselect data=WORK.Train_Split;
	partition fraction(validate=0.97) / seed=2022;
	class Hospital_code HospTyp_sort City_Code_Hospital HospReg_sort 
		  Department_sort Ward_Type_sort Ward_FclCd_sort Bed_Grade_sort 
		  CityCd_Pt_sort Typ_Adm_sort Svr_Illn_sort 
		  Age_sort Stay_sort;
	model Stay_sort(order=internal desc)=
		Hospital_code HospTyp_sort City_Code_Hospital HospReg_sort 
		'Available Extra Rooms in Hospita'n Department_sort 
		Ward_Type_sort Ward_FclCd_sort Bed_Grade_sort CityCd_Pt_sort 
		Typ_Adm_sort Svr_Illn_sort 'Visitors with Patient'n Age_sort 
		Admission_Deposit / cl dist=mult /*link=logit*/; 
	selection method=lasso (stop=none choose=validate) /*details=all*/;
	code File="score_OrdReg01.txt";
run;
title;

/* Dataset of prediction and actual per observation 
   using testing set*/
data score_OrdReg01;
	set WORK.Test_Split;
	%inc "score_OrdReg01.txt";
run;

/* Align format of the prediction column to the actual. */
data score_OrdReg01;
format I_Stay_sort_num StyFmt.;
set score_OrdReg01;
select (I_Stay_sort);
	when ('0-10')	I_Stay_sort_num = 5;
	when ('11-20')	I_Stay_sort_num = 15.5;
	when ('21-30')	I_Stay_sort_num = 25.5;
	when ('31-40')	I_Stay_sort_num = 35.5;
	when ('41-50')	I_Stay_sort_num = 45.5;
	when ('51-60')	I_Stay_sort_num = 55.5;
	when ('61-70')	I_Stay_sort_num = 65.5;
	when ('71-80')	I_Stay_sort_num = 75.5;
	when ('81-90')	I_Stay_sort_num = 85.5;
	when ('91-10')	I_Stay_sort_num = 95.5;
	when ('More')	I_Stay_sort_num = 105.5;
otherwise;
end;
run;

/* Add right/wrong label at each observation for accuracy scoring.*/
data score_OrdReg01;
	set score_OrdReg01;
	if I_Stay_sort_num=Stay_sort then 'Right or Wrong'n="Right";
	else 'Right or Wrong'n="Wrong";
run;

/* Compare prediction vs actual through plotting */
ods graphics / reset width=6in height=5in imagemap;
proc sgplot data=score_OrdReg01;
	title  height=14pt "(Multinomial Logistic Regression) Comparison Plot ";
	title2 height=12pt "Prediction vs Actual Using Testing Data";
	vbox I_Stay_sort_num / category=Stay_sort;
	xaxis label="Actual";	
	yaxis label="Prediction";
run;
title;
ods graphics / reset;

proc freq data=score_OrdReg01 
	(rename=(Stay_sort='Length of Stay (Actual)'n) 
	 rename=(I_Stay_sort_num='Length of Stay (Prediction)'n));
	table 'Length of Stay (Actual)'n*'Length of Stay (Prediction)'n 
		/ nocol norow nopercent;
run;

proc freq data=score_OrdReg01;
	table 'Right or Wrong'n / nocol norow;
run;

/* 
Article about penalized regression (https://support.sas.com/rnd/app/stat/papers/2015/PenalizedRegression_LinearModels.pdf)
Article about automatic normalization (https://communities.sas.com/t5/Statistical-Procedures/Does-HPGENSELECT-standardize-predictors/td-p/252965)
*/



* 2. Random forest model;
title  "Random Forest Model";
proc hpforest data=WORK.Train_Split seed=2022 trainn=5000;
	target Stay_sort / level= ordinal; 
	input 'Available Extra Rooms in Hospita'n 
		  'Visitors with Patient'n
		  Admission_Deposit
		  / level= interval;
	input Hospital_code HospTyp_sort City_Code_Hospital HospReg_sort 
		  Department_sort Ward_Type_sort Ward_FclCd_sort CityCd_Pt_sort 
		  Typ_Adm_sort 
		  / level= nominal;
	input Bed_Grade_sort Svr_Illn_sort Age_sort
		  / level= ordinal;
	save file="/home/u59413028/SasCuriCup/RF_01.bin";
run;

/* Prediction on testing data */
ods select none;
proc hp4score data=WORK.Test_Split;
    score file="/home/u59413028/SasCuriCup/RF_01.bin" out=score_RF01;
run;
ods select all;

/* Align format of the prediction column to the actual. */
data score_RF01;
format I_Stay_sort_num StyFmt.;
set score_RF01;
select (I_Stay_sort);
	when ('0-10')	I_Stay_sort_num = 5;
	when ('11-20')	I_Stay_sort_num = 15.5;
	when ('21-30')	I_Stay_sort_num = 25.5;
	when ('31-40')	I_Stay_sort_num = 35.5;
	when ('41-50')	I_Stay_sort_num = 45.5;
	when ('51-60')	I_Stay_sort_num = 55.5;
	when ('61-70')	I_Stay_sort_num = 65.5;
	when ('71-80')	I_Stay_sort_num = 75.5;
	when ('81-90')	I_Stay_sort_num = 85.5;
	when ('91-10')	I_Stay_sort_num = 95.5;
	when ('More')	I_Stay_sort_num = 105.5;
otherwise;
end;
run;

/* Add right/wrong label at each observation for accuracy scoring.*/
data score_RF01;
	set score_RF01;
	if I_Stay_sort_num=Stay_sort then 'Right or Wrong'n="Right";
	else 'Right or Wrong'n="Wrong";
run;

/* Compare prediction vs actual through plotting */
ods graphics / reset width=6in height=5in imagemap;
proc sgplot data=score_RF01;
	title  height=14pt "(Random Forest) Comparison Plot";
	title2 height=12pt "Prediction vs Actual Using Testing Data";
	vbox I_Stay_sort_num / category=Stay_sort;
	xaxis label="Actual";	
	yaxis label="Prediction";
run;
title;
ods graphics / reset;

proc freq data=score_RF01 
	(rename=(Stay_sort='Length of Stay (Actual)'n) 
	 rename=(I_Stay_sort_num='Length of Stay (Prediction)'n));
	table 'Length of Stay (Actual)'n*'Length of Stay (Prediction)'n 
		/ nocol norow nopercent;
run;

proc freq data=score_RF01;
	table 'Right or Wrong'n / nocol norow;
run;
