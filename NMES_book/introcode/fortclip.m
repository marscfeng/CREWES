function trout=fortclip(trin,amp)

for k=1:length(trin)
   if(abs(trin(k)>amp))
      trin(k)=sign(trin(k))*amp;
   end
end

trout=trin;
