function varargout = JEMRIS_sim(varargin)
%GUI for jemris simulation visualisation

%TS@IME-FZJ 03/2007

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @JEMRIS_sim_OpeningFcn, ...
                   'gui_OutputFcn',  @JEMRIS_sim_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before JEMRIS_sim is made visible.
function JEMRIS_sim_OpeningFcn(hObject, eventdata, handles, varargin)

colordef white

% Choose default command line output for JEMRIS_sim
handles.output = hObject;

handles.seqfile = 'FID.xml';
hax{1}=handles.axes1; hax{2}=handles.axes2;
hax{3}=handles.axes3; hax{4}=handles.axes4;
hax{5}=handles.axes5; hax{6}=handles.axes6;
for i=1:6; set(hax{i},'color',[1 1 1],'visible','off'); end
handles.hax=hax;
handles.epil=0;
handles.epir=0;
handles.CWD=pwd;
sample.type='Sphere';
sample.T1=1000;sample.T2=100;sample.M0=1;sample.CS=0;
sample.R=50;sample.DxDy=1;
sim.DF=0;sim.CSF=0;sim.CF=0;sim.RN=0;
handles.sample=sample;
handles.sim=sim;
handles.img_num=1;
%set(gcf,'color',[.88 .88 .88])

C={'Sample','Signal','k-Space','Image'};
set(handles.showLeft,'String',C);
C={'Signal','k-Space','Image'};
set(handles.showRight,'String',C);
C={'Sphere','2Spheres','brain1','brain2'};
set(handles.Sample,'String',C);
set(handles.EPI_L,'Visible','off');
set(handles.EPI_R,'Visible','off');
set(handles.ImageL,'Visible','off');
set(handles.ImageR,'Visible','off');
guidata(hObject, handles);


% UIWAIT makes JEMRIS_sim wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- writes the simulation xml file. This is *not* an object of the GUI!
function write_simu_xml(handles,redraw)
sample=handles.sample;sim=handles.sim;
fid=fopen('simu.xml','w');
 fprintf(fid,'<?xml version="1.0" encoding="iso-8859-1"?>\n');
 fprintf(fid,'<JMRI-SIM>\n');
 switch sample.type
     case 'Sphere'
                fprintf(fid,[' <Sample Shape="%s2D" Radius="%4.2f" Delta="%4.2f"',...
                             ' M0="%4.2f" T1="%5.2f" T2="%5.2f" CS="%5.2f"/>\n'], ...
                        sample.type,sample.R,sample.DxDy,sample.M0,sample.T1,sample.T2,sample.CS);
     case '2Spheres'
                 fprintf(fid,[' <Sample Shape="%s2D"  Delta="%4.2f"',...
                              ' Radius_1="%4.2f" M0_1="%4.2f" T1_1="%5.2f" T2_1="%5.2f" CS_1="%5.2f"',...
                              ' Radius_2="%4.2f" M0_2="%4.2f" T1_2="%5.2f" T2_2="%5.2f" CS_2="%5.2f"/>\n'], ...
                         sample.type,sample.DxDy,sample.R(1),sample.M0(1),sample.T1(1),sample.T2(1),...
                         sample.CS(1),sample.R(2),sample.M0(2),sample.T1(2),sample.T2(2),sample.CS(2));
    case 'brain1'
         fprintf(fid,' <Sample InFile="tra0mm_mr_Susc_CS.bin" />\n'); sim.CSF=sample.CS(1);
     case 'brain2'
         fprintf(fid,' <Sample InFile="tra32mm_mr_Susc_CS.bin" />\n'); sim.CSF=sample.CS(1);
 end
 if nargin<2
 if (sim.CF==0),CF=-1;else CF=1/sim.CF;end
  fprintf(fid,[' <Model FieldFluctuations="%5.4f" ChemicalShiftFactor="%5.4f"',...
               ' ConcomitantFields="%5.4f"/>\n'],sim.DF,sim.CSF,CF);
 end
 fprintf(fid,'</JMRI-SIM>\n');
fclose(fid);
if nargin==2 %redraw sample
 [dummy,SUBDIR]=fileparts(handles.CWD);
 unixcommand=sprintf('ssh tstoecker@mrcluster "cd %s ; ./jemris %s simu.xml"',SUBDIR,handles.seqfile);
 [status,dump]=unix(unixcommand);
 for i=[1 3 4 5 6]
    cla(handles.hax{i},'reset');
    set(handles.hax{i},'color',[1 1 1],'visible','off');
 end
 plotall(handles.hax,1,0,0,0);
 set(handles.showLeft,'Value',1);
end

% --- Outputs from this function are returned to the command line.
function varargout = JEMRIS_sim_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

