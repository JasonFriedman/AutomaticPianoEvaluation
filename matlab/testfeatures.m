function varargout = testfeatures(varargin)
% TESTFEATURES MATLAB code for testfeatures.fig
%      TESTFEATURES, by itself, creates a new TESTFEATURES or raises the existing
%      singleton*.
%
%      H = TESTFEATURES returns the handle to a new TESTFEATURES or the handle to
%      the existing singleton*.
%
%      TESTFEATURES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTFEATURES.M with the given input arguments.
%
%      TESTFEATURES('Property','Value',...) creates a new TESTFEATURES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testfeatures_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testfeatures_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testfeatures

% Last Modified by GUIDE v2.5 09-Jan-2022 16:04:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testfeatures_OpeningFcn, ...
                   'gui_OutputFcn',  @testfeatures_OutputFcn, ...
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


% --- Executes just before testfeatures is made visible.
function testfeatures_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testfeatures (see VARARGIN)

% Choose default command line output for testfeatures
handles.output = hObject;

tmp = load('evaluationfeatures');
handles.t = tmp.t;
handles.t_ztransformed = tmp.t_ztransformed;

params = fields(handles.t);
params = params(1:end-3);

set(handles.xChoice,'String',params);
set(handles.yChoice,'String',params);

% Update handles structure
guidata(hObject, handles);

updategraph(handles);

% UIWAIT makes testfeatures wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function updategraph(handles)
xParam = handles.xChoice.String{handles.xChoice.Value};
yParam = handles.yChoice.String{handles.yChoice.Value};

log1 = handles.log1.Value;
log2 = handles.log2.Value;
zScores = handles.zScores.Value;

regressionline = handles.regressionLine.Value;

if zScores
    t = handles.t_ztransformed;
else
    t = handles.t;
end

x = t.(xParam);
y = t.(yParam);

if log1
    x = log(x);
    xlab = sprintf('log(%s)',xParam);
else
    xlab = xParam;
end

if log2
    y = log(y);
    ylab = sprintf('log(%s)',yParam);
else
    ylab = yParam;
end

cla(handles.axes1);
plot(x,y,'*');

if handles.showNumbers.Value
    hold on
    for k=1:numel(x)
        text(x(k),y(k),num2str(k));
        hold on
    end
end

if regressionline
    hold on
    Y = y;
    X = [x ones(size(x))];
    [b,~,~,~,stats] = regress(Y,X);
    xl = xlim;
    plot(xl,b(1)*xl + b(2),'k--');
    rsquared = stats(1);
    p = stats(3);
    set(handles.regressionDetails,'String',sprintf('%s = %.2f %s + %.2f, R^2=%.2f, p=%.3f',ylab,b(1),xlab,b(2),rsquared,p));
else
    set(handles.regressionDetails,'String','');
end

xlabel(xlab);
ylabel(ylab);


% --- Outputs from this function are returned to the command line.
function varargout = testfeatures_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in xChoice.
function xChoice_Callback(~, ~, handles)
updategraph(handles)

% --- Executes on selection change in yChoice.
function yChoice_Callback(~, ~, handles)
updategraph(handles)

% --- Executes during object creation, after setting all properties.
function xChoice_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function yChoice_CreateFcn(hObject, ~, ~)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in log1.
function log1_Callback(~, ~, handles)
updategraph(handles)

% --- Executes on button press in log2.
function log2_Callback(~, ~, handles)
updategraph(handles)

% --- Executes on button press in regressionLine.
function regressionLine_Callback(~, ~, handles)
updategraph(handles)

% --- Executes on button press in showNumbers.
function showNumbers_Callback(~, ~, handles)
updategraph(handles)

% --- Executes on button press in zScores.
function zScores_Callback(~, ~, handles)
updategraph(handles)
