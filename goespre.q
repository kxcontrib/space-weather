args:first each .Q.opt .z.x
if[not count args`sdate;2"No sdate arg";exit 1];
if[null sdate:"D"$args`sdate;-2"Invalid sdate arg";exit 2];
if[not count args`edate;2"No edate arg";exit 1];
if[null edate:"D"$args`edate;-2"Invalid edate arg";exit 2];
if[not count dir:args`dir;2"No dir arg";exit 1];
if[not sdate<=edate;-2"edate must be after sdate";exit 3];

goesUrl:"https://satdat.ngdc.noaa.gov/sem/goes/data/full"

fileArgs:sdate+til 1+edate-sdate

loadGoes:{[dt]
  url:0N!"/"sv(goesUrl;string`year$dt;-2#"0",string`mm$dt;"goes15/csv";"g15_xrs_2s_",d,"_",(d:ssr[string dt;".";""]),".csv");  
  cmd:"curl ",url," 2>/dev/null";
  if[(::)~r:@[system;cmd;{[e] -2"Error: ",e;}];:()];
  t:select dt:"p"$first time_tag.datetime,time:first time_tag.time,minute:first time_tag.minute,GOESx:avg B_FLUX by 1 xbar time_tag.minute from("ZSJFSJF";(),csv)0:139_r;
  select dt,goes from update dt:dt-time-minute from t
  }

start:.z.T
goes:raze loadGoes each fileArgs
-1"\nReading in GOES data took ",string .z.T-start;

if["/"=string[dir][0]0;dir:raze 1_string dir]
dstdir:hsym `$(raze system"pwd"),"/",dir

savegoes:{[dir;t;d]0N!.Q.par[dir;d;`$"goes/"]set .Q.en[dir]select from t where d="d"$dt}
savegoes[dstdir;goes]each exec distinct"d"$dt from goes;
.Q.chk dstdir;
