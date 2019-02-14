%deconvolve the Q synthetic noise-free traces. 
%Be sure to run makeQsynthetic before this
t1=1;t2=1.5;%define the design window
ind=near(t,t1,t2);%indices of design window
mw=mwindow(length(ind),40);%window function
stab=.00001;%decon stab stationary
stabn=.001;%decon stab nonstationary
fsmo=5;%frequency smoother in Hz
nsmo=round(fsmo/t(end));%fsmo in samples
sd=deconf(s,s(ind).*mw,nsmo,stab,1);%stationary case
sqd=deconf(sq,sq(ind).*mw,nsmo,stabn,1);%nonstationary case
sd=sd*norm(r(ind))/norm(sd(ind));%amplitude balance
sqd=sqd*norm(r(ind))/norm(sqd(ind));%amplitude balance
ncc=40;%number of correlation lags
[x,strstat]=maxcorr_ephs(r,sd,ncc);%measure cc and phase
[x,strnon]=maxcorr_ephs(r,sqd,ncc);%measure cc and phase