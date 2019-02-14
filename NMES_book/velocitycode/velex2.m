plot(v2,t2,v,t,'r*');flipy
vrms=vint2vrms(v2,t2);
tblock=linspace(min(t2),max(t2),10);
vrmsblock=vint2vrms(v2,t2,tblock);
drawvint(t2,vrms);drawvint(tblock,vrmsblock);
vint=vrms2vint(vrmsblock,tblock);
drawvint(tblock,vint);
xlabel('meters/sec');ylabel('seconds');
