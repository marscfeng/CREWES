function trout=clip(trin,amp);
% CLIP performs amplitude clipping on a seismic trace
%
% trout=clip(trin,amp)
%
% CLIP adjusts only those samples on trin which are greater
% in absolute value than 'amp'. These are set equal to amp but
% with the sign of the original sample.
%
% trin= input trace
% amp= clipping amplitude
% trout= output trace
%
% by G.F. Margrave, May 1991
%
if(nargin~=2)
   error('incorrect number of input variables');
end
% find the samples to be clipped
 indices=find(abs(trin)>amp);
% clip them
 trout=trin;
 trout(indices)=sign(trin(indices))*amp; 
