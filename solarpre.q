args:first each .Q.opt .z.x
if[not count args`sdate;2"No sdate arg";exit 1];
if[null sdate:"D"$args`sdate;-2"Invalid sdate arg";exit 2];
if[not count args`edate;2"No edate arg";exit 1];
if[null edate:"D"$args`edate;-2"Invalid edate arg";exit 2];
if[not sdate<=edate;-2"edate must be after sdate";exit 3];
if[not count dir:args`dir;2"No dir arg";exit 1];

/utils
pi:acos -1
sqr:{x*x}
atan2:{2*atan x%sqrt[sqr[x]+sqr y]+y}
times:{[int;start]select from([]dt:"p"$s+`minute$til`int$60*24*1+("z"$edate)-s:"z"$start)where 0=i mod int}

solarUrl:"ftp://spdf.gsfc.nasa.gov/pub/data/omni/"
dir5mn:"high_res_omni/omni_5min"
dir1hr:"low_res_omni/omni2_"

col5mn:raze(49#"S";csv)0:`:scols5mn.csv
col1hr:raze(55#"S";csv)0:`:scols1hr.csv

solar5mn:solarUrl,dir5mn
solar1hr:solarUrl,dir1hr

omniDate:"D"$string[-1+`year$sdate],".01.01"
y:(`year$sdate)+til[4]-1

width5mn:4 4 3 3 3 3 4 4 4 7 7 6 7 8 8 8 8 8 8 8 8 8 8 8 8 7 9 6 7 7 6 8 8 8 8 8 8 6 6 6 6 6 6 6 7 5 9 9 9
width1hr:4 4 3 5 3 3 4 4 6 6 6 6 6 6 6 6 6 6 6 6 6 6 9 6 6 6 6 6 6 9 6 6 6 6 6 7 7 6 3 4 6 5 10 9 9 9 9 9 3 4 6 6 6 6 5
dtype5mn:"IIIIIIIIIIIFIFFFFFFFFFFFFFFFFFFFFFFFFIFIIIIIFFFFF"
dtype1hr:"IIIIIIIIFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFIIFIFFFFFFFIFFFIF"

loadSolar:{[y;t]
  input:`width`dtype`url`file`col!$[t=5;(width5mn;dtype5mn;solar5mn;".asc";col5mn);(width1hr;dtype1hr;solar1hr;".dat";col1hr)];
  0N!url:input[`url],string[y],input`file;
  cmd:"curl ",url," 2>/dev/null";
  if[(::)~r:@[system;cmd;{[e] -2"Error: ",e;}];:()];
  flip input[`col]!(input`dtype;input`width)0:r
  }

start:.z.T
solar5mn:raze loadSolar[;5]each y
solar1hr:raze loadSolar[;1]each -3#y
-1"\nReading in solar data took ",string .z.T-start;

solar5mn:update angle:atan2[By;Bz],btot:sqrt sqr[By]+sqr Bz from solar5mn
solar5mn:update borovsky:0.0329*sqr[V*sin angle%2]*sqrt[n]*xexp[mach;-.18]*exp sqrt mach%3.42 from solar5mn
solar5mn:update angle:angle+pi from solar5mn where i in where 0>=cos[angle]*Bz*btot
solar5mn:update newell:xexp[V;1.33333]*xexp[abs sin angle%2;2.66667]*xexp[btot;0.66667] from solar5mn

solar5mn:select dt:times[5;omniDate]`dt,By,Bz,AE,symH,V,P,borovsky:borovsky,newell:newell,proton10,proton30,proton60 from solar5mn
solar5mn:reverse fills reverse times[1;omniDate]lj 1!solar5mn

solar5mn:{[t;lb]
   t lj 1!?[t;();0b;(`dt,`$string[c],\:"_",string lb)!(enlist[(+;`dt;"u"$lb)],c:`By`Bz`AE`symH`V`P`borovsky`newell)]
  }/[solar5mn;15 30]

solar1hr:select dt:times[60;sdate]`dt,f107,kp:kp%10 from solar1hr

solar:lj[solar5mn;1!solar1hr]
solar:select from solar where dt within(sdate;edate)

if["/"=string[dir][0]0;dir:raze 1_string dir]
dstdir:hsym `$(raze system"pwd"),"/",dir

savesolar:{[dir;t;d]0N!.Q.par[dir;d;`$"solar/"]set .Q.en[dir]select from t where d="d"$dt}
savesolar[dstdir;solar]each exec distinct"d"$dt from solar;
.Q.chk dstdir;
