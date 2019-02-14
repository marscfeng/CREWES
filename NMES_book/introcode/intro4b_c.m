global NOSIG SCALEOPT;NOSIG=1;SCALEOPT=1;
[r,t]=reflec(1,.002,.2,3,sqrt(pi));%make reflectivity
nt=length(t);
[w,tw]=wavemin(.002,20,.2);%make wavelet
s=convm(r,w);%make convolutional seismogram
ntr=100;%number of traces
seis=zeros(length(s),ntr);%preallocate seismic matrix
shift=round(20*(sin((1:ntr)*2*pi/ntr)+1))+1; %a time shift for each trace
%load the seismic matrix
for k=1:ntr
   seis(1:nt-shift(k)+1,k)=s(shift(k):nt);
end
x=(0:99)*10; %make an x coordinate vector
plotimage(seis,t,x);ylabel('seconds')
prepfig
nudge=.05;
fs=2;
hax=findobj(gcf,'tag','MAINAXES');
pos=get(hax,'position');
set(hax,'position',[pos(1) pos(2)+nudge pos(3) pos(4)-nudge]);
bigfont(gcf,fs,1);title('');xlabel('');
hmsg=findobj(gcf,'tag','messages');set(hmsg,'string','');

print -depsc .\intrographics\intro4b.eps

[seis2,t2,x2]=hardzoom(seis,t,x,[0 500 .1 .5]);

plotimage(seis2,t2,x2);ylabel('seconds')
prepfig
nudge=.05;
hax=findobj(gcf,'tag','MAINAXES');
pos=get(hax,'position');
set(hax,'position',[pos(1) pos(2)+nudge pos(3) pos(4)-nudge]);
bigfont(gcf,fs,1);title('');xlabel('');
hmsg=findobj(gcf,'tag','messages');set(hmsg,'string','');

print -depsc .\intrographics\intro4c.eps