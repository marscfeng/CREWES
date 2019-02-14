%fkspace figure
clear
close all
dt=.002;
dx=10;
fnyq=.5/dt;
kxnyq=.5/dx;
v=4000;
knyq=fnyq/v;

kx=linspace(-kxnyq,kxnyq,1000);
iplus=find(kx>=0);
iminus=find(kx<=0);
f=linspace(0,fnyq,500);
k=f/v;

fmax=.5*fnyq;
kmax=fmax/v;

figure('position',[200,200,1000,1000])
axis([-kxnyq,kxnyq,0,knyq])
set(gca,'xaxislocation','top');
flipy
hwavelike=patch([-kxnyq 0 kxnyq kxnyq -kxnyq],[kxnyq 0 kxnyq knyq knyq],.7*[1 1 1]);
hevanescent=patch([-kxnyq 0 kxnyq kxnyq -kxnyq],[kxnyq 0 kxnyq 0 0],.4*[1 1 1]);

xtick([-kxnyq -kmax 0 kmax kxnyq]);
set(gca,'xticklabel',{'-k_{nyq}','-k_{max}','0','k_{max}','k_{nyq}'});
ytick([0 kmax knyq]);set(gca,'yticklabel',{'0','f_{max}','f_{nyq}'});
xlabel('wavenumber (k_x)');ylabel('frequency (f)')

nlines=21;
delk=2*kmax/(nlines+1);
for j=1:nlines
    know=-kmax+j*delk;
    hzone=linesgray({[know know],[abs(know) kmax],'-',1,.5});
end
hbdy=linesgray({kx(iplus),kx(iplus),'-',1,0},{kx(iminus),-kx(iminus),'-',1,0});
hfmax=linesgray({[-kxnyq kxnyq],[kmax kmax],'--',.5,.99});
hkmax=linesgray({[-kmax -kmax 0 kmax kmax],[0 kmax nan 0 kmax],'--',.5,.99});
hl=legend([hbdy(1) hwavelike hevanescent hzone],'evanescent boundary',...
    'wavelike region','evanescent region','signal band','location','southeast');
set(hl,'position',[0.3287 0.0623 0.3860 0.1855])
ha=arrow([.2*kmax 1.2*kmax],[1.5*kmax 1.2*kmax],'|f/k_x|=v',.99*[1 1 1],.5,'-',.03,1);
set(ha(3),'horizontalalignment','right')
ha2=arrow([-.3*kmax -1.2*kmax],[1.5*kmax 1.2*kmax],'',.99*[1 1 1],.5,'-',.03,1);

whitefig
bigfont(gcf,3,1);
boldlines(gcf,4);
legendfontsize(1)

print -depsc .\signalgraphics\fkspace
