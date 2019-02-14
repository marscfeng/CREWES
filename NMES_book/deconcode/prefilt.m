nlag=1;nop=80;%prediction lag and operator length (in samples)
stab=.00001;%stability constant
a=auto(s,nlag+nop,0);%one-sided auto
a(1)=a(1)*(1.0 +stab);% stabilize the auto
a=a/a(1);%normalize
b=a(nlag+1:nlag+nop);% RHS of pred filt normal equations
prfilt=levrec(a(1:nop),b);% do the levinson recursion
spre=conv(s,prfilt);%the predictable part of s
sun=s-[zeros(nlag,1); spre(1:length(s)-nlag)];%unpredictable
