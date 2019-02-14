%pad with zero samples
[nsamp,ntr]=size(seis);
seis=[seis;zeros(nzs,ntr)];
%pad with zero traces
seis=[seis zeros(nsamp+nzs,nzt)];
