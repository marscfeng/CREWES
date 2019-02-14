function xc=cycle(x,y)
%
% xc=cycle(x,y)
% 
% x can be a vector while y is a number.
% xc is cyclicly wrapped through y. For example
% cycle(1:10,4) returns 
% 1     2     3     4     1     2     3     4     1     2
% 
% This is similar to rem but rem(1:10,4) returns
% 1     2     3     0     1     2     3     0     1     2
%

xc=rem(x,y);
ind=find(xc==0);
if(~isempty(ind))
    xc(ind)=y;
end