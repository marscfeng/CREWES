function vec=multspace(x1,xfactor,xmax)

tmp=zeros(1,1000);

xnow=x1;
count=1;
while xnow<=xmax
    tmp(count)=xnow;
    xnow=xnow*xfactor;
    count=count+1;
end

vec=tmp(1:count-1);