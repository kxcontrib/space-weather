args:first each .Q.opt .z.x
if[not count args`sdate;2"No sdate arg";exit 1];
if[null sdate:"D"$args`sdate;-2"Invalid sdate arg";exit 2];
if[not count args`edate;2"No edate arg";exit 1];
if[null edate:"D"$args`edate;-2"Invalid edate arg";exit 2];
if[not count dir:args`dir;2"No dir arg";exit 1];
if[not sdate<=edate;-2"edate must be after sdate";exit 3];

magUrl:"http://data.carisma.ca/FGM/1Hz/"
magStn:`mcmu`fsim`fchu!`mcm`fsi`chu

fileArgs:key[magStn]cross sdate+til 1+edate-sdate;

loadMag:{[s;dt]
  0N!url:magUrl,sv["/";ssr[string dt;"."]each("/";"")],upper[string s],".F01.gz";
  cmd:"curl ",url," 2>/dev/null | gunzip -c 2>/dev/null";
  if[(::)~r:@[system;cmd;{[e] -2"Error: ",e;}];:()];
  d:ssr[;"  ";" "]each r;
  t:update{(+)."DV"$'0 8_x}each dt from flip`dt`x`y`z!("*FFF";" ")0:1_d;
  update cs:magStn s from 0!select first x,first y,first z by("n"$"u"$1)xbar"p"$dt from t
 }

start:.z.T;
mag:raze loadMag .'fileArgs
-1"\nReading in mag data took ",string .z.T-start;

if["/"=string[dir][0]0;dir:raze 1_string dir]
dstdir:hsym `$(raze system"pwd"),"/",dir

savemag:{[dir;t;d]0N!.Q.par[dir;d;`$"mag/"]set .Q.en[dir]select from t where d="d"$dt}
savemag[dstdir;mag]each exec distinct"d"$dt from mag;
.Q.chk dstdir;
