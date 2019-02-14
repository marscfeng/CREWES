function trout=fortclip(trin,amp)

for k=1:length(trin)
   if(abs(trin(k)>amp))
      trout(k)=sign(trin(k))*amp;
   end
end
