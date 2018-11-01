pi:acos(-1); 
shape:{-1_count each first scan x};
log1p:log 1+
round:{y*"j"$x%y}; 
stdscaler:{{(x-y)%z}[;avg x;dev x]each x}
cfm:{[labels;preds] classes:asc distinct preds;:exec 0^(count each group label)classes by pred from([]label:labels;pred:preds);} /returns confusion matrix vals in dict
metrics:{[cnfM] `tn`fn set' first cnfM;`fp`tp set' last cnfM;100*precdict `tn`fn`fp`tp!(tn;fn;fp;tp)} /returns true/false pos/neg values
bc:{[y;score] 
 fps:1+ti-tps:sums[y@:si]ti:-1+1_where differ score,1+last score@:si:idesc score;
 :(fps;tps;score ti);
 } 
gradients:{[x;y]deltas[y]%deltas x};
curveinds:{[x;y]where(-1_differ gradients[x;y]),1b};
roc:{[y;score]u@\:curveinds .(u:@[bc[y;score];0 1;{x%last x}])0 1};
auc:{[x;y]sum 1_(w*y)-.5*deltas[y]*w:deltas x};
rocaucscore:{[y;score]auc . 2#roc[y;score]};
splitIdx:{(0,floor n*sums -1_x%sum x)_neg[n]?n:count y}; /returns indices for train-test split
