function enhance(action,arg2)
% ENHANCE: Seismic ANalysis Environment (3D)
%
% Just type ENHANCE and the GUI will appear
%
% ENHANCE establishes an analysis environment for 3D seismic datasets. There is currently no facility
% for 2D. ENHANCE is meant to be used in an energy company environment where 3D seismic volumes must be
% compared, QC'd, and perhaps en'infohanced. To make effective use of ENHANCE you should run this on a
% workstation with lots of RAM. ENHANCE was developed on a computer with 128GB of RAM. It is suggested
% that your workstation should have at least 2 times the RAM of the size of the SEGY volumes that
% you wish to analyze. So, for eaxmple, if you have a 3D dataset that is 10GB as a SEGY file on
% disk, then you should have at least 20GB of RAM available. ENHANCE allows you to read in one or more
% 3D volumes into a project. Its a good idea if the volumes are all somehow related or similar. For
% example maybe they are different processing of the same data. You load these into ENHANCE using the
% "Read SEGY" option and then save the project. Reading SEGY is quite slow but once you save the
% project (as a Matlab binary) further reads are much faster. ENHANCE saves your data internally in
% single precision because that reduces memory and that is how SEGY files are anyway. If your 3D
% dataset has a very irregular patch size, then forming the data into a 3D volume will require
% padding it with lots of zero traces and this can significantly increase memory usage. ENHANCE allows
% you to control which datasets in the project are in memory and which are displayed at any one
% time. Thus it is quite possible to have many more datasets in a project than you can possibly
% display at any one time. Data display is done by sending the data to plotimage3D and you might
% want to check the help for that function. So each dataset you display is in a separate plotimage3D
% window and the windows can be "grouped" to cause them all to show the same view. Plotimage3D can
% show 2D slices of either inline, xline (crossline), or timeslice. In each view there are a number
% of analysis tools available and these are accessed by a right-click of the mouse directly on the
% image plot. Such a right-click brings up a "context menu" of available analysis tools. These tools
% just operate directly on the 2D image that is being displayed. ENHANCE also offers a gradually
% expanding list of "tasks" that are accesible from the "Compute" menu that operate on an entire 3D
% volume and usually produces a same-size 3D volume. Examples are filtering and deconvolution.
%
% G.F. Margrave, Devon Energy, 2017-2018
%
% NOTE: This SOFTWARE may be used by any individual or corporation for any purpose
% with the exception of re-selling or re-distributing the SOFTWARE.
% By using this software, you are agreeing to the terms detailed in this software's
% Matlab source file.

% BEGIN TERMS OF USE LICENSE
%
% This SOFTWARE is maintained by the CREWES Project at the Department
% of Geology and Geophysics of the University of Calgary, Calgary,
% Alberta, Canada.  The copyright and ownership is jointly held by
% its 'AUTHOR' (identified above) and the CREWES Project.  The CREWES
% project may be contacted via email at:  crewesinfo@crewes.org
%
% The term 'SOFTWARE' refers to the Matlab source code, translations to
% any other computer language, or object code
%
% Terms of use of this SOFTWARE
%
% 1) This SOFTWARE may be used by any individual or corporation for any purpose
%    with the exception of re-selling or re-distributing the SOFTWARE.
%
% 2) The AUTHOR and CREWES must be acknowledged in any resulting publications or
%    presentations
%
% 3) This SOFTWARE is provided "as is" with no warranty of any kind
%    either expressed or implied. CREWES makes no warranties or representation
%    as to its accuracy, completeness, or fitness for any purpose. CREWES
%    is under no obligation to provide support of any kind for this SOFTWARE.
%
% 4) CREWES periodically adds, changes, improves or updates this SOFTWARE without
%    notice. New versions will be made available at www.crewes.org .
%
% 5) Use this SOFTWARE at your own risk.
%
% END TERMS OF USE LICENSE

% To Do:
%
% 
% Plotimage3D needs to be able to send signals to enhance. For example when grouping changes
%   - Done: ENHANCE sets the 'tag' of the PI3D figure to 'fromenhance' and the userdata to {idata henhance}
%   where idata is the dataset number and henhance is the handle of the ENHANCE window.
%   - PI3D then calls ENHANCE for: group and ungroup: enhance('pi3d:group',{idata henhance}). This causes
%   ENHANCE to examine the globals and reset the group buttons as needed
%
% Need ability to edit time shifts and to apply coordinate scalars
%
% It would be nice to be able to write out a subset.
%
% Need a way to edit the project structure fields like dx, dy, tshift, filenames, 
%
% Need a way to edit the SEGY text header
% 
% 

% How to edit a ENHANCE Project dataset. ENHANCE project datasets are saved as .mat files with just two
% variables visible at the top level: proj and datasets. proj is a structure with lots of fields and
% datasets is a cell array with the 3D datasets stored in it. The easiest way to edit a dataset from
% the command line is to use the "matfile" facility. If you are unfamiliar with matfile then you
% should read the online help. Suppose enhanceproject.mat is the name of a ENHANCE project file that needs
% to be edited. Then open it like this
% >> m=matfile('enhanceproject.mat','writable',true);
% This command does not read the objects in the file, it just opens them. To read the project
% structure into memory do
% >> proj=m.proj
% where I've left off the semicolon to list the structure fields. If you choose to edit this
% structure, beware that there are lots of implied logical connections between the fields and making
% a change in one field can require a corresponding change in another in order that ENHANCE will
% understand. Also, never change the field names. Notice that the field 'filenames' is a cell array
% with a certain length, there is one filename for each 3D survey in the project. Most, but not all,
% of the fields in proj must also have this same length. So, if you make an edit that changes a
% field length, then you must change all of the other fields in the same way.  Also notice that most
% of the fields are cell arrays but some are ordinary arrays. Be sure to preserve this. There is a
% field in proj called 'datasets' that is a cell array to put the seismic datasets in. When you read
% proj from disk like is done here, this will always be empty and the seismic volumes are all in the
% datasets cell array on disk. The field 'isloaded' is an ordinary array of 1 or 0, for each
% dataset. If 1, then the dataset is read from disk into proj.datasets when the project is first
% opened. The isloaded field reflects the load status of things when the project was last saved.
% ENHANCE reads this upon opening the project and puts up a dialog allowing you to decide what is to be
% loaded and what is to be displayed (there is also an isdisplayed field). When a dataset is
% deleted, the various fields are not shortened in length, rather, the corresponding entry in
% datasets is set to null and the fields 'isdeleted' and 'deletedondisk' are set to indicate
% deletion. To read a dataset from the datasets cell array on disk you must know the number of the
% dataset. This is just the integer number of the dataset in the cell array. In determining this, be
% sure to allow for any deleted datasets by checking the isdeleted field. To read in dataset number
% 3 the two-step syntax is
% >> cdat=m.datasets(1,3);
% >> seis=cdat{1};
% The first line here uses regular round brackets even though we are reading from a cell array. This
% is a 'feature' of the matfile behaviour. Note also that you must use two index addressing like
% (1,3) and not simply (3). This line reads the dataset into a cell array of length 1 and the second
% line is required to unpack the dataset into a conventional 3D matrix. This matrix is stored in the
% order expected by plotimage3D which is with time as dimension 1, xline as dimension 2, and inline
% as dimension3. If you wish to write a new dataset into location 3, the syntax is
% >> m.datasets(1,3)={seis};
% Where seis is a 3D volume of the proper size. If you changed the dimensions of this volume in the
% course of altering it, then you must also update the various coordinate fields that have the same
% dimensions. You may also encounter problems if you try to output a SEGY volume from ENHANCE after
% changing the dimensions. This is because ENHANCE remembers the SEGY headers from the original read
% and tries to reuse them. Deletion of a dataset is similar
% >> m.datasets(1,3)={[]};
% which must be followed with
% >> proj.isdeleted(3)=1;
% >> proj.deletedondisk(3)=1;
% >> m.proj=proj;
% Deletion is the one exception to changing the size of a dataset that does not require
% corresponding changes in the coordinate arrays.

% plan for tasks. There will be two types of tasks, those accesible via the context menu of the
% current view in plotimage3D and those accessible by the tasks menu in Sane. I discuss the latter
% here and the former in plotimage where they are called anaysis tools. Sane tasks will be applied
% to entire datasets with the subsequent option of saving the result in the project, writing to
% segy, or discarding. Since many tasks in Sane will be similar to those in plotimage3d, there needs
% to be a mechanism to share parmsets. Sane tasks will execute via a callback to an action in enhance.
% Each callback needs to do: (1) identify the input dataset, (2) identify the parameters, (3) run
% the task, and (4) determine the disposition of the output.

