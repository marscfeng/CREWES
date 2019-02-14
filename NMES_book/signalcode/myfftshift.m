function v2=myfftshift(v)

n=length(v);
n0=ceil((n+1)/2);
nr=n-n0;
nl=n-nr-1;

v2=[v(n0:n) v(1:n0-1)];