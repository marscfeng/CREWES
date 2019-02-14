function s=slicem(a,traj,hwid)

[m,n]=size(a);
for k=1:n %loop over columns
	i1=max(1,traj(k)-hwid); %start of slice
	i2=min(m,traj(k)+hwid); %end of slice
	ind=(i1:i2)-traj(k)+hwid; %output indices
	s(ind,k) = a(i1:i2,k); %extract the slice
end
