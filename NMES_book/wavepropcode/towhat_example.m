[w,tw]=ricker(.002,40,.2);%make Ricker wavelet
figure
wall
for k=1:nrot
    theta=(k-1)*deltheta;
    wrot=phsrot(w,theta);%phase rotated wavelet
    xnot=.1*(k-1);ynot=-.1*(k-1);
    line(tw+xnot,wrot+ynot);%plot each wavelet
    text(xnot+.005,ynot+.1,[int2str(theta) '^\circ'])
end