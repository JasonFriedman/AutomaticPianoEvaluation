function varargout = songVisualization(varargin)
% SONGVISUALIZATION MATLAB code for songVisualization.fig
%      SONGVISUALIZATION, by itself, creates a new SONGVISUALIZATION or raises the existing
%      singleton*.
%
%      H = SONGVISUALIZATION returns the handle to a new SONGVISUALIZATION or the handle to
%      the existing singleton*.
%
%      SONGVISUALIZATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SONGVISUALIZATION.M with the given input arguments.
%
%      SONGVISUALIZATION('Property','Value',...) creates a new SONGVISUALIZATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before songVisualization_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to songVisualization_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help songVisualization

% Last Modified by GUIDE v2.5 17-Jan-2022 10:26:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @songVisualization_OpeningFcn, ...
                   'gui_OutputFcn',  @songVisualization_OutputFcn, ...
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


% --- Executes just before songVisualization is made visible.
function songVisualization_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to songVisualization (see VARARGIN)

% Choose default command line output for songVisualization
handles.output = hObject;

% Make a list of the performances

handles.basedir = 'songs/real data/';

handles.evaluation = readEvaluation;

d = dir(handles.basedir);
count = 0;
for k=1:numel(d)
    if d(k).isdir && d(k).name(1) ~= '.'
        count = count+1;
        songnames{count} = d(k).name;
    end
end

if count==0
    error('Could not find any songs, are you in the right directory?')
end

set(handles.songSelector,'String',songnames);

graphtypes = updategraph();

set(handles.graphType,'String',graphtypes);

handles = updateSong(handles);

% If there is midi, connect to it
devices = mididevinfo;
if ~isempty(devices.output)
    handles.device = mididevice(devices.output(1).Name);
    set(handles.playPerformance,'Enable','on');
else
    handles.devices = NaN;
    set(handles.playPerformance,'Enable','off');
end

% Update handles structure
guidata(hObject, handles);

function handles = updateSong(handles)

songname = handles.songSelector.String{handles.songSelector.Value};

[~,M_duration] = readIdealBPMs;

% load the midi of the ideal song
ideal_fn = ['songs/original songs/' songname '.midi'];
handles.idealmididuration = M_duration(songname);
handles.idealmidi = readmidifile(ideal_fn);

thedir = [handles.basedir songname '/*.midi'];
d = dir(thedir);
for k=1:numel(d)
    [~,students{k}] = fileparts(d(k).name);
    studentnum(k) = str2double(strrep(students{k},'Student ',''));
end
if handles.studentSelector.Value > numel(handles.studentSelector)
    set(handles.studentSelector,'Value',1);
end

[handles.studentnums,order] = sort(studentnum);

set(handles.studentSelector,'String',students(order));
handles = updateStudent(handles);


function handles = updateStudent(handles)
songname = handles.songSelector.String{handles.songSelector.Value};
studentname = handles.studentSelector.String{handles.studentSelector.Value};
fn = [handles.basedir songname '/' studentname '.midi'];

handles.midi = readmidifile(fn);
handles.studentnum = handles.studentnums(handles.studentSelector.Value);
updategraph(handles);

% UIWAIT makes songVisualization wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function graphtypes = updategraph(handles,parent)

if nargin==0
    graphtypes = {'rectangles','onsettimes vs notes','deviation from onset time','duration','tempo','velocity'};
    return
end

if nargin<2 || isempty(parent)
    parent = handles.uipanel1;
end

[features,tocheck,tocheckIdeal,details] = calculateFeatures(handles.midi,handles.idealmidi,handles.idealmididuration);

featurefields = fields(features);
for k=1:numel(featurefields)
    data2{k,1} = featurefields{k};
    data2{k,2} = features.(featurefields{k});
end

handles.uitable2.Data = data2;

showIdeal = handles.showIdeal.Value;

if showIdeal
    set(handles.showComparison,'Visible','on')
    showComparison = handles.showComparison.Value;
else
    set(handles.showComparison,'Visible','off')
    showComparison=0;
end

normalizeTime = handles.normalizeTime.Value;

overallduration = details.overallduration; 
idealmididuration = details.idealmididuration; 

graphtype = handles.graphType.String{handles.graphType.Value};
subplot(1,1,1,'Parent',parent);
cla

if strcmp(graphtype,'rectangles')
    for k=1:numel(handles.midi.note)
        % color represents press velocity
        color = [0 0.4470 0.7410] * handles.midi.pressvelocity(k) / 128;
        onset = handles.midi.onset(k);
        duration = handles.midi.duration(k);
        if normalizeTime
            onset = (onset - min(handles.midi.onset)) / overallduration;
            duration = duration / overallduration;
        end
        
        rectangle('Position',[onset handles.midi.note(k) duration 1],'FaceColor',color,'Edgecolor',color);
        hold on;
    end
    if showIdeal
        for k=1:numel(handles.idealmidi.note)
            onset = handles.idealmidi.onset(k);
            duration = handles.idealmidi.duration(k);
            if normalizeTime
                onset = (onset - min(handles.idealmidi.onset)) / idealmididuration;
                duration = duration / idealmididuration;
            end

            rectangle('Position',[onset handles.idealmidi.note(k) duration 1],...
                'FaceColor',[1 1 1 0.1],'Edgecolor',[1 0 0],...
                'LineWidth',2);
            hold on;
        end
    end
