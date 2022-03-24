options fullstimer=1;

/************************************************/
/* 　径和最小値　　　　　　　　　　　　　　　　　　　　　　　　　　　*/
/************************************************/

*実行環境ROOT　※適宜変更してください;
%let RT_PATH=C:\Users\xxx\Desktop;

*データの場所　※適宜変更してください;
%let Raw	= &RT_PATH.\1 ;
%let OUT	= &RT_PATH.\1 ;

*ライブラリ登録;
libname RAW " &Raw." access = readonly;
libname OUT " &OUT.";

*日付変換マクロ;
%macro DATECONV(VAR=);
	&VAR.=datepart(&VAR.);
	format &VAR. yymmdd10.;
%mend;
/************************************************/
/* ここまで設定
/************************************************/
*必要なデータを抽出  *****試験ごとに設定*****;
data tu_tl2 ;
	set raw.tu_tl;
	keep  Subject InstanceName S_TUTLDTC TRORRES_SUMDIAM;
run;
data rs_tl2 ;
	set raw.rs_tl;
	keep  Subject InstanceName TRDTC_TL TRORRES_SUMDIAM;
run;

*変数名を統一する;
data rs_tl3;
	set rs_tl2;
	rename  TRDTC_TL = DTC;
run;
data tu_tl3;
	set tu_tl2;
	rename  S_TUTLDTC = DTC;
run;

*データセットを縦積みする;
data TL_ALL;
	set rs_tl3 tu_tl3;
	if DTC =. then delete;
	%DATECONV(VAR=DTC);
run;

proc sort data = TL_ALL out = TL_ALL2;
	by subject;
run;

*径和最小値を算出;
proc means data=TL_ALL2 noprint;
	var	TRORRES_SUMDIAM;
	by	Subject ;
	output	out=TU_min(drop=_type_ _freq_)
			min=TU_min;
;
run;

*データをCSVにエクスポート　※適宜変更してください;
PROC EXPORT DATA= work.TL_ALL2
OUTFILE= "&OUT.\最小径和.csv"
DBMS=CSV REPLACE ; PUTNAMES=YES;
RUN;
