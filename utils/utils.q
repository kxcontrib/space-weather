pi:acos(-1); 
shape:{-1_count each first scan x};
log1p:log 1+
round:{y*"j"$x%y}; 
stdscaler:{{(x-y)%z}[;avg x;dev x]each x}
cfm:{[labels;preds] classes:asc distinct preds;:exec 0^(count each group label)classes by pred from([]label:labels;pred:preds);} /returns confusion matrix vals in dict
bc:{[y;score] 
 fps:1+ti-tps:sums[y@:si]ti:-1+1_where differ score,1+last score@:si:idesc score;
 :(fps;tps;score ti);
 } 
gradients:{[x;y]deltas[y]%deltas x};
curveinds:{[x;y]where(-1_differ gradients[x;y]),1b};
roc:{[y;score]u@\:curveinds .(u:@[bc[y;score];0 1;{x%last x}])0 1};
auc:{[x;y]sum 1_(w*y)-.5*deltas[y]*w:deltas x};
rocaucscore:{[y;score]auc . 2#roc[y;score]};
splitIdx:{[x;y]k:neg[n]?n:count y;p:floor x*n;(p _ k;p#k)};
metrics:{$[1=count key x;
            [$[first key x;[`tp set first value x;`tn`fn`fp set'3#0];[`tn set first value x;`tp`fn`fp set'3#0]]];
            [`tn`fn set'first x;`fp`tp set'last x]];
         100*precdict`tn`fn`fp`tp!(tn;fn;fp;tp)};
getTabDate:{[dt;cfg;t]?[t;enlist(=;`date;dt);0b;{x!x}exec colname from cfg where table=t]};
predVal:{[t;hr]t lj 2!?[t;();0b;(`dt`cs,`$"sigPhiVer",string[hr],"hr")!((-;`dt;"u"$60*hr);`cs;`sigPhiVer)]};
