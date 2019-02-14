[w,tw]=ricker(.002,40,.2);%make Ricker wavelet
nrot=5;deltheta=45;%number of phases and increment
figure
for k=1:nrot
    theta=(k-1)*deltheta;
    wrot=phsrot(w,theta);%phase rotated wavelet
    xnot=.1*(k-1);ynot=-.1*(k-1);
    line(tw+xnot,wrot+ynot,'color','k');%plot each wavelet
    text(xnot+.005,ynot+.1,[int2str(theta) '^\circ'])
end