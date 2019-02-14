  a=auto(trdsign,n,0);% generate the autocorrelation
  a(1)=a(1)*(1.0 +stab);% stabilize the auto
  b=[1.0 zeros(1,length(a)-1)];% RHS normal equations
  x=levrec(a,b);% do the levinson recursion
  trout=convm(trin,x);% deconvolve trin