[nsamp,ntr]=size(seis);

for col=1:ntr
   for row=1:nsamp
      seis(row,col)=scales(col)*seis(row,col);
   end
end