elseif strcmp(graphtype,'onsettimes vs notes')
    onset = handles.midi.onset;
    notes = handles.midi.note;
    if normalizeTime
        onset = (onset - min(handles.midi.onset)) / overallduration;
    end    
    hold off
    plot(onset,notes,'-*');
    hold on
    if showIdeal
        onsetIdeal = handles.idealmidi.onset;
        notesIdeal = handles.idealmidi.note;
        if normalizeTime
            onsetIdeal = (onsetIdeal - min(handles.idealmidi.onset)) / idealmididuration;
        end
        plot(onsetIdeal,notesIdeal,'k-*');
        if showComparison
            for k=1:numel(tocheck)
                plot([onset(tocheck(k)) onsetIdeal(tocheckIdeal(k))],...
                     [notes(tocheck(k)) notesIdeal(tocheckIdeal(k))],...
                     'r-');
            end
        end
    end
elseif strcmp(graphtype,'deviation from onset time')
    onset = handles.midi.onset;
    if normalizeTime
        onset = (onset - min(handles.midi.onset)) / overallduration;
    end    
    onsetIdeal = handles.idealmidi.onset;
    if normalizeTime
        onsetIdeal = (onsetIdeal - min(handles.idealmidi.onset)) / idealmididuration;
    end
    % We need to match the notes - so only do for those in "tocheck"
    onsetDiff = onset(tocheck)-onsetIdeal(tocheckIdeal);

    plot(onsetDiff);
    if normalizeTime    
        plot([1 numel(onsetDiff)],features.onsetoffset(1) + features.onsetslope * [1 numel(onsetDiff)],'k--');
    end
    xlabel('Note number');
    ylabel('Offset');
elseif strcmp(graphtype,'duration')
    % relative duration, e.g. 0.5 = half "instructed" duration
    plot(details.playeddurations ./ details.idealdurations);
    hold on;
    plot([1 numel(details.playeddurations)],features.durationoffset(1) + features.durationslope * [1 numel(details.playeddurations)],'k--');
    xlabel('Note number');
    ylabel('Relative duration');
elseif strcmp(graphtype,'tempo')
    % relative gap, e.g. 0.5 = half "instructed" gap
    plot((details.actualgaps - details.idealgaps) ./ details.idealgaps);
    hold on;
    plot([1 numel(details.idealgaps)],features.durationdifferenceoffset(1) + features.durationdifferenceslope * [1 numel(details.idealgaps)],'k--');
    xlabel('Note number');
    ylabel('Relative tempo');
elseif strcmp(graphtype,'velocity')
    onset = handles.midi.onset;
    velocity = handles.midi.pressvelocity;
    if normalizeTime
        onset = (onset - min(handles.midi.onset)) / overallduration;
    end    
    plot(onset,velocity);
    if showIdeal
        hold on;
        onsetIdeal = handles.idealmidi.onset;
        if normalizeTime
            onsetIdeal = (onsetIdeal - min(handles.idealmidi.onset)) / idealmididuration;
        end
        velocityIdeal = handles.idealmidi.pressvelocity;
        plot(onsetIdeal,velocityIdeal,'k-*');
    end
    %hold on;
    %plot([1 numel(details.idealgaps)],features.durationdifferenceoffset(1) + features.durationdifferenceslope * [1 numel(details.idealgaps)],'k--');
    xlabel('Note number');
    ylabel('Velocity');
else
    error('Unknown graph type');
end

if any(strcmp(graphtype,{'rectangles','onsettimes vs notes'}))
    if normalizeTime
        xlabel('Normalized time')
    else
        xlabel('time (s)');
    end
    ylabel('note');
    % convert the y axis to note names
    ylim('auto')
    yl = ylim;
    yt = yl(1):yl(end);
    set(gca,'YTick',yt+0.5,'YTickLabel',getnotename(yt))
    set(gca,'FontSize',16,'Box','off')
end

% fill the table
thisevaluation = squeeze(handles.evaluation(:,handles.studentnum,:));
for k=1:5
    data{k,2} = nanmean(thisevaluation(:,k));
end
data{1,1} = 'Pitch';
data{2,1} = 'Tempo';
data{3,1} = 'Rhythm';
data{4,1} = 'Articulation';
data{5,1} = 'Overall';

handles.uitable1.Data = data;


% --- Outputs from this function are returned to the command line.
function varargout = songVisualization_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in songSelector.
function songSelector_Callback(hObject, ~, handles)
handles = updateSong(handles);
guidata(hObject, handles);

% --- Executes on selection change in graphType.
function graphType_Callback(~, ~, handles)
updategraph(handles);

% --- Executes on button press in showIdeal.
function showIdeal_Callback(~, ~, handles)
updategraph(handles);

% --- Executes on button press in normalizeTime.
function normalizeTime_Callback(~, ~, handles)
updategraph(handles);

% --- Executes on selection change in studentSelector.
function studentSelector_Callback(hObject, ~, handles)
handles = updateStudent(handles);
guidata(hObject, handles);

% --- Executes on button press in playPerformance.
function playPerformance_Callback(~, ~, handles)
channel = 1;
note = handles.midi.note;
velocity = handles.midi.pressvelocity;
duration = handles.midi.duration;
timestamp = handles.midi.onset;
for k=numel(note):-1:1
    msgs((k-1)*2+(1:2)) = midimsg('Note',channel,note(k),velocity(k),duration(k),timestamp(k));
end
midisend(handles.device,msgs)

% --- Executes on button press in showComparison.
function showComparison_Callback(~, ~, handles)
updategraph(handles);

% --- Executes during object creation, after setting all properties.
function songSelector_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function graphType_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function studentSelector_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openGraphInNewWindow.
function openGraphInNewWindow_Callback(~, ~, handles)
f = figure;
updategraph(handles,f);