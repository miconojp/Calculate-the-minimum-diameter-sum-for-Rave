options fullstimer=1;

/************************************************/
/* �@�a�a�ŏ��l�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@*/
/************************************************/

*���s��ROOT�@���K�X�ύX���Ă�������;
%let RT_PATH=C:\Users\xxx\Desktop;

*�f�[�^�̏ꏊ�@���K�X�ύX���Ă�������;
%let Raw	= &RT_PATH.\1 ;
%let OUT	= &RT_PATH.\1 ;

*���C�u�����o�^;
libname RAW " &Raw." access = readonly;
libname OUT " &OUT.";

*���t�ϊ��}�N��;
%macro DATECONV(VAR=);
	&VAR.=datepart(&VAR.);
	format &VAR. yymmdd10.;
%mend;
/************************************************/
/* �����܂Őݒ�
/************************************************/
*�K�v�ȃf�[�^�𒊏o  *****�������Ƃɐݒ�*****;
data tu_tl2 ;
	set raw.tu_tl;
	keep  Subject InstanceName S_TUTLDTC TRORRES_SUMDIAM;
run;
data rs_tl2 ;
	set raw.rs_tl;
	keep  Subject InstanceName TRDTC_TL TRORRES_SUMDIAM;
run;

*�ϐ����𓝈ꂷ��;
data rs_tl3;
	set rs_tl2;
	rename  TRDTC_TL = DTC;
run;
data tu_tl3;
	set tu_tl2;
	rename  S_TUTLDTC = DTC;
run;

*�f�[�^�Z�b�g���c�ς݂���;
data TL_ALL;
	set rs_tl3 tu_tl3;
	if DTC =. then delete;
	%DATECONV(VAR=DTC);
run;

proc sort data = TL_ALL out = TL_ALL2;
	by subject;
run;

*�a�a�ŏ��l���Z�o;
proc means data=TL_ALL2 noprint;
	var	TRORRES_SUMDIAM;
	by	Subject ;
	output	out=TU_min(drop=_type_ _freq_)
			min=TU_min;
;
run;

*�f�[�^��CSV�ɃG�N�X�|�[�g�@���K�X�ύX���Ă�������;
PROC EXPORT DATA= work.TL_ALL2
OUTFILE= "&OUT.\�ŏ��a�a.csv"
DBMS=CSV REPLACE ; PUTNAMES=YES;
RUN;
