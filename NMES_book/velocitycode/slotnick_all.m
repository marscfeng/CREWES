slotnick1
bigfont(gca,1.8,1);
boldlines;
slotnick2
bigfont(gca,1.8,1);
boldlines;
figure;plot(x/1000,zraypath/1000);flipy;
xlabel('x kilometers');ylabel('z kilometers')
hold;plot(xwavefront/1000,zw/1000);
bigfont(gca,1.8,1);boldlines;
axis([0 30 0 30])
