load wellog
dt=tlog(2)-tlog(1);maxr=max(rcs);
h1=figure;
line(tlog,rcs,'color','k');
text(max(tlog),0,'well');
h2=figure;
arcs=auto2(rcs);
tlag=dt*(-(length(arcs)-1)/2:(length(arcs)-1)/2);
ind=near(tlag,-.3,.3);
line(tlag(ind),arcs(ind),'color','k');
text(max(tlag(ind)),0,'well');
m=[1:6];
for k=1:length(m)
    figure(h1);
    [r,t]=reflec(max(tlog),dt,maxr,m(k),pi);
    line(t,r+k*1.5*maxr,'color','k')
    text(max(t),k*1.5*maxr,['m=' int2str(m(k))]);
    a=auto2(r);
    figure(h2);
    line(tlag(ind),a(ind)+1.2*k,'color','k');
    text(max(tlag(ind)),k*1.2,['m=' int2str(m(k))]);
end
