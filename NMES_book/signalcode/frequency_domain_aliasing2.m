
dt=.004;
fnyq=1/(2*dt);
%dels describes the frequency shift from Nyquist of the frequencies to be
%analyzed. Negative dels are below Nyquist and positive are above
dels=[-20,-10,0,5,15];%should be 5 entries precisely
% dels=[-40 -30 -20 -10 -1];
fs=fnyq*ones(size(dels))+dels;
t=(0:dt:1)';
s=zeros(length(t),length(fs));
names=cell(size(fs));
for k=1:length(fs);
    s(:,k)=sin(2*pi*fs(k)*t)+2*(k-1);
    [S,f]=fftrl(s(:,k)-2*(k-1),t);
    if(k==1)
        A=zeros(length(f),length(fs));
    end
    A(:,k)=abs(S);
    names{k}=[num2str(fs(k)) ' Hz'];
end

figure
subplot(1,2,1)
ind=near(t,.5,.6);
linesgray({t(ind),s(ind,1),'-',.5,.8},{t(ind),s(ind,2),'-',.5,.6},...
    {t(ind),s(ind,3),'-',.5,.4},{t(ind),s(ind,4),'-',.5,.2},...
    {t(ind),s(ind,5),'-',.6,0});
%legend(names)
xlabel('time (sec)')
ht1=text(.501,4.5,'a)');
subplot(1,2,2)
ind=near(f,40,140);
linesgray({f(ind),A(ind,1),'-',.5,.8},{f(ind),A(ind,2),'-',.5,.6},...
    {f(ind),A(ind,3),'-',.5,.4},{f(ind),A(ind,4),'-',.5,.2},...
    {f(ind),A(ind,5),'-',.6,0});
legend(names,'location','northwest')
xlabel('frequency (Hz)')
xlim([40 140])
xtick([85:10:135])
set(gca,'xgrid','on','xticklabelrotation',-90)
ht2=text(42,54,'b)');
prepfig
bigfont(gcf,.8,1)
legendfontsize(.8)
set([ht1,ht2],'fontweight','bold')

print -depsc ..\signalgraphics\fd_aliasing2