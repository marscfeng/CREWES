e=env(s);%compute the Hilbert envelope
tsmo=.2;%define the smoother length in seconds
nsmo=round(tsmo/dt);%smoother length in samples
stab=.01;%define stability constant
esmo=convz(e,ones(nsmo,1))/nsmo;%compute smoothed envelope
emax=max(esmo);%maximum value of the smoothed envelope
sg=s./(esmo+stab*emax);%stabilized division for AEC