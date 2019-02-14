load .\data\smallshot
% select space-time window and apply simple apply gain
ind=near(t,0,1.5);%time window
indx=near(x,0,950);%space window
seisg=gainmute(seis(ind,indx),t(ind),x(indx),max(x),[0 max(x(indx))],[0 0],1);
%define filter panels using cell arrays
fmins={0, 0, [10 3], [20 3], [40 5]};%cell array of fmin specs
fmaxs={[230 10], [10 5], [20 5], [40 5], [60 5]};%cell array of fmax specs
seisf=cell(size(fmins));%cell array for the panels
As=seisf;%cell array for average amplitude spectra
figure
for k=1:length(seisf)
    subplot(1,5,k)
    seisf{k}=filtf(seisg,t(ind),fmins{k},fmaxs{k},0,80);%apply filter
    imagesc(x(indx),t(ind),seisf{k});%image plot in current axes
    [As{k},f]=aveampspectrum(seisf{k},t(ind));%calculate ave amp spectra
end
colormap('seisclrs')%install the seisclrs colormap