function pos=figpos_ur(pos)
% Check figure position for upper right corner
% 

ss=get(0,'screensize');
ymax=pos(2)+pos(4);
xmax=pos(1)+pos(3);

fudge=20;%pixels

if(xmax>ss(3))
    del=xmax-ss(3);
    pos(1)=pos(1)-del-fudge;
end

if(ymax>ss(4))
    del=ymax-ss(4);
    pos(2)=pos(2)-del-fudge;
end