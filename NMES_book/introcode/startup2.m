global MYPATH
if(isempty(MYPATH))
   p=path;
   path([p ';C:\MatlabR11\toolbox\local\mytools']);
   MYPATH=path;
else
   path(MYPATH);
end
