fs=1:120;
dt=.004;
tmax=1;
t=(0:dt:tmax)';
s=zeros(length(t),length(fs));
%now, we attempt to reconstruct at times tint
tint=(dt/2:dt:tmax)';
ind=near(tint,.1,.9);
sint=zeros(length(tint),length(fs));
tc=zeros(1,8);
%make the signals
for k=1:length(fs)
    s(:,k)=sin(2*pi*fs(k)*t);%these are the samples signals
    sint(:,k)=sin(2*pi*fs(k)*tint);%this is the exact result from interpolation
end

%linear
tic
slin=interp1(t,s,tint,'linear');
tc(1)=toc;
%spline
tic
sspline=interp1(t,s,tint,'spline');
tc(2)=toc;
%pchip
tic
spchip=interp1(t,s,tint,'pchip');
tc(3)=toc;
%cubic
tic
scubic=interp1(t,s,tint,'cubic');
tc(4)=toc;
%v5cubic
tic
sv5cubic=interp1(t,s,tint,'v5cubic');
tc(5)=toc;
%16point sinc
tic
ssinc16=interpbl(t,s,tint,8);
tc(6)=toc;
%8point sinc
tic
ssinc8=interpbl(t,s,tint,4);
tc(7)=toc;
%16point sinc untapered
tic
ssinc16un=interpbl(t,s,tint,8,0);
tc(8)=toc;

tc=tc/min(tc);%make times relative to fastest

% measure errors
elin=zeros(1,length(fs));
espline=zeros(1,length(fs));
epchip=zeros(1,length(fs));
esinc16un=zeros(1,length(fs));
esinc8=zeros(1,length(fs));
esinc16=zeros(1,length(fs));
ev5cubic=zeros(1,length(fs));
ecubic=zeros(1,length(fs));
% dnom=sint(:,k)+.01;
dnom=ones(size(tint(ind)));
for k=1:length(fs)
    elin(k)=norm((slin(ind,k)-sint(ind,k))./dnom)/sqrt(length(tint));
    espline(k)=norm((sspline(ind,k)-sint(ind,k))./dnom)/sqrt(length(tint));
    epchip(k)=norm((spchip(ind,k)-sint(ind,k))./dnom)/sqrt(length(tint));
    ecubic(k)=norm((scubic(ind,k)-sint(ind,k))./dnom)/sqrt(length(tint));
    esinc16(k)=norm((ssinc16(ind,k)-sint(ind,k))./dnom)/sqrt(length(tint));
    esinc16un(k)=norm((ssinc16un(ind,k)-sint(ind,k))./dnom)/sqrt(length(tint));
    esinc8(k)=norm((ssinc8(ind,k)-sint(ind,k))./dnom)/sqrt(length(tint));
    ev5cubic(k)=norm((sv5cubic(ind,k)-sint(ind,k))./dnom)/sqrt(length(tint));
end


figure
linesgray({fs,elin,'-',.5,.5},{fs,espline,':',.5,.3.'.'},{fs,ev5cubic,'-',1.5,.8},...
    {fs,epchip,'none',.5,0,'+',2},{fs,ecubic,'none',.5,.5,'o',4},...
    {fs,esinc16,'-',.5,0},{fs,esinc8,'-',.5,0,'o',2},{fs,esinc16un,'-',.5,.7,'o',2});
xlabel('frequency (Hz)'); ylabel('average RMS error')
legend(['linear, ' num2str(tc(1))],['spline, ' num2str(tc(2))],...
    ['v5cubic, ' num2str(tc(5))],['pchip, ' num2str(tc(3))],...
    ['cubic, ' num2str(tc(4))],['sinc 16pt, ' num2str(tc(6))],...
    ['sinc 8pt, ' num2str(tc(7))],['sinc (no taper) 16pt, ' num2str(tc(8))],...
    'location','northwest')
prepfig
bigfont(gcf,1.5,1);
legendfontsize(1)

print -depsc .\signalgraphics\interpolation

%%
t=(0:.004:1)'+1;
f=60;
s=sin(2*pi*f*t);
tint=(0:.002:1)'+1;
s2=sin(2*pi*f*tint);
nreps=100;
% tint=20*.004+.002;
tint(1:5)=nan;
tic
for k=1:nreps
    sint=interpbl(t,s,tint,8);
end
t1=toc;
tic
for k=1:nreps
    sint2=sinci_old(s,t,tint);
end
t2=toc;
tm=min([t1 t2]);
figure
plot(tint,s2,'-ko',tint,sint,'r.',tint,sint2,'b.');
ind=near(t,1.1,1.9);
e1=norm(s2(ind)-sint(ind))/length(ind);
e2=norm(s2(ind)-sint2(ind))/length(ind);
e=min([e1 e2]);

legend('exact',['interpbl, err=' num2str(e1/e),', t=' num2str(t1/tm)],['sinci, err=' num2str(e2/e) ', t=' num2str(t2/tm)])

