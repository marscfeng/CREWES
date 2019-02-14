nonstat_synthetic

trow=dt*(0:length(s)-1)';
tnots=[0,.6,1.2];twins=.6;
A=cell(1,3);
Aw=A;
A0=0;
Aw0=0;
for k=1:3
    ind=near(trow,tnots(k),tnots(k)+twins);
    mw=mwindow(length(ind));
    n=length(ind);
    n2=2^nextpow2(n);
    [S,f]=fftrl(sn(ind).*mw,trow(ind),10,n2);
    A{k}=abs(S);
    Atmp=max(A{k});
    if(Atmp>A0); A0=Atmp; end
    tmid=tnots(k)+.5*twins;
    imid=near(t,tmid);
    wp=qmat(:,imid(1));
    [S,f]=fftrl(wp(ind),trow(ind),10,n2);
    Aw{k}=abs(S);
    Atmp=max(Aw{k});
    if(Atmp>Aw0); Aw0=Atmp; end
end

figure
for k=1:3
    subplot(1,3,k);
    hh=linesgray({f,real(todb(A{k},A0)),'-',.5,0},{f,real(todb(Aw{1},Aw0)),'-',1,.5},...
        {f,real(todb(Aw{2},Aw0)),'-.',.5,0},{f,real(todb(Aw{3},Aw0)),':',.5,0});
    ylim([-100 0]);xlim([0 250])
    grid
    if(k==1)
        title({'Shallow window', '(0->0.6 s)'})
        titlefontsize(.8,1)
        xlabel('Frequency (Hz)');
        ylabel('decibels');
    elseif(k==2)
        title({'Intermediate window','(0.6->1.2 s)'})
        titlefontsize(.8,1)
        xlabel('Frequency (Hz)');
    else
        title({'Deep window','(1.2->1.8 s)'})
        titlefontsize(.8,1)
        xlabel('Frequency (Hz)');
        hl=legend('Seismic spectrum','Qmatrix shallow','Qmatrix intermediate','Qmatrix deep');
        set(hl,'position',[0.7685 0.7769 0.1594 0.1394]);
    end
end
prepfig
bigfont(gcf,1.25,1)
legendfontsize(.75)    

print -depsc wavepropgraphics\nonstatspectra_3axe