% --- Executes on selection change in Sample.
function Sample_Callback(hObject, eventdata, handles)
 C=get(hObject,'String');
 Nsample=get(hObject,'Value');
 handles.sample.type=C{Nsample};
 switch Nsample
    case 1
        handles.sample.T1=1000;handles.sample.T2=100;handles.sample.M0=1;handles.sample.CS=0;
        handles.sample.R=50;handles.sample.DxDy=1;
        handles.sim.DF=0;handles.sim.CSF=1;
    case 2
        handles.sample.T1=[100 50];handles.sample.T2=[100 50];handles.sample.M0=[1 1];handles.sample.CS=[0 0];
        handles.sample.R=[50 25];handles.sample.DxDy=1;
        handles.sim.DF=0;handles.sim.CSF=1;
 end
 if Nsample>2;bvis='off';handles.sample.CS=handles.sample.CS(1);else;bvis='on';end
 if Nsample>2;CSstr='CS fact';else;CSstr='CS [kHz]';end
 set(handles.text17,'String',CSstr); 
 set(handles.setT1,'String',num2str(handles.sample.T1),'Visible',bvis);
 set(handles.setT2,'String',num2str(handles.sample.T2),'Visible',bvis);
 set(handles.setM0,'String',num2str(handles.sample.M0),'Visible',bvis);
 set(handles.setChemShift,'String',num2str(handles.sample.CS));
 set(handles.setRadius,'String',num2str(handles.sample.R),'Visible',bvis);
 set(handles.setGrid,'String',num2str(handles.sample.DxDy),'Visible',bvis);
 set(handles.setDeltaF,'String',num2str(handles.sim.DF));
 set(handles.text10,'Visible',bvis);
 set(handles.text11,'Visible',bvis);
 set(handles.text12,'Visible',bvis);
 set(handles.text13,'Visible',bvis);
 set(handles.text16,'Visible',bvis);
 %redraw sample
 write_simu_xml(handles,1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function Sample_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in start_simu.
function start_simu_Callback(hObject, eventdata, handles)
write_simu_xml(handles);
[dummy,SUBDIR]=fileparts(handles.CWD);
%set up a PBS script on the cluster
S_PBS=sprintf('sed -e ''s/XML_SEQ/%s/'' -e ''s/XML_SIM/simu.xml/'' pbs.script > mypbs',handles.seqfile);
%command to launch command into queue on cluster 
unixcommand=sprintf('ssh tstoecker@mrcluster "cd %s; rm -f simu.done out.txt; %s; qsub mypbs"',SUBDIR,S_PBS);
C={'now executing',unixcommand,'','... wait for results'};
set(handles.sim_dump,'String',C);
guidata(hObject, handles);
[status,dump]=unix(unixcommand);
pause(1);
%block matlab until result appears (?? is there a better way ??)
while exist('simu.done')~=2,end
unix(['ssh tstoecker@mrcluster "cd ',SUBDIR,'; rm -f mypbs simu.done *.ime462.tmp"']);
C={};
fid=fopen('out.txt');
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    C{end+1}=tline;
end
fclose(fid);
set(handles.sim_dump,'String',C);
set(handles.showLeft,'Value',1);
set(handles.showRight,'Value',1);
guidata(hObject, handles);
showLeft_Callback(hObject, eventdata, handles);
showRight_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function FileTag_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function loadSeqTag_Callback(hObject, eventdata, handles)
[FileName,PathName] = uigetfile('*.xml','Select the Sequence XML file');
if FileName==0,return;end
handles.seqfile=FileName;
set(handles.SeqNameTag,'String',['Sequence: ',FileName]);
guidata(hObject, handles);

% --------------------------------------------------------------------
function loadSampleTag_Callback(hObject, eventdata, handles)

% --- Executes on button press in save_plot.
function SAVEPLOT(hObject, eventdata, handles)
[a,b,c]=fileparts(handles.seqfile);
D=dir([b,'*_sim*.pdf']);
pdfname=sprintf('%s_sim%03d',b,length(D)+1);
set(gcf,'PaperPositionMode','auto','InvertHardcopy','off')
print('-dpdf',pdfname)

% --- Executes on selection change in sim_dump.
function sim_dump_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function sim_dump_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setT1_Callback(hObject, eventdata, handles)
handles.sample.T1=str2num(get(hObject,'String'));
write_simu_xml(handles,1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setT1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setT2_Callback(hObject, eventdata, handles)
handles.sample.T2=str2num(get(hObject,'String'));
write_simu_xml(handles,1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setT2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setM0_Callback(hObject, eventdata, handles)
handles.sample.M0=str2num(get(hObject,'String'));
write_simu_xml(handles,1);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setM0_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setChemShift_Callback(hObject, eventdata, handles)
handles.sample.CS=str2num(get(hObject,'String'));
if strcmp('on',get(handles.setM0,'visible'))
 write_simu_xml(handles,1);
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setChemShift_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setRadius_Callback(hObject, eventdata, handles)
handles.sample.R=str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setRadius_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setGrid_Callback(hObject, eventdata, handles)
handles.sample.DxDy=str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setGrid_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setDeltaF_Callback(hObject, eventdata, handles)
handles.sim.DF=1e-3*str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setDeltaF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setConcField_Callback(hObject, eventdata, handles)
handles.sim.CF=str2num(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setConcField_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setNoise_Callback(hObject, eventdata, handles)
handles.sim.RN=str2num(get(hObject,'String'));
guidata(hObject, handles);
set(hObject,'Value',get(handles.showRight,'Value'));
showRight_Callback(hObject, eventdata, handles);
set(hObject,'Value',get(handles.showLeft,'Value'));
showLeft_Callback(hObject, eventdata, handles);
set(hObject,'Value',0);
set(handles.zoomflag,'Value',0);
 zoom(gcf,'off')
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function setNoise_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in showLeft.
function showLeft_Callback(hObject, eventdata, handles)
axes(handles.hax{1});
for i=[1 3 4 5 6]
    cla(handles.hax{i},'reset');
    set(handles.hax{i},'color',[1 1 1],'visible','off');
end
Nimg=plotall(handles.hax,get(hObject,'Value'),handles.epil,handles.sim.RN,handles.img_num);
if get(hObject,'Value')<3,bvis='off';else;bvis='on';end
set(handles.EPI_L,'Visible',bvis);
if (Nimg==1),bvis='off';
else;bvis='on';for i=1:Nimg;C{i}=['# ',num2str(i)];end;set(handles.ImageL,'String',C);end
set(handles.ImageL,'Visible',bvis);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function showLeft_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in showRight.
function showRight_Callback(hObject, eventdata, handles)
axes(handles.hax{2});
cla(handles.hax{2},'reset');
set(handles.hax{2},'color',[1 1 1],'visible','off');
Nimg=plotall(handles.hax,1+get(hObject,'Value'),handles.epir,handles.sim.RN,handles.img_num);
if get(hObject,'Value')==1,bvis='off';else;bvis='on';end
set(handles.EPI_R,'Visible',bvis);
if (Nimg==1),bvis='off';
else;bvis='on';for i=1:Nimg;C{i}=['# ',num2str(i)];end;set(handles.ImageR,'String',C);end
set(handles.ImageR,'Visible',bvis);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function showRight_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in EPI_R.
function EPI_R_Callback(hObject, eventdata, handles)
handles.epir=get(hObject,'Value');
set(hObject,'Value',get(handles.showRight,'Value'));
showRight_Callback(hObject, eventdata, handles);
set(hObject,'Value',handles.epir);
guidata(hObject, handles);

% --- Executes on button press in EPI_L.
function EPI_L_Callback(hObject, eventdata, handles)
handles.epil=get(hObject,'Value');
set(hObject,'Value',get(handles.showLeft,'Value'));
showLeft_Callback(hObject, eventdata, handles);
set(hObject,'Value',handles.epil);
guidata(hObject, handles);


% --- Executes on button press in zoomflag.
function zoomflag_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    zoom(gcf,'on')
else
 set(hObject,'Value',get(handles.showRight,'Value'));
 showRight_Callback(hObject, eventdata, handles);
 set(hObject,'Value',get(handles.showLeft,'Value'));
 showLeft_Callback(hObject, eventdata, handles);
 set(hObject,'Value',0);
 guidata(hObject, handles);
 zoom(gcf,'off')
end


% --- Executes on selection change in ImageL.
function ImageL_Callback(hObject, eventdata, handles)
handles.img_num=get(hObject,'Value');
set(hObject,'Value',get(handles.showLeft,'Value'));
showLeft_Callback(hObject, eventdata, handles);
set(hObject,'Value',handles.img_num);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ImageL_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ImageR.
function ImageR_Callback(hObject, eventdata, handles)
handles.img_num=get(hObject,'Value');
set(hObject,'Value',get(handles.showRight,'Value'));
showRight_Callback(hObject, eventdata, handles);
set(hObject,'Value',handles.img_num);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ImageR_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function setROI_Callback(hObject, eventdata, handles)
r=str2num(get(hObject,'String'));
[x,y]=ginput(1);
try
 c=get(gca,'Children'); A=get(c(end),'Cdata');
 [X,Y]=size(A);[X,Y]=meshgrid(1:X,1:Y);
 [I,J]=find( (X-x).^2+(Y-y).^2 <= r^2 );
 if length(I>0); A=A(I,J); else, A=A(round(x),round(y));end
 set(handles.MROI,'String',['M=',num2str(mean(A(:)),3)]);
 set(handles.SROI,'String',['S=',num2str(std(A(:)),3)]);
 hold on
  if r>0
   plot(x+r*cos(0:.01:2*pi),y+r*sin(0:.01:2*pi),'r','linewidth',2)
  else
   plot(x,y,'xr')
  end
 hold off
catch
 set(handles.MROI,'String','');
 set(handles.SROI,'String','');
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function setROI_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function plotTag_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function plotGUITag_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function plotLeftTag_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function plotRightTag_Callback(hObject, eventdata, handles)