% To implement a new ENHANCE task, do the following
% 1) Add a new entry to the Compute menu. The tag of this menu will be the name of the task.
% 2) Create a parmset function. This is an internal-to-ENHANCE function that does two things (i) it
% defines the parameters needed to run the task and (ii) it checks a parmset edited by the user for
% validity. See parmsetfilter and parmsetdecon (in this file) for examples.
% 3) Create a new case in the switch in the internal function getparmset (in this file). This new
% case must call the parmset function created in step 2.
% 4) Create a new case in the switch in 'starttask' action for the new task. This function calls the
% internal function enhancetask (in this file) that puts up a GUI showing the current parameters in the
% parmset and their current values. The user then changes them and pushes the done button which
% calls the action 'dotask'. Internal function enhancetask is meant to automatically adapt to parmsets
% of different lengths and types and (hopefully) will not require modification. 
% 5) In the 'dotask' action there are two switch's that need new cases. The first is the switch
% statment that calls the appropriate parmset function to check the current parmset for validity.
% The second is the switch that actually does the computation. This switch will generally need more
% work and thought than the others.
%
% NOTE: Initially, there are no parmsets saved in a project and so the parmset presented to the
% user is the default one. However, once a task is run, the parmset is saved in the proj structure.
% The next time that same task is run, then the starting parmset is the saved one.
%
% NOTE: At present all of the tasks have two things in common: (i) They are either trace-by-trace
% operation or slice-by-slice. As such it is easy to put them in a loop and save the results in the
% input matrix. This is a great memory savings because otherwise a 3D matrix the same size as the
% input would be needed. This means that if a computation is partially complete, then the input
% matrix is part input and part output. For this reason, if a task is interrupted when partially
% done, the input dataset is unloaded from memory. Rerunning the task will therefore require a
% reload (which is automatic). (ii) They all have the same 4 options for dealing with the output
% dataset. The options are established in the internal function enhancetask and are {'Save SEGY','Save
% SEGY and display','Replace input in project','Save in project as new'} . If these two behaviors
% are not appropriate, then more work will be required to implement the new task. The four output
% options are implemented in the action 'dotask' . NOTE: Spectral Decomp has special output
% behaviour. 


% ENHANCE project structure fields
% name ... name of the project
% projfilename ... file name of the project
% projpath ... path of the project.
% filenames ... cell array of filenames for datasets
% paths ... cell array of paths for datasets
% datanames ... cell array of dataset names
% isloaded ... array of flags for loaded or not, one per dataset
% isdisplayed ... array of flags for displayed or not, one per dataset
% xcoord ... cell array of x (xline) coordinate vectors, will be empty if dataset not loaded.
% ycoord ... cell array of y (inline) coordinate vectors, will be empty if dataset not loaded.
% tcoord ... cell array of t (time or depth) coordinate vectors, will be empth if not loaded.
% datasets ... cell array of datasets as 3D matrices, will be empty if not loaded
% xcdp ... cell array of xcdp numbers, empty if not loaded
% ycdp ... cell array of ycdp numbers, empty if not loaded
% dx ... array of physical grid in x direction, will be empty if not loaded
% dy ... array of physical grid in x direction, will be empty if not loaded
% depth ... array of flags, 1 for depth, 0 for time
% texthdr ... cell array of text headers
% texthdrfmt ... cell array of text header formats
% segfmt ... cell array of seg trace formats (IBM, IEEE, etc)
% byteorder ... cell array of byte orders
% binhdr ... cell array of binary headers
% exthdr ... cell array of extended headers
% tracehdr ... cell array of trace headers
% bindef ... cell array of bindef, nan indicates default behaviour and should be passed to readsegy and writesegy as [];
% trcdef ... cell array of trcdef, nan indicates default behaviour and should be passed to readsegy and writesegy as [];
% segyrev ... ordinary array of segyrev. nan indicates default behaviour and should be passed to readsegy and writesegy as []; 
% kxline ... cell array of kxlineall values as returned from make3Dvol
% gui ... array of handles of the data panels showing name and status
% rspath ... last used path for reading segy
% wspath ... last used path for writing segy
% rmpath ... last used path for reading matlab
% wmpath ... last used path for writing matlab
% pifigures ... Cell array of plotimage3D figure handles. One for each dataset. Will be empty if not displayed.
% isdeleted ... array of flags signalling deleted or no
% isdeletedondisk ... array of flags signalling deleted on disk or not
% saveneeded ... array of flags indicating a dataset needs to be saved
% parmsets ... cell array of parmsets which are also cell arrays. A parmset holds parameters for 
%           functions like filters, decon, etc. Each parmset is a indefinite length cell array of
%           name value triplets. However the first entry is always a string giving the name of the
%           task for which the parmset applies. Thus a parmset always has length 3*nparms+1. A name
%           value triple consists of (1) parameter name, (2) parameter value, (3) tooltip string.
%           The latter being a hint or instruction. The parameter value is either a string or a cell
%           array. If the parameter is actually a number then it is read from the string with
%           str2double. If the parameter is a choice, then it is encoded as a cell array like this:
%           param={'choice1' 'choice2' 'choice3' 1}. The last entry is numeric and in this example
%           means that the default is choice1. A thirs option exists to accomodate a parameter that
%           is a vector of values such that the list of frequencies in specdecomp. In this case the
%           vector of values is provided as a string inside a cell. The values are listed in the
%           string either comma or space separated. Internal function getparmset is used to retrieve
%           a parmset by task name from the structure. In the event that no parmset is found it
%           returns the default parmset. Internal function setparmset stores a modified parmset in
%           the project structure, replacing any already existing parmset of the same name. Once a
%           parmset is retrieved, internal function getparm is used to retrieve a given parameter by
%           name from a parmset.
% xlineloc ... cell array for each dataset, the header location of the xline number (in bytes)
% inlineloc ... cell array for each dataset, the header location of the inline number (in bytes)
% horizons ... structure array of horizon structures, one for each dataset. The horizon structure has the
%           fields:
%           horstruc.horizons ... a 3D array of horizon times. Each horizon is a 2D array the same
%               size as the base survey and is stored as a slice in the horizons 3D array. Horizon
%               arrays have x as coordinate 2, y as coordinate 3, while coordinate 1 is the horizon
%               index.
%           horstruc.filenames ... cell array of file names for each horizon. These may be long
%               complicated names that document the dataset that the picking was done on.
%           horstruc.names ... cell array horizon names. These are short names that will be shown on plots.
%           horstruc.showflags ... numeric array of flags. For each horizon, this is a flag (1 or 0)
%               indicating if the horizon is to be shown or not.
%           horstruc.colors ... cell array of colors for each horizon. If a color is
%               not specified, then one is obtained automatically from the axes colororder.
%           horstruc.linewidths ... numerica array containing linewidths for plotting. Set to 1 on
%               import.
%           horstruc.handles ... array of graphics handles for the displayed horizons.
% history ... cell array of text matrices, one per dataset, giving history. Upon loading from SEGY,
%           this just gives the SEGY file name. When computed by a task, this gives the input
%           dataset name, the task name, and lists the parameters.
% 



%userdata assignments
%hfile ... the project structure
%hmpan ... (the master panel) {hpanels geom thispanel}
%hpan ... the idata (data index) which is the number of the dataset for that data panel
%hreadsegy ... path for the most recently read segy
%hreadmat ... path for the most recently read .mat
%any plotimage figure ... {idata henhance}, idata is the number of the dataset, henhance is the enhance figure
%any figure menu in "view" ... the handle of the figure the menu refers to
%hmessage ... array of figure handles that may need to be closed if enhance is closed (usually info
%           windows)
% 

global PLOTIMAGE3DTHISFIG PLOTIMAGE3DFIGS HWAIT CONTINUE WaitBarContinue
%global SEGYTI_ENDIAN SEGYTI_FORMATCODE
%HWAIT and CONTINUE are used by the waitbar for continueing or cancelling

if(nargin<1)
    action='init';
end

if(strcmp(action,'init'))
%     test=findenhancefig;
%     if(~isempty(test))
%         msgbox('You already have ENHANCE running, only one at a time please');
%         return
%     end
    henhance=figure;
    ssize=get(0,'screensize');
    figwidth=1000;
    figheight=floor(ssize(4)*.4);
    if(figheight<600)
        if(ssize(4)>600)
            figheight=600;
        end
    end
    xnot=(ssize(3)-figwidth)*.5;
    ynot=(ssize(4)-figheight)*.5;
    set(henhance,'position',[xnot,ynot,figwidth,figheight],'tag','enhance');
    if(isdeployed)
        set(henhance,'menubar','none','toolbar','none','numbertitle','off','name','ENHANCE New Project',...
            'nextplot','new','closerequestfcn','enhance(''close'')');
    else
        set(henhance,'menubar','none','toolbar','none','numbertitle','off','name','ENHANCE (MATLAB) New Project',...
            'nextplot','new','closerequestfcn','enhance(''close'')');
    end
    
    hfile=uimenu(henhance,'label','File','tag','file');
    uimenu(hfile,'label','Load existing project','callback','enhance(''loadproject'');','tag','loadproject');
    uimenu(hfile,'label','Save project','callback','enhance(''saveproject'');');
    uimenu(hfile,'label','Save project as ...','callback','enhance(''saveprojectas'');');
    uimenu(hfile,'label','New project','callback','enhance(''newproject'');');
    hread=uimenu(hfile,'Label','Read datasets','tag','read');
    uimenu(hread,'label','*.sgy file','callback','enhance(''readsegy'');','tag','readsegy');
    uimenu(hread,'label','Multiple sgy files','callback','enhance(''readmanysegy'');','tag','readmanysegy');
    uimenu(hread,'label','*.mat file','callback','enhance(''readmat'');','tag','readmat');
    hwrite=uimenu(hfile,'label','Write datasets');
    uimenu(hwrite,'label','*.sgy file','callback','enhance(''writesegy'');');
    if(~isdeployed)
        uimenu(hwrite,'label','Multiple sgy files','callback','enhance(''writemanysegy'');','tag','writemanysegy');
    end
    uimenu(hwrite,'label','*.mat file','callback','enhance(''writemat'');');
    hreadhor=uimenu(hfile,'label','Read horizons');
    uimenu(hreadhor,'label','.xyz file','callback','enhance(''readhor'');','tag','xyz','enable','on');
    uimenu(hfile,'label','Quit','callback','enhance(''close'');');
    
    uimenu(henhance,'label','View','tag','view');
    
    hcompute=uimenu(henhance,'label','Compute','tag','compute');
    uimenu(hcompute,'label','Bandpass filter','callback','enhance(''starttask'');','tag','filter');
    uimenu(hcompute,'label','Spiking decon','callback','enhance(''starttask'');','tag','spikingdecon');
    if(isdeployed)
        uimenu(hcompute,'label','Gabor decon','callback','enhance(''starttask'');','tag','gabordecon','enable','on');
    else
        uimenu(hcompute,'label','Gabor decon','callback','enhance(''starttask'');','tag','gabordecon','enable','on');
    end
    uimenu(hcompute,'label','Wavenumber lowpass filtering','callback','enhance(''starttask'');','tag','wavenumber','enable','on');
    if(exist('tvfdom','file')==2)
        uimenu(hcompute,'label','Dominant frequency volumes','callback','enhance(''starttask'');','tag','fdom','enable','on');
    end
    hsd=uimenu(hcompute,'label','Spectral Decomp');
    uimenu(hsd,'label','Decision maker','callback','enhance(''specdecompdecide'');');
    uimenu(hsd,'label','Compute Spec Decomp','callback','enhance(''starttask'');','tag','specdecomp','enable','on');
    if(isdeployed)
        uimenu(hcompute,'label','SVD separation','callback','enhance(''starttask'');','tag','svdsep','enable','on');
    else
        uimenu(hcompute,'label','SVD separation','callback','enhance(''starttask'');','tag','svdsep','enable','on');
    end
    uimenu(hcompute,'label','Phase maps','callback','enhance(''starttask'');','tag','phasemap','enable','off');
    
    proj=makeprojectstructure;
    set(hfile,'userdata',proj);
    
    x0=.05;width=.2;height=.05;
    ysep=.02;
    xsep=.02;
    xnow=x0;
    ynow=1-height-ysep;
    fs=10;
    %a message area
    uicontrol(gcf,'style','text','string','Load an existing project or read a SEGY file','units','normalized',...
        'position',[xnow,ynow,.8,height],'tag','message','fontsize',fs,'fontweight','bold');
    %project name display
    ynow=ynow-height-ysep;
    uicontrol(gcf,'style','text','string','Project Name:','tag','name_label','units','normalized',...
        'position',[xnow,ynow-.25*height,width,height],'fontsize',fs,'horizontalalignment','right');
    xnow=xnow+xsep+width;
    uicontrol(gcf,'style','edit','string',proj.name,'tag','project_name','units','normalized',...
        'position',[xnow,ynow,2*width,height],'fontsize',fs,'callback','enhance(''projectnamechange'');');
    xnow=xnow+xsep+2*width;
    %ppt button
    uicontrol(gcf,'style','pushbutton','string','Start PPT','tag','pptx','units','normalized',...
        'position',[xnow,ynow,.5*width,height],'callback','enhance(''pptx'');','backgroundcolor','y',...
        'tooltipstring','Click to initiate PowerPoint slide creation');
    %info button
    winfo=.25*width;
    hinfo=.5*height;
    uicontrol(gcf,'style','pushbutton','string','Info','tag','info','units','normalized',...
        'position',[0,1-hinfo,winfo,hinfo],'callback','enhance(''enhanceinfo'');','backgroundcolor','y');
    panelwidth=1-2*x0;
    panelheight=1.2*height;
    xnow=x0;
    ynow=ynow-height-ysep;
    %the master panel
    hmpan=uipanel(gcf,'tag','master_panel','units','normalized','position',...
        [xnow ynow panelwidth panelheight]);
    xn=0;yn=0;wid=.5;ht=.8;ht2=1.1;
    ng=.94*ones(1,3);
    dg=.7*ones(1,3);
    uicontrol(hmpan,'style','text','string','Dataset','tag','dataset_label','units','normalized',...
        'position',[xn,yn,wid,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+wid+xsep;
    wid2=(1-wid-3*xsep)/4.5;
    uicontrol(hmpan,'style','text','string','Info','tag','info_label','units','normalized',...
        'position',[xn,yn,.75*wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+.75*wid2+xsep;
    uicontrol(hmpan,'style','text','string','In memory','tag','memory_label','units','normalized',...
        'position',[xn,yn,wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized',...
        'position',[xn+wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+wid2+xsep;
    uicontrol(hmpan,'style','text','string','Displayed','tag','display_label','units','normalized',...
        'position',[xn,yn,wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized',...
        'position',[xn+wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+wid2+xsep;
    uicontrol(hmpan,'style','text','string','Delete','tag','delete_label','units','normalized',...
        'position',[xn,yn,.5*wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %a separator
    uicontrol(hmpan,'style','text','string','','units','normalized',...
        'position',[xn+.5*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
    xn=xn+.5*wid2+xsep;
    uicontrol(hmpan,'style','text','string','Group','tag','group_label','units','normalized',...
        'position',[xn,yn,.5*wid2,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
    %userdata of hmpan will be a cell array. The first entry is an array of panel handles, one for each dataset in the project
    %the second entry is geometry information: panelwidth panelheight wid ht xsep ysep
    ysep=.01;
    set(hmpan,'userdata',{[],[panelwidth panelheight xnow ynow wid ht xsep ysep ynow]});
    
    %now a the 'enhance_panel' which stretches from the master_panel to the figure bottom. Inside the
    %enhance_panel will be the data_panel which has the same width but 4 times the height.
    hsp=uipanel(gcf,'tag','enhance_panel','units','normalized','position',[xnow,.05,panelwidth,ynow-.05;]);
    %data_panel
    hdp=uipanel(hsp,'tag','data_panel','units','normalized','position',[0 -3 1 4]);
    %scrollbar
    uicontrol(henhance,'style','slider','tag','slider','units','normalized','position',...
        [xnow+panelwidth,.05,.5*x0,ynow-.05],'value',1,'Callback',{@enhance_slider,hdp})
    
elseif(strcmp(action,'readsegy'))
    %read in a segy dataset
    henhance=findenhancefig;
    hmsg=findobj(henhance,'tag','message');
    pos=get(henhance,'position');
    hreadsegy=findobj(henhance,'tag','readsegy');
    startpath=get(hreadsegy,'userdata');
    if(isempty(startpath))
        spath='*.sgy';
    else
        spath=[startpath '*.sgy'];
    end
    [fname,path]=uigetfile(spath,'Choose the .sgy file to import');
    if(fname==0)
        return
    end
    %test last 4 characters for .SGY or .SGY
    nsgy=3;
    if(~strcmpi(fname(end-nsgy:end),'.sgy'))
        nsgy=4;
        if(~strcmpi(fname(end-nsgy:end),'.segy'))
            msgbox('Chosen file is not a either .sgy or .segy, cannot proceed');
            return;
        end
    end
    %put up second dialog
%     SEGYTI_ENDIAN=[];
%     SEGYTI_FORMATCODE=[];
    hdial=figure;
    fight=300;
    figwid=400;
    set(hdial,'position',[pos(1)+.5*(pos(3)-figwid),pos(2)+.5*(pos(4)-fight),figwid,fight],...
        'menubar','none','toolbar','none','numbertitle','off',...
        'name','ENHANCE: Read Segy dialog','userdata',{[],henhance},'tag','fromenhance',...
        'closerequestfcn','enhance(''readsegy2cancel'');');
    xnot=.05;ynow=.85;
    xnow=xnot;
    wid=.9;ht=.09;
    ysep=.01;xsep=.02;
    uicontrol(hdial,'style','text','string',['File: ' fname],'tag','fname','units','normalized',...
        'position',[xnow,ynow,wid,ht],'userdata',fname,'horizontalalignment','left','fontsize',10);
    ynow=ynow-ht-ysep;
    uicontrol(hdial,'style','text','string',['Path: ' path],'tag','path','units','normalized',...
        'position',[xnow,ynow,wid,ht],'userdata',path,'horizontalalignment','left','fontsize',10);
    ynow=ynow-ht-ysep;
    wid=.3;
    uicontrol(hdial,'style','pushbutton','string','Trace headers','units','normalized','tag','traceheaders',...
        'position',[xnow,ynow,wid,ht],'callback','enhance(''showtraceheaders'');',...
        'tooltipstring','push to view trace headers');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','text','string','# hdrs to view:','units','normalized','position',...
        [xnow,ynow-.1*ht,wid,ht],'horizontalalignment','right');
    uicontrol(hdial,'style','edit','string','100','tag','ntraces','units','normalized',...
        'position',[xnow+wid+xsep,ynow,.3*wid,ht]);
    xnow=xnot;
    wid=.3;
    ynow=ynow-ht-ysep;
    uicontrol(hdial,'style','text','string','Inline byte loc:','units','normalized',...
        'position',[xnow,ynow-.25*ht,wid,ht],'horizontalalignment','right');
    xnow=xnow+wid+xsep;
    locs=segybytelocs;
    uicontrol(hdial,'style','pushbutton','string','SEGY standard','tag','inline','units',...
        'normalized','position',[xnow,ynow,wid,ht],'callback','enhance(''choosebyteloc'');',...
        'tooltipstring',['loc= ' int2str(locs(1)) ', Push to change.'],'userdata',locs(1));
    ynow=ynow-ht-ysep;
    xnow=xnot;
    uicontrol(hdial,'style','text','string','Xline byte loc:','units','normalized',...
        'position',[xnow,ynow-.25*ht,wid,ht],'horizontalalignment','right');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','pushbutton','string','SEGY standard','tag','xline','units',...
        'normalized','position',[xnow,ynow,wid,ht],'callback','enhance(''choosebyteloc'');',...
        'tooltipstring',['loc= ' int2str(locs(2)) ', Push to change.'],'userdata',locs(2));
    xnow=xnot;
    ynow=ynow-ht-ysep;
    uicontrol(hdial,'style','pushbutton','string','Trace inspector','tag','inspector',...
        'units','normalized','position',[xnow,ynow,wid,ht],...
        'callback','enhance(''starttraceinspector'');')
    
    xnow=xnot;
    ynow=ynow-ht-ysep;
    wid=.5;
    uicontrol(hdial,'style','radiobutton','string','Display immediately','tag','display',...
        'units','normalized','position',[xnow,ynow,wid,ht],'value',1,'tooltipstring',...
        'Option to display the dataset immediately after import')
    ynow=ynow-ht-ysep;
    wid=.2;
    uicontrol(hdial,'style','edit','string','0.0','tag','tshift','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tooltipstring','Enter a value in seconds or depth units');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','text','string','time shift','units','normalized','position',...
        [xnow,ynow-.1*ht,3*wid,ht],'horizontalalignment','left');
    ynow=ynow-ht-ysep;
    xnow=xnot;
    wid=.3;
    uicontrol(hdial,'style','pushbutton','string','Done','tag','done','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','enhance(''readsegy2'');');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','pushbutton','string','Cancel','tag','cancel','units','normalized',...
        'position',[xnow,ynow,wid,ht],'callback','enhance(''readsegy2'');');
    xnow=1-.5*wid;
    uicontrol(hdial,'style','pushbutton','string','Info','tag','inspector',...
        'units','normalized','position',[xnow,ynow,.5*wid,ht],...
        'callback','enhance(''helpsegyin'');','backgroundcolor','y')
    %register hdial with hmsg
    ud=get(hmsg,'userdata');
    set(hmsg,'userdata',[ud hdial],'string','Starting SEGY inport');
    WinOnTop(hdial,true);
elseif(strcmp(action,'helpsegyin'))    
    msg={['There are two essential tasks that must be accomplished in the SEGY import. First, the ',...
        'inline and crossline numbers must be read in correctly from the Trace Headers, and second, ',...
        'the traces themselves must be read in correctly. In order for these to happen, ',...
        'the byte locations in the headers for the inline and crossline numbers must be specified, ',...
        'the byte order of the dataset must be determined, and the data format must be determined. ',...
        'Ideally, all of these things should be automatically prescribed by the dataset itself, but ',...
        'in practice many datasets depart from the SEGY standard in various ways and therefore ',...
        'it is a good idea to verify that these items are correctly identified before reading ',...
        'the entire dataset. '],' ',[' First, to verify the byte order ("big endian" or "little ',...
        'endian"), the best test is to verify that a sample trace is read correctly. This test also ',...
        'confirms the data format (e.g. IBM 4 byte, IEEE 4 byte, etc). To do this, push the ',...
        '"Trace inspector" button and work with the resulting window. Only the correct choice of ',...
        'both byte order and data format will result in a believable trace display and spectrum.',...
        'The initial settings for these choices are those suggested by the SEGY file itself.'],...
        ' ',['Lastly to verify that the inline and crossline numbers are being read from the proper ',...
        'header location, push the "Trace headers" button to inspect the headers. Then hover the ',...
        'mouse over the "Inline byte loc:" button to see the current target location. Upon inspection ',...
        'if this location does not contain a believable value, then push the button and redefine ',...
        'the target location. Repeat for the "Xline byte loc:" button. Note that the headers will ',...
        'only be displayed correctly if the proper byte order has been determined.']};
    msgbox(msg,'Information for SEGY Input');
    return;
elseif(strcmp(action,'starttraceinspector'))
    hbutton=gcbo;
    hdial=gcf;
    hparent=get(hbutton,'parent');
    if(strcmp(get(hparent,'type'),'figure'))
        %case for single file
        hfile=findobj(hdial,'tag','fname');
        fname=get(hfile,'userdata');
        hpath=findobj(hdial,'tag','path');
        path=get(hpath,'userdata');
    else
        %case for multi-files
        hfname=findobj(hparent,'tag','filename');
        fname=get(hfname,'string');
        path=get(hfname,'userdata');
    end
    pos=get(hdial,'position');
    SegyTraceInspector([path fname],hbutton);
    hti=gcf;
    pos2=get(hti,'position');
    set(hti,'position',[pos(1)+.5*pos(3), pos2(2:4)]);
    WinOnTop(hti,true);
    ud=get(hdial,'userdata');
    ud{1}=[ud{1} hti];
    set(hdial,'userdata',ud);
    
elseif(strcmp(action,'readsegy2')||strcmp(action,'readsegy2cancel'))
    hdial=gcf;%the dialog from readsegy
    ud=get(hdial,'userdata');
    henhance=ud{2};
    hotherfigs=ud{1};
    hfile=findobj(henhance,'label','File');
    hreadsegy=findobj(henhance,'tag','readsegy');
    hmsg=findobj(henhance,'tag','message');
    hbut=gcbo;%the button clicked
    %look for a trace header or trace inspector window open and close them
    for k=1:length(hotherfigs)
        if(isgraphics(hotherfigs(k)))
            delete(hotherfigs(k));
        end
    end
    if(strcmp(get(hbut,'tag'),'cancel')||strcmp(action,'readsegy2cancel'))
        delete(hdial);
        set(hmsg,'string','SEGY import cancelled');
        return;
    end

%     htrbut=findobj(hdial,'tag','traceheaders');
%     ud=get(htrbut,'userdata');
%     if(isgraphics(ud))
%         delete(ud);
%     end
    
    hfname=findobj(hdial,'tag','fname');
    fname=get(hfname,'userdata');
    hpath=findobj(hdial,'tag','path');
    path=get(hpath,'userdata');
    loc=[0,0];
    hinline=findobj(hdial,'tag','inline');
    loc(1)=get(hinline,'userdata');
    hxline=findobj(hdial,'tag','xline');
    loc(2)=get(hxline,'userdata');
    hdisp=findobj(hdial,'tag','display');
    dispopt=get(hdisp,'value');
    htshift=findobj(hdial,'tag','tshift');
    tshift=str2double(get(htshift,'string'));
    if(isnan(tshift)); tshift=0; end
    %check the trace inspector button for format code, byte order, and tmax
    hbutton=findobj(hdial,'string','Trace inspector');
    udat=get(hbutton,'userdata');
    if(~isempty(udat))
        byteord=udat{1};
        dataformat=udat{2};
        tmax=udat{3};
    else
        byteord=[];
        dataformat=[];
        tmax=udat{3};
    end
    delete(hdial)
    
    nsgy=3;
    if(~strcmpi(fname(end-nsgy:end),'.sgy'))
        nsgy=4;
    end
    dname=fname(1:end-nsgy-1);
    figure(henhance)
    waitsignalon
    t1=clock;
    segyrev=1;%hardwired
    set(hmsg,'string',['Reading SEGY dataset ' path fname]);
    %open the segyfile
    warning off
    sf=SegyFile([path fname],'r',segyrev);
%     %check for globals defining byteorder and formatcode
    if(~isempty(byteord))
        sf.ByteOrder=byteord;
    end
    if(~isempty(dataformat))
        sf.FormatCode=dataformat;
    end

    if(sf.FormatCode==6)%formatcode 6 is nonstandard in Devon. We remap it to 1
        sf.FormatCode=1;
    end
    sf.GUI=henhance;
    %get traces and headers
    [tracehdr,seis]=sf.Trace.read();
    trcdef=sf.Trace.HdrDef;
    %get binary header
    binhdr=sf.BinaryHeader.read;
    bindef=sf.BinaryHeader.HdrDef;
    %extended header
    exthdr=sf.ExtendedTextHeader.read;
    %text header
    texthdr=sf.TextHeader.read;
    %other things
    segyrev=sf.SegyRevision;%should just be 1 back again
    dt=double(sf.SampleInterval)/1000000;
    segfmt=sf.Trace.FormatCode;
    byteorder=sf.ByteOrder;
    texthdrfmt=sf.TextHeader.TextFormat;
    t2=clock;
    time2read=etime(t2,t1);
    set(hmsg,'string',['Dataset read in ', num2str(time2read/60) ' minutes']);

%     [seis,segyrev,dt,segfmt,texthdrfmt,byteorder,texthdr,binhdr,...
%         exthdr,tracehdr,bindef,trcdef] =readsegy([path fname],[],segyrev,[],[],...
%         [],[],[],[],[],henhance);

    warning on
    t=dt*(0:size(seis,1)-1)';
    %determine if time or depth
    dt=abs(t(2)-t(1));
    depthflag=0;
    if(dt>.02)
        depthflag=1;
    end
    
    if(~strcmp(tmax,'all'))
        %reduced trace length. Truncate seis and update headers
        itkill=near(t,tmax+dt,t(end));
        seis(itkill,:)=[];
        t(itkill)=[];
        [nt,ntraces]=size(seis);
        tracehdr.SampThisTrc=nt*ones(1,ntraces,'uint16');
        binhdr.SampPerTrc=nt*ones(1,1,'uint16');
    end
    
    %read inline and xline numbers according to the byte locations
    fld1=tracebyte2word(loc(1),1);%segyrev 1 was forced on input
    y=double(getfield(tracehdr,fld1));
    fld2=tracebyte2word(loc(2),1);
    x=double(getfield(tracehdr,fld2));
    if(isfield(tracehdr,'GroupX'))
        cdpx=tracehdr.GroupX; %bytes 81 & 85
        cdpy=tracehdr.GroupY;
        if(sum(abs(cdpx))==0 || sum(abs(cdpy))==0)
            cdpx=tracehdr.SrcX; %bytes 73 & 77
            cdpy=tracehdr.SrcY;
        end
        if(sum(abs(cdpx))==0 || sum(abs(cdpy))==0)
            if(isfield(tracehdr,'CdpX'))
                cdpx=tracehdr.CdpX; %bytes 181 & 185
                cdpy=tracehdr.CdpY;
            end
        end
    end
    if(sum(abs(cdpx))==0)
        cdpx=x;%this happens if the above strategies have netted nothing
        cdpy=y;
    end
    %cdp coords are doubles in the headers. No need to typecast
    
    [seis3D,xline,iline,xcdp,ycdp,kxline]=make3Dvol(seis,x,y,cdpx,cdpy);
    
    dx=mean(abs(diff(xcdp)));
    dy=mean(abs(diff(ycdp)));
    dx=max([dx, 1]);
    dy=max([dy, 1]);
    
    

    if(depthflag==0 && tshift>10)
        tshift=tshift/1000;%assume they mean milliseconds
    end
    
    
    
    %update the project structure
    
    proj=get(hfile,'userdata');
    nfiles=length(proj.filenames)+1;
    proj.filenames{nfiles}=fname;
    proj.paths{nfiles}=path;
    proj.datanames{nfiles}=dname;
    if(dispopt)
        proj.isloaded(nfiles)=1;
        proj.isdisplayed(nfiles)=1;
    else
        proj.isloaded(nfiles)=0;
        proj.isdisplayed(nfiles)=0;
    end
    %make the new data panel
    hpan=newdatapanel(dname,proj.isloaded(nfiles),proj.isdisplayed(nfiles));
    %finish updating project structure
    proj.xcoord{nfiles}=xline;
    proj.ycoord{nfiles}=iline(:);
    proj.tcoord{nfiles}=t+tshift;
    proj.tshift(nfiles)=tshift;
    proj.xcdp{nfiles}=xcdp;
    proj.ycdp{nfiles}=ycdp(:);
    proj.dx(nfiles)=dx;
    proj.dy(nfiles)=dy;
    proj.depth(nfiles)=depthflag;
    proj.texthdr{nfiles}=texthdr;
    proj.texthdrfmt{nfiles}=texthdrfmt;
    proj.segfmt{nfiles}=segfmt;
    proj.byteorder{nfiles}=byteorder;
    proj.tracehdr{nfiles}=tracehdr;
    proj.binhdr{nfiles}=binhdr;
    proj.exthdr{nfiles}=exthdr;
    proj.bindef{nfiles}=bindef;
    proj.trcdef{nfiles}=trcdef;
    proj.segyrev(nfiles)=segyrev;
    proj.kxline{nfiles}=kxline;
    proj.datasets{nfiles}=seis3D;
    proj.gui{nfiles}=hpan;
    proj.isdeleted(nfiles)=0;
    proj.deletedondisk(nfiles)=0;
    proj.saveneeded(nfiles)=1;
    proj.history{nfiles}=['Loaded from SEGY file ' fname];
    

    %call plotimage3D
    if(dispopt)
        plotimage3D(seis3D,t,{xline,xcdp},{iline,ycdp},dname,'seisclrs',dx,dy);
        set(gcf,'tag','fromenhance','userdata',{nfiles henhance});
        set(gcf,'closeRequestFcn','enhance(''closepifig'');')
        hview=findobj(henhance,'tag','view');
        uimenu(hview,'label',dname,'callback','enhance(''popupfig'');','userdata',gcf);
        proj.pifigures{nfiles}=gcf;
    else
        proj.pifigures{nfiles}=[];
    end
    %save the path
    set(hreadsegy,'userdata',path);
    
    %save the project structure into user data (not disk)
    set(hfile,'userdata',proj);
    figure(henhance)
    waitsignaloff
    if(dispopt)
        set(hmsg,'string',['File "' fname '" imported and displayed. Data will be written to disk when you save the project.'])
    else
        set(hmsg,'string',['File "' fname '" imported. Data will be written to disk when you save the project.'])
    end
    
    %save project
    enhance('saveproject');
    set(hmsg,'string',['Dataset read in ', num2str(time2read/60) ' minutes']);
    
elseif(strcmp(action,'readmanysegy'))
    %Here we read in a bunch of SEGY's at once. 
    %If the existing project is not new, then we first ask if we want to add to it. Otherwise we suggest save.  
    henhance=findenhancefig;
    hmsg=findobj(henhance,'tag','message');
    hfile=findobj(henhance,'tag','file');
    proj=hfile.UserData;
    newproject=true;
    if(~isempty(proj.filenames))
       Q='Merge new data into existing project?';
       Q0='What about the current project?';
       A1='Yes';
       A2='No, start new project';
       A3='Cancel, I forgot to save';
       answer=questdlg(Q,Q0,A1,A2,A3,A1);
       if(strcmp(answer,A3))
           set(hmsg,'string','Multilple SEGY load cancelled, Save your project first');
           return;
       elseif(strcmp(answer,A2))
           enhance('newproject');
       else
           newproject=false;
       end
    end
    %put up dialog
    set(hmsg,'string','Beginning Multiple SEGY load');
    multiplesegyload(newproject);
    hdial=gcf;
    ud=get(hmsg,'userdata');
    set(hmsg,'userdata',[ud, hdial]);
    return;
elseif(strcmp(action,'readmanysegy2'))
    hdial=gcf;
    ud=get(hdial,'userdata');
    henhance=ud{2};
    hotherfigs=ud{1};
    %close any trace header or trace inspector windows
    for k=1:length(hotherfigs)
       if(isgraphics(hotherfigs(k)))
           delete(hotherfigs(k))
       end
    end
    %henhance=findenhancefig;
    hmsg=findobj(henhance,'tag','message');
    set(hmsg,'string','Beginning multiple SEGY read');
    hfile=findobj(henhance,'tag','file');
    proj=hfile.UserData;
%     %look for open trace header windows and close if necessary
%     htrbut=findobj(hdial,'tag','traceheaders');
%     for k=1:length(htrbut)
%        if(isgraphics(htrbut(k)))
%            delete(htrbut(k));
%        end
%     end
    hmpan=findobj(hdial,'tag','readmanymaster');
    udat=get(hmpan,'userdata');
    hpanels=udat{1};
    if(isempty(hpanels))
        msgbox('You need to choose some datasets to import','Oooops!');
        return;
    end
    hprojfile=findobj(hdial,'tag','projsavefile');
    projfile=get(hprojfile,'string');
    
    if(strcmpi('undefined',projfile))
        msgbox('You need define the project save file','Oooops!');
        return;
    end
    proj.projfilename=projfile;
    proj.projpath=get(hprojfile,'userdata');
    matobj=matfile([proj.projpath proj.projfilename],'writable',true);%open the mat file
    nd=length(proj.datanames);%number of datasets currently in project
    ndnew=length(hpanels);%number of new datasets
    proj=expandprojectstructure(proj,ndnew);
    set(hfile,'userdata',proj);
    %harvest the data info from the dialog
    data=cell(ndnew,10);%entries are: filename, pathname, dataname, displayopt, tshift, inlineloc, xlineloc byteorder dataformat tmax
    for k=1:ndnew
        hfname=findobj(hpanels{k},'tag','filename');
        data{k,1}=get(hfname,'string');
        data{k,2}=get(hfname,'userdata');
        hdname=findobj(hpanels{k},'tag','dataname');
        data{k,3}=get(hdname,'string');
        hdisp=findobj(hpanels{k},'tag','display');
        data{k,4}=get(hdisp,'value');
        htshift=findobj(hpanels{k},'tag','tshift');
        tshift=str2double(get(htshift,'string'));
        if(isnan(tshift))
            tshift=0;
        end
        data{k,5}=tshift;
        hinline=findobj(hpanels{k},'tag','inline');
        data{k,6}=get(hinline,'userdata');
        hxline=findobj(hpanels{k},'tag','xline');
        data{k,7}=get(hxline,'userdata');
        hti=findobj(hpanels{k},'string','Trace inspector');
        ud=get(hti,'userdata');
        if(~isempty(ud))
            data{k,8}=ud{1};%byteorder
            data{k,9}=ud{2};%dataformat
            data{k,10}=ud{3};
        end
    end
    delete(hdial);%kill the dialog
    t0=clock;
    figure(henhance);
    waitsignalon
    %we force everything to be read with rev 1. This is benign and simply causes fields the were
    %unassigned under rev 0 to be named
    segyrev=1;
    warning off
    for k=nd+1:nd+ndnew
        filename=data{k-nd,1};
        datapath=data{k-nd,2};
        proj.datanames{k}=data{k-nd,3};
        dispopt=data{k-nd,4};
        if(dispopt)
            proj.isdisplayed(k)=1;
            proj.isloaded(k)=1;
        end
        tshift=str2double(data{k-nd,5});
        if(isnan(tshift))
            tshift=0;
        elseif(tshift>10)
            tshift=tshift/1000;
        end
        proj.tshift(k)=tshift;
        if(isdeployed)
            set(hmsg,'string',['reading file ' int2str(k-nd) ' of ' int2str(ndnew) ', ' filename ...
                ' from path ' datapath ]);
        else
            set(hmsg,'string',['reading file ' int2str(k-nd) ' of ' int2str(ndnew) ', ' filename ...
                ' from path ' datapath ', see main Matlab window for progress']);
        end
        drawnow
        %open the segyfile
        
        sf=SegyFile([datapath filename],'r',segyrev);
        %assign byteorder
        if(~isempty(data{k-nd,8}))
            sf.ByteOrder=data{k-nd,8};
        end
        %assign data format
        if(~isempty(data{k-nd,9}))
            sf.FormatCode=data{k-nd,9};
        end
        sf.GUI=henhance;
        %get traces and headers
        [proj.tracehdr{k},seis]=sf.Trace.read();
        proj.trcdef{k}=sf.Trace.HdrDef;
        %get binary header
        proj.binhdr{k}=sf.BinaryHeader.read;
        proj.bindef{k}=sf.BinaryHeader.HdrDef;
        %extended header
        proj.exthdr{k}=sf.ExtendedTextHeader.read;
        %text header
        proj.texthdr{k}=sf.TextHeader.read;
        %other things
        segyrev=sf.SegyRevision;%should just be 1 back again
        dt=double(sf.SampleInterval)/1000000;
        proj.segfmt{k}=sf.Trace.FormatCode;
        proj.byteorder{k}=sf.ByteOrder;
        proj.texthdrfmt{k}=sf.TextHeader.TextFormat;
        %note the flag forcing everything to be read in a rev1. This causes a rev0 to have its
        %unassigned trace header values renamed to the rev1 names. I think this is a benign thing.
%         [seis,proj.segyrev(k),dt,proj.segfmt{k},proj.texthdrfmt{k},proj.byteorder{k},proj.texthdr{k},proj.binhdr{k},...
%             proj.exthdr{k},proj.tracehdr{k},proj.bindef{k},proj.trcdef{k}] =readsegy([datapath filename],[],1,[],[],...
%             [],[],[],[],[],{henhance});
        
        t=dt*(0:size(seis,1)-1)'+tshift;
        proj.tcoord{k}=t;
        dt=abs(t(2)-t(1));
        if(dt>.02)
            proj.depth(k)=1;
        end
        
        if(~strcmp(data{k,10},'all'))
            %reduced trace length. Truncate seis and update headers
            t=t-tshift;
            itkill=near(t,data{k,10}+dt,t(end));
            seis(itkill,:)=[];
            t(itkill)=[];
            [nt,ntraces]=size(seis);
            proj.tracehdr{k}.SampThisTrc=nt*ones(1,ntraces,'uint16');
            proj.binhdr{k}.SampPerTrc=nt*ones(1,1,'uint16');
            proj.tcoord{k}=t;
        end
        
        %read inline and xline numbers according to the byte locations
        fld1=tracebyte2word(data{k-nd,6},segyrev);%segyrev 1 was forced on input
        y=double(getfield(proj.tracehdr{k},fld1));
        fld2=tracebyte2word(data{k-nd,7},1);
        x=double(getfield(proj.tracehdr{k},fld2));
        if(isfield(proj.tracehdr{k},'GroupX'))
            cdpx=proj.tracehdr{k}.GroupX; %bytes 81 & 85
            cdpy=proj.tracehdr{k}.GroupY;
            if(sum(abs(cdpx))==0 || sum(abs(cdpy))==0)
                cdpx=proj.tracehdr{k}.SrcX; %bytes 73 & 77
                cdpy=proj.tracehdr{k}.SrcY;
            end
            if(sum(abs(cdpx))==0 || sum(abs(cdpy))==0)
                if(isfield(proj.tracehdr{k},'CdpX'))
                    cdpx=proj.tracehdr{k}.CdpX;
                    cdpy=proj.tracehdr{k}.CdpY;
                end
            end
        end
        if(sum(abs(cdpx))==0 || sum(abs(cdpy))==0)
            cdpx=x;%this happens if the above strategies have netted nothing
            cdpy=y;
        end
        
        [seis3D,proj.xcoord{k},tmp,xcdp,ycdp,proj.kxline{k}]=make3Dvol(seis,x,y,cdpx,cdpy);
        proj.ycoord{k}=tmp';
        dx=mean(abs(diff(xcdp)));
        dy=mean(abs(diff(ycdp)));
        proj.dx(k)=max([dx, 1]);
        proj.dy(k)=max([dy, 1]);
        proj.xcdp{k}=xcdp;
        proj.ycdp{k}=ycdp';
        proj.history{k}=['Loaded from SEGY file ' filename];
        proj.gui{k}=newdatapanel(proj.datanames{k},proj.isloaded(k),proj.isdisplayed(k));%make a data panel
        matobj.datasets(1,k)={seis3D};
        
        if(proj.isloaded(k)==1)
            proj.datasets{k}=seis3D;
            plotimage3D(seis3D,t,{proj.xcoord{k},xcdp},{proj.ycoord{k},ycdp},proj.datanames{k},'seisclrs',proj.dx(k),proj.dy(k));
            set(gcf,'tag','fromenhance','userdata',{k henhance});
            set(gcf,'closeRequestFcn','enhance(''closepifig'');')
            hview=findobj(henhance,'tag','view');
            uimenu(hview,'label',proj.datanames{k},'callback','enhance(''popupfig'');','userdata',gcf);
            proj.pifigures{k}=gcf;
            figure(henhance)
        end
        
        
        
        tnow=clock;
        timeused=etime(tnow,t0);
        
        set(hmsg,'string',['Finished reading file ' int2str(k-nd) ' of ' int2str(ndnew) ', '...
            filename ', Time used = ' num2str(timeused/60) ' minutes']);
    end
    warning on
    set(hfile,'userdata',proj);
    for k=nd+1:nd+ndnew
        proj.datasets{k}=[];%don't save a dataset in the project structure
        proj.pifigures{k}={};%don't want to save a graphics handle
        proj.gui{k}={};
    end
    if(strcmp(proj.name,'New Project'))
        tmp=proj.projfilename;
        ind=strfind(tmp,'.mat');
        if(isempty(ind)); ind=length(tmp); end
        proj.name=tmp(1:ind(1)-1);
        %update the gui
        hn=findobj(henhance,'tag','project_name');
        set(hn,'string',proj.name);
        if(isdeployed)
            set(henhance,'name',['Sane, Project: ' proj.name])
        else
            set(henhance,'name',['Sane, (MATLAB) Project: ' proj.name])
        end
    end
    matobj.proj=proj;%save project structure
    figure(henhance)
    waitsignaloff
elseif(strcmp(action,'writemanysegy'))
    %Here we write out a bunch of SEGY's at once.   
    henhance=findenhancefig;
    hmsg=findobj(henhance,'tag','message');
    %put up dialog
    set(hmsg,'string','Beginning Multiple SEGY output');
    multiplesegywrite;
    return;  
elseif(strcmp(action,'writemanysegy2'))
    hdial=gcf;
    udat=get(hdial,'userdata');
    henhance=udat{1};
    checkboxes=udat{2};
    %make sure theyve selected something
    ncheck=0;
    for k=1:length(checkboxes)
       if(get(checkboxes(k),'value')==1)
           ncheck=ncheck+1;
       end
    end
    if(ncheck==0)
        msgbox('You need to select at least one dataset to output','Oops...');
        return;
    end
    % make sure output folder is defined
    hfolder=findobj(hdial,'tag','folder');
    folder=get(hfolder,'userdata');
    if(strcmp(folder,'Undefined'))
        msgbox('You must define the output folder','Oops...');
        return;
    end
    delete(hdial);
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    hmsg=findobj(henhance,'tag','message');
    ndatasets=length(proj.datanames);
    nout=0;
    for k=1:ndatasets
        if(get(checkboxes(k),'value')==1)
            nout=nout+1;
            set(hmsg,'string',['Writing dataset ' proj.datanames{k}])
%             writesegy([path fname],seis,getsegyrev(iout),dt,proj.segfmt{iout},proj.texthdrfmt{iout},...
%                 proj.byteorder{iout},proj.texthdr{iout},proj.binhdr{iout},proj.exthdr{iout},...
%                 proj.tracehdr{iout},proj.bindef{iout},proj.trcdef{iout},henhance);
        end
    end
    set(hmsg,'string','Multiple SEGY write completed')
elseif(strcmp(action,'definewritefolder'))
    hdial=gcf;
    udat=get(hdial,'userdata');
    henhance=udat{1};
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    hmsg=findobj(henhance,'tag','message');
    folder=uigetdir(proj.projpath,'Choose output directory');
    if(folder==0)
        return;
    end
    hfolder=findobj(hdial,'tag','folder');
    if(length(folder)<50)
        set(hfolder,'string',['Output to: ' folder],'userdata',folder,'foregroundcolor','k',...
        'tooltipstring', folder);
    else
        set(hfolder,'string','Output to: Long name (hover mouse to see)','userdata',folder,'foregroundcolor','k',...
        'tooltipstring', folder);
    end
    set(hmsg,'string','Multiple SEGY output folder defined');
    return;
elseif(strcmp(action,'selectnewdataset'))
    %this is called by the multiplesegyload internal function
    %It can happen eith by pushing the 'New dataset' button of by p[ushing the 'Filename button' of
    %an already defined dataset.
    hdial=gcf;
    hbut=gcbo;
    hnew=findobj(hdial,'tag','new');
    if(hbut==hnew)
       hpan=[];
    else
       hpan=get(hbut,'parent');
    end
    startpath=get(hnew,'userdata');
    if(isempty(startpath))
        spath='*.sgy';
    else
        spath=[startpath '*.sgy'];
    end
    [fname,path]=uigetfile(spath,'Choose the .sgy file to import');
    if(fname==0)
        return
    end
    nsgy=3;
    if(~strcmpi(fname(end-nsgy:end),'.sgy'))
        nsgy=4;
        if(~strcmpi(fname(end-nsgy:end),'.segy'))
            msgbox('Chosen file is not a either .sgy or .segy, cannot proceed');
            return;
        end
    end
    dname=fname(1:end-nsgy-1);
    if(isempty(hpan))
        newfileloadpanel(fname,path,dname);
    else
       hfname=findobj(hpan,'tag','filename');
       set(hfname,'string',fname,'userdata',path,'tooltipstring',['Path: ' path]);
       hdname=findobj(hpan,'tag','dataname');
       set(hdname,'string',dname);
    end

    set(hnew,'userdata',path);%the is always the path of the last chosen dataset
elseif(strcmp(action,'defineprojectsavefile'))
%     henhance=findenhancefig;
    hdial=gcf;
    %hfile=findobj(henhance,'label','File');
    %hreadsegy=findobj(henhance,'tag','readsegy');
%     hmsg=findobj(henhance,'tag','message');
    hdialmsg=findobj(hdial,'tag','dialmsg');
%     hreadmany=findobj(henhance,'tag','readmanysegy');
    hnew=findobj(hdial,'tag','new');
    ht=findobj(hdial,'tag','table');
    paths=get(ht,'userdata');
    if(isempty(paths))
        startpath=get(hnew,'userdata');
    else
        startpath=paths{1};
    end
    if(isempty(startpath))
        spath='*.mat';
    else
        spath=[startpath '*.mat'];
    end
    [fname,path]=uiputfile(spath,'Specify the Project .mat file');
    if(fname==0)
        set(hdialmsg,'string','UNDEFINED');
        return
    end
    nsgy=3;
    if(strcmpi(fname(end-nsgy:end),'.sgy'))
        msgbox('Chosen file must be a .mat file not a .sgy. Try again');
            set(hdialmsg,'String','Project save file must be a .mat file');
            return;
    end
    nsgy=4;
    if(strcmpi(fname(end-nsgy:end),'.segy'))
        msgbox('Chosen file must be a .mat file not a .segy. Try again');
            set(hdialmsg,'String','Project save file must be a .mat file');
            return;
    end
%     ind=strfind(fname,'.mat');
%     if(isempty(ind)) %#ok<STREMP>
    if(~contains(fname,'.mat'))
        fname=[fname '.mat'];
    end
    if(exist([path fname],'file'))
        response=questdlg('The specified prohect file already exists. Overwrite?','Project file question.',...
            'Yes','No','Yes');
        if(strcmp(response','No'))
           set(hdialmsg,'string','Choose a different Project file');
           return;
        end
    end
    hprojfile=findobj(hdial,'tag','projsavefile');
    set(hprojfile,'string',fname,'userdata',path);
elseif(strcmp(action,'cancelmultipleload'))
    udat=get(gcf,'userdata');
    hdial2=udat{1};
    for k=1:length(hdial2)
        if(isgraphics(hdial2(k)))
            delete(hdial2(k))
        end
    end
    henhance=udat{2};
    hmsg=findobj(henhance,'tag','message');
    delete(gcf)
    set(hmsg,'string','Multiple SEGY load cancelled');
elseif(strcmp(action,'cancelmultiplewrite'))
    udat=get(gcf,'userdata');
    henhance=udat{1};
    hmsg=findobj(henhance,'tag','message');
    delete(gcf)
    set(hmsg,'string','Multiple SEGY write cancelled');
elseif(strcmp(action,'reloaddataset'))
    henhance=findenhancefig;
    hmsg=findobj(henhance,'tag','message');
    %this is called from a datapanel to load a dataset not in memory. The data panel is identified
    %by the third entry of the userdata of the master panel
    hmpan=findobj(henhance,'tag','master_panel');
    udat=hmpan.UserData;
    idata=udat{3};%this is the dataset we are loading
    %hpan=udat{1}(udat{3});
    hfile=findobj(henhance,'tag','file');
    proj=hfile.UserData;
    
    set(hmsg,'string',['Recalling dataset ' proj.datanames{idata} ' from disk'])
    figure(henhance)
    waitsignalon
    matobj=matfile([proj.projpath proj.projfilename]);
    cseis3D=matobj.datasets(1,idata);%this reads from disk
    seis3D=cseis3D{1};
    t=proj.tcoord{idata};
    xline=proj.xcoord{idata};
    iline=proj.ycoord{idata};
    xcdp=proj.xcdp{idata};
    ycdp=proj.ycdp{idata};
    dname=proj.datanames{idata};
    
    %update the project structure
    proj.datasets{idata}=seis3D;
    proj.isloaded(idata)=1;
    proj.saveneeded(idata)=0;
    %call plotimage3D
    if(proj.isdisplayed(idata)==0)%don't display it a second time
        plotimage3D(seis3D,t,{xline,xcdp},{iline,ycdp},dname,'seisclrs',proj.dx(idata),proj.dy(idata));
        set(gcf,'tag','fromenhance','userdata',{idata henhance});
        set(gcf,'closeRequestFcn','enhance(''closepifig'');')
        hview=findobj(henhance,'tag','view');
        uimenu(hview,'label',dname,'callback','enhance(''popupfig'');','userdata',gcf);
        proj.pifigures{idata}=gcf;
        proj.isdisplayed(idata)=1;
    end
    memorybuttonon(idata);
    figure(henhance)
    waitsignaloff;
    
    set(hfile,'userdata',proj);
    figure(henhance);
    
    set(hmsg,'string',['Dataset ' dname ' reloaded']);
    
elseif(strcmp(action,'readmat'))
    henhance=findenhancefig;
    hreadmat=gcbo;
    %basic idea is that the .mat file can contain one and only one 3D matrix. It should also contain
    %coordinate vectors for each of the 3 dimensions. So, an abort will occur if there are more than
    %1 3D matrices (or none), and also if there are no possible coordinate vectors for the 3
    %dimensions. If there are coordinate vectors but it is not clear which is which, then an
    %ambiguity dialog is put up to resolve this.
    %read in a *.mat file
    [fname,path]=uigetfile('*.mat','Choose the .mat file to import');
    if(fname==0)
        return
    end
    m=matfile([path fname]);
    varnames=fieldnames(m);
    varnames(1)=[];
    varsizes=cell(size(varnames));
    threed=zeros(size(varsizes));
    %find any 3D matrices. only one is allowed
    for k=1:length(varnames)
        varsizes{k}=size(m,varnames{k});
        if(length(varsizes{k})==3)
            threed(k)=1;%points to 3D matrices
        end
    end
    if(sum(threed)>1)
        msgbox('Dataset contains more than 1 3D matrix. Unable to proceed.','Sorry!');
        return
    end
    %look for t,iline and xline
    i3d=find(threed==1);
    sz3d=size(m,varnames{i3d});
    nt=sz3d(1);%time is always the first dimension
    nx=sz3d(2);%xline is always the second dimension
    ny=sz3d(3);%inline is always the third dimension
    it=zeros(size(threed));
    ix=it;
    iy=it;
    %find things that are the size of nt, nx, and ny
    itchoice=0;
    ixchoice=0;
    iychoice=0;
    inamechoice=0;
    for k=1:length(varnames)
        if(k~=i3d)
            szk=varsizes{k};
            if((min(szk)==1)&&(max(szk)>1))
                %ok its a vector
                n=max(szk);
                if(n==nt)
                    %mark as possible time coordinate
                    it(k)=1;
                    if(strcmp(varnames{k},'t'))
                        itchoice=k;
                    end
                end
                if(n==nx)
                    %mark as possible xline
                    ix(k)=1;
                    if(strcmp(varnames{k},'xline'))
                        ixchoice=k;
                    end
                end
                if(n==ny)
                    %mark as possible iline
                    iy(k)=1;
                    if(strcmp(varnames{k},'iline')||strcmp(varnames{k},'inline')||strcmp(varnames{k},'yline'))
                        iychoice=k;
                    end
                end
            end
            if(strfind(varnames{k},'dname'))
                inamechoice=k;
            end
        end
    end
    %ok, the best case is that it, ix, and iin all sum to 1 meaning there is only 1 possible
    %coordinate vector for each. If any one sums to zero, then we cannot continue. If any one sums
    %to greater than 1 then we have ambiguity that must be resolved.
    failmsg='';
    if(sum(it)==0)
        failmsg={failmsg 'Dataset contains no time coordinate vector. '};
    end
    if(sum(ix)==0)
        failmsg={failmsg 'Dataset contains no xline coordinate vector. '};
    end
    if(sum(iy)==0)
        failmsg={failmsg 'Dataset contains no inline coordinate vector. '};
    end
    if(~isempty(failmsg))
        msgbox(failmsg,'Sorry, dataset is not compaible with ENHANCE.')
        return
    end
    if(itchoice==0)
        ind=find(it==1);
        itchoice=it(ind(1));
    end
    if(ixchoice==0)
        ind=find(ix==1);
        ixchoice=ix(ind(1));
    end
    if(iychoice==0)
        ind=find(iy==1);
        iychoice=iy(ind(1));
    end
    ambig=[0 0 0];
    if(sum(it)>1)
        ambig(1)=1;
    end
    if(sum(ix)>1)
        ambig(2)=1;
    end
    if(sum(iy)>1)
        ambig(3)=1;
    end
    if(sum(ambig)>1)
        % put up dialog to resolve ambiguity
        [itchoice,ixchoice,iychoice]=ambigdialog(ambig,it,ix,iy,varnames,itchoice,ixchoice,iychoice);
    end
    %ok now get stuff from the matfile
    seis=getfield(m,varnames{i3d}); %#ok<*GFLD>
    t=getfield(m,varnames{itchoice});
    xline=getfield(m,varnames{ixchoice});
    iline=getfield(m,varnames{iychoice});
    dname='';
    if(inamechoice>0)
        dname=getfield(m,varnames{inamechoice});
    end
    if(inamechoice==0 || ~ischar(dname))
        dname=fname;
    end
    
    %determine if time or depth
    dt=abs(t(2)-t(1));
    depthflag=0;
    if(dt>.02)
        depthflag=1;
    end
    
    %ask for a few things
    tshift=0;
    if(depthflag==1)
        q4='Datum shift (depth units)';
    else
        q4='Datum shift (seconds)';
    end
    dx=1;
    dy=1;
    q={'Specify dataset name:','Physical distance between crosslines:','Physical distance between inlines:',q4};
    a={dname num2str(dy) num2str(dx) num2str(tshift)};
    a=askthingsle('name','Please double check these values','questions',q,'answers',a);
    if(isempty(a))
        msgbox('SEGY input aborted');
        return;
    end
    dname=a{1};
    dy=str2double(a{2});
    dx=str2double(a{3});
    tshift=str2double(a{4});
    if(isnan(tshift));tshift=0;end
    %insist on a positive number for dx and dy
    if(isnan(dy)); dy=0; end
    if(isnan(dx)); dx=0; end
    if(dx<0); dx=0; end
    if(dy<0); dy=0; end
    while(dx*dy==0)
        q={'Specify dataset name:','Physical distance between crosslines:','Physical distance between inlines:',q4};
        a={dname num2str(dy) num2str(dx) num2str(tshift)};
        a=askthingsle('name','Inline and crossline distances must be positive numbers!!','questions',q,'answers',a);
        if(isempty(a))
            msgbox('.mat input aborted');
            return;
        end
        dname=a{1};
        dy=str2double(a{2});
        dx=str2double(a{3});
        if(isnan(dy)); dy=0; end
        if(isnan(dx)); dx=0; end
        if(dx<0); dx=0; end
        if(dy<0); dy=0; end
    end
    if(depthflag==0 && tshift>2)
        tshift=tshift/1000;%assume they mean milliseconds
    end
    
    hpan=newdatapanel(dname,1,1);
    
    %update the project structure
    hfile=findobj(henhance,'label','File');
    proj=get(hfile,'userdata');
    nfiles=length(proj.filenames)+1;
    proj.filenames{nfiles}=fname;
    proj.paths{nfiles}=path;
    proj.datanames{nfiles}=dname;
    proj.isloaded(nfiles)=1;
    proj.isdisplayed(nfiles)=1;
    proj.xcoord{nfiles}=xline;
    proj.ycoord{nfiles}=iline;
    proj.tcoord{nfiles}=t+tshift;
    proj.tshift(nfiles)=tshift;
    proj.xcdp{nfiles}=dx*(1:length(xline));
    proj.ycdp{nfiles}=dy*(1:length(iline));
    proj.dx(nfiles)=dx;
    proj.dy(nfiles)=dy;
    proj.depth(nfiles)=depthflag;
    proj.texthdr{nfiles}='Data from .mat file. No text header available';
    proj.texthdrfmt{nfiles}=nan;
    proj.segfmt{nfiles}=nan;
    proj.byteorder{nfiles}=nan;
    proj.tracehdr{nfiles}=nan;
    proj.binhdr{nfiles}=nan;
    proj.exthdr{nfiles}=nan;
    proj.kxline{nfiles}=nan;
    proj.datasets{nfiles}=seis;
    proj.gui{nfiles}=hpan;
    proj.isdeleted(nfiles)=0;
    proj.deletedondisk(nfiles)=0;
    proj.saveneeded(nfiles)=1;
    
    %save the path
    set(hreadmat,'userdata',path);
    
    plotimage3D(seis,t,{xline,proj.xcdp{nfiles}},{iline,proj.ycdp{nfiles}},dname,'seisclrs',dx,dy);
    set(gcf,'tag','fromenhance','userdata',{nfiles henhance});
    set(gcf,'closeRequestFcn','enhance(''closepifig'');')
    hview=findobj(henhance,'tag','view');
    uimenu(hview,'label',dname,'callback','enhance(''popupfig'');','userdata',gcf);
    proj.pifigures{nfiles}=gcf;
    set(hfile,'userdata',proj);
    figure(henhance)
    
elseif(strcmp(action,'datainfo'))
    hinfo=gco;%the button clicked
    henhance=findenhancefig;
    hpan=get(hinfo,'parent');%panel we are in
    idata=get(hpan,'userdata');%number of the dataset
    hfile=findobj(henhance,'label','File');
    proj=get(hfile,'userdata');%the project
    hmsg=findobj(henhance,'tag','message');
    %msgbox(hproj.texthdr{dataindex});
    pos=get(henhance,'position');
    x0=pos(1);
    y0=max([1 pos(2)-1.2*pos(4)]);
    hinfofig=figure('position',[x0 y0 .7*pos(3) 1.4*pos(4)],'name',...
        ['Info for dataset ' proj.datanames{idata}],'menubar','none','toolbar','none',...
        'numbertitle','off','tag','datainfo','userdata',henhance);
    %put up the text header
    hpan1=uipanel('title','Text Header','position',[.1 .05 .8 .67]);
    uicontrol(hpan1,'style','text','units','normalized','position',[0 0 1 1],...
        'string',proj.texthdr{idata},'HorizontalAlignment','left','tag','texthdr');
    nt=length(proj.tcoord{idata});
    nx=length(proj.xcoord{idata});
    ny=length(proj.ycoord{idata});
    dt=abs(proj.tcoord{idata}(2)-proj.tcoord{idata}(1));
    dx=proj.dx(idata);
    dy=proj.dy(idata);
    tshift=proj.tshift(idata);
    ntraces=nx*ny;
    tmax=proj.tcoord{idata}(end)-proj.tcoord{idata}(1);
    mb=round(ntraces*nt*4/10^6);
    [ylmin,ilmin]=min(proj.ycoord{idata});
    [ylmax,ilmax]=max(proj.ycoord{idata});
    [xlmin,ixlmin]=min(proj.xcoord{idata});
    [xlmax,ixlmax]=max(proj.xcoord{idata});
    datasummary=cell(1,6);
    datasummary{1,1}=['Dataset consists of ' int2str(ntraces) ' traces, ' num2str(tmax) ' seconds long, datum shift= ' num2str(tshift)];
    datasummary{1,2}=['Number of inlines= ' int2str(ny) ', number of crosslines= ' int2str(nx) ', number of time samples=' int2str(nt)];
    datasummary{1,3}=['Inline numbers run from ' int2str(ylmin) ' to ' int2str(ylmax) ', Xlines from ' int2str(xlmin) ' to ' int2str(xlmax)];
    datasummary{1,4}=['Y (inline) coordinates from ' num2str(proj.ycdp{idata}(ilmin)) ' to ' num2str(proj.ycdp{idata}(ilmax))...
        ', X coordinates from ' num2str(proj.xcdp{idata}(ixlmin)) ' to ' num2str(proj.xcdp{idata}(ixlmax))];
    datasummary{1,5}=['Time sample size= ' num2str(dt) ' seconds, inline separation= ' num2str(dy) ', crossline separation= ' num2str(dx)];
    datasummary{1,6}=['Dataset size (without headers) = ' int2str(mb) ' megabytes'];
    hpan2=uipanel('title','Data summary','position',[.1 .8 .8 .15]);
    uicontrol(hpan2,'style','text','units','normalized','position',[0 0 1 1],...
        'string',datasummary,'HorizontalAlignment','left','fontsize',10,'tag','datasummary','userdata',idata);
    
    ht=.02;
    xnow=.1;
    ynow=.8-1.5*ht;
    wid=.2;
    uicontrol(hinfofig,'style','pushbutton','string','Trace headers','units','normalized',...
        'position',[xnow,ynow,.75*wid,ht],'callback','enhance(''showtraceheaders'');');
    xnow=xnow+wid;
    uicontrol(hinfofig,'style','text','string','# of trace headers to show:','units','normalized',...
        'position',[xnow ynow wid ht],'horizontalalignment','right');
    xnow=xnow+wid;
    uicontrol(hinfofig,'style','edit','string','1000','tag','ntraces','units','normalized',...
        'position',[xnow,ynow,.75*wid,ht],'tooltipstring','Enter a positive number or ''all''',...
        'userdata',idata);
    xnow=.1;
    ynow=ynow-ht;
    uicontrol(hinfofig,'style','pushbutton','string','Binary header','units','normalized',...
        'position',[xnow,ynow,.75*wid,ht],'callback','enhance(''showbinaryheader'');');
    xnow=xnow+wid;
    uicontrol(hinfofig,'style','text','string','Applied time shift:','units','normalized',...
        'position',[xnow ynow wid ht],'horizontalalignment','right');
    xnow=xnow+wid;
    uicontrol(hinfofig,'style','edit','string',num2str(proj.tshift(idata)),'tag','tshift','units','normalized',...
        'position',[xnow,ynow,.5*wid,ht],'tooltipstring','Enter a value in seconds or depth units',...
        'userdata',idata,'callback','enhance(''changetshift'');');
    xnow=xnow+.5*wid;
    uicontrol(hinfofig,'style','text','string','<<You can change this value','units','normalized',...
        'position',[xnow ynow 1.5*wid ht],'horizontalalignment','left');
    
    ynow=ynow-ht;
    xnow=.1;
    uicontrol(hinfofig,'style','pushbutton','string','History','units','normalized',...
        'position',[xnow,ynow,.75*wid,ht],'callback','enhance(''showhistory'');');
    
    hppt=addpptbutton([.95 .95 .05 .05]);
    set(hppt,'userdata',['Info for dataset ' proj.datanames{idata}]);
    
    hfigs=get(hmsg,'userdata');
    set(hmsg,'userdata',[hfigs hinfofig]);
elseif(strcmp(action,'projectnamechange'))
    hfile=findobj(gcf,'tag','file');
    proj=get(hfile,'userdata');
    hprojname=gcbo;
    proj.name=get(hprojname,'string');
    if(isdeployed)
        set(gcf,'name',['ENHANCE, Project: ' proj.name])
    else
        set(gcf,'name',['ENHANCE, (MATLAB) Project: ' proj.name])
    end
    set(hfile,'userdata',proj);
elseif(strcmp(action,'saveproject')||strcmp(action,'saveproj'))
    % The project file is a mat file with two variables: proj and datasets. Proj is a structure and
    % datasets is a cell array. Proj has a field called datasets but this is always saved to disk as
    % null and the datasets are sames separately in the cell array. Also in the proj structure are
    % fields isloaded and isdisplayed. When a project is loaded, only proj is read at first and a
    % dialog is presented showing which datasets were previously loaded and/or displayed. The user
    % can then choose to load and display as before or make any changes desired. Datasets that are
    % currently in memory are included in project as proj.datasets. All datasets, in memory or not,
    % are found in the datasets cell array. When a dataset is moved out of memory, it is saved into
    % the datasets array where it can be retrieved when desired. Syntax for retrieving a dataset
    % matobj=matfile([path filename]);
    % cdataset=matobj.datasets(1,thisdataset);%variable thisdataset is the index of the dataset
    % dataset=cdataset{1};
    % Syntax for saveing a dataset
    % matobj=matfile([path filename],'writable',true);
    % matobj.datasets(1,thisdataset)={dataset};
    % There does not appear to be a need to formally close a mat file after writing to it.
    % There does not seem to be a way to load a portion of a dataset. I have to load it all at once.
    %
    
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    hmsg=findobj(henhance,'tag','message');
    proj=get(hfile,'userdata');
    filename=proj.projfilename;
    path=proj.projpath;
    %newprojectfile=0;
    if(isempty(filename) || isempty(path))
        [filename, path] = uiputfile('*.mat', 'Specify project filename');
        if(filename==0)
            msgbox('Project save cancelled');
            return;
        end
        %ind=strfind(filename,'.mat');
        %if(isempty(ind))
        if(~contains(filename,'.mat'))
            filename=[filename '.mat'];
        end
        proj.projfilename=filename;
        proj.projpath=path;
        set(hfile,'userdata',proj);
        %newprojectfile=1;
        if(exist([path filename],'file'))
            delete([path filename]);
        end
    end
    set(hmsg,'string','Saving project ...')
    figure(henhance)
    waitsignalon
    %plan: strip out the datasets from the project structure. Make sure we have all of the datasets saved in
    %the datasets cell array on disk. Active datasets will be automatically moved into the proj
    %structure on loading.
    datasets=proj.datasets;
    pifigs=proj.pifigures;
    gui=proj.gui;
    proj.datasets={};%save it as an empty cell
    proj.pifigures={};%don't save graphics handles
    proj.gui={};
    disp('opening mat file')
    matobj=matfile([path filename],'Writable',true);
    
   
    isave=proj.saveneeded;
    %save any new datasets
    if(sum(isave)>0)
        disp('saving datasets')
        set(hmsg,'string','Saving new datasets');
        for k=1:length(isave)
            if(isave(k)==1)
                if(isempty(datasets(1,k)))
                    error('attempt to save empty dataset');
                end
                matobj.datasets(1,k)=datasets(1,k);%writes to disk
            end
        end
    end
    %check for newly deleted datasets
    ndatasets=length(datasets);
    for k=1:ndatasets
        if(proj.isdeleted(k)==1 && proj.deletedondisk(k)==0)
            matobj.datasets(1,k)={[]};
            proj.deletedondisk(k)=1;
        end
    end
    disp('writing project structure')
    set(hmsg,'string','Writing project structure');
    proj.saveneeded=zeros(1,ndatasets);
    matobj.proj=proj;%this writes the project structure
    proj.datasets=datasets;
    proj.pifigures=pifigs;
    proj.gui=gui;
    set(hfile,'userdata',proj)
    figure(henhance)
    waitsignaloff
    if(isdeployed)
        set(henhance,'name',['ENHANCE, Project file: ' filename]);
    else
        set(henhance,'name',['ENHANCE, (MATLAB) Project file: ' filename]);
    end
    set(hmsg,'string',['Project ' filename ' saved'])
    
elseif(strcmp(action,'saveprojectas'))
    % In this case we squeeze out any deleted datasets
    
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    hmsg=findobj(henhance,'tag','message');
%     filename=proj.projfilename;
    path=proj.projpath;
    [filename, path] = uiputfile([path '*.mat'], 'Specify project filename');
    if(filename==0)
        msgbox('Project save cancelled');
        return;
    end
    if(exist([path filename],'file'))
        delete([path filename]);
    end
    %     ind=strfind(filename,'.mat');
    %     if(isempty(ind))
    if(~contains(filename,'.mat'))
        filename=[filename '.mat'];
    end
    if(exist([path filename],'file'))
        delete([path filename]);
    end
    set(hmsg,'string',['Saving project into ' path filename])
    %open the old file
    mOld=matfile([proj.projpath proj.projfilename]);
    
%     proj.projfilename=filename;
%     proj.projpath=path;
    set(hfile,'userdata',proj);
    figure(henhance)
    waitsignalon
    nfiles=length(proj.datanames);
    for k=1:nfiles
       if(proj.isdeleted(k)~=1)
           if(isempty(proj.datasets{k}))
               proj.datasets(1,k)=mOld.datasets(1,k);
           end
       end
    end
    %ok, proj.datasets is fully loaded with those that we are keeping
    ind=proj.isdeleted~=1;
    datasets=proj.datasets(ind);%these are the keepers
    newproj=makeprojectstructure;
    newproj.projfilename=filename;
    newproj.projpath=path;
    newproj.filenames=proj.filenames(ind);
    newproj.paths=proj.paths(ind);
    newproj.datanames=proj.datanames(ind);
    newproj.isloaded=proj.isloaded(ind);
    newproj.isdisplayed=proj.isdisplayed(ind);
    newproj.xcoord=proj.xcoord(ind);
    newproj.ycoord=proj.ycoord(ind);
    newproj.tcoord=proj.tcoord(ind);
    newproj.tshift=proj.tshift(ind);
    newproj.xcdp=proj.xcdp(ind);
    newproj.ycdp=proj.ycdp(ind);
    newproj.dx=proj.dx(ind);
    newproj.dy=proj.dy(ind);
    newproj.depth=proj.depth(ind);
    newproj.texthdr=proj.texthdr(ind);
    newproj.texthdrfmt=proj.texthdrfmt(ind);
    newproj.segfmt=proj.segfmt(ind);
    newproj.byteorder=proj.byteorder(ind);
    newproj.binhdr=proj.binhdr(ind);
    newproj.exthdr=proj.exthdr(ind);
    newproj.tracehdr=proj.tracehdr(ind);
    newproj.kxline=proj.kxline(ind);
    newproj.isdeleted=proj.isdeleted(ind);
    newproj.deletedondisk=proj.deletedondisk(ind);
    newproj.saveneeded=zeros(size(ind));
    newproj.xlineloc=proj.xlineloc;%currently nonfunctional
    newproj.ylineloc=proj.ylineloc;%currently nonfunctional
    newproj.parmsets=proj.parmsets;
    newproj.horizons=proj.horizons(ind);
    newproj.history=proj.history(ind);
    
    matobj=matfile([path filename],'Writable',true);
    matobj.proj=newproj;
    matobj.datasets=datasets(ind);
 
    newproj.pifigures=proj.pifigures(ind);
    newproj.datasets=datasets;
    
    %delete any gui panels
    for k=1:length(proj.gui)
        if(isgraphics(proj.gui{k}))
            delete(proj.gui{k});
        end
    end
    hmpan=findobj(henhance,'tag','master_panel');
    udat=get(hmpan,'userdata');
    geom=udat{2};
    geom(4)=geom(9);%resets the initial y coordinates of the panels
    udat{2}=geom;
    set(hmpan,'userdata',udat);
    if(isdeployed)
        set(henhance,'name',['ENHANCE, Project file: ' filename]);
    else
        set(henhance,'name',['ENHANCE, (MATLAB) Project file: ' filename]);
    end
    set(hmsg,'string',['Project ' filename ' saved'])
    proj=newproj;
    %hmpan=findobj(henhance,'tag','master_panel');
    %udat=get(hmpan,'userdata');
    udat{1}=[];
    set(hmpan,'userdata',udat);
    
    ndatasets=length(proj.datanames);
    proj.gui=cell(1,ndatasets);
    
    % put up datapanels for each dataset, read and display if needed
    %hpanels=cell(1,ndatasets);
    %PIfigs=cell(1,ndatasets);
    for k=1:ndatasets
        if(proj.isdeleted(k)~=1)
            proj.gui{k}=newdatapanel(proj.datanames{k},proj.isloaded(k),proj.isdisplayed(k));
        end
    end
    figure(henhance)
    waitsignaloff
    set(hfile,'userdata',proj);
    hpn=findobj(henhance,'tag','project_name');
    set(hpn,'string',proj.name)
elseif(strcmp(action,'loadproject'))
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    hmsg=findobj(henhance,'tag','message');
    [fname,path]=uigetfile('*.mat','Choose the ENHANCE Project file (.mat) to load');
    if(fname==0)
        return
    end
    m=matfile([path fname],'writable',true);
    varnames=fieldnames(m);
    ivar=[];
    for k=1:length(varnames)
        ind=strcmp(varnames{k},'proj');
        if(ind~=0)
            ivar=k;
        end
    end
    if(isempty(ivar))
        msgbox('Chosen file is not a ENHANCE Project file, Nothing has been loaded');
        return
    end
    set(hmsg,'string',['Loading project ' path fname ' ... '])
    %check for existing project and delete any data panels
    projold=get(hfile,'userdata');
    if(~isempty(projold))
       hpanels=projold.gui;
       for k=1:length(hpanels)
           if(isgraphics(hpanels{k}))
               delete(hpanels{k});
           end
       end
       for k=1:length(projold.pifigures)
           if(isgraphics(projold.pifigures{k}))
               delete(projold.pifigures{k});
           end
       end
       hview=findobj(henhance,'tag','view');
       hk=get(hview,'children');
       delete(hk);
       hmpan=findobj(gcf,'tag','master_panel');
       udat=get(hmpan,'userdata');
       udat{1}={};
       geom=udat{2};
       geom(4)=geom(9);%resets the initial y coordinates of the panels
       udat{2}=geom;
       set(hmpan,'userdata',udat);
    end
    figure(henhance)
    waitsignalon 
    proj=getfield(m,varnames{ivar});
    ndatasets=length(proj.datanames);
    proj.projfilename=fname;
    proj.projpath=path;
    proj.pifigures=cell(1,ndatasets);
    proj.gui=cell(1,ndatasets);
    proj.datasets=cell(1,ndatasets);
    %check proj.segyrev and if necessary change from cell to ordinary array
    if(isfield(proj,'segyrev'))
        if(iscell(proj.segyrev))
            tmp=proj.segyrev{:};
            if(length(tmp)~=length(proj.datanames))
                tmp=zeros(1,length(proj.datanames));
            end
            %check segyrev for validity
            for k=1:length(tmp)
                if(isfield(proj.tracehdr{k},'CdpX'))
                    tmp(k)=1;
                else
                    tmp(k)=0;
                end
            end
            proj.segyrev=tmp;
            m.proj=proj;
        end
    else
        %ok we are missing a segyrev field so we insert one
        nd=length(proj.datanames);
        tmp=zeros(1,nd);
        for k=1:nd
            if(isfield(proj.tracehdr{k},'CdpX'))
                    tmp(k)=1;
                else
                    tmp(k)=0;
            end
        end
        proj.segyrev=tmp;
        m.proj=proj;
    end
    if(~isfield(proj,'history'))
        nd=length(proj.datanames);
        tmp=cell(1,nd);
        for k=1:nd
            tmp{k}='Loaded from SEGY';
        end
        proj.history=tmp;
    elseif(length(proj.history)~=length(proj.datanames))
        nd=length(proj.datanames);
        tmp=cell(1,nd);
        for k=1:nd
            tmp{k}='Loaded from SEGY';
        end
        proj.history=tmp;
    end
    set(hfile,'userdata',proj);
    loadprojectdialog
    return;
elseif(strcmp(action,'cancelprojectload'))
    hdial=gcf;
    henhance=get(hdial,'userdata');
    delete(hdial);
    hmsg=findobj(henhance,'tag','message');
    set(hmsg,'string','Project load cancelled');
    figure(henhance)
    waitsignaloff
    return
elseif(strcmp(action,'loadprojdial'))
    hdial=gcf;
    henhance=get(hdial,'userdata');
    hbutt=gcbo;
    subaction=get(hbutt,'tag');
    hh=findobj(hdial,'tag','loaded');
    hloaded=get(hh,'userdata');
    hh=findobj(hdial,'tag','display');
    hdisplayed=get(hh,'userdata');
    switch subaction
        case 'allyes'
            set([hloaded hdisplayed],'value',2);
            
        case 'allno'
            set([hloaded hdisplayed],'value',1);
            
        case 'continue'
            hfile=findobj(henhance,'tag','file');
            proj=get(hfile,'userdata');
            ndata=length(hloaded);
            for k=1:ndata
                if(proj.isdeleted(k)~=1)
                    proj.isloaded(k)=get(hloaded(k),'value')-1;
                    proj.isdisplayed(k)=get(hdisplayed(k),'value')-1;
                end
            end
            set(hfile,'userdata',proj);
            delete(hdial);
            figure(henhance);
            enhance('loadproject2');  
    end
    
elseif(strcmp(action,'loadproject2'))
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    hmsg=findobj(henhance,'tag','message');
    t0=clock;
    proj=get(hfile,'userdata');
    ndatasets=length(proj.datanames);
    m=matfile([proj.projpath proj.projfilename]);
    % put up datapanels for each dataset, read and display if needed
    %hpanels=cell(1,ndatasets);
    %PIfigs=cell(1,ndatasets);
    for k=1:ndatasets
        if(proj.isdeleted(k)~=1)
            proj.gui{k}=newdatapanel(proj.datanames{k},proj.isloaded(k),proj.isdisplayed(k));
            if(proj.isloaded(k)==1 || proj.isdisplayed(k)==1)%see if we read the dataset from disk
                cseis=m.datasets(1,k);%this reads it
                if(proj.isloaded(k)==1)
                    proj.datasets(1,k)=cseis;
                end
            end
            if(proj.isdisplayed(k)==1)%see if we display the dataset
                plotimage3D(cseis{1},proj.tcoord{k},{proj.xcoord{k},proj.xcdp{k}},{proj.ycoord{k},proj.ycdp{k}},...
                    proj.datanames{k},'seisclrs',proj.dx(k),proj.dy(k));
                %check for horizons
                if(isfield(proj,'horizons'))
                    if(length(proj.horizons)==ndatasets)
                        if(~isempty(proj.horizons{k}))
                            plotimage3D('importhorizons',proj.horizons{k});
                        end
                    end
                end
                %
                set(gcf,'tag','fromenhance','userdata',{k henhance});
                set(gcf,'closeRequestFcn','enhance(''closepifig'');');
                hview=findobj(henhance,'tag','view');
                uimenu(hview,'label',proj.datanames{k},'callback','enhance(''popupfig'');','userdata',gcf);
                proj.pifigures{k}=gcf;
                figure(henhance)
            end
        end
    end
    %check for the existence of horizons as a field
    if(~isfield(proj,'horizons'))
        proj.horizons=cell(1,ndatasets);
    elseif(length(proj.horizons)~=ndatasets)
        proj.horizons=cell(1,ndatasets);
    end
    %check fo the existence of a history field
    if(~isfield(proj,'history'))
        proj.history=cell(1,ndatasets);
        for k=1:ndatasets
            proj.history{k}=['Loaded from SEGY file ' proj.filenames{k}]; 
        end
    end
    %check for the existence of xlineloc as a field
    if(~isfield(proj,'xlineloc'))
        proj.xlineloc=cell(1,ndatasets);
    end
    if(~isfield(proj,'ylineloc'))
        proj.ylineloc=cell(1,ndatasets);
    end
    %check for existance of parmsets as a field
    if(~isfield(proj,'parmsets'))
        proj.parmsets={};
    end
    figure(henhance)
    waitsignaloff
    set(hfile,'userdata',proj);
    hpn=findobj(henhance,'tag','project_name');
    set(hpn,'string',proj.name)
    
    tnow=clock;
    timeused=etime(tnow,t0)/60;
    if(timeused>1)
        timeused=round(100*timeused)/100;
        set(hmsg,'string',['Project ' proj.name ' loaded in ' num2str(timeused) ' min'])
    else
        timeused=round(60*10*timeused)/10;
        set(hmsg,'string',['Project ' proj.name ' loaded in ' num2str(timeused) ' sec'])
    end
    set(henhance,'name',['ENHANCE, Project: ' proj.name ])

elseif(strcmp(action,'newproject'))
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    %check for existing project and delete any data panels
    projold=get(hfile,'userdata');
    if(~isempty(projold))
        hpanels=projold.gui;
        for k=1:length(hpanels)
            if(isgraphics(hpanels{k}))
                delete(hpanels{k});
            end
        end
        for k=1:length(projold.pifigures)
            if(isgraphics(projold.pifigures{k}))
                delete(projold.pifigures{k});
            end
        end
        hview=findobj(henhance,'tag','view');
        hk=get(hview,'children');
        delete(hk);
        hmpan=findobj(gcf,'tag','master_panel');
        udat=get(hmpan,'userdata');
        geom=udat{2};
        geom(4)=geom(9);%resets the initial y coordinates of the panels
        udat{1}={};
        udat{2}=geom;
        set(hmpan,'userdata',udat);
    end
    proj=makeprojectstructure;
    set(hfile,'userdata',proj);
    hpn=findobj(henhance,'tag','project_name');
    set(hpn,'string',proj.name)
    hmsg=findobj(henhance,'tag','message');
    set(hmsg,'string','Now read some data into your project')
    if(isdeployed)
        set(henhance,'name',['ENHANCE, Project: ' proj.name ])
    else
        set(henhance,'name',['ENHANCE, (MATLAB) Project: ' proj.name ])
    end
elseif(strcmp(action,'readhor'))
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    %put up dialog window
    [path]=uigetdir('Select horizon (.xyz file) folder');
    if(path==0)
        return
    end
    files=dir(fullfile(path,'*.xyz'));
    if(isempty(files))
        msgbox('Chosen folder has no .xyz files');
        return;
    end
    pos=get(henhance,'position');
    xc=pos(1)+.5*pos(3);
    yc=pos(2)+.5*pos(4);
    fwd=1000;
    fht=400;
    hdial=figure('position',[xc-.5*fwd, yc-.5*fht, fwd, fht],'name','ENHANCE: Horizon import dialog',...
        'numbertitle','off','menubar','none','toolbar','none');
    set(hdial,'userdata',henhance);
    
    %table showing datasets
    ndata=length(proj.datanames);
    d=cell(ndata,2);
    nmax=0;
    for k=1:ndata
       d(k,:)={proj.datanames{k},false};
       nm=length(proj.datanames{k});
       if(nm>nmax)
           nmax=nm;
           kmax=k;%points to longest name
       end
    end
    %determine pixel size of longest name
    ht=uicontrol(hdial,'style','text','string',proj.datanames{kmax},'units','pixels','visible','off');
    pxsize=ht.Extent;
    delete(ht);
    wid=5*pxsize(3)/fwd;
    ht=2*ndata*pxsize(4)/fht;
    xnow=.05;ynow=.8-ht;
    htab=uitable(hdial,'units','normalized','position',[xnow,ynow,wid,ht],'data',d,...
        'columneditable',[false,true],'columnname',{'data','assoc.'},'tag','datasets');
    ext=get(htab,'extent');
    pos=get(htab,'position');
    set(htab,'position',[pos(1) pos(2)+(pos(4)-ext(4)) ext(3:4)])
    pos=get(htab,'position');
    ynow=pos(2)+pos(4);
    uicontrol(hdial,'style','text','string','Choose the datasets to associate with the horizons',...
        'units','normalized','position',[xnow,ynow,.4,.05],'horizontalalignment','left','fontsize',10);
    nf=length(files);
    d2=cell(nf,3);
    for k=1:nf
        d2(k,:)={files(k).name, false, ''};
    end
    wid=.9-xnow;
    ht=.8;
    %ynow=ynow-pos(4)-.05;
    ynow=.2;
    htab2=uitable(hdial,'units','normalized','position',[xnow,ynow,wid,ht],'data',d2,...
        'columneditable',[false,true,true],'columnname',{'File','import','Horizon name'},'columnwidth',...
        {round(wid*fwd*.8),round(wid*fwd*.05),round(wid*fwd*.15)},'tag','files','userdata',path);
    ext2=get(htab2,'extent');
    pos2=get(htab2,'position');
    set(htab2,'position',[pos2(1), pos(2)-ext2(4)-.1 ext2(3:4)])
    pos2=get(htab2,'position');
    ynow=pos2(2)+pos2(4);
    uicontrol(hdial,'style','text','string','Choose the horizon files to import and a name for each horizon',...
        'units','normalized','position',[xnow,ynow,.4,.05],'horizontalalignment','left','fontsize',10);
    ynow=.1;
    wid=.1;ht=.05;
    uicontrol(hdial,'style','pushbutton','string','Done','units','normalized','tag','done',...
        'position',[xnow,ynow,wid,ht],'callback','enhance(''readhor2'');');
    uicontrol(hdial,'style','pushbutton','string','Cancel','units','normalized','tag','cancel',...
        'position',[xnow+wid+.05,ynow,wid,ht],'callback','enhance(''readhor2'');');
    return;
elseif(strcmp(action,'readhor2'))
    hdial=gcf;
    henhance=get(hdial,'userdata');
    hbut=gcbo;
    tag=get(hbut,'tag');
    if(strcmp(tag,'cancel'))
        hmsg=findobj(henhance,'tag','message');
        set(hmsg,'string','Horizon import cancelled')
        delete(hdial)
        return;
    end
    
    hd=findobj(hdial,'tag','datasets');
    data=hd.Data;
    hf=findobj(hdial,'tag','files');
    files=hf.Data;
    %make sure there is at least one thing checked in each
    nd=size(data,1);
    ichkd=zeros(nd,1);
    for k=1:nd
        if(data{k,2})
            ichkd(k)=1;
        end
    end
    if(sum(ichkd)==0)
        msgbox('You must check at least one dataset');
        return;
    end
    nf=size(files,1);
    ichkf=zeros(nf,1);
    for k=1:nf
        if(files{k,2})
            ichkf(k)=1;
        end
    end
    if(sum(ichkf)==0)
        msgbox('You must check at least one file');
        return;
    end
    %make sure we have a short name for each horizon
    namesok=true;
    for k=1:nf
        if(ichkf(k)==1)
           if(isempty(files{k,3}))
               namesok=false;
           end
        end
    end
    if(~namesok)
       msgbox('You must provide a Horizon Name for each imported file');
       return
    end
    %check that the associated datasets are the same size
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    nx=0;ny=0;
    for k=1:nd
        if(ichkd(k)==1)
            if(nx==0)
                x=proj.xcoord{k};
                y=proj.ycoord{k};
                nx=length(x);
                ny=length(y);
            else
                nx2=length(proj.xcoord{k});
                ny2=length(proj.ycoord{k});
                if((nx~=nx2)||(ny~=ny2))
                    msgbox('Horizon files can only be associated with multiple datasets if the datasets are the same size');
                    return;
                end
            end
        end
    end
    %ok, good to go
    path=get(hf,'userdata');
    delete(hdial);
    figure(henhance);
    hmsg=findobj(henhance,'tag','message');
    inlinemin=min(y);
    xlinemin=min(x);
    figure(henhance)
    waitsignalon
    %put an ampty horizon structure in each dataset
    for k=1:nf %loop over the horizon files
        
        if(ichkf(k)==1)
            set(hmsg,'string',['Importing horizon file ' files{k,1}]);
            drawnow;
            [value,xf,yf,xlf,ilf]=readhorizonfile([path '\' files{k,1}]); %#ok<ASGLU>
            %check for milliseconds and correct
            if(max(value)>10)
                value=value/1000;
            end
            %sort into a survey-sized array
            horizon=nan*zeros(nx,ny);
            set(hmsg,'string','Sorting ...');
            drawnow;
            for jj=1:length(value)
               ii=round(ilf(jj)-inlinemin)+1;
               kk=round(xlf(jj)-xlinemin)+1;
               if(ii>=1 && ii<=ny && kk>=1 && kk<=nx)
                  horizon(kk,ii)=value(jj); 
               end
            end
            %now load this horizon into project structure and associate with the datasets
            thishor=files{k,3};%name of this horizon
            for jj=1:nd
                if(ichkd(jj)==1)
                    %make a horizon structure if needed
                    if(isempty(proj.horizons{jj}))
                        %make a horizon structure
                        horstruct.horizons=[];
                        horstruct.filenames={};
                        horstruct.names={};
                        horstruct.showflags=[];
                        horstruct.colors={};
                        horstruct.linewidths=[];
                        horstruct.handles=[];
                    else
                        horstruct=proj.horizons{jj};
                    end
                    nhors=length(horstruct.names);%number of horizons for this dataset before this one
                    %check for exisiting horizon of same name
                    jjhor=nhors+1;%anticipate this is a new horizon
                    if(nhors>0)
                        for kk=1:nhors
                           if(strcmp(thishor,horstruct.names(kk)))
                               jjhor=kk;
                               break;
                           end
                        end
                    end
                    horstruct.horizons(jjhor,:,:)=horizon;
                    horstruct.filenames{jjhor}=files{k,1};
                    horstruct.names{jjhor}=files{k,3};
                    horstruct.showflags(jjhor)=1;
                    horstruct.colors{jjhor}=[];
                    horstruct.linewidths(jjhor)=1;
                    horstruct.handles(jjhor)=-1;% a -1 always fails the isgraphics test
                    proj.horizons{jj}=horstruct;
                end
                
            end
            
        end
    end
    set(hfile,'userdata',proj)
    set(hmsg,'string','Horizon import complete');
    figure(henhance)
    waitsignaloff
    
elseif(strcmp(action,'datamemory'))
    %This gets called if the "in memory" radio buttons are toggled
    %We want to be able to control whether a dataset is in memory or not. When in memory, then it is
    %present in the "datasets" field of the proj structure. If it is displayed, then it is also
    %present in the userdata of a plotimage3D window. Once a dataset is displayed, we may want to
    %clear it from memory, otherwise there are effectively two copies of it in memory. We would
    %really only want to save it in memory if we planned on applying an operation to it. If a
    %dataset has just been loaded to SEGY and not yet saved in the project, then we need to write it
    %to disk first before clearing it from memory.
    henhance=findenhancefig;
    hbut=gcbo;%will be either 'Y' or 'N'
    hbg=get(hbut,'parent');
    hpan=get(hbg,'parent');
    hmsg=findobj(henhance,'tag','message');
    idata=hpan.UserData;%the dataset number
    choice=get(hbut,'string');%this will be 'Y' or 'N'
    hfile=findobj(henhance,'tag','file');
    proj=hfile.UserData;
    ilive=find(proj.isdeleted==0);
    if(strcmp(choice','N'))
        %dataset is being cleared from memory
        %first check to ensure that the project has been save so that a project file exists on disk
        if(isempty(proj.projfilename)||isempty(proj.projpath))
            msgbox('Please save the project to disk before clearing data from memory');
            return;
        end
        %we also close any display
%         hfig=proj.pifigures(ilive(idata));
%         if(isgraphics(hfig))
%             close(hfig);
%         end
%         proj.pifigures{ilive(idata)}=[];
%         proj.isdisplayed(ilive(idata))=0;
        proj.isloaded(ilive(idata))=0;
        %now we need to be sure that the data exists on disk before clearing it from memory
        if(proj.saveneeded(ilive(idata))==1)
            %open the project file
            matobj=matfile([proj.projpath proj.projfilename],'writable',true);
            [meh,ndatasetsondisk]=size(matobj,'datasets'); %#ok<ASGLU>%this is the number datasets that exist on disk
            ndatasets=length(proj.datasets);%this is how many datasets there are in total
            if(ndatasetsondisk<ndatasets)
                nnew=ndatasetsondisk+1:ndatasets;
                matobj.datasets(1,nnew)=cell(1,length(nnew));
            end
            if(isempty(proj.datasets(1,ilive(idata))))
                error('attempt to save empty dataset');
            end
            matobj.datasets(1,ilive(idata))=proj.datasets(1,ilive(idata));
            proj.saveneeded(ilive(idata))=0;
            proj.datasets{ilive(idata)}=[];
            pifigs=proj.pifigures;
            proj.pifigures=[];
            matobj.proj=proj;%need to save the project for consistency on disk
            proj.pifigures=pifigs;
        end
        proj.datasets{ilive(idata)}=[];
%         %set the isdisplayed button to no
%         hno=findobj(hpan,'tag','displayno');
%         set(hno,'value',0);
        set(hfile,'userdata',proj);
        set(hmsg,'string',['Datset ' proj.datanames{ilive(idata)} ' cleared from memory but may still be displayed']);
    else
        %dataset is being loaded into memory and displayed
        hmpan=findobj(gcf,'tag','master_panel');
        udat=hmpan.UserData;
        udat{3}=idata;%this flags to reload which dataset we are reading
        hmpan.UserData=udat;
        enhance('reloaddataset');%this updates proj and displays the dataset
        %set the isdisplayed button to yes
        hyes=findobj(hpan,'tag','displayyes');
        set(hyes,'value',1);
    end
elseif(strcmp(action,'datadisplay'))
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    hmsg=findobj(henhance,'tag','message');
    proj=get(hfile,'userdata');
    %determine choice
    hbut=gcbo;
    butname=get(hbut,'string');
    val=get(hbut,'value');
    if((strcmp(butname,'Y')&&val==1)||(strcmp(butname,'N')&&val==0))
        choice='display';
    else
        choice='dontdisplay';
    end
    %deternime dataset number
    hpan=get(get(hbut,'parent'),'parent');
    idata=get(hpan,'userdata');
    ilive=find(proj.isdeleted==0);
    switch choice
        case 'display'
            figure(henhance)
            waitsignalon
            %check if dataset is loaded
            if(~proj.isloaded(ilive(idata))||isempty(proj.datasets{ilive(idata)}))
                hmpan=findobj(gcf,'tag','master_panel');
                udat=hmpan.UserData;
                udat{3}=idata;%this flags to reload which dataset we are reading
                hmpan.UserData=udat;
                enhance('reloaddataset');%this loads and displays and updates proj
                %set the isdisplayed button to yes
                hyes=findobj(hpan,'tag','displayyes');
                set(hyes,'value',1);
                hyes=findobj(hpan,'tag','memoryyes');
                set(hyes,'value',1);
            else
                %now display
%                 plotimage3D(proj.datasets{ilive(idata)},proj.tcoord{ilive(idata)},proj.xcoord{ilive(idata)},...
%                     proj.ycoord{ilive(idata)},proj.datanames{ilive(idata)},'seisclrs',proj.dx(ilive(idata)),proj.dy(ilive(idata)))
                plotimage3D(proj.datasets{ilive(idata)},proj.tcoord{ilive(idata)},{proj.xcoord{ilive(idata)},proj.xcdp{ilive(idata)}},...
                    {proj.ycoord{ilive(idata)},proj.ycdp{ilive(idata)}},proj.datanames{ilive(idata)},'seisclrs',proj.dx(ilive(idata)),proj.dy(ilive(idata)))
                %check for horizons
                if(isfield(proj,'horizons'))
                    if(length(proj.horizons)==length(proj.datanames))
                        if(~isempty(proj.horizons{ilive(idata)}))
                            plotimage3D('importhorizons',proj.horizons{ilive(idata)});
                        end
                    else
                        proj.horizons=cell(1,length(proj.datanames));
                    end
                end
                set(gcf,'tag','fromenhance','userdata',{idata henhance});
                set(gcf,'closeRequestFcn','enhance(''closepifig'');')
                hview=findobj(henhance,'tag','view');
                uimenu(hview,'label',proj.datanames{ilive(idata)},'callback','enhance(''popupfig'');','userdata',gcf);
                proj.isdisplayed(ilive(idata))=1;
                proj.pifigures{ilive(idata)}=gcf;
                set(hfile,'userdata',proj);
                set(hmsg,'string',['Dataset ' ,proj.datanames{ilive(idata)} ' displayed'])
            end
            figure(henhance)
            waitsignaloff
        case 'dontdisplay'
            hpifig=proj.pifigures{ilive(idata)};
            if(isgraphics(hpifig))
                figure(hpifig);
                enhance('closepifig');
            else
                proj.isdisplayed(ilive(idata))=0;
                proj.pifigures{ilive(idata)}=[];
                set(hfile,'userdata',proj)
            end
            
    end
    figure(henhance)
elseif(strcmp(action,'closepifig'))
    hthisfig=gcbf;
    if(strcmp(get(hthisfig,'tag'),'enhance'))
        %ok, the call came from ENHANCE
        hpan=get(get(gcbo,'parent'),'parent');%should be the panel of the dataset whose figure is closing
        idat=get(hpan,'userdata');
        hfile=findobj(hthisfig,'tag','file');
        proj=get(hfile,'userdata');
        hthisfig=proj.pifigures{idat};
    end
    test=get(hthisfig,'name');
    %ind=strfind(test,'plotimage3D');
    tag=get(hthisfig,'tag');
    udat=get(hthisfig,'userdata');
    if(length(udat)>1)
        henhance=udat{2};
    else
        henhance=findenhancefig;
    end
    hview=findobj(henhance,'tag','view');
    if(contains(test,'plotimage3D')&&strcmp(tag,'fromenhance')&&iscell(udat)&&length(udat)==2)
        %if we get this far then we have a legitimate closure of a pifig
        %that pifig is called hthisfig
        hmenus=get(hview,'children');
        for k=1:length(hmenus)
           fig=get(hmenus(k),'userdata');
           if(fig==hthisfig)
              delete(hmenus(k));
           end
        end
%         PLOTIMAGE3DTHISFIG=proj.pifigures{idata};
%         flag=get(hg,'value');
%         if(flag==1)
%             plotimage3D('groupex');
%         else
%             plotimage3D('ungroupex')
%         end
        %check for horstruct
        hfile=findobj(henhance,'tag','file');
        proj=get(hfile,'userdata');
        hhor=findobj(hthisfig,'tag','horizons');
        idata=udat{1};
        if(~isempty(hhor))
           horstruct=get(hhor,'userdata');
           proj.horizons{idata}=horstruct;
        end
        
        plotimage3D('closeenhance');
        if(isgraphics(hthisfig))
            return; %this happens if they choose not to close
        end
        %delete(hthisfig);
        hmsg=findobj(henhance,'tag','message');
        
        
        proj.pifigures{idata}=[];
        hpanels=proj.gui;
        hpan=hpanels{idata};
        hno=findobj(hpan,'tag','displayno');
        set(hno,'value',1);
        proj.isdisplayed(idata)=0;
        %ungroup if needed
        hg=findobj(hpan,'tag','group');
        val=get(hg,'value');
        if(val==1)
            set(hg,'value',0);
        end
        set(hfile,'userdata',proj);
        bn=questdlg('Do you want to keep the data in memory?','Memory question','Yes','No','No');
        if(strcmp(bn,'No'))
            %remove from memory
            figure(henhance)
            waitsignalon
            %need to check if it has been saved before we delete it
            if(~isempty(proj.projfilename))
                %this means the project has been save at least onece. However, the dataset might not
                %have been. So, we check for dataset saved.
                mObj=matfile([proj.projpath proj.projfilename],'writable',true);
                [meh,ndatasetsondisk]=size(mObj,'datasets'); %#ok<ASGLU>
                ndatasets=length(proj.datasets);
                if(ndatasets>ndatasetsondisk)
                    jdata=ndatasetsondisk+1:ndatasets;
                    nnew=length(jdata);
                    mObj.datasets(1,jdata)=cell(1,nnew);
                end
                %check total project datasize and compare to size of datasets on disk. If the disk
                %size is greater than the computed data size, then we can assume the dataset has
                %already been written to disk
                info=whos(mObj,'datasets');
                if(info.bytes<datasetsize)
                    set(hmsg,'string','Saving dataset to disk');
                    if(isempty(proj.datasets(1,idata)))
                        error('attempt to save empty dataset');
                    end
                    mObj.datasets(1,idata)=proj.datasets(1,idata);
                end
                figure(henhance)
                waitsignaloff
            else
                enhance('saveproject');
                proj=get(hfile,'userdata');
            end
            proj.datasets{idata}=[];
            hno=findobj(hpan,'tag','memoryno');
            set(hno,'value',1);
            proj.isloaded(idata)=0;
            set(hmsg,'string','Dataset removed from memory')
            set(hfile,'userdata',proj);
        else
            set(hmsg,'string','Display closed but data retained in memory');
        end
        
        figure(henhance)
    end
elseif(strcmp(action,'datanamechange'))
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    hmsg=findobj(henhance,'tag','message');
    hnamebox=gcbo;
    idata=get(get(hnamebox,'parent'),'userdata');
    oldname=proj.datanames{idata};
    newname=get(hnamebox,'string');
    proj.datanames{idata}=newname;
    set(hfile,'userdata',proj);
    %look for open pi3d windows and change those
    hview=findobj(henhance,'tag','view');
    hkids=get(hview,'children');
    for k=1:length(hkids)
        if(strcmp(get(hkids(k),'label'),oldname))%see if the name matches
            hpifig=get(hkids(k),'userdata');
            if(isgraphics(hpifig))
                udat=get(hpifig,'userdata');
                jdata=udat{1};%there might be two datasets with the same name so jdata must match idata
                if(jdata==idata)
                    %this is it
                    plotimage3D('datanamechange',hpifig,newname);
                    set(hkids(k),'label',newname);
                end
            end
        end
    end
    set(hmsg,'string',[' dataset name changed to ' newname])
elseif(strcmp(action,'close'))
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    if(isempty(proj.datanames))
        hmsg=findobj(henhance,'tag','message');
        ud=get(hmsg,'userdata');
        for k=1:length(ud)
           if(isgraphics(ud(k)))
               delete(ud(k));
           end
        end
        delete(henhance);
        return;
    end
    bn=questdlg('Do you want to save the project first?','Close ENHANCE','Yes','No','Cancel','Yes');
    hmsg=findobj(henhance,'tag','message');
    hfigs=get(hmsg,'userdata');%figures needing closure other than PI3D figures
    switch bn
        case 'Cancel'
            set(hmsg,'string','Close cancelled')
            return;
        case 'Yes'
            enhance('saveproject')
            %check if ppt is open and save it
            hppt=findobj(henhance,'tag','pptx');
            str=get(hppt,'string');
            if(strcmp(str,'Close PPT'))
                enhance('pptx')
            end
            for k=1:length(hfigs)
                if(isgraphics(hfigs(k)))
                    delete(hfigs(k))
                end
            end
            delete(henhance)
            for k=1:length(proj.pifigures)
%                if(isgraphics(proj.pifigures{k}))
%                    delete(proj.pifigures{k});
%                end
                if(isgraphics(proj.pifigures{k}))
                    figure(proj.pifigures{k})
                    plotimage3D('close','Yes');
                end
            end
        case 'No'
            %check if ppt is open and save it
            hppt=findobj(henhance,'tag','pptx');
            str=get(hppt,'string');
            if(strcmp(str,'Close PPT'))
                enhance('pptx')
            end
            for k=1:length(hfigs)
                if(isgraphics(hfigs(k)))
                    delete(hfigs(k))
                end
            end
            delete(henhance)
            for k=1:length(proj.pifigures)
%                if(isgraphics(proj.pifigures{k}))
%                    delete(proj.pifigures{k});
%                end
                if(isgraphics(proj.pifigures{k}))
                    figure(proj.pifigures{k});
                    plotimage3D('close','Yes');
                end
            end
    end
elseif(strcmp(action,'popupfig'))
    hmenu=gcbo;
    fig=get(hmenu,'userdata');
    if(isgraphics(fig))
        figure(fig);
    else
        delete(hmenu);
    end
elseif(strcmp(action,'datadelete'))
    henhance=findenhancefig;
    hbutt=gcbo;
    idata=get(get(hbutt,'parent'),'userdata');
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    hmsg=findobj(henhance,'tag','message');
    %confirm
    choice=questdlg(['Please confirm the deletion of dataset ' proj.datanames{idata}],'Data deletion','Yes','No','Cancel','Yes');
    switch choice
        case 'No'
            set(hmsg,'string','Data deletion cancelled');
        case 'Cancel'
            set(hmsg,'string','Data deletion cancelled');
        case 'Yes'
            proj.isdeleted(idata)=1;%set deletion flag
            proj.deletedondisk(idata)=0;
            if(isgraphics(proj.pifigures{idata}))
                delete(proj.pifigures{idata});
            end
            proj.filenames{idata}=[];
            proj.paths{idata}=[];
            deadname=proj.datanames{idata};
            proj.datanames{idata}=[];
            proj.isloaded(idata)=0;
            proj.isdisplayed(idata)=0;
            proj.xcoord{idata}=[];
            proj.ycoord{idata}=[];
            proj.tcoord{idata}=[];
            proj.tshift(idata)=0;
            proj.datasets{idata}=[];
            proj.xcdp{idata}=[];
            proj.ycdp{idata}=[];
            proj.dx(idata)=0;
            proj.dy(idata)=0;
            proj.depth(idata)=0;
            proj.texthdr{idata}=[];
            proj.texthdrfmt{idata}=[];
            proj.segfmt{idata}=[];
            proj.byteorder{idata}=[];
            proj.binhdr{idata}=[];
            proj.exthdr{idata}=[];
            proj.tracehdr{idata}=[];
            proj.kxline{idata}=[];
            if(isgraphics(proj.gui{idata}))
                pos=get(proj.gui{idata},'position');
                parent=get(proj.gui{idata},'parent');
                delete(proj.gui{idata});
                uicontrol(parent,'style','text','string',{['dataset ' deadname ' has been deleted.'],...
                    'This space will disappear when you save and reload the Project. Deletion on disk does not happen until you save the project'},...
                    'units','normalized','position',pos);
            end
            set(hmsg,'string',['dataset ' deadname ' has been deleted.'])
            set(hfile,'userdata',proj);
    end
elseif(strcmp(action,'group'))
    henhance=findenhancefig;
    hg=gcbo;
    idata=get(get(hg,'parent'),'userdata');
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    if(proj.isdisplayed(idata)==0)
        msgbox({'Grouping only works if the dataset is displayed.' 'Display it first, then group.'});
        return
    end
    if(isgraphics(proj.pifigures{idata}))
        PLOTIMAGE3DTHISFIG=proj.pifigures{idata};
        flag=get(hg,'value');
        if(flag==1)
            plotimage3D('groupex');
        else
            plotimage3D('ungroupex')
        end
    else
        error('Logic error in ENHANCE when trying to group/ungroup figures')
    end
elseif(strcmp(action,'pi3d:group'))
    %this is a message from plotimage3D saying either a group or an ungroup has happened
%     hpi3d=gcf;%if this happens then a pi3d figure is current
%     %now we verify that the pi3d figure is from enhance
%     udat=get(hpi3D,'userdata');
%     tag=get(hpi3d,'tag');
%     if(strcmp(tag,'fromenhance')&&length(udat)==2)
%         henhance=udat{2};
%     else
%         return; %if this happens then the logic has failed
%     end
    henhance=arg2{2};
    
    hgroup=PLOTIMAGE3DFIGS;%these are the grouped figures
    
    hmpan=findobj(henhance,'tag','master_panel');%the master panel is the key to ENHANCE data panels
    udat2=get(hmpan,'userdata');
    hpanels=udat2{1};%the enhance data panels
    idatas=zeros(size(hgroup));
    %loop over the grouped figures and find their enhance data numbers
    for k=1:length(hgroup)
        udat3=get(hgroup(k),'userdata');
        if(strcmp(get(hgroup(k),'tag'),'fromenhance'))
            idatas(k)=udat3{1};
        end    
    end
    %now loop over panels and compare their data numbers to those in the group
    for k=1:length(hpanels)
        hg=findobj(hpanels{k},'tag','group');
        idata=get(hpanels{k},'userdata');
        ind=find(idata==idatas, 1);
        if(~isempty(ind))
            set(hg,'value',1);
        else
            set(hg,'value',0);
        end
    end
elseif(strcmp(action,'writesegy'))
    henhance=findenhancefig;
    hmsg=findobj(henhance,'tag','message');
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    iout=listdlg('Promptstring','Choose the dataset for output','liststring',proj.datanames(~proj.isdeleted),...
        'selectionmode','single','listsize',[500,300]);
    %adjust iout to account for deletions
    ik=0;
    for k=1:length(proj.datanames)
        if(~isempty(proj.datanames{k}))
            ik=ik+1;
        end
        if(ik==iout)
            iout=k;
        end
    end
    if(isempty(iout))
        return;
    end
    [fname,path]=uiputfile('*.sgy','Select the output file');
    if(isequal(fname,0) || isequal(path,0))
        msgbox('Output cancelled');
        return;
    end
    if(exist([path fname],'file'))
        delete([path fname]);
    end
    if(isempty(proj.datasets{iout}))
        %recall the dataset from disk
        mObj=matfile([pro.projpath proj.projfilename]);
        cseis=mObj.datasets(1,iout);
    else
        cseis=proj.datasets(1,iout);
    end
    figure(henhance)
    waitsignalon
    set(hmsg,'string','Forming output array');
    seis=unmake3Dvol(cseis{1},proj.xcoord{iout},proj.ycoord{iout},proj.xcdp{iout},proj.ycdp{iout},...
        'kxlineall',proj.kxline{iout});
    dt=abs(proj.tcoord{iout}(2)-proj.tcoord{iout}(1));
    set(hmsg,'string','Beginning SEGY output');
    writesegy([path fname],seis,getsegyrev(iout),dt,proj.segfmt{iout},proj.texthdrfmt{iout},...
        proj.byteorder{iout},proj.texthdr{iout},proj.binhdr{iout},proj.exthdr{iout},...
        proj.tracehdr{iout},proj.bindef{iout},proj.trcdef{iout},henhance);
    figure(henhance)
    waitsignaloff
    set(hmsg,'string',['Dataset ' [path fname] ' written']);
elseif(strcmp(action,'writemat'))
    msgbox('Sorry, feature not yet implemented')
    return;
elseif(strcmp(action,'starttask'))
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    proj=hfile.UserData;
    if(isempty(proj.datasets))
        msgbox('You need to load some data before you can do this!','Oh oh ...');
        return
    end
    %determine the task
    task=get(gcbo,'tag');
    parmset=getparmset(task);
    switch task
        case 'filter'
            enhancetask(proj.datanames,parmset,task);
        case 'phasemap'
            return;
        case 'spikingdecon'
            enhancetask(proj.datanames,parmset,task);
            return;
        case 'fdom'
            enhancetask(proj.datanames,parmset,task);
            return;
        case 'wavenumber'
            enhancetask(proj.datanames,parmset,task);
        case 'specdecomp'
            enhancetask(proj.datanames,parmset,task,[1 1 0 1]);
        case 'gabordecon'
            enhancetask(proj.datanames,parmset,task);
        case 'svdsep'
            svdsep_dialog(parmset,'enhance(''dotask'');');%svd_sep need a more complex dialog than the standard
    end
    hmsg=findobj(henhance,'tag','message');
    set(hmsg,'string',['Fill out parameter dialog for task "' task '"'])
elseif(strcmp(action,'dotask'))
    htaskfig=gcf;
    ud=get(htaskfig,'userdata');
    henhance=ud{2};
    htask=findobj(htaskfig,'tag','task');
    udat=get(htask,'userdata');
    task=udat{1};
    parmset=udat{2};%these are the parameters before user modification
    nparms=(length(parmset)-1)/3;
    %determine the dataset name, get the project
    hdat=findobj(htaskfig,'tag','datasets');
    idat=get(hdat,'value');
    %henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    hmsg=findobj(henhance,'tag','message');
    proj=hfile.UserData;
    if(~strcmp(task,'svdsep'))
        %pull the updated parameters out of the gui, don't need this for svdsep because the
        %parameter dialog has done the QC
        for k=1:nparms
            hobj=findobj(htaskfig,'tag',parmset{3*(k-1)+2});
            val=get(hobj,'string');
            parm=parmset{3*(k-1)+3};
            if(iscell(val))
                ival=get(hobj,'value');
                parm{end}=ival;
            else
                flag=get(hobj,'userdata');
                if(flag==1)
                    parm={val};
                else
                    parm=val;
                end
            end
            parmset{3*(k-1)+3}=parm;
        end
        %check the parms for validity
        switch task
            case 'filter'
                parmset=parmsetfilter(parmset);
                %if parmset comes back as a string, then we have failure
            case 'phasemap'
                
                
            case 'spikingdecon'
                parmset=parmsetdecon(parmset,proj.tcoord{idat});
                
            case 'fdom'
                parmset=parmsetfdom(parmset,proj.tcoord{idat});
                
            case 'wavenumber'
                parmset=parmsetwavenumber(parmset);
                
            case 'specdecomp'
                parmset=parmsetspecdecomp(parmset,proj.tcoord{idat});
                
            case 'gabordecon'
                parmset=parmsetgabordecon(parmset,proj.tcoord{idat});
                
        end
        if(ischar(parmset))
            msgbox(parmset,'Oh oh, there are problems...');
            return;
        end
    end
    %save the updated parmset
    setparmset(parmset);
    %get the dataset
    if(~proj.isloaded(idat))
        %load the dataset
        figure(henhance)
        waitsignalon
        set(hmsg,'string',['Loading ' proj.datanames{idat} ' from disk']);
        hmpan=findobj(henhance,'tag','master_panel');
        udat=hmpan.UserData;
        udat{3}=idat;%this flags to reload which dataset we are reading
        hmpan.UserData=udat;
        enhance('reloaddataset');%this updates proj and displays the dataset
        proj=hfile.UserData;
        figure(henhance)
        waitsignaloff
    end
    %determine output dataset's fate
    hout=findobj(htaskfig,'tag','outputs');
    outopts=get(hout,'string');
    fate=outopts{get(hout,'value')};
    seis=proj.datasets{idat};
    t=proj.tcoord{idat};
    x=proj.xcoord{idat};
    y=proj.ycoord{idat};
    xcdp=proj.xcdp{idat};
    ycdp=proj.ycdp{idat};
    dx=proj.dx(idat);
    dy=proj.dy(idat);
    dname=proj.datanames{idat};
    %close the task window
    close(htaskfig);
    %start the task
    hcompute=findobj(henhance,'label','Compute');
    switch task
        case 'filter'
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Bandpass filtering in progress')
            fmin=getparm(parmset,'fmin');
            dfmin=getparm(parmset,'dfmin');
            fmax=getparm(parmset,'fmax');
            dfmax=getparm(parmset,'dfmax');
            phase=getparm(parmset,'phase');
            if(strcmp(phase,'zero'))
                phase=0;
            else
                phase=1;
            end
            hstry=[{[task ' on ' proj.datanames{idat}]} parmset2history(parmset)];
            nx=length(x);ny=length(y);
            itrace=0;
            %The waitbar implements a cancel operation that works through the globals HWAIT and
            %CONTINUE. When the cancel button is hit (on the waitbar) the callback 'enhance(''canceltaskafter'')'
            %sets the value of CONTINUE to false which causes the loop to stop. The callback also
            %removes the input dataset from memory and deletes the waitbar. Thus to restart the task
            %(it always must start from the beginning) then the dataset must be reloaded.
            HWAIT=waitbar(0,'Please wait for bandpass filtering to complete','CreateCancelBtn','enhance(''canceltaskafter'')');
            ntraces=nx*ny;
            t0=clock;
            CONTINUE=true;
            for k=1:nx
                for j=1:ny
                    tmp=seis(:,k,j);
                    if(sum(abs(tmp))>0)
                        seis(:,k,j)=filtf(tmp,t,[fmin dfmin],[fmax dfmax],phase);
                    end
                    itrace=itrace+1;
                    if(~CONTINUE)
                        break;
                    end
                end
                if(~CONTINUE)
                        break;
                end
                t1=clock;
                timeused=etime(t1,t0);
                timeleft=(timeused/itrace)*(ntraces-itrace)/60;%in minutes
                timeleft=round(timeleft*100)/100;
                waitbar(itrace/ntraces,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
            end
            t1=clock;
            timeused=etime(t1,t0);
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused/60) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'spikingdecon'
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Spiking decon in progress')
            oplen=getparm(parmset,'oplen');
            stab=getparm(parmset,'stab');
            topgate=getparm(parmset,'topgate');
            botgate=getparm(parmset,'botgate');
            fmin=getparm(parmset,'fmin');
            dfmin=getparm(parmset,'dfmin');
            fmax=getparm(parmset,'fmax');
            dfmax=getparm(parmset,'dfmax');
            phase=getparm(parmset,'phase');
            dt=t(2)-t(1);
            if(strcmp(phase,'zero'))
                phase=0;
            else
                phase=1;
            end
            hstry=[{task} parmset2history(parmset)];
            nx=length(x);ny=length(y);
            itrace=0;
            HWAIT=waitbar(0,'Please wait for decon to complete','CreateCancelBtn','enhance(''canceltaskafter'')');
            ntraces=nx*ny;
            t0=clock;
            idesign=near(t,topgate,botgate);
            nop=round(oplen/dt);
            CONTINUE=true;
            for k=1:nx
                for j=1:ny
                    tmp=seis(:,k,j);
                    tmpd=seis(idesign,k,j);
                    if(sum(abs(tmpd))>0)
                        tmpdecon=deconw(tmp,tmpd,nop,stab);
                        seis(:,k,j)=filtf(tmpdecon,t,[fmin dfmin],[fmax dfmax],phase);
                    end
                    itrace=itrace+1;
                    if(~CONTINUE)
                        break;
                    end
                end
                if(~CONTINUE)
                        break;
                end
                t1=clock;
                timeused=etime(t1,t0);
                timeleft=(timeused/itrace)*(ntraces-itrace)/60;%in minutes
                timeleft=round(timeleft*100)/100;
                waitbar(itrace/ntraces,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
            end
            t1=clock;
            timeused=etime(t1,t0);
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused/60) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'gabordecon'
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Gabor decon beginning, starting parallel pool');drawnow
            %unpack parameters
            twin=getparm(parmset,'Twin');
            tinc=getparm(parmset,'Tinc');
            tsmo=getparm(parmset,'Tsmo');
            fsmo=getparm(parmset,'Fsmo');
            stab=getparm(parmset,'Stab');
            gphase=getparm(parmset,'Gabor_phase');
            smotype=getparm(parmset,'Smoother');
            fmin=getparm(parmset,'Fmin');
            fmax=getparm(parmset,'Fmax');
            dfmin=getparm(parmset,'dFmin');
            dfmax=getparm(parmset,'dFmax');
            t1=getparm(parmset,'T1');
            fmaxmax=getparm(parmset,'Fmaxmax');
            fmaxmin=getparm(parmset,'Fmaxmin');
            tmax=getparm(parmset,'Tmax');
            %dt=t(2)-t(1);
            if(strcmp(gphase,'zero'))
                phase=0;
            else
                phase=1;
            end
            if(strcmp(smotype,'boxcar'))
                ihyp=0;
            else
                ihyp=1;
            end
            hstry=[{task} parmset2history(parmset)];
            nx=length(x);
            ny=length(y);
            %cannot use waibar with parfor
%             HWAIT=waitbar(0,['Gabor decon beginning inline 1 of ' int2str(ny)],'CreateCancelBtn','enhance(''canceltaskafter'')');
            t0=clock;
            CONTINUE=true;%still need this to ensure execution continues
            ind=near(t,t(1),tmax);
            ind2=ind(end)+1:length(t);%samples at the end to discard
            t=t(ind);
            disp('Gabordecon... Parfor loop beginning')
%             if(isdeployed)
%                 setmcruserdata('ParallelProfile', 'local.settings');
%             end
            if(isempty(gcp))%create parallel pool if one does not already exist
                pp=parpool('local');
            else
                pp=gcp;
            end
            %estimate compute time
            ntraces=length(proj.tracehdr{idat}.SrcX);
            timepertrace=.1;%guess at run time for single thread
            timeguess=ntraces*timepertrace/(60*pp.NumWorkers);
            pos=get(henhance,'position');
            posc=[pos(1)+.5*pos(3),pos(2)+.5*pos(4)];
            response=questdlg_pos(['Estimated run time with ' int2str(ntraces) ' live traces and ',...
                 int2str(pp.NumWorkers) ' workers is ' num2str(timeguess) ' minutes. Do you wish to ',...
                 'proceed?'],'Gabor decon last chance','Yes','No','cancel','Yes',posc);
            if(strcmp(response,'No')||strcmp(response,'cancelled'))
                delete(pp);
                set(hmsg,'string','Gabor decon cancelled');
                return;
            end
            set(hmsg,'string','Gabor decon: entering parfor loop');
            drawnow
%             ppm=ParforProgMon('Gabor decon progress',ny);
            figure(henhance)
            waitsignalon
            parfor k=1:ny
                ttnow=clock;
                seis(ind,:,k)=gabordecon_stackPar(seis(ind,:,k),t,twin,tinc,tsmo,fsmo,ihyp,stab,phase,...
                    t1,[fmin dfmin],[fmax dfmax],[fmaxmax fmaxmin],0,80);
                
%                 %filter
%                 if(t1==-1)
%                     seis(ind,:,k)=filter_stack(tmp,t,fmin,fmax,'method','filtf','dflow',dfmin,'dfhigh',dfmax);
%                 else
%                     seis(ind,:,k)=filt_hyp(tmp,t,t1,[fmin dfmin],[fmax dfmax],[fmaxmax fmaxmin],0,80,1,2*twin,nx);
%                 end
                timeforline=etime(clock,ttnow);
                timepertrace=timeforline/nx;
                disp(['finished inline ' int2str(k) ' in ' num2str(timeforline/60)  ' min']);
                disp(['time-per-trace= ' int2str(1000*timepertrace) ' ms'])
%                 ppm.increment();
                %even with drawnow, the following line won't update in a parfor loop
                %set(hmsg,'string',['finished inline ' int2str(y(k)) ' in ' num2str(timeforline/60)  ' min']);drawnow;
            end
            if(~isempty(ind2))
                seis(ind2,:,:)=[];
            end
            t1=clock;
            timeused=etime(t1,t0);
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused/60) ' minutes'])
            telluserinit(['Gabor decon completed in ' num2str(timeused/60),...
                ' minutes. Estimated time was ' num2str(timeguess) ' minutes'],...
                'Gabor decon results');
            hresults=gcf;
%             delete(HWAIT)
            set(hcompute,'userdata',[]);
            figure(henhance)
            waitsignaloff
        case 'wavenumber'
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Wavenumber filtering in progress')
            sigmax=getparm(parmset,'sigmax');
            sigmay=getparm(parmset,'sigmay');
            hstry=[{task} parmset2history(parmset)];
            nt=length(t);
            HWAIT=waitbar(0,'Please wait for wavenumber filtering to complete','CreateCancelBtn','enhance(''canceltaskafter'')');
            t0=clock;
            ievery=10;
            CONTINUE=true;
            for k=1:nt

                slice=squeeze(seis(k,:,:));
                slice2=wavenumber_gaussmask2(slice,sigmax,sigmay);
                slice2=slice2*norm(slice)/norm(slice2);
                seis(k,:,:)=shiftdim(slice2,-1);
                if(~CONTINUE)
                        break;
                end
                if(rem(k,ievery)==0)
                    tnow=clock;
                    timeused=etime(tnow,t0);
                    timeperslice=timeused/k;
                    timeleft=timeperslice*(nt-k)/60;
                    timeleft=round(timeleft*100)/100;
                    waitbar(k/nt,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
                end

            end
            t1=clock;
            timeused=etime(t1,t0);
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused/60) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'phasemap'
            
            
        case 'fdom'
            ny=length(y);
            twin=getparm(parmset,'twin');
            ninc=getparm(parmset,'ninc');
            fmax=getparm(parmset,'Fmax');
            tfmax=getparm(parmset,'tfmax');
            hstry=[{task} parmset2history(parmset)];
            tinc=ninc*(t(2)-t(1));
            interpflag=1;
            p=2;
            fc=1;
            
            
            if(isnan(tfmax))
                fmt0=fmax;
            else
                fmt0=[fmax tfmax];
            end
            
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Dominant frequency volume computation in progress')
            
            HWAIT=waitbar(0,'Please wait for fdom computation to complete','CreateCancelBtn','enhance(''canceltaskafter'')');
            t0=clock;
            CONTINUE=true;
            ievery=1;
            for k=1:ny
                %process each iline as a panel in tvfdom3
                spanel=squeeze(seis(:,:,k));
                test=sum(abs(spanel));
                ilive=find(test~=0);
                if(~isempty(ilive))
                    fd=tvfdom3(spanel(:,ilive),t,twin,tinc,fmt0,interpflag,p,fc);
                    ind=find(fd<0);
                    if(~isempty(ind))
                        fd(ind)=0;
                    end
                    seis(:,ilive,k)=single(fd);
                end
                if(rem(k,ievery)==0)
                    time_used=etime(clock,t0);
                    time_per_line=time_used/k;
                    timeleft=(ny-k-1)*time_per_line/60;
                    timeleft=round(100*timeleft)/100;
                    waitbar(k/ny,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
                end
                if(~CONTINUE)
                        break;
                end
            end
            t1=clock;
            timeused=etime(t1,t0)/60;
            timeused=round(timeused*100)/100;
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'specdecomp'
            ny=length(y);
            nx=length(x);
            twin=getparm(parmset,'Twin');
            ninc=getparm(parmset,'Ninc');
            tmin=getparm(parmset,'Tmin');
            tmax=getparm(parmset,'Tmax');
            %fout=getparm(parmset,'Fout');
            fmin=getparm(parmset,'Fmin');
            fmax=getparm(parmset,'Fmax');
            delf=getparm(parmset,'delF');
            fout=fmin:delf:fmax;
            hstry=[{task} parmset2history(parmset)];
            tinc=ninc*(t(2)-t(1));
            ind=near(t,tmin,tmax);
            nt=length(ind);
            %check that the requested frequencies will fit in memory
            [availmem,reqmem,nfreqs,resmem]=specdmemory(nx,ny,nt); %#ok<ASGLU>
            if(nfreqs<length(fout))
                msgbox('Number of frequecies exceeds the maximum allowed by your computer''s memory');
                return;
            end
            
            %loop over y=constant lines
            fmin=min(fout);fmax=max(fout);df=1;
            phaseflag=3;
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','Spectral Decomp computation in progress')
            HWAIT=waitbar(0,'Please wait for SpecDecomp computation to complete','CreateCancelBtn','enhance(''canceltaskafter'')');
            t0=clock;
            CONTINUE=true;
            ievery=1;
            for k=1:ny
                s2d=squeeze(seis(:,:,k));
                [amp2d,phs,tsd,f2d]=specdecomp(s2d,t,twin,tinc,fmin,fmax,df,tmin,tmax,phaseflag,1,-1); %#ok<ASGLU>
                if(k==1)
                    %allocate output volumes
                    amp=cell(size(fout));
                    for j=1:length(fout)
                        amp{j}=zeros(length(tsd),nx,ny);
                    end
                end
                for j=1:length(fout)
                    jf=near(f2d,fout(j));
                    amp{j}(:,:,k)=amp2d(:,:,jf(1));
                end
                if(rem(k,ievery)==0)
                    time_used=etime(clock,t0);
                    time_per_line=time_used/k;
                    timeleft=(ny-k-1)*time_per_line/60;
                    timeleft=round(100*timeleft)/100;
                    waitbar(k/ny,HWAIT,['Estimated time remaining ' num2str(timeleft) ' minutes']);
                end
                if(~CONTINUE)
                        break;
                end
            end
            t1=clock;
            timeused=etime(t1,t0)/60;
            timeused=round(timeused*100)/100;
            set(hmsg,'string',['Completed task ' task ' for ' dname ' in ' num2str(timeused) ' minutes'])
            delete(HWAIT)
            set(hcompute,'userdata',[]);
        case 'svdsep'
            set(hcompute,'userdata',idat); %this allows a "cancel" to determine the input dataset
            set(hmsg,'string','SVD Separation in progress')
            IdimX=getparm(parmset,'IdimX');
            IdimY=getparm(parmset,'IdimY');
            IdimT=getparm(parmset,'IdimT');
            SingcutX=getparm(parmset,'SingcutX');
            SingcutY=getparm(parmset,'SingcutY');
            SingcutT=getparm(parmset,'SingcutT');
            OpgX=getparm(parmset,'OpgX');
            OpgY=getparm(parmset,'OpgY');
            OpgT=getparm(parmset,'OpgT');
            OpdX=getparm(parmset,'OpdX');
            OpdY=getparm(parmset,'OpdY');
            OpdT=getparm(parmset,'OpdT');
            TfmaxG=getparm(parmset,'TfmaxG');
            FminG=getparm(parmset,'FminG');
            FmaxG=getparm(parmset,'FmaxG');
            DfminG=getparm(parmset,'DfminG');
            DfmaxG=getparm(parmset,'DfmaxG');
            FmaxmaxG=getparm(parmset,'FmaxmaxG');
            FmaxminG=getparm(parmset,'FmaxminG');
            TfmaxD=getparm(parmset,'TfmaxD');
            FminD=getparm(parmset,'FminD');
            FmaxD=getparm(parmset,'FmaxD');
            DfminD=getparm(parmset,'DfminD');
            DfmaxD=getparm(parmset,'DfmaxD');
            FmaxmaxD=getparm(parmset,'FmaxmaxD');
            FmaxminD=getparm(parmset,'FmaxminD');
            TsigmaG=getparm(parmset,'TsigmaG');
            SigmaG=getparm(parmset,'SigmaG');
            SigmaGmax=getparm(parmset,'SigmaGmax');
            SigmaGmin=getparm(parmset,'SigmaGmin');
            TsigmaD=getparm(parmset,'TsigmaD');
            SigmaD=getparm(parmset,'SigmaD');
            SigmaDmax=getparm(parmset,'SigmaDmax');
            SigmaDmin=getparm(parmset,'SigmaDmin');

            hstry=[{[task ' on ' proj.datanames{idat}]} parmset2history(parmset)];
            nx=length(x);ny=length(y);nt=length(t);
            ipass=0;
            npasses=0;
            if(IdimX>0); npasses=npasses+1; end
            if(IdimY>0); npasses=npasses+1; end
            if(IdimT>0); npasses=npasses+1; end
            for j=1:3 %possible 3 passes
               if(IdimX==j)
                  %loop over crosslines
                  ipass=ipass+1;
                  hbar=WaitBar(0,nx,'Computing SVD separation',['SVD separation Pass ' int2str(ipass) ' of ' int2str(npasses)]);
                  for k=1:nx
                     sx=squeeze(seis(:,k,:));
                     [U,S,V]=svd(sx);
                     singvals=diag(S);%the singular values
                     m=size(U,1);
                     n=size(V,1);
                     nsing=length(singvals);
                     jj=1:nsing;
                     g=exp(-(jj-1).^2/SingcutX^2)';%window function
                     singvalsg=singvals.*g;
                     tmp=diag(singvalsg);
                     if(m>n)
                         Sg=[tmp;zeros(m-n,n)];
                     elseif(n>m)
                         Sg=[tmp zeros(m,n-m)];
                     else
                         Sg=tmp;
                     end
                     sxg=U*Sg*V';%gross
                     sxd=sx-sxg;%detail
                     if(OpgX==3)
                         %apply filter to gross
                         sxg=filt_hyp(sxg,t,TfmaxG,[FminG DfminG],[FmaxG DfmaxG],[FmaxmaxG FmaxminG]); 
                     end
                     if(OpdX==3)
                         %apply filter to detail
                         sxd=filt_hyp(sxd,t,TfmaxD,[FminD DfminD],[FmaxD DfmaxD],[FmaxmaxD FmaxminD]); 
                     end
                     %recombine
                     if(OpgX~=2)
                         if(OpdX~=2)
                             sx2=sxg+sxd;
                         else
                             sx2=sxg;
                         end
                     else
                         sx2=sxd;
                     end
                     %put the result back in the volume
                     for kk=1:ny
                         seis(:,k,kk)=sx2(:,kk);
                     end
                     if(~WaitBarContinue)
                         delete(hbar);
                         break
                     else
                         WaitBar(k,hbar,['Completed crossline ' int2str(k) ' of ' int2str(nx)])
                     end
                  end
                  if(isgraphics(hbar)); delete(hbar); end
               elseif(IdimY==j)
                  %loop over inlines
                  ipass=ipass+1;
                  hbar=WaitBar(0,ny,'Computing SVD separation',['SVD separation Pass ' int2str(ipass) ' of ' int2str(npasses)]);
                  for k=1:ny
                     sy=squeeze(seis(:,:,k));
                     [U,S,V]=svd(sy);
                     singvals=diag(S);%the singular values
                     m=size(U,1);
                     n=size(V,1);
                     nsing=length(singvals);
                     jj=1:nsing;
                     g=exp(-(jj-1).^2/SingcutY^2)';%window function
                     singvalsg=singvals.*g;
                     tmp=diag(singvalsg);
                     if(m>n)
                         Sg=[tmp;zeros(m-n,n)];
                     elseif(n>m)
                         Sg=[tmp zeros(m,n-m)];
                     else
                         Sg=tmp;
                     end
                     syg=U*Sg*V';%gross
                     syd=sy-syg;%detail
                     if(OpgY==3)
                         %apply filter to gross
                         syg=filt_hyp(syg,t,TfmaxG,[FminG DfminG],[FmaxG DfmaxG],[FmaxmaxG FmaxminG]); 
                     end
                     if(OpdY==3)
                         %apply filter to detail
                         syd=filt_hyp(syd,t,TfmaxD,[FminD DfminD],[FmaxD DfmaxD],[FmaxmaxD FmaxminD]); 
                     end
                     %recombine
                     if(OpgY~=2)
                         if(OpdY~=2)
                             sy2=syg+syd;
                         else
                             sy2=syg;
                         end
                     else
                         sy2=syd;
                     end
                     %put the result back in the volume
                     seis(:,:,k)=sy2;
                     if(~WaitBarContinue)
                         delete(hbar);
                         break
                     else
                         WaitBar(k,hbar,['Completed inline ' int2str(k) ' of ' int2str(ny)])
                     end
             
                  end
                  if(isgraphics(hbar)); delete(hbar); end
               elseif(IdimT==j)
                  %loop over time slices
                  ipass=ipass+1;
                  hbar=WaitBar(0,ny,'Computing SVD separation',['SVD separation Pass ' int2str(ipass) ' of ' int2str(npasses)]);
                  for k=1:nt
                     st=squeeze(seis(k,:,:));
                     [U,S,V]=svd(st);
                     singvals=diag(S);%the singular values
                     m=size(U,1);
                     n=size(V,1);
                     nsing=length(singvals);
                     jj=1:nsing;
                     g=exp(-(jj-1).^2/SingcutT^2)';%window function
                     singvalsg=singvals.*g;
                     tmp=diag(singvalsg);
                     if(m>n)
                         Sg=[tmp;zeros(m-n,n)];
                     elseif(n>m)
                         Sg=[tmp zeros(m,n-m)];
                     else
                         Sg=tmp;
                     end
                     stg=U*Sg*V';%gross
                     std=st-stg;%detail
                     if(OpgT==3)
                         %apply filter to gross
                         sigma=SigmaG*(TsigmaG-t(1))/((t(k)-t(1))+1000*eps);
                         if(sigma>SigmaGmax); sigma=SigmaGmax; end
                         if(sigma<SigmaGmin); sigma=SigmaGmin; end
                         stg=wavenumber_gaussmask2(stg,sigma,sigma);
                     end
                     if(OpdT==3)
                         %apply filter to detail
                         sigma=SigmaD*(TsigmaD-t(1))/((t(k)-t(1))+1000*eps);
                         if(sigma>SigmaDmax); sigma=SigmaDmax; end
                         if(sigma<SigmaDmin); sigma=SigmaDmin; end
                         std=wavenumber_gaussmask2(std,sigma,sigma);
                     end
                     %recombine
                     if(OpgT~=2)
                         if(OpdT~=2)
                             st2=stg+std;
                         else
                             st2=stg;
                         end
                     else
                         st2=std;
                     end
                     %put the result back in the volume
                     seis(k,:,:)=shiftdim(st2,-1);
                     if(~WaitBarContinue)
                         delete(hbar);
                         break
                     else
                         WaitBar(k,hbar,['Completed timeslice ' int2str(k) ' of ' int2str(nt)])
                     end
             
                  end
                  if(isgraphics(hbar)); delete(hbar); end
               end
               if(~WaitBarContinue)
                   break
               end
            end
 
            set(hcompute,'userdata',[]);
    end
    if(~WaitBarContinue)
        figure(henhance)
        waitsignaloff
        set(hmsg,'string','Computation interrupted by user, input dataset unloaded');
        return
    end
    %deal with the output
    switch fate
        case 'Save SEGY'
            if(strcmp(task,'specdecomp'))
                goodname=false;
                while(~goodname)
                    [fname,path]=uiputfile('*.sgy',...
                        'Select the output file (a number will be afixed for each frequency)');
                    if(isequal(fname,0) || isequal(path,0))
                        msgbox('Output cancelled');
                        return;
                    else
                        idot=strfind(fname,'.');
                        if(length(idot)~=1)
                            goodname=false;
                        else
                            goodname=true;
                        end
                    end
                end
                figure(henhance)
                waitsignalon
                for k=1:length(amp)
                    fname2=[fname(1:idot-1) num2str(fout(k)) fname(idot:end)];
                    if(exist([path fname],'file'))
                        delete([path fname2]);
                    end
                    
                    set(hmsg,'string','Forming output array');
                    seis=unmake3Dvol(amp{k},proj.xcoord{idat},proj.ycoord{idat},proj.xcdp{idat},proj.ycdp{idat},...
                        'kxlineall',proj.kxline{idat});
                    dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                    set(hmsg,'string','Beginning SEGY output');
                    %update trace headers to reflect changed trace length
                    trch=proj.tracehdr{idat};
                    ntraces=length(trch.TrcNumLine);
                    trch.SampThisTrc=length(tsd)*ones(1,ntraces,'uint16');
                    trch.SampRateThisTrc=1000000*(tsd(2)-tsd(1))*ones(1,ntraces,'uint16');
                    %update binary header
                    binh=proj.binhdr{idat};
                    binh.SampPerTrc=length(tsd)*ones(1,1,'uint16');
                    binh.SampleRate=1000000*(tsd(2)-tsd(1))*ones(1,1,'uint16');
                    writesegy([path fname2],seis,getsegyrev(idat),dt,proj.segfmt{idat},proj.texthdrfmt{idat},...
                        proj.byteorder{idat},proj.texthdr{idat},binh,proj.exthdr{idat},...
                        trch,proj.bindef{idat},proj.trcdef{idat},henhance);
                    set(hmsg,'string',['Dataset ' [path fname2] ' written']);
                end
                figure(henhance)
                waitsignaloff
            else
                [fname,path]=uiputfile('*.sgy','Select the output file');
                if(isequal(fname,0) || isequal(path,0))
                    msgbox('Output cancelled');
                    return;
                end
                if(exist([path fname],'file'))
                    delete([path fname]);
                end
                figure(henhance)
                waitsignalon
                set(hmsg,'string','Forming output array');
                seis=unmake3Dvol(seis,proj.xcoord{idat},proj.ycoord{idat},proj.xcdp{idat},proj.ycdp{idat},...
                    'kxlineall',proj.kxline{idat});
                dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                set(hmsg,'string','Beginning SEGY output');
                %update trace headers to reflect possibly changed trace length
                trch=proj.tracehdr{idat};%get trace headers
                [nt,ntraces]=size(seis);
                trch.SampThisTrc=nt*ones(1,ntraces,'uint16');
                trch.SampRateThisTrc=1000000*dt*ones(1,ntraces,'uint16');
                %update binary header
                binh=proj.binhdr{idat};
                binh.SampPerTrc=nt*ones(1,1,'uint16');
                binh.SampleRate=1000000*dt*ones(1,1,'uint16');
                writesegy([path fname],seis,getsegyrev(idat),dt,proj.segfmt{idat},proj.texthdrfmt{idat},...
                    proj.byteorder{idat},proj.texthdr{idat},proj.binhdr{idat},proj.exthdr{idat},...
                    proj.tracehdr{idat},proj.bindef{idat},proj.trcdef{idat},henhance);
                figure(henhance)
                waitsignaloff
                set(hmsg,'string',['Dataset ' [path fname] ' written']);
                if(strcmp(task,'gabordecon'))
                    figure(hresults)
                end
            end
        case 'Save SEGY and display'
            if(strcmp(task,'specdecomp'))
                %output
                goodname=false;
                while(~goodname)
                    [fname,path]=uiputfile('*.sgy',...
                        'Select the output file (a number will be afixed for each frequency)');
                    if(isequal(fname,0) || isequal(path,0))
                        msgbox('Output cancelled');
                        return;
                    else
                        idot=strfind(fname,'.');
                        if(length(idot)~=1)
                            goodname=false;
                        else
                            goodname=true;
                        end
                    end
                end
                %display
                figure(henhance)
                waitsignalon
                for k=1:length(amp)
                    fname2=[fname(1:idot-1) num2str(fout(k)) fname(idot:end)];
                    if(exist([path fname],'file'))
                        delete([path fname2]);
                    end
                    %display
                    plotimage3D(amp{k},t,{x,xcdp},{y,ycdp},[dname ' ' task],dx,dy)
                    %
                    set(hmsg,'string','Forming output array');
                    seis=unmake3Dvol(amp{k},proj.xcoord{idat},proj.ycoord{idat},proj.xcdp{idat},proj.ycdp{idat},...
                        'kxlineall',proj.kxline{idat});
                    dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                    set(hmsg,'string','Beginning SEGY output');
                    %update trace headers to reflect changed trace length
                    trch=proj.tracehdr{idat};
                    ntraces=length(trch.TrcNumLine);
                    trch.SampThisTrc=length(tsd)*ones(1,ntraces,'uint16');
                    trch.SampRateThisTrc=1000000*(tsd(2)-tsd(1))*ones(1,ntraces,'uint16');
                    %update binary header
                    binh=proj.binhdr{idat};
                    binh.SampPerTrc=length(tsd)*ones(1,1,'uint16');
                    binh.SampleRate=1000000*(tsd(2)-tsd(1))*ones(1,1,'uint16');
                    writesegy([path fname2],seis,getsegyrev(idat),dt,proj.segfmt{idat},proj.texthdrfmt{idat},...
                        proj.byteorder{idat},proj.texthdr{idat},binh,proj.exthdr{idat},...
                        trch,proj.bindef{idat},proj.trcdef{idat},henhance);
                    set(hmsg,'string',['Dataset ' [path fname2] ' written']);
                end
                figure(henhance)
                waitsignaloff
                
            else
                %display
                plotimage3D(seis,t,{x,xcdp},{y,ycdp},[dname ' ' task],dx,dy)
                %output
                [fname,path]=uiputfile('*.sgy','Select the output file');
                if(isequal(fname,0) || isequal(path,0))
                    msgbox('Output cancelled');
                    return;
                end
                if(exist([path fname],'file'))
                    delete([path fname]);
                end
                figure(henhance)
                waitsignalon
                set(hmsg,'string','Forming output array');
                seis=unmake3Dvol(seis,proj.xcoord{idat},proj.ycoord{idat},proj.xcdp{idat},proj.ycdp{idat},...
                    'kxlineall',proj.kxline{idat});
                dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                set(hmsg,'string','Beginning SEGY output');
                %update trace headers to reflect possibly changed trace length
                trch=proj.tracehdr{idat};%get trace headers
                [nt,ntraces]=size(seis);
                trch.SampThisTrc=nt*ones(1,ntraces,'uint16');
                trch.SampRateThisTrc=1000000*dt*ones(1,ntraces,'uint16');
                %update binary header
                binh=proj.binhdr{idat};
                binh.SampPerTrc=nt*ones(1,1,'uint16');
                binh.SampleRate=1000000*dt*ones(1,1,'uint16');
                writesegy([path fname],seis,getsegyrev(idat),dt,proj.segfmt{idat},proj.texthdrfmt{idat},...
                    proj.byteorder{idat},proj.texthdr{idat},proj.binhdr{idat},proj.exthdr{idat},...
                    proj.tracehdr{idat},proj.bindef{idat},proj.trcdef{idat},henhance);
                figure(henhance)
                waitsignaloff
                set(hmsg,'string',['Dataset ' [path fname] ' written']);
                if(strcmp(task,'gabordecon'))
                    figure(hresults)
                end
            end
        case 'Replace input in project'
            proj.datasets{idat}=seis;
            %see if data is displayed
            if(proj.isdisplayed{idat}==1)
                delete(proj.pifigures{idat})
                plotimage3D(seis,t,{x,xcdp},{y,ycdp},dname,'seisclrs',proj.dx(idat),proj.dy(idat));
                set(gcf,'tag','fromenhance','userdata',{idat henhance});
                set(gcf,'closeRequestFcn','enhance(''closepifig'');')
                hview=findobj(henhance,'tag','view');
                uimenu(hview,'label',dname,'callback','enhance(''popupfig'');','userdata',gcf);
                proj.pifigures{idat}=gcf;
                proj.isdisplayed(idat)=1;
            end
            
            %update trace headers to reflect possibly changed trace length
            dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
            trch=proj.tracehdr{idat};%get trace headers
            [nt,ntraces]=size(seis);
            trch.SampThisTrc=nt*ones(1,ntraces,'uint16');
            trch.SampRateThisTrc=1000000*dt*ones(1,ntraces,'uint16');
            %update binary header
            binh=proj.binhdr{idat};
            binh.SampPerTrc=nt*ones(1,1,'uint16');
            binh.SampleRate=1000000*dt*ones(1,1,'uint16');
            proj.saveneeded(idat)=1;
            proj.tracehdr{idat}=trch;
            proj.binhdr{idat}=binh;
            proj.datanames{idat}=[dname ': ' task];
            if(~iscell(proj.history{idat}))
                oldhist={proj.history{idat}};
            else
                oldhist=proj.history{idat};
            end
            newhist=cell(1,length(oldhist)+length(hstry)+1);
            newhist(1:length(oldhist))=oldhist;
            newhist(length(oldhist)+2:length(oldhist)+1+length(hstry))=hstry;
            proj.history{idat}=newhist;
            set(hfile,'userdata',proj)
            set(hmsg,'string',[proj.datanames{idat} ...
                ' replaced. Data will be written to disk when you save the project.'])
            if(strcmp(task,'gabordecon'))
                figure(hresults)
            end
        case 'Save in project as new'
            if(strcmp(task,'specdecomp'))
                figure(henhance)
                waitsignalon
                for k=1:length(amp)
                    %update project structure
                    ndatasets=length(proj.datanames)+1;
                    proj.datasets{ndatasets}=amp{k};
                    fnames=fieldnames(proj);
                    %this loop checks each field name in the project structure and updates as needed.
                    %The only fieldnames that need updating are those which have one entry per dataset.
                    %For those names, a new entry is created by copying the entry from the input dataset
                    for kk=1:length(fnames)
                        tmp=proj.(fnames{kk});
                        if(~isempty(tmp))
                            if(length(tmp)==ndatasets-1)
                                if(~strcmp(tmp,'parmsets'))
                                    proj.(fnames{kk})(ndatasets)=tmp(idat);
                                end
                            end
                        end
                    end

                    proj.datanames{ndatasets}=[proj.datanames{ndatasets} '_specdecomp' num2str(fout(k))];
                    proj.pifigures{ndatasets}=[];
                    proj.isdeleted(ndatasets)=0;
                    proj.deletedondisk(ndatasets)=0;
                    proj.saveneeded(ndatasets)=1;
                    %update trace headers to reflect changed trace length
                    trch=proj.tracehdr{idat};
                    ntraces=length(trch.TrcNumLine);
                    trch.SampThisTrc=length(tsd)*ones(1,ntraces,'uint16');
                    trch.SampRateThisTrc=1000000*(tsd(2)-tsd(1))*ones(1,ntraces,'uint16');
                    proj.tracehdr{ndatasets}=trch;
                    %update binary header
                    binh=proj.binhdr{idat};
                    binh.SampPerTrc=length(tsd)*ones(1,1,'uint16');
                    binh.SampleRate=1000000*(tsd(2)-tsd(1))*ones(1,1,'uint16');
                    proj.binhdr{ndatasets}=binh;
                    hpan=newdatapanel(proj.datanames{ndatasets},1,1);
                    proj.gui{ndatasets}=hpan;
                    if(~iscell(proj.history{ndatasets}))
                        oldhist={proj.history{ndatasets}};
                    else
                        oldhist=proj.history{ndatasets};
                    end
                    newhist=cell(1,length(oldhist)+length(hstry)+1);
                    newhist(1:length(oldhist))=oldhist;
                    newhist(length(oldhist)+2:length(oldhist)+1+length(hstry))=hstry;
                    proj.history{ndatasets}=newhist;
                    
                    %call plotimage3D
                    plotimage3D(amp{k},tsd,{x,xcdp},{y,ycdp},proj.datanames{ndatasets},'seisclrs',dx,dy);
                    set(gcf,'tag','fromenhance','userdata',{ndatasets henhance});
                    set(gcf,'closeRequestFcn','enhance(''closepifig'');')
                    hview=findobj(henhance,'tag','view');
                    uimenu(hview,'label',dname,'callback','enhance(''popupfig'');','userdata',gcf);
                    proj.pifigures{ndatasets}=gcf;
                end
                
                %save the project
                set(hfile,'userdata',proj);
                figure(henhance)
                waitsignaloff
%                 set(hmsg,'string',[proj.datanames{ndatasets}...
%                     ' saved and displayed. Data will be written to disk when you save the project.'])
            else
                figure(henhance)
                waitsignalon
                %update project structure
                ndatasets=length(proj.datanames)+1;
                proj.datasets{ndatasets}=seis;
                fnames=fieldnames(proj);
                %this loop checks each field name in the project structure and updates as needed.
                %The only fieldnames that need updating are those which have one entry per dataset.
                %For those names, a new entry is created by copying the entry from the input dataset
                for k=1:length(fnames)
                    tmp=proj.(fnames{k});
                    if(~isempty(tmp))
                        if(length(tmp)==ndatasets-1)
                            if(~strcmp(tmp,'parmsets'))
                                proj.(fnames{k})(ndatasets)=tmp(idat);
                            end
                        end
                    end
                end
                switch task
                    case 'filter'
                        if(phase==0)
                            proj.datanames{ndatasets}=[proj.datanames{ndatasets} ' filter ' ...
                                num2str(fmin) '-' num2str(fmax) ];
                        else
                            proj.datanames{ndatasets}=[proj.datanames{ndatasets} ' filter ' ...
                                num2str(fmin) '-' num2str(fmax) ];
                        end
                    case 'spikingdecon'
                        proj.datanames{ndatasets}=[proj.datanames{ndatasets} ' spiking decon '];
                    case 'wavenumber'
                        proj.datanames{ndatasets}=[proj.datanames{ndatasets} ' spiking decon oplen=' ...
                            num2str(oplen) ' gate:' num2str(topgate) '-' num2str(botgate)];
                    case 'fdom'
                        proj.datanames{ndatasets}=[proj.datanames{ndatasets} ' Fdom '];
                    case 'phasemap'
                        proj.datanames{ndatasets}=[proj.datanames{ndatasets} ' phasemap ' ];
                    case 'gabordecon'
                        proj.datanames{ndatasets}=[proj.datanames{ndatasets} ' Gabor decon '];
                    case 'svdsep'
                        proj.datanames{ndatasets}=[proj.datanames{ndatasets} ' SVD_sep '];
                end
                %update trace headers to reflect possibly changed trace length
                dt=abs(proj.tcoord{idat}(2)-proj.tcoord{idat}(1));
                trch=proj.tracehdr{idat};%get trace headers
                [nt,ntraces]=size(seis);
                trch.SampThisTrc=nt*ones(1,ntraces,'uint16');
                trch.SampRateThisTrc=1000000*dt*ones(1,ntraces,'uint16');
                %update binary header
                binh=proj.binhdr{idat};
                binh.SampPerTrc=nt*ones(1,1,'uint16');
                binh.SampleRate=1000000*dt*ones(1,1,'uint16');
                proj.saveneeded(idat)=1;
                proj.tracehdr{idat}=trch;
                proj.binhdr{idat}=binh;

                proj.pifigures{ndatasets}=[];
                proj.isdeleted(ndatasets)=0;
                proj.deletedondisk(ndatasets)=0;
                proj.saveneeded(ndatasets)=1;
                
                hpan=newdatapanel(proj.datanames{ndatasets},1,1);
                proj.gui{ndatasets}=hpan;
                if(~iscell(proj.history{ndatasets}))
                    oldhist={proj.history{ndatasets}};
                else
                    oldhist=proj.history{ndatasets};
                end
                newhist=cell(1,length(oldhist)+length(hstry)+1);
                newhist(1:length(oldhist))=oldhist;
                newhist(length(oldhist)+2:length(oldhist)+1+length(hstry))=hstry;
                proj.history{ndatasets}=newhist;
                
                %call plotimage3D
                plotimage3D(seis,t,{x,xcdp},{y,ycdp},proj.datanames{ndatasets},'seisclrs',dx,dy);
                set(gcf,'tag','fromenhance','userdata',{ndatasets henhance});
                set(gcf,'closeRequestFcn','enhance(''closepifig'');')
                hview=findobj(henhance,'tag','view');
                uimenu(hview,'label',proj.datanames{ndatasets},'callback','enhance(''popupfig'');','userdata',gcf);
                proj.pifigures{ndatasets}=gcf;
                
                %save the project
                set(hfile,'userdata',proj);
                figure(henhance)
                enhance('saveproject');
                figure(henhance)
                waitsignaloff
                set(hmsg,'string',[proj.datanames{ndatasets} ' saved and displayed.'])
                if(strcmp(task,'gabordecon'))
                    figure(hresults)
                end
            end
    end
    
    
    
elseif(strcmp(action,'canceltask'))
    %this is called if the task is cancelled before it actually begins to compute
    delete(gcf);
    henhance=findenhancefig;
    figure(henhance);
    hmsg=findobj(henhance,'tag','message');
    set(hmsg,'string','Computation task cancelled');
    return
    
    
elseif(strcmp(action,'canceltaskafter'))
    %this is call if the task has already started to compute. This is a special problem because the
    %tasks are designed to replace the input data array either trace-by-trace or slice-by-slice. So
    %cancelling the task once the computation has begun means the data volume must be discarded.
    drawnow
    henhance=findenhancefig;
    hmsg=findobj(henhance,'tag','message');
    set(hmsg,'string','Computation task cancelled');
    CONTINUE=false;
    delete(HWAIT);
    hcompute=findobj(henhance,'label','Compute');
    idat=get(hcompute,'userdata');
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    proj.isloaded(idat)=0;%this will cause a reload if the task is restarted
    memorybuttonoff(idat);
    proj.datasets{idat}=[];
    set(hfile,'userdata',proj);
    return
    
elseif(strcmp(action,'choosebyteloc'))
    %this pops up a dialog allowing the specification of byte locations for inline and crossline.
    %it is called by the Multiple segyload dialog.
    hdial=gcf;%the calling dialog window
    udat=get(hdial,'userdata');
    hdialarray=udat{1};%array of any existing byte location dialogs
    hbut=gcbo;%the button that was clicked
    mode=get(hbut,'string');%this will be one of 'SEGY standard','Canadian locs','Kingdom locs','Other'
    hpan=get(hbut,'parent');%The panel of the button
    locs=zeros(1,2);
    if(strcmp(get(hbut,'tag'),'inline'))
        locs(1)=get(hbut,'userdata');
        hbut2=findobj(hpan,'tag','xline');
        locs(2)=get(hbut2,'userdata');
    else
        locs(2)=get(hbut,'userdata');
        hbut2=findobj(hpan,'tag','inline');
        locs(1)=get(hbut2,'userdata');
    end
    pos=get(hdial,'position');
    hdial2=figure;
    hdialarray(end+1)=hdial2;
    udat{1}=hdialarray;
    set(hdial,'userdata',udat);
    dialht=200;%in pixels
    dialwid=400;%in pixels
    set(hdial2,'position',[pos(1)+.5*(pos(3)-dialwid) pos(2)+.5*(pos(4)-dialht) dialwid dialht],...
        'name','ENHANCE: Define header locations','menubar','none','toolbar','none','numbertitle','off');
    xnot=.05;ynot=.8;
    xnow=xnot;ynow=ynot;ht=1/7;wid=.4;
    xsep=.05;ysep=.02;
    %get filename
    hfn=findobj(hpan,'tag','filename');
    fname=get(hfn,'string');
    uicontrol(hdial2,'style','text','string',['define byte locs for ' fname],'units','normalized',...
        'position',[xnow,ynow,2*wid,ht],'tag','message','userdata',hpan)
    ynow=ynow-1.5*ht-ysep;
    choices={'SEGY standard','Canadian locs','Kingdom locs','Other'};
    for k=1:length(choices)
        if(strcmp(choices{k},mode))
            val=k;
        end
    end
    uicontrol(hdial2,'style','popupmenu','string',choices,'tag','options','units','normalized',...
        'position',[xnow+.5*wid,ynow,wid,ht],'callback','enhance(''choosebyteloc2'');','value',val);
    xnow=xnot;
    ynow=ynow-ht-ysep;
    fsbig=10;
    uicontrol(hdial2,'style','text','string','Inline byte loc:','units','normalized','position',...
        [xnow ynow-.25*ht wid ht],'horizontalalignment','right','fontsize',fsbig);
    xnow=xnow+wid+xsep;
    if(strcmp(mode,'Other'))
        val='on';
        hint1='<<Changable';
    else
        val='inactive';
        hint1='';
    end
    uicontrol(hdial2,'style','edit','string',int2str(locs(1)),'tag','inline','enable',val,'units',...
        'normalized','position',[xnow ynow .5*wid ht],'fontsize',fsbig);
    uicontrol(hdial2,'style','text','string',hint1,'tag','hint1','units','normalized',...
        'position',[xnow+.5*wid ynow-.25*ht wid ht],'foregroundcolor','r','fontsize',fsbig',...
        'fontweight','bold','horizontalalignment','left');
    xnow=xnot;
    ynow=ynow-ht-ysep;
    uicontrol(hdial2,'style','text','string','Xline byte loc:','units','normalized','position',...
        [xnow ynow-.25*ht wid ht],'horizontalalignment','right','fontsize',fsbig);
    xnow=xnow+wid+xsep;
    uicontrol(hdial2,'style','edit','string',int2str(locs(2)),'tag','xline','enable',val,'units',...
        'normalized','position',[xnow ynow .5*wid ht],'fontsize',fsbig);
    uicontrol(hdial2,'style','text','string',hint1,'tag','hint2','units','normalized',...
        'position',[xnow+.5*wid ynow-.25*ht wid ht],'foregroundcolor','r','fontsize',fsbig',...
        'fontweight','bold','horizontalalignment','left');
    %done and cancel buttons
    xnow=xnot;
    ynow=ynow-ht-ysep;
    uicontrol(hdial2,'style','pushbutton','string','Done','tag','done','units','normalized',...
        'position',[xnow+.5*wid ynow .5*wid ht],'callback','enhance(''choosebyteloc2'');','Backgroundcolor','c',...
        'fontsize',fsbig);
    xnow=xnow+wid+xsep;
    uicontrol(hdial2,'style','pushbutton','string','Cancel','tag','cancel','units','normalized',...
        'position',[xnow ynow .5*wid ht],'callback','enhance(''choosebyteloc2'');');
    WinOnTop(hdial2,true)
elseif(strcmp(action,'choosebyteloc2'))
    %this is called by one of several controls on the byte location dialog
    %determine calling control
    hcntrl=gcbo;
    mode=get(hcntrl,'tag');
    hdial2=gcf;
    hhint1=findobj(hdial2,'tag','hint1');
    hhint2=findobj(hdial2,'tag','hint2');
    switch mode
        case 'options'
            hopt=findobj(hdial2,'tag','options');
            opts=get(hopt,'string');
            val=get(hopt,'value');
            option=opts{val};
            hinline=findobj(gcf,'tag','inline');
            hxline=findobj(gcf,'tag','xline');
            switch option
                case 'SEGY standard'
                    locs=segybytelocs;
                    set(hinline,'string',int2str(locs(1)),'enable','inactive');
                    set(hxline,'string',int2str(locs(2)),'enable','inactive');
                    set([hhint1 hhint2],'string','')
                case 'Canadian locs'
                    locs=canadabytelocs;
                    set(hinline,'string',int2str(locs(1)),'enable','inactive');
                    set(hxline,'string',int2str(locs(2)),'enable','inactive');
                    set([hhint1 hhint2],'string','')
                case 'Kingdom locs'
                    locs=kingdombytelocs;
                    set(hinline,'string',int2str(locs(1)),'enable','inactive');
                    set(hxline,'string',int2str(locs(2)),'enable','inactive');
                    set([hhint1 hhint2],'string','')
                case 'Other'
                    set(hinline,'enable','on');
                    set(hxline,'enable','on');
                    set([hhint1 hhint2],'string','<<Changable');
            end
            
        case 'done'
            %get the option
            hopt=findobj(hdial2,'tag','options');
            opts=get(hopt,'string');
            val=get(hopt,'value');
            option=opts{val};
            %get the byte locations
            hinline=findobj(gcf,'tag','inline');
            hxline=findobj(gcf,'tag','xline');
            loc1=round(str2double(get(hinline,'string')));
            loc1flag=true;
            if(isnan(loc1) || loc1<1 || loc1>237)
                loc1flag=false;
            end
            loc2=round(str2double(get(hxline,'string')));
            loc2flag=true;
            if(isnan(loc2) || loc2<1 || loc2>237)
                loc2flag=false;
            end
            
            if(loc1flag && loc2flag)
                %ok we go
                hmsg=findobj(hdial2,'tag','message');
                hpan=get(hmsg,'userdata');%the panel we are updating
                %get the buttons
                hinline=findobj(hpan,'tag','inline');
                hxline=findobj(hpan,'tag','xline');
                set(hinline','string',option,'userdata',loc1,'tooltipstring',...
                    ['loc= ' int2str(loc1) ', Push to change.']);
                set(hxline','string',option,'userdata',loc2,'tooltipstring',...
                    ['loc= ' int2str(loc2) ', Push to change.']);
                delete(hdial2)
                return;
                          
            elseif(~loc1flag)
                set(hhint1,'string','<<Bad value');
                return
                
            else
                set(hhint2,'string','<<Bad value');
                return
                
            end
            
        case 'cancel'
            delete(hdial2);
            return
            
    end
elseif(strcmp(action,'showtraceheaders'))
    %called by Multiple SEGY load dialog, or single segyload, or from Datainfo window
    hfig=gcf;%the figure that called this;
    frominfo=false;
    if(strcmp(get(hfig,'tag'),'datainfo'))
        frominfo=true;
    end
    pos=get(hfig,'position');
    
    %get number of traces
    hbut=gcbo;%the calling button
    ntr=get(hbut,'userdata');
    if(isempty(ntr))
        hntraces=findobj(hfig,'tag','ntraces');
        ntraces=str2double(get(hntraces,'string'));%number of headers to read
        if(isnan(ntraces)||ntraces<1)
            ntraces=1000;
            set(hntraces,'string',int2str(ntraces));
        end
    else
        ntraces=ntr;
    end
    if(frominfo)
        henhance=get(hfig,'userdata');
        hfile=findobj(henhance,'label','File');
        proj=get(hfile,'userdata');%project structure
        idata=get(hntraces,'userdata');%dataset number
        alltr=false;
        if(ischar(ntraces))%test for 'all'
            if(strcmpi(ntraces,'all'))
                nx=length(proj.xcoord{idata});
                ny=length(proj.ycoord{idata});
                ntraces=nx*ny;
                alltr=true;
            else
                ntraces=1000;
                set(hntraces,'string','ntraces');
            end
        elseif(isnan(ntraces))
            ntraces=1000;
            set(hntraces,'string','1000');
        end
        dname=proj.datanames{idata};
        %sgrv=getsegyrev(idata,henhance);
        if(alltr)
            msg=['For ' dname ', all traceheaders.'];
            viewtraceheaders(proj.tracehdr{idata},proj.segyrev(idata),msg);
            htrhfig=gcf;
        else
            msg=['For ' dname ', first ' int2str(ntraces) ' traceheaders.'];
            viewtraceheaders(tracehdr_subset(proj.tracehdr{idata},1:ntraces),proj.segyrev(idata),msg);
            htrhfig=gcf;
        end
        pos2=get(htrhfig,'position');%position of the new figure
        set(htrhfig,'position',[pos(1)+.5*(pos(3)-pos2(3)) pos(2)+.5*(pos(4)-pos2(4)) pos2(3:4)])
        
        hppt=addpptbutton([.95 .95 .05 .05]);
        set(hppt,'userdata',['Trace headers for ' dname]);
        
    else
        udat=get(hfig,'userdata');
        henhance=udat{2};
        %get filename and path
        hpan=get(hbut,'parent');
        hfname=findobj(hpan,'tag','filename');
        if(isempty(hfname))
            %happens when called from single readsegy file input
            hfname=findobj(hpan,'tag','fname');
            fname=get(hfname,'userdata');
            hpath=findobj(hpan,'tag','path');
            path=get(hpath,'userdata');
        else
            fname=get(hfname,'string');
            path=get(hfname,'userdata');
        end
        trc=SegyTrace([path fname]);
        trchdr=trc.read(1:ntraces,'headers');
        viewtraceheaders(trchdr,trc.SegyRevision,['First ' int2str(ntraces) ' headers of ' fname]);
        htrhfig=gcf;
        pos2=get(htrhfig,'position');%position of the new figure
        set(htrhfig,'position',[pos(1)+.5*(pos(3)-pos2(3)) pos(2)+.5*(pos(4)-pos2(4)) pos2(3:4)])
        %save the figure handle in buttons userdata
        udat{1}=[udat{1} htrhfig];
        set(hfig,'userdata',udat);
    end
%     sf=SegyFile([path fname],'r');
%     trchdr = sf.Trace.read(1:ntraces,'headers');
%     viewtraceheaders(trchdr,sf.SegyRevision,['First ' int2str(ntraces) ' headers of ' fname]);
    hm=findobj(henhance,'tag','message');
    hfigs=get(hm,'userdata');
    set(hm,'userdata',[hfigs htrhfig]);
elseif(strcmp(action,'showbinaryheader'))
    hfig=gcf;%should be the datainfo figure
    pos=get(hfig,'position');
    hntraces=findobj(hfig,'tag','ntraces');
    henhance=get(hfig,'userdata');
    hfile=findobj(henhance,'label','File');
    proj=get(hfile,'userdata');%project structure
    idata=get(hntraces,'userdata');%dataset number
    dname=proj.datanames{idata};
    msg=['Binary header for ' dname ];
    viewbinheader(proj.binhdr{idata},msg);
    hbinfig=gcf;
    pos2=get(hbinfig,'position');%position of the new figure
    set(hbinfig,'position',[pos(1)+.5*(pos(3)-pos2(3)) pos(2)+.5*(pos(4)-pos2(4)) pos2(3:4)])
    
    hppt=addpptbutton([.9 .9 .1 .05]);
    set(hppt,'userdata',['Trace headers for ' dname]);
    
    hm=findobj(henhance,'tag','message');
    hfigs=get(hm,'userdata');
    set(hm,'userdata',[hfigs hbinfig]);
elseif(strcmp(action,'showhistory'))
    hfig=gcf;%should be the datainfo figure
    hntraces=findobj(hfig,'tag','ntraces');
    henhance=get(hfig,'userdata');
    hfile=findobj(henhance,'label','File');
    proj=get(hfile,'userdata');%project structure
    idata=get(hntraces,'userdata');%dataset number
    dname=proj.datanames{idata};
    msg=['History for ' dname ];
    msgbox(proj.history{idata},msg);
elseif(strcmp(action,'changetshift'))
    %this is called for the information panel
    hpan=gcf;
    htshift=findobj(hpan,'tag','tshift');
    tshift=str2double(get(htshift,'string'));
    if(isnan(tshift))
        msgbox('Unrecognizable value for time shift');
        set(htshift,'string','0.0');
    end

    
    henhance=get(hpan,'userdata');
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    hdsum=findobj(hpan,'tag','datasummary');
    idata=get(hdsum,'userdata');%the dataset number
    if(tshift>10 && proj.depth(idata)==0)
        tshift=tshift/1000; %assume milliseconds
    end
    t=proj.tcoord{idata};
    tshiftold=proj.tshift(idata);
    proj.tcoord{idata}=t-tshiftold+tshift;
    proj.tshift(idata)=tshift;
    set(hfile,'userdata',proj);
    hmsg=findobj(henhance,'tag','message');
    delete(hpan);
    enhance('saveproject');
    set(hmsg,'string','Time shift updated and project saved');
    msgbox(['Time shift changed for ' proj.datanames{idata} ...
        '. You should close and re-open any displays of this dataset'],'ENHANCE message');
elseif(strcmp(action,'pptx'))
    %here we open a new PPTX file. If one is already open, we close it and start another.
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    hppt=findobj(henhance,'tag','pptx');
    proj=get(hfile,'userdata');
    ndatasets=length(proj.datanames');
    if(isempty(proj.projpath)&&ndatasets==0)
        msgbox('Load a project or dataset first and then press this button');
        return;
    elseif(isempty(proj.projpath)&&ndatasets>0)
        msgbox('You must save your project first to define a file location, then press this button.');
        return;
    end
    str=get(hppt,'string');
    if(strcmp(str,'Start PPT'))
        figure(henhance)
        waitsignalon
        %ok we are starting a new PPTX
        isopen=exportToPPTX();
        if(~isempty(isopen))
            %get the name and path
            
            udat=get(hppt,'userdata');
            exportToPPTX('saveandclose',[udat{1} udat{2}]);
            [success,message,messageid]=movefile([udat{1} udat{2} '.pptx'],[udat{1} udat{2} '.ppt']); %#ok<ASGLU>
        end
        %get the project path
        ppath=proj.projpath;
        %look for existing enhanceppt.pptx files
        inum=1;
        done=false;
        enhanceppt='enhanceppt';
        while(~done)
            fileppt=[enhanceppt '#' int2str(inum)];
            test=exist([ppath fileppt '.ppt'],'file');
            if(test==0)
                done=true;
            end
            inum=inum+1;
        end
        %at this point fileppt with have the name 'enhanceppt#x.ppt' where x is an integrer that gives
        %a filename that does not already exist
        if(~isdeployed)
            pp=which('exportToPPTX');
            ii=strfind(pp,'exportToPPTX.m');
            exportToPPTX('open',[pp(1:ii(1)-1) 'DevonTemplate.pptx']);%opens the PPT
        else
            hn=char(getHostName(java.net.InetAddress.getLocalHost));
            if(strcmp(hn(1:3),'CGY'))
                %pp='\\cgynafsvs001p\MARGRG\Documents\matlab_repository\crewes\exportToPPTX-master\';
                pp='\\dvn.com\network\USA\Corporate\Apps\App-Data\Matlab\crewes\exportToPPTX-master\';
            else
                pp='\\dvn.com\network\USA\Corporate\Apps\App-Data\Matlab\crewes\exportToPPTX-master\';
            end
            exportToPPTX('open',[pp 'DevonTemplate.pptx']);%opens the PPT
        end
        
        set(hppt,'userdata',{ppath fileppt},'string','Close PPT',...
            'tooltipstring','Click to close PPT buffer and write PPT file to disk.');
        %look for open PowerPoint windows and change their copy buttons
        for k=1:length(proj.pifigures)
            hpif=proj.pifigures{k};
            if(~isempty(hpif))
               plotimage3D('buttons2ppt',hpif)
            end
        end
        msgbox(['PowerPoint initiated. File (.ppt) will be written to project save file ',... 
            'when you push the "Close PPPT" button']);
        figure(henhance)
        waitsignaloff
    else
        %ok we are closing the PPTX
        udat=get(hppt,'userdata');
        exportToPPTX('saveandclose',[udat{1} udat{2}]);
        [success,message,messageid]=movefile([udat{1} udat{2} '.pptx'],[udat{1} udat{2} '.ppt']); %#ok<ASGLU>
        set(hppt,'userdata',{},'string','Start PPT',...
            'tooltipstring','Click to initiate PowerPoint slide creation');
        %look for open PowerPoint windows and change their copy buttons
        for k=1:length(proj.pifigures)
            hpif=proj.pifigures{k};
            if(~isempty(hpif))
               plotimage3D('buttons2clipboard',hpif)
            end
        end
        msgbox(['File ' udat{1} udat{2} ' written'],'PowerPoint created');
    end
elseif(strcmp(action,'makepptslide'))
        %this is called from any ENHANCE application with enhance('makepptslide','Title string')
        %The slide is always made from GCF
        hfig=gcf;
        %see if PPT is open
        isopen=exportToPPTX();
        if(isempty(isopen))
            enhance('pptx');%opens a new powerpoint
        end
        %put up the title string for approval
        if(nargin<2)
            hppt=findobj(hfig,'tag','ppt');
            titlestring=get(hppt,'userdata');
        else
            titlestring=arg2;
        end
        tit=askthingsle('name','PPT slide title','questions',{'Title for slide'},'answers',...
            {titlestring});
        if(isempty(tit))
            return;
        end
        titlestring=tit{1};
        %make the slide
        exportToPPTX('addslide','Layout','Title and Footer');
        %slideNum = exportToPPTX('addslide','Layout','Title and Footer');
        exportToPPTX('addtext',titlestring,'Position','Title');
        %fprintf('Added slide %d\n',slideNum);
        exportToPPTX('addpicture',hfig,'position',[0 1.5 13.333 5.5]);
elseif(strcmp(action,'specdecompdecide'))
    henhance=findenhancefig;
    pos=get(henhance,'position');
    figwid=600;
    fight=400;
    xc=pos(1)+.5*pos(3);
    yc=pos(2)+.5*pos(4);
    hdial=figure('position',[xc-.5*figwid,yc-.5*fight,figwid,fight],'tag','SDdecide',...
        'userdata',henhance,'numbertitle','off','name','Spectral Decomp Decision Tool');
    xnow=.1;ynow=.9;
    wid=.8;ht=.05;
    fs=12;sep=.01;
    uicontrol(hdial,'style','text','string','Spectral Decomp Decision Tool','units','normalized',...
        'position',[xnow,ynow,wid,ht],'fontsize',fs,'fontweight','bold');
    ynow=ynow-3*ht;
    msg=['Spectral decompositon creates an output volume the same size as the input volume for ',...
        'each output frequency. This can use up available memory rapidly. Therefore for large datasets ',...
        'it is recommended to reduce the input volume by limiting the time range. This tool allows ',...
        'you to estimate the maximum number of frequecies possible. Try to leave a few GB of '...
        'residual memory.'];
    uicontrol(hdial,'style','text','string',msg,'units','normalized','position',[xnow,ynow,.8,3*ht])
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    ynow=ynow-ht;
    ht=.05;
    wid=.1;
    nudge=.25*ht;
    uicontrol(hdial,'style','text','string','Dataset:','units','normalized',...
        'position',[xnow,ynow-nudge,wid,ht]);
    uicontrol(hdial,'style','popupmenu','string',proj.datanames,'tag','datanames','units','normalized',...
        'position',[xnow+wid+sep,ynow,7*wid,ht],'callback','enhance(''specdecompdecide2'');');
    ynow=ynow-2*ht-sep;
    xnow=.4;
    uicontrol(hdial,'style','text','string','Start time:','units','normalized',...
        'position',[xnow,ynow-nudge,wid,ht]);
    uicontrol(hdial,'style','edit','string',proj.tcoord{1}(1),'tag','start','units','normalized',...
        'position',[xnow+wid+sep,ynow,wid,ht],'callback','enhance(''specdecompdecide2'');',...
        'tooltipstring','Type a value in seconds then hit "enter"');
    ynow=ynow-2*ht-sep;
    uicontrol(hdial,'style','text','string','End time:','units','normalized',...
        'position',[xnow,ynow-nudge,wid,ht]);
    uicontrol(hdial,'style','edit','string',proj.tcoord{1}(end),'tag','end','units','normalized',...
        'position',[xnow+wid+sep,ynow,wid,ht],'callback','enhance(''specdecompdecide2'');',...
        'tooltipstring','Type a value in seconds then hit "enter"');
    ynow=ynow-2*ht;
    wid=.6;
    xnow=.25;
    uicontrol(hdial,'style','text','string','','units','normalized','tag','availmem',...
        'position',[xnow,ynow,wid,ht]);
    ynow=ynow-1.5*ht;
    uicontrol(hdial,'style','text','string','','units','normalized','tag','reqmem',...
        'position',[xnow,ynow,wid,ht]);
    ynow=ynow-1.5*ht;
    uicontrol(hdial,'style','text','string','','units','normalized','tag','resmem',...
        'position',[xnow,ynow,wid,ht]);
    ynow=ynow-1.5*ht;
    uicontrol(hdial,'style','text','string','','units','normalized','tag','nfreqs',...
        'position',[xnow,ynow,wid,ht],'fontsize',10,'fontweight','bold');
    ynow=ynow-2*ht;
    wid=.1;
    xnow=.5;
    uicontrol(hdial,'style','pushbutton','string','Done','units','normalized','position',...
        [xnow,ynow,wid,ht],'callback','close(gcf)');
    enhance('specdecompdecide2');
    return;
elseif(strcmp(action,'specdecompdecide2'))
    hdial=gcf;
    henhance=get(hdial,'userdata');
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    hd=findobj(hdial,'tag','datanames');
    idata=get(hd,'value');
    x=proj.xcoord{idata};
    y=proj.ycoord{idata};
    t=proj.tcoord{idata};
    hstart=findobj(hdial,'tag','start');
    tmin=str2double(hstart.String);
    if(isnan(tmin)); tmin=t(1); end
    tmin=max([t(1) tmin]);
    set(hstart,'string',num2str(tmin));
    hend=findobj(hdial,'tag','end');
    tmax=str2double(hend.String);
    if(isnan(tmax)); tmax=t(1); end
    tmax=max([t(1) tmax]);
    set(hend,'string',num2str(tmax));
    %compute
%     mm=memory;
%     availmem=mm.MaxPossibleArrayBytes;
%     ind=near(t,tmin,tmax);
%     reqmem=length(x)*length(y)*length(ind)*4;
%     nfreqs=floor(availmem/reqmem);
%     resmem=availmem-nfreqs*reqmem;
    ind=near(t,tmin,tmax);
    [availmem,reqmem,nfreqs,resmem]=specdmemory(length(x),length(y),length(ind));
    %annotate
    ha=findobj(hdial,'tag','availmem');
    GB=(1024)^3;
    set(ha,'string',['Available memory: ' num2str(availmem) ' bytes (' num2str(availmem/GB,3) 'GB)']);
    hr=findobj(hdial,'tag','reqmem');
    set(hr,'string',['Memory required per frequency: ' num2str(reqmem) ' bytes (' num2str(reqmem/GB,3) 'GB)']);
    hr=findobj(hdial,'tag','resmem');
    set(hr,'string',['Residual memory ' num2str(resmem) ' bytes (' num2str(resmem/GB,3) 'GB)']);
    hf=findobj(hdial,'tag','nfreqs');
    set(hf,'string',['Maximum number of output frequencies: ' int2str(nfreqs) ]);
    
elseif(strcmp(action,'enhanceinfo'))
    henhance=gcf;
    hmsg=findobj(henhance,'tag','message');
    msg={['ENHANCE, or Seismic ANalysis Environment, is a tool designed to facilitate the anlysis, comparison, ',...
        'and enhancement of 3D seismic volumes. To use ENHANCE you will need to have one or more 3D seismic ',...
        'datasets available as SEGY files. ENHANCE lets you define "Projects" which contain one or more related 3D ',...
        'volumes. For example, you might wish to compare several volumes of the same data processed in different ways ',...
        'and it would make sense to have them in the same project. Or you might have several 3D volumes that are ',...
        'from adjacent areas that you wish to compare and again you would put these in the same project. '],...
        [],['Before loading data into ENHANCE, it is useful to understand ',...
        'the dataset size (in gigabytes or GB) and the size of the availble memory on your computer. For each '...
        'SEGY file, just note the file size in a Windows directory, and for the computer memory, use ',...
        'the Windows Task Manager under the "Performance" tab. If any of your SEGY files are larger than 50% ',...
        'of the computer memory then they are probably too large for ENHANCE. You can load any number of SEGY ',...
        'volumes into a ENHANCE Project even if their combined size exceeds your computer memory. This is because ',...
        'ENHANCE gives you control over which datasets in a Project are actually loaded into memory. '],...
        [],['To load a single SEGY, use File/Read datasets/*.sgy file, and to load many SEGY''s at once use ',...
        'File/Read datasets/Multiple sgy files. Either of these options puts up a dialog that gives you ',...
        'the opportunity to define where in the SEGY trace headers the inline and crossline numbers are ',...
        'read from. It is recommended to verify that the locations are correct or, if not, then change them. ',...
        'This is easily done by clicking the button labelled "Trace headers". By default, ENHANCE will ',...
        'read these values from the SEGY standard locations (bytes 189 and 193) but it is possible your ',...
        'dataset will not conform to this standard. Pushing the button labelled "Segy standard" allows ',...
        'you to change the locations. It can take hours to read in a large dataset and it is often ',...
        'advisable to do so overnight. You only nead to read the SEGY once, because thereafter the data ',...
        'are stored as Matlab binaries which load much faster.'],...
        [],['Each dataset in a project will have a unique row, or subpanel, in the main data panel of the ENHANCE window, stating its name, ',...
        'and other relevant information. The names are editable and easily changed. They will appear ',...
        'above any plots so you may want to make them more meaningful than the default which is the file name. '],...
        [],['ENHANCE has the ability to automatically make PowerPoint slides of almost any view that you see. ',...
        'If you push the "Start PPT" button on the main ENHANCE window this initiates the process. ',...
        '(Alternatively, just push the "PPT" button on any display window.) The PowerPoint slides are ',...
        'accumulated in memory as you work but the PowerPoint file is not written to disk until you push ',...
        'the "Close PPT" button (formerly the "Start PPT" button).'],...
        [],['When you choose to display a particular dataset within ENHANCE it appears in a separate window ',...
        'called a PI3D window, which has controls for examining inlines, crosslines, and timeslices. ',...
        'At this point a number of "analysis tools" are available and are accessed by right-clicking ',...
        'within the data display (click on the data itself). Each of these tools will launch in a new window. ',...
        'Analysis tools do not change the data volume itself but allow you to determine things like "signal band", ',...
        'and the effect of spiking decon or Gabor decon. '],...
        [],['Sane also has a growing number of "computational tasks" that apply to the entire 3D volume ',...
        'resulting in a new volume that can either be exported or retained in the Project. These are ',...
        'accessed through the "Compute" menu in the main ENHANCE window.']};
     hinfo=msgbox(msg,'Information for ENHANCE');
     udat=get(hmsg,'userdata');
     udat=[udat hinfo];
     set(hmsg,'userdata',udat);
end

end

function [availmem,reqmem,nfreqs,resmem]=specdmemory(nx,ny,nt)
    mm=memory;
    availmem=mm.MaxPossibleArrayBytes;
    reqmem=nx*ny*nt*4;
    nfreqs=floor(availmem/reqmem);
    resmem=availmem-nfreqs*reqmem;
end

function [itchoice,ixchoice,iychoice]=ambigdialog(ambig,it,ix,iin,varnames,itchoice,ixchoice,iychoice)
%this is called when importing a .mat file that may have many variables in it.
henhance=findenhancefig;
pos=get(henhance,'position');
if(pos(3)<450);pos(3)=450;end
%hdial=dialog;
hdial=figure('windowstyle','modal');
set(hdial,'position',pos,'menubar','none','toolbar','none','numbertitle','off',...
    'name','ENHANCE mat file input ambiguity dialog','nextplot','new');
indt= it==1;
indx= ix==1;
indin= iin==1;
columnformat={};
data={};
columnnames={};
if(ambig(1)==1)
   columnformat=[columnformat {varnames(indt)'}];
   data=[data varnames{itchoice}];
   columnnames=[columnnames {'time coordinate'}];
end
if(ambig(2)==1)
   columnformat=[columnformat {varnames(indx)'}];
%    if(strcmp(varnames{indt(itchoice)},varnames{indx(ixchoice)}))
%     data=[data varnames{indx(2)}];
%     ixchoice=2;
%    else
    data=[data varnames{ixchoice}];
%    end
   columnnames=[columnnames {'xline coordinate'}];
end
if(ambig(3)==1)
   columnformat=[columnformat {varnames(indin)'}];
%    if(strcmp(varnames{indin(iychoice)},varnames{indx(ixchoice)}))
%       iychoice=ixchoice+1;
%    end
   data=[data varnames{iychoice}];
   columnnames=[columnnames {'inline coordinate'}];
end

ynow=.4;ht=.3;
htab=uitable(hdial,'data',data,'columnformat',columnformat,'columnname',columnnames,...
    'rowname','choose:','columneditable',true,'units','normalized','position',[.1 ynow .8 ht],...
    'tag','table','userdata',varnames);
htab.Position(3)=htab.Extent(3);
htab.Position(4)=htab.Extent(4);
ynow=.6;
msg={'Unable to determine coordinate vectors based on size only.'...
    'Please choose a unique name for each coordinate'};
uicontrol(hdial,'style','text','units','normalized','position',[.1 ynow .8 ht],'string',msg,...
    'tag','msg');
uicontrol(hdial,'style','pushbutton','string','Done','units','normalized',...
    'position',[.1 .1 .3 .1],'callback',@checkambig,'userdata',ambig,'tag','done');

uiwait(hdial)

%function [itchoice,ixchoice,iychoice]=checkambig(~,~)
function checkambig(~,~)
htable=findobj(gcf,'tag','table');
choices=htable.Data;
if(length(choices)==3)
    if(strcmp(choices{1},choices{2})||strcmp(choices{1},choices{3})...
            ||strcmp(choices{2},choices{3}))
        hmsg=findobj(gcf,'tag','msg');
        set(hmsg,'string','You must choose unique names for each!!!','foregroundcolor',[1 0 0],...
            'fontsize',10,'fontweight','bold');
        itchoice=0;
        ixchoice=0;
        iychoice=0;
        return
    end
elseif(length(choices)==2)
    if(strcmp(choices{1},choices{2}))
        hmsg=findobj(gcf,'tag','msg');
        set(hmsg,'string','You must choose unique names for each!!!','foregroundcolor',[1 0 0],...
            'fontsize',10,'fontweight','bold');
        itchoice=0;
        ixchoice=0;
        iychoice=0;
        return
    end
end
varnames=get(htable,'userdata');
hbut=findobj(gcf,'tag','done');
ambig=get(hbut,'userdata');
colnames=htable.ColumnName;
if(sum(ambig)==3)
    for k=1:length(varnames)
        if(strcmp(varnames{k},choices{1}))
            itchoice=k;
        end
        if(strcmp(varnames{k},choices{2}))
            ixchoice=k;
        end
        if(strcmp(varnames{k},choices{3}))
            iychoice=k;
        end
    end
elseif(sum(ambig)==2)
    for k=1:length(varnames)
        if(strcmp(varnames{k},choices{1}))
            if(colnames{1}(1)=='t')
                itchoice=k;
            elseif(colnames{1}(1)=='x')
                ixchoice=k;
            end
        end
        if(strcmp(varnames{k},choices{2}))
            if(colnames{2}(1)=='x')
                ixchoice=k;
            elseif(colnames{2}(1)=='i')
                iychoice=k;
            end
        end
    end
else
    for k=1:length(varnames)
        if(strcmp(varnames{k},choices{1}))
            if(colnames{1}(1)=='t')
                itchoice=k;
            elseif(colnames{1}(1)=='x')
                ixchoice=k;
            elseif(colnames{1}(1)=='i')
                iychoice=k;
            end
        end
    end
end
close(gcf)
end

end

function proj=makeprojectstructure

proj.name='New Project';
proj.filenames={};
proj.projfilename=[];
proj.projpath=[];
proj.paths={};
proj.datanames={};
proj.isloaded=[];
proj.isdisplayed=[];
proj.xcoord={};
proj.ycoord={};
proj.tcoord={};
proj.tshift=[];
proj.datasets={};
proj.xcdp={};
proj.ycdp={};
proj.dx=[];
proj.dy=[];
proj.depth=[];
proj.texthdr={};
proj.texthdrfmt={};
proj.segfmt={};
proj.byteorder={};
proj.binhdr={};
proj.exthdr={};
proj.tracehdr={};
proj.bindef={};
proj.trcdef={};
proj.segyrev=[];
proj.kxline={};
proj.gui={};
proj.rspath=[];
proj.wspath=[];
proj.rmpath=[];
proj.wmpath=[];
proj.pifigures=[];
proj.isdeleted=[];
proj.deletedondisk=[];
proj.saveneeded=[];
proj.xlineloc={};
proj.inlineloc={};
proj.parmsets={};
proj.horizons={};
proj.history={};

end

function projnew=expandprojectstructure(proj,nnew)

projnew.name=proj.name;
projnew.projfilename=proj.projfilename;
projnew.filenames=[proj.filenames cell(1,nnew)];
projnew.projpath=proj.projpath;
projnew.paths=[proj.paths cell(1,nnew)];
projnew.datanames=[proj.datanames cell(1,nnew)];
projnew.isloaded=[proj.isloaded zeros(1,nnew)];
projnew.isdisplayed=[proj.isdisplayed zeros(1,nnew)];
projnew.xcoord=[proj.xcoord cell(1,nnew)];
projnew.ycoord=[proj.ycoord cell(1,nnew)];
projnew.tcoord=[proj.tcoord cell(1,nnew)];
projnew.tshift=[proj.tshift zeros(1,nnew)];
projnew.datasets=[proj.datasets cell(1,nnew)];
projnew.xcdp=[proj.xcdp cell(1,nnew)];
projnew.ycdp=[proj.ycdp cell(1,nnew)];
projnew.dx=[proj.dx ones(1,nnew)];
projnew.dy=[proj.dy ones(1,nnew)];
projnew.depth=[proj.depth zeros(1,nnew)];
projnew.texthdr=[proj.texthdr cell(1,nnew)];
projnew.texthdrfmt=[proj.texthdrfmt cell(1,nnew)];
projnew.segfmt=[proj.segfmt cell(1,nnew)];
projnew.byteorder=[proj.byteorder cell(1,nnew)];
projnew.binhdr=[proj.binhdr cell(1,nnew)];
projnew.exthdr=[proj.exthdr cell(1,nnew)];
projnew.tracehdr=[proj.tracehdr cell(1,nnew)];
projnew.bindef=[proj.bindef cell(1,nnew)];
projnew.trcdef=[proj.trcdef cell(1,nnew)];
projnew.segyrev=[proj.segyrev zeros(1,nnew)];
projnew.kxline=[proj.kxline cell(1,nnew)];
projnew.gui=[proj.gui cell(1,nnew)];
projnew.rspath=proj.rspath;
projnew.wspath=proj.wspath;
projnew.rmpath=proj.rmpath;
projnew.wmpath=proj.wmpath;
projnew.pifigures=[proj.pifigures cell(1,nnew)];
projnew.isdeleted=[proj.isdeleted zeros(1,nnew)];
projnew.deletedondisk=[proj.deletedondisk zeros(1,nnew)];
projnew.saveneeded=[proj.saveneeded zeros(1,nnew)];
projnew.xlineloc=[proj.xlineloc zeros(1,nnew)];
projnew.inlineloc=[proj.inlineloc zeros(1,nnew)];
projnew.parmsets=proj.parmsets;
proj.horizons=[proj.horizons cell(1,nnew)];

end

function hpan=newdatapanel(dname,memflag,dispflag)
henhance=findenhancefig;
hmpan=findobj(henhance,'tag','master_panel');%the master panel
hsp=findobj(henhance,'tag','enhance_panel');
poss=get(hsp,'position');
hdp=findobj(henhance,'tag','data_panel');%the data panel
posd=get(hdp,'position');
udat=get(hmpan,'userdata');
geom=udat{2};
hpanels=udat{1};
npanels=length(hpanels)+1;
panelwidth=1;panelheight=geom(2)/(poss(4)*posd(4));xnow=0;
wid=geom(5);ht=geom(6);xsep=geom(7);ysep=geom(8)/(poss(4)*posd(4));
%ynow=ynow-panelheight-ysep;
ynow=1-npanels*(panelheight+ysep);
hpan=uipanel(hdp,'tag',['data_panel' int2str(npanels)],'units','normalized',...
    'position',[xnow ynow panelwidth panelheight],'userdata',npanels);
geom(4)=ynow;
hpanels{npanels}=hpan;
set(hmpan,'userdata',{hpanels geom []});
%dataset name
xn=0;yn=.1;
dg=.7*ones(1,3);
ht2=1.1;
uicontrol(hpan,'style','edit','string',dname,'tag','dataname','units','normalized',...
    'position',[xn yn wid ht],'callback','enhance(''datanamechange'');','horizontalalignment','center');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%info button
xn=xn+wid+xsep;
wid2=(1-wid-3*xsep)/4.5;
uicontrol(hpan,'style','pushbutton','string','Information','tag','dataname','units','normalized',...
    'position',[xn yn .75*wid2 ht],'callback','enhance(''datainfo'');');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%memory
xn=xn+.75*wid2+xsep;
hbg1=uibuttongroup(hpan,'tag','memory','units','normalized','position',[xn yn wid2 ht]);
if(memflag==1)
    val1=1;val2=0;
else
    val1=0;val2=1;
end
uicontrol(hbg1,'style','radio','string','Y','units','normalized','position',[.1 .2 .35 .8],'value',val1,...
    'callback','enhance(''datamemory'');','tag','memoryyes');
uicontrol(hbg1,'style','radio','string','N','units','normalized','position',[.6 .2 .35 .8],'value',val2,...
    'callback','enhance(''datamemory'');','tag','memoryno');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%display
xn=xn+wid2+xsep;
hbg2=uibuttongroup(hpan,'tag','display','units','normalized','position',[xn yn wid2 ht]);
if(dispflag==1)
    val1=1;val2=0;
else
    val1=0;val2=1;
end
uicontrol(hbg2,'style','radio','string','Y','units','normalized','position',[.1 .2 .35 .8],'value',val1,...
    'callback','enhance(''datadisplay'');','tag','displayyes');
uicontrol(hbg2,'style','radio','string','N','units','normalized','position',[.6 .2 .35 .8],'value',val2,...
    'callback','enhance(''datadisplay'');','tag','displayno');

%delete button
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
xn=xn+wid2+xsep;
uicontrol(hpan,'style','pushbutton','string','Delete','tag','dataname','units','normalized',...
    'position',[xn yn .5*wid2 ht],'callback','enhance(''datadelete'');');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+.5*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
xn=xn+.65*wid2+xsep;
uicontrol(hpan,'style','radio','string','','units','normalized','position',[xn yn .5*wid2 ht],'value',0,...
    'callback','enhance(''group'');','tag','group');

end



function waitsignalon
pos=get(gcf,'position');
spinnersize=[40 40];
waitspinner('start',[pos(3)-spinnersize(1), pos(4)-spinnersize(2), spinnersize]);
drawnow
end

function waitsignaloff
waitspinner('stop');
end

function henhance=findenhancefig
hfigs=figs;
if(isempty(hfigs))
    henhance=[];
    return;
end
hfig=gcf;
hs=findobj(hfig,'tag','fromenhance');
if(~isempty(hs))
    ud=get(hs,'userdata');
    if(isgraphics(ud))
        henhance=ud;
        return;
    end
end
if(strcmp(get(hfig,'tag'),'enhance'))
    henhance=hfig;
    return;
elseif(strcmp(get(hfig,'tag'),'fromenhance'))
    udat=get(hfig,'userdata');
    if(~iscell(udat))
        udat=get(udat,'userdata');
    end
    %explanation for the above. When plotimage3D is called from ENHANCE the tag is set to 'fromenhance'
    %and the userdata of the PI3D figrue is set to a two element cell where the second entry is the
    %enhance figure handle. (The first entry is lost in time.) With some plotimage3D tools, this tag is
    %copied to the tool window but the userdata of the tool window is just the pi3D handle.
    if(isgraphics(udat{2}))
        if(strcmp(get(udat{2},'tag'),'enhance'))
            henhance=udat{2};
            return;
        end
    end
else
    
    ienhance=zeros(size(figs));
    for k=1:length(figs)
        if(strcmp(get(hfigs(k),'tag'),'enhance'))
            ienhance(k)=1;
        end
    end
    if(sum(ienhance)==1)
        ind= ienhance==1;
        henhance=hfigs(ind);
    elseif(sum(ienhance)==0)
        henhance=[];
    else
        error('unable to resolve ENHANCE figure')
    end
end
end

function loadprojectdialog
henhance=findenhancefig;
hfile=findobj(henhance,'tag','file');
proj=get(hfile,'userdata');
dnames=proj.datanames;

isloaded=proj.isloaded;
isdisplayed=proj.isdisplayed;
islive=~proj.isdeleted;
nnames=length(dnames(islive));
pos=get(henhance,'position');
hdial=figure;
htfig=1.2*pos(4);
y0=pos(2)+pos(4)-htfig;
set(hdial,'position',[pos(1) y0 pos(3)*.6 htfig],'menubar','none','toolbar','none','numbertitle','off',...
    'name','ENHANCE: Project load dialogue','closerequestfcn','enhance(''cancelprojectload'');');
wid1=.5;wid2=.1;sep=.02;ht=.05;
xnow=.1;ynow=.95;
uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,.8,ht],...
    'string','Choose which datasets to load and display. Initial settings are from last save.');
ynow=ynow-ht-sep;
uicontrol(hdial,'string','Dataset','units','normalized','position',[xnow,ynow,wid1,ht]);
hload=uicontrol(hdial,'string','Loaded','units','normalized','position',[xnow+wid1+sep, ynow,wid2, ht],...
    'tag','loaded');
hdisp=uicontrol(hdial,'string','Displayed','units','normalized',...
    'position',[xnow+wid1+2*sep+wid2, ynow,wid2, ht],'tag','display');
hpan=uipanel(hdial,'position',[xnow,.1,.8,.77]);
hpan2=uipanel(hpan,'position',[0, -3, 1 4]);
%scrollbar
uicontrol(hdial,'style','slider','tag','slider','units','normalized','position',...
    [xnow+.8,.1,.5*xnow,.77],'value',1,'Callback',{@enhance_slider,hpan2})
xn=.02;yn=.96;h=1.5*ht/(4);
wd1=wid1;sp=.01;wd2=wid2;
xf=1.3;
hloaded=zeros(1,nnames);
hdisplayed=hloaded;
for k=1:length(dnames)
    if(~proj.isdeleted(k))
        mb=round(length(proj.xcoord{k})*length(proj.ycoord{k})*length(proj.tcoord{k})*4/10^6);
        uicontrol(hpan2,'style','text','string',[dnames{k} ' (' int2str(mb) 'MB)'],'units','normalized','position',[xn yn wd1 h]);
        hloaded(k)=uicontrol(hpan2,'style','popupmenu','string','No|Yes','units','normalized',...
            'position',[xn+wd1*xf yn wd2 h],'value',isloaded(k)+1);
        hdisplayed(k)=uicontrol(hpan2,'style','popupmenu','string','No|Yes','units','normalized',...
            'position',[xn+wd1*xf+wd2*xf+2*sp*xf yn wd2 h],'value',isdisplayed(k)+1);
        yn=yn-h-sp;
    end
end
ynow=.05;wid=.1;sep=.05;
uicontrol(hdial,'style','pushbutton','string','OK, continue','units','normalized',...
    'position',[xnow,ynow,2*wid,ht],'tooltipstring','Push to continue loading',...
    'callback','enhance(''loadprojdial'')','tag','continue','backgroundcolor','b','foregroundcolor','w');
uicontrol(hdial,'style','pushbutton','string','All Yes','units','normalized',...
    'position',[xnow+2*wid+sep,ynow,wid,ht],'tooltipstring','set all responses to Yes',...
    'callback','enhance(''loadprojdial'')','tag','allyes');
uicontrol(hdial,'style','pushbutton','string','All No','units','normalized',...
    'position',[xnow+3*wid+2*sep,ynow,wid,ht],'tooltipstring','set all responses to No',...
    'callback','enhance(''loadprojdial'')','tag','allno');

set(hload,'userdata',hloaded);
set(hdisp,'userdata',hdisplayed);
set(hdial,'userdata',henhance);

end

function multiplesegyload(newproject)
henhance=findenhancefig;
hfile=findobj(henhance,'tag','file');
proj=get(hfile,'userdata');
%hreadmany=findobj(henhance,'tag','readmanysegy');
pos=get(henhance,'position');
hdial=figure;
htfig=1*pos(4);
widfig=1.45*pos(3);
y0=pos(2)+pos(4)-htfig;
x0=pos(1)+.5*(pos(3)-widfig);
set(hdial,'position',[x0 y0 widfig htfig],'menubar','none','toolbar','none','numbertitle','off',...
    'name','ENHANCE: Multiple SEGY load dialogue','closerequestfcn','enhance(''cancelmultipleload'');');
WinOnTop(hdial,true)
wid1=.8;wid2=.1;sep=.02;ht=.05;
xnow=.1;ynow=.9;
if(newproject)
    msg='Select the SEGY Datasets to be read. Then define the project save file.';
else
    msg='Select the SEGY Datasets to be read. Datasets will be included in existing project.';
end
fsb=10;
uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid1,ht],...
    'string',msg,'fontsize',fsb,'fontweight','bold','tag','dialmsg');
% ynow=ynow-.5*ht-sep;
% uicontrol(hdial,'style','text','units','normalized','position',[xnow,ynow,wid1,ht],...
%     'string','','tag','dialmsg');
ynow=ynow-ht-sep;
uicontrol(hdial,'style','pushbutton','string','New dataset','units','normalized','tag','new',...
    'position',[xnow,ynow,wid2,ht],'tooltipstring','push this to select a new dataset',...
    'callback','enhance(''selectnewdataset'')','userdata',[],'fontsize',fsb);%userdata will contain the panel handles
if(newproject)
    uicontrol(hdial,'style','pushbutton','string','Project save file','units','normalized','tag','proj',...
        'position',[xnow+wid2+sep,ynow,wid2,ht],'tooltipstring','push this to define project save file',...
        'callback','enhance(''defineprojectsavefile'')','fontsize',fsb);
end
ynow=ynow-ht-sep;
uicontrol(hdial,'style','text','string','Project will be saved in:','units','normalized',...
    'position',[xnow,ynow,2*wid2,ht]);
if(isempty(proj.projfilename))
    projsavefile='Undefined';
else
    projsavefile=[proj.projpath proj.projfilename];
end
uicontrol(hdial,'style','pushbutton','string','Info','units','normalized','position',...
    [.9,ynow+ht,.3*wid2,ht],'backgroundcolor','y','callback','enhance(''helpsegyin'');');
uicontrol(hdial,'style','text','string',projsavefile,'units','normalized','tag','projsavefile',...
    'position',[xnow+2*wid2,ynow,wid1-2*wid2,ht],'horizontalalignment','left');
ynow=ynow-.5*ht-sep;
uicontrol(hdial,'style','pushbutton','string','Done','units','normalized','tag','done',...
    'position',[xnow,ynow,wid2,ht],'tooltipstring','Push to begin reading datasets',...
    'callback','enhance(''readmanysegy2'')','fontsize',fsb);
uicontrol(hdial,'style','pushbutton','string','Cancel','units','normalized','tag','cancel',...
    'position',[xnow+wid2+sep,ynow,wid2,ht],'tooltipstring','Push to cancel reading datasets',...
    'callback','enhance(''cancelmultipleload'')');

xnow=.9-.6*wid2;
htt=.8*ht;
uicontrol(hdial,'style','text','string','# hdrs to view:','units','normalized','position',...
    [xnow,ynow-.25*htt,.65*wid2,htt],'horizontalalignment','right');
xnow=xnow+.65*wid2;
uicontrol(hdial,'style','edit','string','100','units','normalized','tag','ntraces',...
    'position',[xnow ynow .35*wid2 htt]);
%make a master panel
xnow=.05;
ynow=ynow-ht-sep;
panelwidth=.9;
panelheight=ht;
hmpan=uipanel(hdial,'tag','readmanymaster','units','normalized','position',...
    [xnow,ynow,panelwidth,panelheight]);
%filename
wid=.24;ht=.8;ht2=1.1;
xn=0;yn=0;
ng=.94*ones(1,3);
dg=.7*ones(1,3);
fs=8;
xsep=.02;
ysep=.01;
%file name
uicontrol(hmpan,'style','text','string','Filename','tag','fname_label','units','normalized',...
    'position',[xn,yn,wid,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%dataset name
xn=xn+wid+xsep;
uicontrol(hmpan,'style','text','string','Dataset name','tag','dname_label','units','normalized',...
    'position',[xn,yn,wid,ht],'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng);
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%display option
xn=xn+wid+xsep;
wid2=(1-2.1*wid-7*xsep)/6;%nominal width of last six items
uicontrol(hmpan,'style','text','string','Display?','tag','dlabel','units','normalized','position',[xn,yn,.75*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Will this dataset be displayed after reading?');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%time shift
xn=xn+.75*wid2+xsep;
uicontrol(hmpan,'style','text','string','Time shift','tag','tslabel','units','normalized','position',[xn,yn,.75*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Datum shift for this dataset, seconds for time data. Feet or meters for depth data.');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%inline loc
xn=xn+.75*wid2+xsep;
uicontrol(hmpan,'style','text','string','Inline byte loc','tag','inlabel','units','normalized','position',[xn,yn,1.25*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Byte location in the SEGY trace headers for the inline number');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%xline loc
xn=xn+1.25*wid2+xsep;
uicontrol(hmpan,'style','text','string','Xline byte loc','tag','xlabel','units','normalized','position',[xn,yn,1.25*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Byte location in the SEGY trace headers for the crossline number');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%Trace headers
xn=xn+1.25*wid2+xsep;
uicontrol(hmpan,'style','text','string','Trace headers','tag','trclbl','units','normalized','position',[xn,yn,1.25*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Browse the trace headers');
%separator
uicontrol(hmpan,'style','text','string','','units','normalized','position',...
        [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%Trace inspector
xn=xn+1.25*wid2+xsep;
uicontrol(hmpan,'style','text','string','Trace inspector','tag','tilbl','units','normalized','position',[xn,yn,1.25*wid2,ht],...
    'horizontalalignment','center','fontsize',fs,'backgroundcolor',ng,...
    'tooltipstring','Inspect traces');

set(hmpan,'userdata',{[],[panelwidth,panelheight,xnow,ynow,wid,ht,xsep,ysep]})%the first slot in UserData will contain the array of panel handles

%Now make the scrolling panel which is a panel within a panel
panelht=ynow-.1-ysep;
ynow=.1;
hlp=uipanel(hdial,'tag','load_panel','units','normalized','position',[xnow,ynow,1.01*panelwidth,panelht]);
hdp=uipanel(hlp,'tag','data_panel','units','normalized','position',[0, -3, 1 4]);
%scrollbar
uicontrol(hdial,'style','slider','tag','slider','units','normalized','position',...
    [xnow+1.01*panelwidth,ynow,.025,panelht],'value',1,'Callback',{@enhance_slider,hdp});

set(hdial,'tag','fromenhance','userdata',{[] , henhance});
end

function multiplesegywrite
henhance=findenhancefig;
hfile=findobj(henhance,'tag','file');
proj=get(hfile,'userdata');
%hreadmany=findobj(henhance,'tag','readmanysegy');
pos=get(henhance,'position');
hdial=figure;
htfig=.5*pos(4);
widfig=.5*pos(3);
y0=pos(2)+pos(4)-htfig;
set(hdial,'position',[pos(1) y0 widfig htfig],'menubar','none','toolbar','none','numbertitle','off',...
    'name','ENHANCE: Multiple SEGY write dialogue','closerequestfcn','enhance(''cancelmultiplewrite'');');
xnow=.1;ynow=.85;
wid1=.8;ht1=.05;
uicontrol(hdial,'style','text','string','Choose the datasets to output','units','normalized',...
    'position',[xnow,ynow,wid1,ht1],'foregroundcolor','r','fontweight','bold')
wid1=.8;ht1=.5;
ynow=.3;
hpan=uiscrollpanel(hdial,[xnow,ynow,wid1,ht1]);
ndatasets=length(proj.datanames);

wid2=.9;ht2=.025;
checkboxes=zeros(1,ndatasets);
xn=0;yn=1-ht2;ysep=.02;
for k=1:ndatasets
    checkboxes(k)=uicontrol(hpan(2),'style','checkbox','units','normalized','position',[xn,yn,wid2,ht2],...
        'string',proj.datanames{k});
    yn=yn-ht2-ysep;
end
set(hdial,'userdata',{henhance,checkboxes})
ynow=.22;
wid2=.1;ht2=.05;
uicontrol(hdial,'style','pushbutton','string','Define output folder','units','normalized',...
    'position',[xnow,ynow,3*wid2,ht2],'tooltipstring','Push to define output folder',...
    'callback','enhance(''definewritefolder'');','foregroundcolor','r','fontweight','bold');
ynow=ynow-ht2;
uicontrol(hdial,'style','text','string','Output to: Undefined','units','normalized','tag','folder',...
    'position',[xnow,ynow,.8,ht2],'userdata','Undefined','horizontalalignment','left','foregroundcolor','r','fontweight','bold')

ynow=.1;
uicontrol(hdial,'style','pushbutton','string','Done','units','normalized','tag','done',...
    'position',[xnow,ynow,wid2,ht2],'tooltipstring','Push to begin writing datasets',...
    'callback','enhance(''writemanysegy2'')','backgroundcolor','c');
uicontrol(hdial,'style','pushbutton','string','Cancel','units','normalized','tag','cancel',...
    'position',[xnow+1.5*wid2,ynow,wid2,ht2],'tooltipstring','Push to cancel writing datasets',...
    'callback','enhance(''cancelmultiplewrite'')');
end

function newfileloadpanel(fname,path,dname)
hdial=gcf;
hlp=findobj(hdial,'tag','load_panel');
posl=get(hlp,'position');
hdp=findobj(hdial,'tag','data_panel');
posd=get(hdp,'position');
hmpan=findobj(hdial,'tag','readmanymaster');
udat=get(hmpan,'userdata');
geom=udat{2};
hpanels=udat{1};%the array of existing panels
npanels=length(hpanels)+1;
panelwidth=1;panelheight=1.1*geom(2)/(posl(4)*posd(4));xnow=0;
wid=.99*geom(5);ht=geom(6);xsep=geom(7);ysep=geom(8)/(posl(4)*posd(4));
ynow=1-npanels*(panelheight+ysep);
hpan=uipanel(hdp,'tag',['data_panel' int2str(npanels)],'units','normalized',...
    'position',[xnow ynow panelwidth panelheight],'userdata',npanels);
geom(4)=ynow;
hpanels{npanels}=hpan;
set(hmpan,'userdata',{hpanels geom []});
if(npanels==1)
    inlinedefault='SEGY standard';
    xlinedefault=inlinedefault;
    locs=segybytelocs;
else
    hinline=findobj(hpanels{npanels-1},'tag','inline');
    hxline=findobj(hpanels{npanels-1},'tag','xline');
    inlinedefault=get(hinline,'string');
    xlinedefault=get(hxline,'string');
    locs(2)=get(hxline,'userdata');
    locs(1)=get(hinline,'userdata');
end
%file name
xn=0;yn=.1;
dg=.7*ones(1,3);
ht2=1.1;
uicontrol(hpan,'style','pushbutton','string',fname,'tag','filename','units','normalized',...
    'position',[xn yn wid ht],'horizontalalignment','center','userdata',path,...
    'callback','enhance(''selectnewdataset'');','Tooltipstring',['Path: ' path]);
%separator
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%dataset name
xn=xn+wid+xsep;
uicontrol(hpan,'style','edit','string',dname,'tag','dataname','units','normalized',...
    'position',[xn yn wid ht],'horizontalalignment','center');
%separator
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+wid+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%display button
xn=xn+wid+xsep;
wid2=(1-2.1*wid-7*xsep)/6.1;%nominal width of last six items
uicontrol(hpan,'style','radiobutton','tag','display','units','normalized',...
    'position',[xn+.3*wid2 yn .75*wid2 ht],'value',0,...
    'tooltipstring','If clicked, then this dataset will be displayed after reading.');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%time shift
xn=xn+.75*wid2+xsep;
uicontrol(hpan,'style','edit','string','0.0','units','normalized','position',[xn,yn,.75*wid2,ht],...
    'tooltipstring','Dataum shift for this dataset.','tag','tshift');
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+.75*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%inlineloc button
xn=xn+.75*wid2+xsep;
uicontrol(hpan,'style','pushbutton','string',inlinedefault,'units','normalized','position',...
    [xn,yn,1.25*wid2,ht],'callback','enhance(''choosebyteloc'');','tag','inline',...
    'tooltipstring',['loc= ' int2str(locs(1)) ', Push to change.'],'userdata',locs(1));
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%xlineloc button
xn=xn+1.25*wid2+xsep;
uicontrol(hpan,'style','pushbutton','string',xlinedefault,'units','normalized','position',...
    [xn,yn,1.25*wid2,ht],'callback','enhance(''choosebyteloc'');','tag','xline',...
    'tooltipstring',['loc= ' int2str(locs(2)) ', Push to change.'],'userdata',locs(2));
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%trace headers button
xn=xn+1.25*wid2+xsep;
uicontrol(hpan,'style','pushbutton','string','Trace headers','units','normalized','position',...
    [xn,yn,1.25*wid2,ht],'callback','enhance(''showtraceheaders'');','tag','traceheaders',...
    'tooltipstring','Show first # trace headers.','userdata',[]);
uicontrol(hpan,'style','text','string','','units','normalized','position',...
    [xn+1.25*wid2+.25*xsep yn .5*xsep ht2],'backgroundcolor',dg);
%trace inspector button
xn=xn+1.25*wid2+xsep;
uicontrol(hpan,'style','pushbutton','string','Trace inspector','units','normalized','position',...
    [xn,yn,1.25*wid2,ht],'callback','enhance(''starttraceinspector'');',...
    'tag','traceheaders','tooltipstring','Inspect traces','userdata',[]);
if(npanels>8)
    %scroll the window
    hslider=findobj(hdial,'tag','slider');
    sliderval=get(hslider,'value');
    sliderval=sliderval-.04;
    set(hslider,'value',sliderval);
    set(hdp,'position',[0 -3*sliderval 1 4]);
end
end

function parmset=parmsetfilter(parmset)
% With no input: returns a filter parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function enhancetask (below) for more detail.

if(nargin<1)
    nparms=5;
    parmset=cell(1,3*nparms+1);
    parmset{1}='filter';
    parmset{2}='fmin';
    parmset{3}='10';
    parmset{4}='Define low-cut frequency in Hz';
    parmset{5}='dfmin';
    parmset{6}='5';
    parmset{7}='Define low-end rolloff in Hz (use .5*fmin if uncertain)';
    parmset{8}='fmax';
    parmset{9}='100';
    parmset{10}='Define high-cut frequency in Hz';
    parmset{11}='dfmax';
    parmset{12}='10';
    parmset{13}='Define high-end rolloff in Hz (use 10 or 20 if uncertain)';
    parmset{14}='phase';
    parmset{15}={'zero' 'minimum' 1};
    parmset{16}='Choose zero or minimum phase';
else
   fmin=str2double(parmset{3});
   dfmin=str2double(parmset{6});
   fmax=str2double(parmset{9});
   dfmax=str2double(parmset{12});
   msg=[];
   if(isnan(fmin) || isnan(fmax) || isnan(dfmin) || isnan(dfmax))
       msg='Parameters must be numbers';
   else
       if(fmin<0)
           msg=[msg '; fmin cannot be negative'];
       end
       if(dfmin<0)
           msg=[msg '; dfmin cannot be negative'];
       end
       if(dfmin>fmin)
           msg=[msg '; dfmin cannot be greater than fmin'];
       end
       if(fmax<0)
           msg=[msg '; fmax cannot be negative'];
       end
       if(dfmax>250-fmax)%bad practice but I've hardwired the Nyquist for 2 mils. I'm a baaaad boy
           msg=[msg '; dfmax is too large'];
       end
       if(fmax<fmin)
           if(fmax~=0)
               msg=[msg '; fmax must be greater than fmin'];
           end
       end
   end
   if(~isempty(msg))
        if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetdecon(parmset,t)
% With no input: returns a filter parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function enhancetask (below) for more detail.

if(nargin<1)
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    t=proj.tcoord{1};
    nparms=9;
    parmset=cell(1,3*nparms+1);
    parmset{1}='decon';
    parmset{2}='oplen';
    parmset{3}='0.1';
    parmset{4}='Decon operator length in seconds';
    parmset{5}='stab';
    parmset{6}='0.001';
    parmset{7}='Stability constant, between 0 and 1';
    parmset{8}='topgate';
    parmset{9}=time2str(t(1)+.25*(t(end)-t(1)));
    parmset{10}='top of design gate (seconds)';
    parmset{11}='botgate';
    parmset{12}=time2str(t(1)+.75*(t(end)-t(1)));
    parmset{13}='bottom of design gate (seconds)';
    parmset{14}='fmin';
    parmset{15}='5';
    parmset{16}='Post-decon filter low-cut frequency in Hz';
    parmset{17}='dfmin';
    parmset{18}='2.5';
    parmset{19}='Define low-end rolloff in Hz (use .5*fmin if uncertain)';
    parmset{20}='fmax';
    parmset{21}='100';
    parmset{22}='Post-decon filter high-cut frequency in Hz';
    parmset{23}='dfmax';
    parmset{24}='10';
    parmset{25}='Define high-end rolloff in Hz (use 10 or 20 if uncertain)';
    parmset{26}='phase';
    parmset{27}={'zero' 'minimum' 1};
    parmset{28}='Post-decon filter: Choose zero or minimum phase';
else
   oplen=str2double(parmset{3});
   stab=str2double(parmset{6});
   topgate=str2double(parmset{9});
   botgate=str2double(parmset{12});
   fmin=str2double(parmset{15});
   dfmin=str2double(parmset{18});
   fmax=str2double(parmset{21});
   dfmax=str2double(parmset{24});
   msg=[];
   if(isnan(fmin) || isnan(fmax) || isnan(dfmin) || isnan(dfmax) || isnan(oplen) ||isnan(stab)...
           || isnan(topgate) || isnan(botgate))
       msg='Parameters must be numbers';
   else
       if(oplen<0)
           msg=[msg '; oplen cannot be negative'];
       end
       if(oplen>1)
           msg=[msg '; oplen must be less than 1 (second)'];
       end
       if(stab<0)
           msg=[msg '; stab cannot be negative'];
       end
       if(stab>1)
           msg=[msg '; stab must be less than 1'];
       end
       if(topgate<t(1))
           msg=[msg ['; topgate must be greater than ' time2str(t(1)) 's']];
       end
       if(topgate>t(end))
           msg=[msg ['; topgate must be less than ' time2str(t(end)) 's']];
       end
       if(botgate<topgate)
           msg=[msg '; botgate must be greater than topgate' ];
       end
       if(botgate>t(end))
           msg=[msg ['; botgate must be less than ' time2str(t(end)) 's']];
       end
       if(fmin<0)
           msg=[msg '; fmin cannot be negative'];
       end
       if(dfmin<0)
           msg=[msg '; dfmin cannot be negative'];
       end
       if(dfmin>fmin)
           msg=[msg '; dfmin cannot be greater than fmin'];
       end
       if(fmax<0)
           msg=[msg '; fmax cannot be negative'];
       end
       if(dfmax>250-fmax)%bad practice but I've hardwired the Nyqiost for 2 mils
           msg=[msg '; dfmax is too large'];
       end
       if(fmax<fmin)
           if(fmax~=0)
               msg=[msg '; fmax must be greater than fmin'];
           end
       end
   end
   if(~isempty(msg))
       if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetwavenumber(parmset)
% With no input: returns a filter parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)

if(nargin<1)
    nparms=2;
    parmset=cell(1,3*nparms+1);
    parmset{1}='wavenumber lowpass';
    parmset{2}='sigmax';
    parmset{3}='0.125';
    parmset{4}='Define high-cut crossline wavenumber as a fraction of Nyquist';
    parmset{5}='sigmay';
    parmset{6}='0.125';
    parmset{7}='Define high-cut inline wavenumber as a fraction of Nyquist';
else
   sigmax=str2double(parmset{3});
   sigmay=str2double(parmset{6});
   msg=[];
   if(isnan(sigmax) || isnan(sigmay) )
       msg='Parameters must be numbers';
   else
       if(sigmax<0)
           msg=[msg '; sigmax cannot be negative'];
       end
       if(sigmax>1)
           msg=[msg '; sigmax cannot be greater than 1'];
       end
       if(sigmay<0)
           msg=[msg '; sigmay cannot be negative'];
       end
       if(sigmay>1)
           msg=[msg '; sigmay cannot be greater than 1'];
       end
   end
   if(~isempty(msg))
        if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetfdom(parmset,t)
% With no input: returns a fdom parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function enhancetask (below) for more detail.

if(nargin<1)
    nparms=4;
    parmset=cell(1,3*nparms+1);
    parmset{1}='Dominant Frequency';
    parmset{2}='twin';
    parmset{3}='0.01';
    parmset{4}='Gaussian window half-width in seconds';
    parmset{5}='ninc';
    parmset{6}='2';
    parmset{7}='Increment between adjacent windows as an integer times the sample rate';
    parmset{8}='Fmax';
    parmset{9}='100';
    parmset{10}='Define high-cut frequency in Hz';
    parmset{11}='tfmax';
    parmset{12}='';
    parmset{13}='Time (seconds) at which Fmax occurs, leave blank if time invariant';
else
   twin=str2double(parmset{3});
   ninc=str2double(parmset{6});
   fmax=str2double(parmset{9});
   tfmax=str2double(parmset{12});
   msg=[];
   if(isnan(twin) || isnan(ninc) || isnan(fmax) )
       msg='Parameters must be numbers';
   else
       trange=t(end)-t(1);
       dt=t(2)-t(1);
       tinc=ninc*dt;
       if(twin<0)
           msg=[msg '; twin cannot be negative'];
       end
       if(twin>.1*trange)
           msg=[msg '; twin is too large'];
       end
       if(tinc<0)
           msg=[msg '; tinc=ninc*dt cannot be negative'];
       end
       if(tinc>twin)
           msg=[msg '; tinc=ninc*dt cannot be greater than twin'];
       end
       if(fmax<0)
           msg=[msg '; fmax cannot be negative'];
       end
       fnyq=.5/dt;
       if(fmax>fnyq)
           msg=[msg '; fmax is too large'];
       end
       if(isnan(tfmax))
           tfmax=[];
       end
       if(tfmax<0)
           msg=[msg '; tfmax cannot be negative'];
       end
       if(tfmax>t(end))
           msg=[msg '; tfmax too large'];
       end
   end
   if(~isempty(msg))
        if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetspecdecomp(parmset,t)
% With no input: returns a specdecomp parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function enhancetask (below) for more detail.

if(nargin<1)
    %invent a fake t
    %t=0:.002:3;
    nparms=7;
    parmset=cell(1,3*nparms+1);
    parmset{1}='specdecomp';
    parmset{2}='Twin';
    parmset{3}='.01';
    parmset{4}='Half-width of Gaussian window (in seconds)';
    parmset{5}='Ninc';
    parmset{6}='2';
    parmset{7}='Increment between window centers, expressed in samples';
    parmset{8}='Tmin';
    %parmset{9}=num2str(t(1));
    parmset{9}='t(1)';
    parmset{10}='Start of time window, in seconds. t(1) means first sample.';
    parmset{11}='Tmax';
    %parmset{12}=num2str(t(end));
    parmset{12}='t(end)';
    parmset{13}='End of time window, in seconds. t(end) means last sample.';
    parmset{14}='Fmin';
    parmset{15}='10';
    parmset{16}='Minimum Output frequency in Hertz.';
    parmset{17}='Fmax';
    parmset{18}='70';
    parmset{19}='Maximum Output frequency in Hertz.';
    parmset{20}='delF';
    parmset{21}='30';
    parmset{22}='Frequency increment in Hertz.';
else
   twin=str2double(parmset{3});
   Ninc=str2double(parmset{6});
   val=parmset{9};
   if(strcmp(val,'t(1)'))
       tmin=t(1);
       parmset{9}=num2str(tmin);
   else
       tmin=str2double(val);
   end
   val=parmset{12};
   if(strcmp(val,'t(end)'))
       tmax=t(end);
       parmset{12}=num2str(tmax);
   else
       tmax=str2double(val);
   end
%    tmp1=sscanf(parmset{15}{1},'%g');%space separated read
%    tmp2=sscanf(parmset{15}{1},'%g,');%comma separated read
%    if(length(tmp1)>length(tmp2))
%        fout=tmp1;
%    else
%        fout=tmp2;
%    end
   fmin=str2double(parmset{15});
   fmax=str2double(parmset{18});
   delf=str2double(parmset{21});
   msg=[];
   if(isnan(twin) || isnan(Ninc) || isnan(tmin) || isnan(tmax) || isnan(fmin) || isnan(fmax) || isnan(delf) )
       msg='Parameters must be numbers';
   else
       if(twin<0)
           msg=[msg '; Twin cannot be negative'];
       end
       if(twin> .1*(t(end)-t(1)))
           msg=[msg '; Twin too large'];
       end
       if(Ninc<=0)
           msg=[msg '; Ninc must be positive'];
       end
       dt=t(2)-t(1);
       if(Ninc*dt>twin)
           msg=[msg '; Ninc too large (Ninc*dt must be less than Twin'];
       end
       if(tmin<0)
           msg=[msg '; Tmin cannot be negative'];
       end
       if(tmin>tmax)
           msg=[msg '; Tmin cannot be greater than Tmax'];
       end
       if(tmax<0)
           msg=[msg '; Tmax cannot be negative'];
       end
       if(tmax<tmin)
           msg=[msg '; Tmax cannot be less than Tmin'];
       end
       fnyq=.5/dt;
       %        if(any(fout<0))
       %            msg=[msg '; Fout cannot have negative entries'];
       %        end
       %        if(any(fout>fnyq))
       %            msg=[msg ['; Fout cannot have values greater than Nyquist=' num2str(fnyq) 'Hz']];
       %        end
       if(fmin<0)
           msg=[msg '; Fmin cannot be negative'];
       end
       if(fmin>fnyq)
           msg=[msg '; Fmin cannot be greater than Nyquist'];
       end
       if(fmax<0)
           msg=[msg '; Fmax cannot be negative'];
       end
       if(fmax>fnyq)
           msg=[msg '; Fmax cannot be greater than Nyquist'];
       end
       if(fmax<0)
           msg=[msg '; Fmax cannot be less than Fmin'];
       end
       if(delf<0)
           msg=[msg '; delF cannot be negative'];
       end
       test=fmin:delf:fmax;
       if(isempty(test))
           msg=[msg '; Fmin:delF:Fmax is empty'];
       end
   end
   if(~isempty(msg))
       if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetgabordecon(parmset,t)
% With no input: returns a gabordecon parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function enhancetask (below) for more detail.

if(nargin<1)

    nparms=7;
    parmset=cell(1,3*nparms+1);
    parmset{1}='gabordecon';
    parmset{2}='Twin';
    parmset{3}='.2';
    parmset{4}='Half-width of Gaussian window (seconds)';
    parmset{5}='Tinc';
    parmset{6}='.1';
    parmset{7}='Increment between window centers (seconds)';
    parmset{8}='Tsmo';
    parmset{9}=num2str(1);
    parmset{10}='Length of temporal smoother (seconds)';
    parmset{11}='Fsmo';
    parmset{12}=num2str(10);
    parmset{13}='Length of frequency smoother (Hertz)';
    parmset{14}='Stab';
    parmset{15}='0.00001';
    parmset{16}='White noise constant (dimensionless)';
    parmset{17}='Smoother';
    parmset{18}={'boxcar' 'hyperbolic' 2};
    parmset{19}='Choose hyperbolc or boxcar';
    parmset{20}='Gabor_phase';
    parmset{21}={'zero' 'minimum' 1};
    parmset{22}='Choose zero or minimum phase';
    parmset{23}='Fmin';
    parmset{24}='5';
    parmset{25}='Low-cut for post decon filter (Hz)';
    parmset{26}='Fmax';
    parmset{27}='100';
    parmset{28}='High-cut for post decon filter (Hz)';
    parmset{29}='dFmin';
    parmset{30}='2.5';
    parmset{31}='Filter edge width on low end (Hz)';
    parmset{32}='dFmax';
    parmset{33}='10';
    parmset{34}='Filter edge width on high end (Hz)';
    parmset{35}='T1';
    parmset{36}='1';
    parmset{37}='Time of filter spec -leave blank for stationary (seconds)';
    parmset{38}='Fmaxmax';
    parmset{39}='120';
    parmset{40}='Maximum allowed value for Fmax -nonstationary only (Hz)';
    parmset{41}='Fmaxmin';
    parmset{42}='50';
    parmset{43}='Minimum allowed value for Fmax -nonstationary only (Hz)';
    parmset{44}='Tmax';
    parmset{45}={'all'};
    parmset{46}='Maximum output time (seconds or "all")';
    
else
   twin=str2double(parmset{3});
   tinc=str2double(parmset{6});
   tsmo=str2double(parmset{9});
   fsmo=str2double(parmset{12});
   stab=str2double(parmset{15});
   fmin=str2double(parmset{24});
   fmax=str2double(parmset{27});
   dfmin=str2double(parmset{30});
   dfmax=str2double(parmset{33});
   val=parmset{36};
   if(isempty(val))
       t1=-1;%flag for stationary
   else
       t1=str2double(val);
   end
   fmaxmax=str2double(parmset{39});
   fmaxmin=str2double(parmset{42});
   val=parmset{45};
   if(isempty(val) || strcmp(val,'all'))
       tmax=t(end);%flag for stationary
       parmset{45}=num2str(tmax);
   else
       tmax=str2double(val);
   end
   msg=[];
   if(isnan(twin) || isnan(tinc) || isnan(tsmo) || isnan(fsmo) || isnan(stab) || isnan(fmin) || isnan(fmax) ...
      || isnan(dfmin) || isnan(dfmax) || isnan(t1) || isnan(fmaxmax) || isnan(fmaxmin) || isnan(tmax))
       msg='Parameters must be numbers';
   else
       dt=t(2)-t(1);
       fnyq=.5/dt;
       if(twin<0)
           msg=[msg '; Twin cannot be negative'];
       end
       if(twin> .5*(t(end)-t(1)))
           msg=[msg '; Twin too large'];
       end
       if(tinc<=0)
           msg=[msg '; Tinc must be positive'];
       end
       
       if(tinc>twin)
           msg=[msg '; Tinc too large (must be less than Twin)'];
       end
       if(tsmo<0)
           msg=[msg '; Tsmo cannot be negative'];
       end
       if(tsmo>t(end))
           msg=[msg '; Tsmo too large'];
       end
       if(fsmo<0)
           msg=[msg '; Fsmo cannot be negative'];
       end
       if(fsmo>.5*fnyq)
           msg=[msg '; Fsmo too large'];
       end
       if(stab<0 || stab>1)
           msg=[msg '; Bad value for Stab'];
       end
       if(fmin<0)
           msg=[msg '; Fmin cannot be negative'];
       end
       if(fmin>fmax ||fmin>fnyq)
           msg=[msg '; bad value for Fmin'];
       end
       if(fmax<0)
           msg=[msg '; Fmax cannot be negative'];
       end
       if(fmin>fmax ||fmax>fnyq)
           msg=[msg '; bad value for Fmax'];
       end
       if(dfmin<0)
           msg=[msg '; dFmin cannot be negative'];
       end
       if(dfmin>fmin )
           msg=[msg '; bad value for dFmin'];
       end
       if(dfmax<0)
           msg=[msg '; dFmax cannot be negative'];
       end
       if(dfmax>(fnyq-fmax))
           msg=[msg '; bad value for dFmax'];
       end
       if(t1<0 && t1~=-1)
           msg=[msg '; bad value for T1'];
       end
       if(t1>tmax)
           msg=[msg '; T1 too large'];
       end
       if(fmaxmax<0)
           msg=[msg '; Fmaxmax cannot be negative'];
       end
       if(fmaxmax<fmax )
           msg=[msg '; bad value for Fmaxmax'];
       end
       if(fmaxmin<0)
           msg=[msg '; Fmaxmin cannot be negative'];
       end
       if(fmaxmin<fmin+10 )
           msg=[msg '; Fmaxmin must be greater than Fmin+10'];
       end
       if(tmax<0)
           msg=[msg '; Tmax cannot be negative'];
       end
       if(tmax>t(end) )
           msg=[msg '; bad value for Tmax'];
       end
   end
   if(~isempty(msg))
       if(msg(1)==';')
           msg(1)='';
       end
       parmset=msg;
   end
end
end

function parmset=parmsetsvdsep(parmset)
% With no input: returns a svdsep parmset with default parameters
% With input parmset: checks the parmset for validity. Returns it if valid, if invalid returns error
%               message (string)
%
% The parmset is a cell array with a defined structure. It has length 3*nparms+1 where nparms is the
% number of parameters that must be defined for the task and all entries are strings. The first
% entry of the parmset is a string giving the name of the task, for example, 'spikingdecon' or
% 'domfreq' or 'filter'. Then for each of nparms parameters, there are three consequtive values: the
% name of the parameter (a string), the current parameter value (a string), and the tooltipstring.
% The current parameter value can either be a number in a string if the parameter is numeric or a
% string with choices such as 'yes|no'. The tooltipstring should be a hint for the user about the
% parameter and is displayed when the mpouse hovers over the GUI component for that parameter. See
% internal function enhancetask (below) for more detail.

if(nargin<1)

    nparms=34;
    parmset=cell(1,3*nparms+1);
    parmset{1}='svdsep';
    parmset{2}='IdimX';
    parmset{3}='0';
    parmset{4}='0,1,2,3 operation flag for crossline dimension';
    parmset{5}='IdimY';
    parmset{6}='0';
    parmset{7}='0,1,2,3 operation flag for inline dimension';
    parmset{8}='IdimT';
    parmset{9}='0';
    parmset{10}='0,1,2,3 operation flag for time dimension';
    parmset{11}='SingcutX';
    parmset{12}=num2str(10);
    parmset{13}='Singular value cutoff for crossline dimension';
    parmset{14}='SingcutY';
    parmset{15}='10';
    parmset{16}='Singular value cutoff for inline dimension';
    parmset{17}='SingcutT';
    parmset{18}=num2str(10);
    parmset{19}='Singular value cutoff for time dimension';
    parmset{20}='OpgX';
    parmset{21}='1';%1 is pass, 2 is kill, 3 is filter
    parmset{22}='Operation flag (K,P,F) for crossline dimension on Gross';
    parmset{23}='OpgY';
    parmset{24}='1';
    parmset{25}='Operation flag (K,P,F) for inline dimension on Gross';
    parmset{26}='OpgT';
    parmset{27}='1';
    parmset{28}='Operation flag (K,P,F) for time dimension on Gross';
    parmset{29}='OpdX';
    parmset{30}='1';
    parmset{31}='Operation flag (K,P,F) for crossline dimension on Detail';
    parmset{32}='OpdY';
    parmset{33}='1';
    parmset{34}='Operation flag (K,P,F) for inline dimension on Detail';
    parmset{35}='OpdT';
    parmset{36}='1';
    parmset{37}='Operation flag (K,P,F) for time dimension on Detail';
    parmset{38}='FminG';
    parmset{39}='5';
    parmset{40}='Min frequency for TV filter on Gross (Hz)';
    parmset{41}='FmaxG';
    parmset{42}='100';
    parmset{43}='Max frequency for TV filter on Gross (Hz)';
    parmset{44}='TfmaxG';
    parmset{45}='1';
    parmset{46}='Time of FmaxG for time-variant filter';
    parmset{47}='FmaxmaxG';
    parmset{48}='120';
    parmset{49}='Max-max frequency for TV filter on Gross (HZ)';
    parmset{50}='FmaxminG';
    parmset{51}='80';
    parmset{52}='Min-max frequency for TV filter on Gross (HZ)';
    parmset{53}='FminD';
    parmset{54}='5';
    parmset{55}='Min frequency for TV filter on Detail (Hz)';
    parmset{56}='FmaxD';
    parmset{57}='100';
    parmset{58}='Max frequency for TV filter on Detail (Hz)';
    parmset{59}='TfmaxD';
    parmset{60}='1';
    parmset{61}='Time of FmaxD for time-variant filter';
    parmset{62}='FmaxmaxD';
    parmset{63}='120';
    parmset{64}='Max-max frequency for TV filter on Detail (HZ)';
    parmset{65}='FmaxminD';
    parmset{66}='80';
    parmset{67}='Min-max frequency for TV filter on Detail (HZ)';
    parmset{68}='SigmaG';
    parmset{69}='.5';
    parmset{70}='Width of K filter (timeslices) on Gross (fraction of Nyquist)';
    parmset{71}='TsigmaG';
    parmset{72}='1';
    parmset{73}='Time of SigmaG for TV K filter';
    parmset{74}='SigmaGmax';
    parmset{75}='.6';
    parmset{76}='Maximum SigmaG for TV K filter on Gross';
    parmset{77}='SigmaGmin';
    parmset{78}='.4';
    parmset{79}='Minimum SigmaG for TV K filter on Gross';
    parmset{80}='SigmaD';
    parmset{81}='.5';
    parmset{82}='Width of K filter (timeslices) on Detail (fraction of Nyquist)';
    parmset{83}='TsigmaD';
    parmset{84}='1';
    parmset{85}='Time of SigmaD for TV K filter';
    parmset{86}='SigmaDmax';
    parmset{87}='.6';
    parmset{88}='Maximum SigmaD for TV K filter on Detail';
    parmset{89}='SigmaDmin';
    parmset{90}='.4';
    parmset{91}='Minimum SigmaD for TV K filter on Detail';
    parmset{92}='DfminG';
    parmset{93}='2';
    parmset{94}='Filter roll-off on low-end for Gross';
    parmset{95}='DfmaxG';
    parmset{96}='10';
    parmset{97}='Filter roll-off on high-end for Gross';
    parmset{98}='DfminD';
    parmset{99}='2';
    parmset{100}='Filter roll-off on low-end for Detail';
    parmset{101}='DfmaxD';
    parmset{102}='10';
    parmset{103}='Filter roll-off on high-end for Detail';
    
else
   %nothing. The parameter checking for svdsep is done by the dialog svdsep_dialog
end
end

function val=contains(str1,str2)
ind=strfind(str1,str2);
if(isempty(ind))   %#ok<STREMP> 
    val=false;
else
    val=true;
end

end

function enhancetask(datasets,parmset,task,iout)
% 
% This function is called by ENHANCE to initiate a data-processing task on one of its datasets. It puts
% up a dialog window in which the dataset is chosen and the parameters are specified. The first two
% inputs are the list of possible datasets and the parameter set, or parmset. The list of possible
% datasets is just a cell array of strings. The parmset is also a cell array but with a defined
% structure. It has length 3*nparms+1 where nparms is the number of parameters that must be defined
% for the task and all entries are strings. The first entry of the parmset is a string giving the
% name of the task, for example, 'spikingdecon' or 'domfreq' or 'filter'. Then for each of nparms
% parameters, there are three consequtive values: the name of the parameter (a string), the current
% parameter value (a string), and the tooltipstring. The current parameter value can either be a
% number in a string if the parameter is numeric or a string with choices such as 'yes|no'.
% 
% datasets ... cell array of dataset names
% parmset ... parameter set for the task
% task ... string giving the internal name of the task. This comes from the tag of the
%       corresponding menu
% iout ... vector of length 4, either 1 or 0, saying which output options are available. The 4
%       options are 'Save SEGY and display','Replace input in project','Save in project as new'
% *********** default = ones(1,4) ***************
% 

if(nargin<4)
    iout=ones(1,4);
end

henhance=gcf;
hmsg=findobj(henhance,'tag','message');
taskname=parmset{1};

set(hmsg,'string',['Please complete parameter specifications in dialog window for task ' taskname])
% set(htask,'name',['ENHANCE: Computation task ' task]);
pos=get(henhance,'position');
% wid=figsize(1)*pos(3);
% ht=figsize(2)*pos(4);
nparms=(length(parmset)-1)/3;
fwid=500;%width in pixels of figure
ht=30;%height of a single item in pixels
ysep=5;%y separation in pixels
xsep=5;
fht=(nparms+5)*(ht+ysep);%fig ht in pixels
%make upper left corners same
xul=pos(1);
yul=pos(2)+pos(4);
yll=yul-fht;
htask=figure('toolbar','none','menubar','none','numbertitle','off','position',[xul yll fwid fht]);
WinOnTop(htask,true);
set(htask,'name',['ENHANCE: ' taskname ' dialog'],'closerequestfcn','enhance(''canceltask'')');
xnot=.1*fwid;ynot=fht-2*ht;
xnow=xnot;ynow=ynot;
wid=fwid*.8;
uicontrol(htask,'style','text','string',['Computation task: ' taskname],'units','pixels',...
    'position',[xnow ynow wid ht],'tag','task','userdata',{task parmset},'fontsize',12,'fontweight','bold');
ynow=ynow-ht-ysep;
wid=fwid*.2;
uicontrol(htask,'style','text','string','Input dataset>>','units','pixels',...
    'position',[xnow ynow wid ht]);
xnow=xnow+wid+xsep;
wid=fwid*.6;
uicontrol(htask,'style','popupmenu','string',datasets,'units','pixels','tag','datasets',...
    'position',[xnow ynow wid ht],'tooltipstring','Choose the input dataset');

ynow=ynow-ht-ysep;
wid=fwid*.2;
xnow=xnot;
uicontrol(htask,'style','text','string','Output dataset>>','units','pixels',...
    'position',[xnow ynow wid ht]);
xnow=xnow+wid+xsep;
wid=fwid*.3;
outopts={'Save SEGY','Save SEGY and display','Replace input in project','Save in project as new'};
uicontrol(htask,'style','popupmenu','string',outopts(logical(iout)),'units','pixels','tag','outputs',...
    'position',[xnow ynow wid ht],'tooltipstring','Choose the output option','value',sum(iout));

for k=1:nparms
    xnow=xnot;
    ynow=ynow-ht-ysep;
    wid=.2*fwid;
    uicontrol(htask,'style','text','string',parmset{3*(k-1)+2},'units','pixels','position',...
        [xnow,ynow,wid,ht],'fontsize',12);
    xnow=xnow+wid+xsep;
    wid=.5*fwid;
    parm=parmset{3*(k-1)+3};
    if(~iscell(parm))
        uicontrol(htask,'style','edit','string',parm,'units','pixels','position',...
            [xnow,ynow,wid,ht],'tooltipstring',parmset{3*(k-1)+4},'tag',parmset{3*(k-1)+2},...
            'fontsize',12,'userdata',0);
    else
        if(length(parm)==1)
            %this happens when the parm is a single word like 'all'
            uicontrol(htask,'style','edit','string',parm{1},'units','pixels','position',...
                [xnow,ynow,wid,ht],'tooltipstring',parmset{3*(k-1)+4},'tag',parmset{3*(k-1)+2},...
                'fontsize',12,'userdata',1);
            %userdata here is a flag saying repackage as string in cell
        else
            uicontrol(htask,'style','popupmenu','string',parm(1:end-1),'units','pixels','position',...
                [xnow,ynow,wid,ht],'tooltipstring',parmset{3*(k-1)+4},'tag',parmset{3*(k-1)+2},...
                'value',parm{end},'fontsize',12,'userdata',0);
        end
    end
end

%done and cancel buttons

xnow=.25*fwid;
wid=.3*fwid;
ynow=ynow-ht-ysep;
uicontrol(htask,'style','pushbutton','string','Done','units','pixels','tag','done',...
    'position',[xnow,ynow,wid,ht],'tooltipstring','Click to initiate the Task',...
    'callback','enhance(''dotask'')');

xnow=xnow+wid+xsep;
uicontrol(htask,'style','pushbutton','string','Cancel','units','pixels','tag','cancel',...
    'position',[xnow,ynow,wid,ht],'tooltipstring','Click to cancel the Task',...
    'callback','enhance(''canceltask'')');

set(htask,'userdata',{[],henhance});%first space is in case the dialog evovles to launch secondary figures

end

function hstry=parmset2history(parmset)
% convert a parmset into a cell array of strings suitable for the history label
nparms=(length(parmset)-1)/3;
hstry=cell(1,nparms+1);
hstry{1}=[parmset{1} ', parameter list'];
for k=1:nparms
    if(~iscell(parmset{3*(k-1)+3}))
        hstry{k+1}=[parmset{3*(k-1)+2} ' ' parmset{3*(k-1)+3} ' (' parmset{3*(k-1)+4} ')'];
    else
        parm=parmset{3*(k-1)+3};
        if(length(parm)==1)
            hstry{k+1}=[parmset{3*(k-1)+2} ' ' parm{1} ' (' parmset{3*(k-1)+4} ')'];
        else
            val=parm{end};
            choices=parm(1:end-1);
            hstry{k+1}=[parmset{3*(k-1)+2} ' ' choices{val} ' (' parmset{3*(k-1)+4} ')'];
        end
    end
end
end

function parmset=getparmset(task)
henhance=findenhancefig;
hfile=findobj(henhance,'tag','file');
proj=hfile.UserData;
if(isfield(proj,'parmsets'))
    parmsets=proj.parmsets;
else
    parmsets=[];
end
%parmset=[];
idelete=[];
for k=1:length(parmsets)
   thisparmset=parmsets{k};
   if(strcmp(thisparmset{1},task))
       %check for an old specdecomp parmset
       if(strcmp(task,'specdecomp'))
           %test for old parmset
           test=getparm(thisparmset,'Fout');
           if(~isempty(test))
               %delete the old parmset, this forces a new default parmset
               idelete=k;
           else
               parmset=thisparmset;
               return;
           end
       else
           parmset=thisparmset;
           return;
       end
   end
end
if(~isempty(idelete))
    proj.parmsets(idelete)=[];
    set(hfile,'userdata',proj);
end
%if we reach here then there is no stored parmset so we get the default one
switch task
    case 'filter'
        parmset=parmsetfilter;
    case 'spikingdecon'
        parmset=parmsetdecon;
    case 'phasemap'
        parmset=parmsetphasemap;
    case 'fdom'
        parmset=parmsetfdom;
    case 'wavenumber'
        parmset=parmsetwavenumber;
    case 'specdecomp'
        parmset=parmsetspecdecomp;
    case 'gabordecon'
        parmset=parmsetgabordecon;
    case 'svdsep'
        parmset=parmsetsvdsep;
end
return

end

function setparmset(parmset)
henhance=findenhancefig;
hfile=findobj(henhance,'tag','file');
proj=hfile.UserData;
if(isfield(proj,'parmsets'))
    parmsets=proj.parmsets;
    task=parmset{1};
    done=false;
    for k=1:length(parmsets)
        thisparmset=parmsets{k};
        if(strcmp(thisparmset{1},task))
            parmsets{k}=parmset;
            done=true;
            break;
        end
    end
    if(~done)
        parmsets{length(parmsets)+1}=parmset;
    end
    proj.parmsets=parmsets;
else
    proj.parmsets={parmset};
end
set(hfile,'userdata',proj);
end

function val=getparm(parmset,parm)
    nparms=(length(parmset)-1)/3;
    val=[];
    for k=1:nparms
        if(strcmp(parm,parmset{3*(k-1)+2}))
            parmdat=parmset{3*(k-1)+3};
            if(~iscell(parmdat))
                val=str2double(parmdat);
            else
                if(length(parmdat)==1)
                    tmp1=sscanf(parmset{15}{1},'%g');%space separated read
                    tmp2=sscanf(parmset{15}{1},'%g,');%comma separated read
                    if(length(tmp1)>length(tmp2))
                        val=tmp1;
                    else
                        val=tmp2;
                    end
                else
                    val=parmdat{parmdat{end}};
                end
            end
        end
    end
end

function memorybuttonoff(idat)
%set the memory button off on the datapanel for dataset #idat
henhance=findenhancefig;
hmpan=findobj(henhance,'tag','master_panel');
udat=get(hmpan,'userdata');
hdatapans=udat{1};
hpan=hdatapans{idat};
hno=findobj(hpan,'tag','memoryno');
hyes=findobj(hpan,'tag','memoryyes');
set(hno,'value',1)
set(hyes,'value',0)
end

function memorybuttonon(idat)
%set the memory button off on the datapanel for dataset #idat
henhance=findenhancefig;
hmpan=findobj(henhance,'tag','master_panel');
udat=get(hmpan,'userdata');
hdatapans=udat{1};
hpan=hdatapans{idat};
hno=findobj(hpan,'tag','memoryno');
hyes=findobj(hpan,'tag','memoryyes');
set(hno,'value',0)
set(hyes,'value',1)
end

function locs=canadabytelocs
locs=[9,13];
end

function locs=kingdombytelocs
locs=[17,25];
end

function locs=segybytelocs
locs=[189,193];
end

function sgrv=getsegyrev(idata,henhance)
%this is needed because of inconsistencies in the project structure definition
if(nargin<2)
    henhance=findenhancefig;
end
hfile=findobj(henhance,'label','File');
proj=get(hfile,'userdata');
sgrv=1;
if(iscell(proj.segyrev))
    tmp=proj.segyrev{:};
    if(length(tmp)<=idata)
        sgrv=tmp(idata);
    end
else
    if(length(proj.segyrev)<=idata)
        sgrv=proj.segyrev(idata);
    end
end

end

function hppt=addpptbutton(pos)
hppt=uicontrol(gcf,'style','pushbutton','string','PPT','tag','ppt','units','normalized',...
    'position',pos,'backgroundcolor','y','callback','enhance(''makepptslide'');');
%the title string for the slide will be stored as userdata
end

function s=datasetsize(idata)
%if idata is provided then we return the size of that dataset, otherwise we return the size of all
%of the datasets in the projects.
if(nargin<1)
    idata=0;
end
henhance=findenhancefig;
hfile=findobj(henhance,'tag','file');
proj=get(hfile,'userdata');
if(idata==0)
    %we determine the total size in bytes of all of the datasets in the project
    ndatasets=length(proj.datanames);
    s=0;
    for k=1:ndatasets
        s=s+length(proj.xcoord{k})*length(proj.ycoord{k})*length(proj.tcoord{k})*4;
    end
else
    ndatasets=length(proj.datanames);
    if(idata>ndatasets)
        error('ENHANCE: attempt to access unknown dataset')
    end
    s=length(proj.xcoord{idata})*length(proj.ycoord{idata})*length(proj.tcoord{idata})*4;
end
end

function enhance_slider(src,eventdata,arg1) %#ok<INUSL>
val = get(src,'Value');
set(arg1,'Position',[0 -3*val 1 4])

end

function svdsep_dialog(arg1,arg2,arg3)
%upon completion, the parmset will be in the user data of the done button. If cancel was pressed, then
%the userdata will be empty. 
if(~isgraphics(arg1))
    action='init';
    parmset=arg1;
    transfer=arg2;
else
    action=arg3;
end
if(strcmp(action,'init'))
    task='svdsep';
    henhance=findenhancefig;
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    pos=get(henhance,'position');
    figwidth=.75*pos(3);
    figheight=pos(4)*1;
    %keep upper left corner constant
    ulx=pos(1);
    uly=pos(2)+pos(4);
    x1=ulx;
    y1=uly-figheight;
    %for compatibility with the "enhancetask" dialog, the userdata of the figure 
    hdial=figure('position',[x1 y1 figwidth figheight],'menubar','none','toolbar','none','numbertitle','off',...
        'name','SVD separation: Parameter Dialog','userdata',{task,henhance},'tag','dialog',...
        'closerequestfcn',{@svdsep_dialog,'done'});
    WinOnTop(hdial,true);
    ht=.075;
    wid=.15;
    xnot=.05;
    ynot=.05;
    xnow=xnot;
    ynow=1-ynot-ht;
    ysep=.01;
    xsep=.01;
    uicontrol(hdial,'style','text','string','Computation task: svdsep','units','normalized',...
        'position',[.5-wid,ynow,2*wid,ht],'userdata',{task,parmset},'tag','task','fontsize',12,...
        'fontweight','bold');
    ynow=ynow-.5*ht;
    idata=1;
    t=proj.tcoord{idata'};
    uicontrol(hdial,'style','text','string','Input dataset>>','units','normalized','position',...
        [xnow,ynow,wid,ht]);
    xnow=xnow+wid;
    uicontrol(hdial,'style','popupmenu','string',proj.datanames,'units','normalized','position',...
        [xnow,ynow,5*wid,ht],'value',idata,'callback',{@svdsep_dialog,'datachoice'},...
        'userdata',t,'tag','datasets');
    ynow=ynow-.5*ht-ysep;
    xnow=xnot;
    uicontrol(hdial,'style','text','string','Output dataset>>','units','normalized','position',...
        [xnow,ynow,wid,ht]);
    xnow=xnow+wid;
    outops={'Save SEGY','Save SEGY and display','Replace input in project','Save in project as new'};
    uicontrol(hdial,'style','popupmenu','string',outops,'units','normalized','position',...
        [xnow,ynow,1.5*wid,ht],'value',4,'tag','outputs');
    ynow=ynow-ht-ysep;
    xnow=xnot+wid+xsep;
    uicontrol(hdial,'style','text','string','Crossline (X)','units','normalized','position',...
        [xnow,ynow,wid,ht]);
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','text','string','Inline (Y)','units','normalized','position',...
        [xnow,ynow,wid,ht]);
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','text','string','Time (T)','units','normalized','position',...
        [xnow,ynow,wid,ht]);
    ynow=ynow-.4*ht-ysep;
    xnow=xnot;
    ynudge=.1*ht;
    uicontrol(hdial,'style','text','string','Dimension flags:','units','normalized','position',...
        [xnow,ynow-ynudge,wid,ht],'tooltipstring','0->no operation, 1->first op, 2->second op, 3->third op',...
        'horizontalalignment','left');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'0','1','2','3'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'IdimX')+1,'callback',{@svdsep_dialog,'dimchoice'},'tag','xdim',...
        'tooltipstring','Crossline dimension: 0->no operation, 1->first op ,2->second op, 3->third op');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'0','1','2','3'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'IdimY')+1,'callback',{@svdsep_dialog,'dimchoice'},'tag','ydim',...
        'tooltipstring','Inline dimension: 0->no operation, 1->first op, 2->second op, 3->third op');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'0','1','2','3'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'IdimT')+1,'callback',{@svdsep_dialog,'dimchoice'},'tag','tdim',...
        'tooltipstring','Time dimension: 0->no operation, 1->first op, 2->second op, 3->third op');
    xnow=xnot;
    ynow=ynow-.6*ht-ysep;
    uicontrol(hdial,'style','text','string','Singcut values:','units','normalized','position',...
        [xnow,ynow,wid,ht],'tooltipstring','Cutoff singular value for each dimension',...
        'horizontalalignment','left');
    xnow=xnow+wid+xsep;
    yn=.6*ht;
    uicontrol(hdial,'style','edit','string',int2str(getparm(parmset,'SingcutX')),'units','normalized',...
        'position',[xnow,ynow+yn,wid,.5*ht],'tag','xcut',...
        'tooltipstring','Crossline dimension: cutoff singular value');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','edit','string',int2str(getparm(parmset,'SingcutY')),'units','normalized',...
        'position',[xnow,ynow+yn,wid,.5*ht],'tag','ycut',...
        'tooltipstring','Inline dimension: cutoff singular value');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','edit','string',int2str(getparm(parmset,'SingcutT')),'units','normalized',...
        'position',[xnow,ynow+yn,wid,.5*ht],'tag','tcut',...
        'tooltipstring','Time dimension: cutoff singular value');
    xnow=xnot;
    ynow=ynow-.5*ht-ysep;
    uicontrol(hdial,'style','text','string','Operation on Gross:','units','normalized','position',...
        [xnow,ynow-ynudge,wid,ht],'tooltipstring','choose pass, kill, or filter',...
        'horizontalalignment','left');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'pass','kill','filter'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'OpgX'),'tag','opgx',...
        'tooltipstring','Crossline dimension: choose pass, kill, or filter','callback',{@svdsep_dialog,'opchoice'});
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'pass','kill','filter'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'OpgY'),'tag','opgy',...
        'tooltipstring','Inline dimension: choose pass, kill, or filter','callback',{@svdsep_dialog,'opchoice'});
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'pass','kill','filter'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'OpgT'),'tag','opgt',...
        'tooltipstring','Time dimension: choose pass, kill, or filter','callback',{@svdsep_dialog,'opchoice'});
    xnow=xnot;
    ynow=ynow-.5*ht-ysep;
    uicontrol(hdial,'style','text','string','Operation on Detail:','units','normalized','position',...
        [xnow,ynow-ynudge,wid,ht],'tooltipstring','choose pass, kill, or filter',...
        'horizontalalignment','left');
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'pass','kill','filter'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'OpdX'),'tag','opdx',...
        'tooltipstring','Crossline dimension: choose pass, kill, or filter','callback',{@svdsep_dialog,'opchoice'});
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'pass','kill','filter'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'OpdY'),'tag','opdy',...
        'tooltipstring','Inline dimension: choose pass, kill, or filter','callback',{@svdsep_dialog,'opchoice'});
    xnow=xnow+wid+xsep;
    uicontrol(hdial,'style','popupmenu','string',{'pass','kill','filter'},'units','normalized','position',...
        [xnow,ynow,wid,ht],'value',getparm(parmset,'OpdT'),'tag','opdt',...
        'tooltipstring','Time dimension: choose pass, kill, or filter','callback',{@svdsep_dialog,'opchoice'});
    widpan=.45;htpan=.175;
    xnow=xnot;
    %Gross frequency filter
    ynow=ynow-htpan;
    hpan1=uipanel(hdial,'units','normalized','position',[xnow,ynow,widpan,htpan],'tag','pan1',...
        'visible','on','title','Frequency Filter Parameters for Gross','visible','off');
    ht2=.2;sep2=.01;
    wid2=.24;
    wid2a=.2;
    yn=1-ht2-5*sep2;
    xn=0;
    FminG=getparm(parmset,'FminG');
    FmaxG=getparm(parmset,'FmaxG');
    DfminG=getparm(parmset,'DfminG');
    DfmaxG=getparm(parmset,'DfmaxG');
    FmaxmaxG=getparm(parmset,'FmaxmaxG');
    FmaxminG=getparm(parmset,'FmaxminG');
    TfmaxG=getparm(parmset,'TfmaxG');
    fnyq=.5/abs(t(2)-t(1));
    uicontrol(hpan1,'style','text','string','TfmaxG:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the time at which filter parameters are specified');
    uicontrol(hpan1,'style','edit','string',time2str(TfmaxG),'units','normalized','tag','tfmaxg',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in seconds ' ...
        time2str(t(1)) ' and ' time2str(t(end))]);
    yn=yn-ht2-sep2;
    uicontrol(hpan1,'style','text','string','FminG:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the minimum frequency (Hz) to pass, enter zero for a lowpass filter');
    uicontrol(hpan1,'style','edit','string',num2str(FminG),'units','normalized','tag','fming',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
     uicontrol(hpan1,'style','text','string','DfminG:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring',...
        'This is the rolloff width on the lowend.');
    uicontrol(hpan1,'style','edit','string',num2str(DfminG),'units','normalized','tag','dfming',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fmin');
    yn=yn-ht2-sep2;
    uicontrol(hpan1,'style','text','string','FmaxG:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the maximum frequency (Hz) to pass, enter zero for a highpass filter');
    uicontrol(hpan1,'style','edit','string',num2str(FmaxG),'units','normalized','tag','fmaxg',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    uicontrol(hpan1,'style','text','string','DfmaxG:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring',...
        'This is the rolloff width on the high end.');
    uicontrol(hpan1,'style','edit','string',num2str(DfmaxG),'units','normalized','tag','dfmaxg',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fnyq-Fmax');
    yn=yn-ht2-sep2;
    uicontrol(hpan1,'style','text','string','FmaxmaxG:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring','Maximimum allowed value of FmaxG');
    uicontrol(hpan1,'style','edit','string',num2str(FmaxmaxG),'units','normalized','tag','fmaxmaxg',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between FmaxG and ' num2str(fnyq)]);
    uicontrol(hpan1,'style','text','string','FmaxminG:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring','Minimum allowed value of FmaxG');
    uicontrol(hpan1,'style','edit','string',num2str(FmaxminG),'units','normalized','tag','fmaxming',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value in Hz between FminG and FmaxG');  
    %Detail frequency filter
    xnow=xnow+.25*xnot+widpan;
    hpan2=uipanel(hdial,'units','normalized','position',[xnow,ynow,widpan,htpan],'tag','pan2',...
        'visible','on','title','Frequency Filter Parameters for Detail','visible','off');
    ht2=.2;sep2=.01;
    wid2=.24;
    wid2a=.2;
    yn=1-ht2-5*sep2;
    xn=0;
    FminD=getparm(parmset,'FminD');
    FmaxD=getparm(parmset,'FmaxD');
    DfminD=getparm(parmset,'DfminD');
    DfmaxD=getparm(parmset,'DfmaxD');
    FmaxmaxD=getparm(parmset,'FmaxmaxD');
    FmaxminD=getparm(parmset,'FmaxminD');
    TfmaxD=getparm(parmset,'TfmaxD');
    fnyq=.5/abs(t(2)-t(1));
    uicontrol(hpan2,'style','text','string','TfmaxD:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the time at which filter parameters are specified');
    uicontrol(hpan2,'style','edit','string',time2str(TfmaxD),'units','normalized','tag','tfmaxd',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in seconds ' ...
        time2str(t(1)) ' and ' time2str(t(end))]);
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','FminD:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the minimum frequency (Hz) to pass, enter zero for a lowpass filter');
    uicontrol(hpan2,'style','edit','string',num2str(FminD),'units','normalized','tag','fmind',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    uicontrol(hpan2,'style','text','string','DfminD:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring',...
        'This is the rolloff width on the lowend.');
    uicontrol(hpan2,'style','edit','string',num2str(DfminD),'units','normalized','tag','dfmind',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fmin');
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','FmaxD:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the maximum frequency (Hz) to pass, enter zero for a highpass filter');
    uicontrol(hpan2,'style','edit','string',num2str(FmaxD),'units','normalized','tag','fmaxd',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between 0 and ' num2str(fnyq)]);
    uicontrol(hpan2,'style','text','string','DfmaxG:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring',...
        'This is the rolloff width on the high end.');
    uicontrol(hpan2,'style','edit','string',num2str(DfmaxD),'units','normalized','tag','dfmaxd',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value in Hz between 0 and Fnyq-Fmax');
    yn=yn-ht2-sep2;
    uicontrol(hpan2,'style','text','string','FmaxmaxD:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring','Maximimum allowed value of FmaxD');
    uicontrol(hpan2,'style','edit','string',num2str(FmaxmaxD),'units','normalized','tag','fmaxmaxd',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in Hz between FmaxD and ' num2str(fnyq)]);
    uicontrol(hpan2,'style','text','string','FmaxminG:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring','Minimum allowed value of FmaxD');
    uicontrol(hpan2,'style','edit','string',num2str(FmaxminD),'units','normalized','tag','fmaxmind',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value in Hz between FminD and FmaxD'); 
    widpan=.45;htpan2=.15;
    xnow=xnot;
    %Gross wavenumber filter
    ynow=ynow-htpan2-2*ysep;
    hpan3=uipanel(hdial,'units','normalized','position',[xnow,ynow,widpan,htpan2],'tag','pan3',...
        'visible','on','title','Wavenumber Filter Parameters for Gross','visible','off');
    ht2=.25;sep2=.01;
    wid2=.24;
    wid2a=.2;
    yn=1-ht2-10*sep2;
    xn=0;
    SigmaG=getparm(parmset,'SigmaG');
    SigmaGmax=getparm(parmset,'SigmaGmax');
    SigmaGmin=getparm(parmset,'SigmaGmin');
    TsigmaG=getparm(parmset,'TsigmaG');
    uicontrol(hpan3,'style','text','string','TsigmaG:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the time at which filter parameters are specified');
    uicontrol(hpan3,'style','edit','string',time2str(TsigmaG),'units','normalized','tag','tsigmag',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in seconds ' ...
        time2str(t(1)) ' and ' time2str(t(end))]);
    yn=yn-ht2-sep2;
    uicontrol(hpan3,'style','text','string','SigmaG:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the Gaussian half-width of the filter expressed as a fraction of Nyquist');
    uicontrol(hpan3,'style','edit','string',num2str(SigmaG),'units','normalized','tag','sigmag',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring','Enter a value 0 and 1');
     uicontrol(hpan3,'style','text','string','SigmaGmax:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring','This is the maximum allowed value for SigmaG');
    uicontrol(hpan3,'style','edit','string',num2str(SigmaGmax),'units','normalized','tag','sigmagmax',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value between SigmaG and 1');
    yn=yn-ht2-sep2;
    uicontrol(hpan3,'style','text','string','SigmaGmin:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring','This is the minimum allowed value for SigmaG');
    uicontrol(hpan3,'style','edit','string',num2str(SigmaGmin),'units','normalized','tag','sigmagmin',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value between 0 and SigmaG'); 
    %Detail wavenumber filter
    xnow=xnow+.25*xnot+widpan;
    hpan4=uipanel(hdial,'units','normalized','position',[xnow,ynow,widpan,htpan2],'tag','pan4',...
        'visible','on','title','Wavenumber Filter Parameters for Detail','visible','off');
    ht2=.25;sep2=.01;
    wid2=.24;
    wid2a=.2;
    yn=1-ht2-10*sep2;
    xn=0;
    SigmaD=getparm(parmset,'SigmaD');
    SigmaDmax=getparm(parmset,'SigmaDmax');
    SigmaDmin=getparm(parmset,'SigmaDmin');
    TsigmaD=getparm(parmset,'TsigmaD');
    uicontrol(hpan4,'style','text','string','TsigmaD:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the time at which filter parameters are specified');
    uicontrol(hpan4,'style','edit','string',time2str(TsigmaD),'units','normalized','tag','tsigmad',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring',['Enter a value in seconds ' ...
        time2str(t(1)) ' and ' time2str(t(end))]);
    yn=yn-ht2-sep2;
    uicontrol(hpan4,'style','text','string','SigmaD:','units','normalized',...
        'position',[xn,yn,wid2a,ht2],'tooltipstring',...
        'This is the Gaussian half-width of the filter expressed as a fraction of Nyquist');
    uicontrol(hpan4,'style','edit','string',num2str(SigmaD),'units','normalized','tag','sigmad',...
        'position',[xn+wid2a+sep2,yn,wid2,ht2],'tooltipstring','Enter a value 0 and 1');
     uicontrol(hpan4,'style','text','string','SigmaDmax:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring','This is the maximum allowed value for SigmaD');
    uicontrol(hpan4,'style','edit','string',num2str(SigmaDmax),'units','normalized','tag','sigmadmax',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value between SigmaD and 1');
    yn=yn-ht2-sep2;
    uicontrol(hpan4,'style','text','string','SigmaDmin:','units','normalized',...
        'position',[xn+wid2a+wid2+2*sep2,yn,wid2a,ht2],'tooltipstring','This is the minimum allowed value for SigmaD');
    uicontrol(hpan4,'style','edit','string',num2str(SigmaDmin),'units','normalized','tag','sigmadmin',...
        'position',[xn+2*wid2a+wid2+3*sep2,yn,wid2,ht2],'tooltipstring','Enter a value between 0 and SigmaD'); 
    
    %done and cancel
    ynow=.05;
    xnow=xnot;
    wid=.2;
    uicontrol(hdial,'style','pushbutton','string','Done (start computation)','units','normalized',...
        'position',[xnow,ynow,wid,ht],'tag','done','callback',{@svdsep_dialog,'done'},'backgroundcolor','c');
    xnow=xnow+wid+2*xsep;
    uicontrol(hdial,'style','pushbutton','string','Cancel','units','normalized',...
        'position',[xnow,ynow,.5*wid,ht],'tag','cancel','callback',{@svdsep_dialog,'done'},'userdata',transfer);
    
    %message panel
    xnow=xnow+.5*wid+2*xsep;
    panwid=1-xnow-2*xsep;
    panht=.1;
    hmpan=uiscrollpanel(hdial,[xnow,ynow,panwid,panht]);
    set(hmpan(1),'title','Messages','tag','mpan1');
    set(hmpan(2),'tag','mpan2');
    
elseif(strcmp(action,'datachoice'))
    hdial=gcf;
    ud=get(hdial,'userdata');
    henhance=ud{2};
    hfile=findobj(henhance,'tag','file');
    proj=get(hfile,'userdata');
    hdata=findobj(hdial,'tag','datasets');
    idata=get(hdata,'value');
    set(hdata,'userdata',proj.tcoord{idata});
    
elseif(strcmp(action,'dimchoice'))
    hthisdim=arg1;
    hdial=gcf;
    hxdim=findobj(hdial,'tag','xdim');
    hydim=findobj(hdial,'tag','ydim');
    htdim=findobj(hdial,'tag','tdim');
    ixdim=get(hxdim,'value');
    iydim=get(hydim,'value');
    itdim=get(htdim,'value');
    switch hthisdim
        case hxdim
            if(ixdim==iydim)
                set(hydim,'value',1);
            end
            if(ixdim==itdim)
                set(htdim,'value',1);
            end
        case hydim
            if(iydim==ixdim)
                set(hxdim,'value',1);
            end
            if(iydim==itdim)
                set(htdim,'value',1);
            end
        case htdim
            if(itdim==ixdim)
                set(hxdim,'value',1);
            end
            if(itdim==iydim)
                set(hydim,'value',1);
            end
    end
elseif(strcmp(action,'opchoice'))
    hthischoice=arg1;
    ithisop=get(hthischoice,'value');
    thistag=get(hthischoice,'tag');
    hdial=gcf;
    hopgx=findobj(hdial,'tag','opgx');
    hopgy=findobj(hdial,'tag','opgy');
    hopgt=findobj(hdial,'tag','opgt');
    hopdx=findobj(hdial,'tag','opdx');
    hopdy=findobj(hdial,'tag','opdy');
    hopdt=findobj(hdial,'tag','opdt');
    hpan1=findobj(hdial,'tag','pan1');
    hpan2=findobj(hdial,'tag','pan2');
    hpan3=findobj(hdial,'tag','pan3');
    hpan4=findobj(hdial,'tag','pan4');
    iopgx=get(hopgx,'value');
    iopgy=get(hopgy,'value');
    iopgt=get(hopgt,'value');
    iopdx=get(hopdx,'value');
    iopdy=get(hopdy,'value');
    iopdt=get(hopdt,'value');
    %now make sure we don't have kills in both gross and detail
    switch thistag
        case 'opgx'
            if(ithisop==2)
                if(iopdx==2)
                    set(hopdx,'value',1);
                end
            end
        case 'opdx'
            if(ithisop==2)
                if(iopgx==2)
                    set(hopgx,'value',1);
                end
            end
        case 'opgy'
            if(ithisop==2)
                if(iopdy==2)
                    set(hopdy,'value',1);
                end
            end
        case 'opdy'
            if(ithisop==2)
                if(iopgy==2)
                    set(hopgy,'value',1);
                end
            end
        case 'opgt'
            if(ithisop==2)
                if(iopdt==2)
                    set(hopdt,'value',1);
                end
            end
        case 'opdt'
            if(ithisop==2)
                if(iopgx==2)
                    set(hopgt,'value',1);
                end
            end
    end
    %switch panels on and off
    if(iopgx==3 || iopgy==3)
        pan1vis='on';
    else
        pan1vis='off';
    end
    if(iopdx==3 || iopdy==3)
        pan2vis='on';
    else
        pan2vis='off';
    end
    if(iopgt==3)
        pan3vis='on';
    else
        pan3vis='off';
    end
    if(iopdt==3)
        pan4vis='on';
    else
        pan4vis='off';
    end
    set(hpan1,'visible',pan1vis);
    set(hpan2,'visible',pan2vis);
    set(hpan3,'visible',pan3vis);
    set(hpan4,'visible',pan4vis);
elseif(strcmp(action,'done'))
    %The final, updated parmset will be put in the userdata of htask. It will be the second entry in
    %the cell. If a cancel occurs, the userdata will be empty
    hdial=gcf;
    hbutt=arg1;
    hdone=findobj(hdial,'tag','done');
    hcancel=findobj(hdial,'tag','cancel');
    htask=findobj(hdial,'tag','task');
    if(strcmp(get(hbutt,'tag'),'cancel')||strcmp(get(hbutt,'tag'),'dialog'))
        set(htask,'userdata',[]);
        enhance('canceltask');
        return;
    end
    %extract the info from the dialog, test for validity, and either put up error message or exit
    %get the initial parmset
    htask=findobj(hdial,'tag','task');
    ud=get(htask,'userdata');
    parmset=ud{2};
    errormsgs={};
    nerr=0;
    %determine the input dataset
    hdata=findobj(hdial,'tag','datasets');
    t=get(hdata,'userdata');
    fnyq=.5/abs(t(2)-t(1));
    %Get the operation flags
    hidx=findobj(hdial,'tag','xdim');
    idx=get(hidx,'value');
    parmset{3}=int2str(idx-1);
    hidy=findobj(hdial,'tag','ydim');
    idy=get(hidy,'value');
    parmset{6}=int2str(idy-1);
    hidt=findobj(hdial,'tag','tdim');
    idt=get(hidt,'value');
    parmset{9}=int2str(idt-1);
    %Get singcut values
    hsingx=findobj(hdial,'tag','xcut');
    val=str2double(get(hsingx,'string'));
    if(isnan(val))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for singcut X';
    else
        parmset{12}=num2str(val);
    end
    hsingy=findobj(hdial,'tag','ycut');
    val=str2double(get(hsingy,'string'));
    if(isnan(val))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for singcut Y';
    else
        parmset{15}=num2str(val);
    end
    hsingt=findobj(hdial,'tag','tcut');
    val=str2double(get(hsingt,'string'));
    if(isnan(val))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for singcut T';
    else
        parmset{18}=num2str(val);
    end
    %Operation flags
    hopgx=findobj(hdial,'tag','opgx');
    parmset{21}=int2str(get(hopgx,'value'));
    hopgy=findobj(hdial,'tag','opgy');
    parmset{24}=int2str(get(hopgy,'value'));
    hopgt=findobj(hdial,'tag','opgt');
    parmset{27}=int2str(get(hopgt,'value'));
    hopdx=findobj(hdial,'tag','opdx');
    parmset{30}=int2str(get(hopdx,'value'));
    hopdy=findobj(hdial,'tag','opdy');
    parmset{33}=int2str(get(hopdy,'value'));
    hopdt=findobj(hdial,'tag','opdt');
    parmset{36}=int2str(get(hopdt,'value'));
    %Frequency Filter on gross
    hpan1=findobj(hdial,'tag','pan1');
    hfming=findobj(hpan1,'tag','fming');
    FminG=str2double(get(hfming,'string'));
    if(isnan(FminG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FminG';
    elseif(FminG<0 || FminG>fnyq)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FminG';
    else
        parmset{39}=num2str(FminG);
    end
    hfmaxg=findobj(hpan1,'tag','fmaxg');
    FmaxG=str2double(get(hfmaxg,'string'));
    if(isnan(FmaxG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxG';
    elseif(FmaxG<FminG || FmaxG>fnyq)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxG';
    else
        parmset{42}=num2str(FmaxG);
    end
    htfmaxg=findobj(hpan1,'tag','tfmaxg');
    TfmaxG=str2double(get(htfmaxg,'string'));
    if(isnan(TfmaxG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for TfmaxG';
    elseif(TfmaxG<t(1) || TfmaxG>t(end))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for TfmaxG';
    else
        parmset{45}=num2str(TfmaxG);
    end
    hfmaxmaxg=findobj(hpan1,'tag','fmaxmaxg');
    FmaxmaxG=str2double(get(hfmaxmaxg,'string'));
    if(isnan(FmaxmaxG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxmaxG';
    elseif(FmaxmaxG<FmaxG || FmaxmaxG>fnyq)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxmaxG';
    else
        parmset{48}=num2str(FmaxmaxG);
    end
    hfmaxming=findobj(hpan1,'tag','fmaxming');
    FmaxminG=str2double(get(hfmaxming,'string'));
    if(isnan(FmaxminG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxminG';
    elseif(FmaxminG<FminG || FmaxminG>FmaxG)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxminG';
    else
        parmset{51}=num2str(FmaxminG);
    end
    hdfming=findobj(hpan1,'tag','dfming');
    DfminG=str2double(get(hdfming,'string'));
    if(isnan(DfminG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for DfminG';
    elseif(DfminG<0 || DfminG>FminG)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for DfminG';
    else
        parmset{93}=num2str(DfminG);
    end
    hdfmaxg=findobj(hpan1,'tag','dfmaxg');
    DfmaxG=str2double(get(hdfmaxg,'string'));
    if(isnan(DfmaxG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for DfmaxG';
    elseif(DfmaxG<0 || DfmaxG>fnyq-FmaxG)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for DfmaxG';
    else
        parmset{96}=num2str(DfmaxG);
    end
    %Frequency Filter on detail
    hpan2=findobj(hdial,'tag','pan2');
    hfmind=findobj(hpan2,'tag','fmind');
    FminD=str2double(get(hfmind,'string'));
    if(isnan(FminD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FminD';
    elseif(FminD<0 || FminD>fnyq)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FminD';
    else
        parmset{54}=num2str(FminD);
    end
    hfmaxd=findobj(hpan2,'tag','fmaxd');
    FmaxD=str2double(get(hfmaxd,'string'));
    if(isnan(FmaxD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxD';
    elseif(FmaxD<FminD || FmaxD>fnyq)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxD';
    else
        parmset{57}=num2str(FmaxD);
    end
    htfmaxd=findobj(hpan2,'tag','tfmaxd');
    TfmaxD=str2double(get(htfmaxd,'string'));
    if(isnan(TfmaxD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for TfmaxD';
    elseif(TfmaxD<t(1) || TfmaxD>t(end))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for TfmaxD';
    else
        parmset{60}=num2str(TfmaxD);
    end
    hfmaxmaxd=findobj(hpan2,'tag','fmaxmaxd');
    FmaxmaxD=str2double(get(hfmaxmaxd,'string'));
    if(isnan(FmaxmaxD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxmaxD';
    elseif(FmaxmaxD<FmaxD || FmaxmaxD>fnyq)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxmaxD';
    else
        parmset{63}=num2str(FmaxmaxD);
    end
    hfmaxmind=findobj(hpan2,'tag','fmaxmind');
    FmaxminD=str2double(get(hfmaxmind,'string'));
    if(isnan(FmaxminD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxminD';
    elseif(FmaxminD<FminD || FmaxminD>FmaxD)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for FmaxminD';
    else
        parmset{66}=num2str(FmaxminD);
    end
    hdfmind=findobj(hpan2,'tag','dfmind');
    DfminD=str2double(get(hdfmind,'string'));
    if(isnan(DfminD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for DfminD';
    elseif(DfminD<0 || DfminD>FminD)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for DfminD';
    else
        parmset{99}=num2str(DfminD);
    end
    hdfmaxd=findobj(hpan2,'tag','dfmaxd');
    DfmaxD=str2double(get(hdfmaxd,'string'));
    if(isnan(DfmaxD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for DfmaxD';
    elseif(DfmaxD<0 || DfmaxD>fnyq-FmaxD)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for DfmaxD';
    else
        parmset{102}=num2str(DfmaxD);
    end
    %wavenumber filter on Gross
    hpan3=findobj(hdial,'tag','pan3');
    hsigmag=findobj(hpan3,'tag','sigmag');
    SigmaG=str2double(get(hsigmag,'string'));
    if(isnan(SigmaG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaG';
    elseif(SigmaG<0 || SigmaG>2)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaG';
    else
        parmset{69}=num2str(SigmaG);
    end
    htsigmag=findobj(hpan3,'tag','tsigmag');
    TsigmaG=str2double(get(htsigmag,'string'));
    if(isnan(TsigmaG))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for TsigmaG';
    elseif(TsigmaG<t(1) || TsigmaG>t(end))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for TsigmaG';
    else
        parmset{72}=num2str(TsigmaG);
    end
    hsigmagmax=findobj(hpan3,'tag','sigmagmax');
    SigmaGmax=str2double(get(hsigmagmax,'string'));
    if(isnan(SigmaGmax))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaGmax';
    elseif(SigmaGmax<SigmaG || SigmaGmax>2)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaGmax';
    else
        parmset{75}=num2str(SigmaGmax);
    end
    hsigmagmin=findobj(hpan3,'tag','sigmagmin');
    SigmaGmin=str2double(get(hsigmagmin,'string'));
    if(isnan(SigmaGmin))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaGmin';
    elseif(SigmaGmin<0 || SigmaGmin>SigmaG)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaGmin';
    else
        parmset{78}=num2str(SigmaGmin);
    end
    %wavenumber filter on Detail
    hpan4=findobj(hdial,'tag','pan4');
    hsigmad=findobj(hpan4,'tag','sigmad');
    SigmaD=str2double(get(hsigmad,'string'));
    if(isnan(SigmaD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaD';
    elseif(SigmaD<0 || SigmaD>2)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaD';
    else
        parmset{81}=num2str(SigmaD);
    end
    htsigmad=findobj(hpan4,'tag','tsigmad');
    TsigmaD=str2double(get(htsigmad,'string'));
    if(isnan(TsigmaD))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for TsigmaD';
    elseif(TsigmaD<t(1) || TsigmaD>t(end))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for TsigmaD';
    else
        parmset{84}=num2str(TsigmaD);
    end
    hsigmadmax=findobj(hpan4,'tag','sigmadmax');
    SigmaDmax=str2double(get(hsigmadmax,'string'));
    if(isnan(SigmaDmax))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaDmax';
    elseif(SigmaDmax<SigmaD || SigmaDmax>2)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaDmax';
    else
        parmset{87}=num2str(SigmaDmax);
    end
    hsigmadmin=findobj(hpan4,'tag','sigmadmin');
    SigmaDmin=str2double(get(hsigmadmin,'string'));
    if(isnan(SigmaDmin))
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaDmin';
    elseif(SigmaDmin<0 || SigmaDmin>SigmaD)
        nerr=nerr+1;
        errormsgs{nerr}='Bad value for SigmaDmin';
    else
        parmset{90}=num2str(SigmaDmin);
    end
    if(nerr>0)
        hmpan1=findobj(hdial,'tag','mpan1');
        hmpan2=findobj(hdial,'tag','mpan2');
        hk=get(hmpan2,'children');
        if(~isempty(hk)); delete(hk); end
        ht=.1;wid=1;
        yn=1-ht;
        xn=0;
        for k=1:nerr
            uicontrol(hmpan2,'style','text','string',errormsgs{k},'units','normalized',...
                'position',[xn,yn,wid,ht]);
            yn=yn-ht;
        end
        set(hdone,'userdata',[]);
        set(hmpan1,'title','Errors Found!','backgroundcolor','y')
        return;
    else
        hmpan1=findobj(hdial,'tag','mpan1');
        hmpan2=findobj(hdial,'tag','mpan2');
        hk=get(hmpan2,'children');
        if(~isempty(hk)); delete(hk); end
        set(hmpan1,'title','Good to go!','backgroundcolor',.94*ones(1,3))
        ud=get(htask,'userdata');
        ud{2}=parmset;
        set(htask,'userdata',ud);
        %set(hdone,'userdata',parmset);
        %transfer control back to ENHANCE
        transfer=get(hcancel,'userdata');
        eval(transfer);
    end
            
end

end