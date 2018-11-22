args:first each .Q.opt .z.x
if[not count args`sdate;2"No sdate arg";exit 1];
if[null sdate:"D"$args`sdate;-2"Invalid sdate arg";exit 2];
if[not count args`edate;2"No edate arg";exit 1];
if[null edate:"D"$args`edate;-2"Invalid edate arg";exit 2];
if[not count user:args`user;2"No user arg";exit 1];
if[not count pass:args`pass;2"No pass arg";exit 1];
if[not count dir:args`dir;2"No dir arg";exit 1];
if[not sdate<=edate;-2"edate must be after sdate";exit 3];

/utils
pi:acos -1
sqr:{x*x}
getDoy:{1+x-"d"$1+(-).`month`mm$\:x}

chainUrl:"ftp://chain.physics.unb.ca/gps/ismr"
chainStn:`arv`arc`chu`cor`edm`fsi`fsm`gil`gjo`gri`mcm`rab`ran`rep

fileArgs:(cross/)(chainStn;sdate+til 1+edate-sdate;til 24)

chainCol:raze(31#"S";csv)0:`:chaincols.csv
chainLatLong:1!update long-360 from("SFF";(),csv)0:`:cslatlong.csv

loadChain:{[stn;dt;hr]
  url:0N!"/"sv(chainUrl;yr;sdoy;-2#"0",string hr;string[stn],"c",(-2#yr:string`year$dt),(sdoy:-3#"00",string doy:getDoy dt),(.Q.a hr),".ismr.gz");
  cmd:"curl -u ",user,":",pass," ",url," 2>/dev/null | gunzip -c 2>/dev/null";
  if[(::)~r:@[system;cmd;{[e] -2"Error: ",e;}];:()];
  update dt,doy,cs:stn from t:flip chainCol!(31#"F";csv)0:r}

start:.z.T;
chain:raze loadChain .'fileArgs
-1"\nReading in chain data took ",string .z.T-start;

chain:select from chain where elevation>=30,locktimeSig1>200

chain:update dt+"v"$tow mod 86400 from chain lj chainLatLong
chain:update tec*sqrt 1-sqr cos[elevation*pi%180]*6378.137%6378.137+110 from chain
chain:update s4*sin[elevation*pi%180]xexp .9 from chain
chain:update sigPhiVer*sqrt sin elevation*pi%180 from chain

chain:0!select med tec,med dtec,med s4,med specSlope,med SI,med sigPhiVer by dt,doy,cs from chain

if["/"=string[dir][0]0;dir:raze 1_string dir]
dstdir:hsym `$(raze system"pwd"),"/",dir

savechain:{[dir;t;d]0N!.Q.par[dir;d;`$"chain/"]set .Q.en[dir]select from t where d="d"$dt}
savechain[dstdir;chain]each exec distinct"d"$dt from chain;
.Q.chk dstdir;



