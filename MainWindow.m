function varargout = MainWindow(varargin)
% MAINWINDOW MATLAB code for MainWindow.fig
%      MAINWINDOW, by itself, creates a new MAINWINDOW or raises the existing
%      singleton*.
%
%      H = MAINWINDOW returns the handle to a new MAINWINDOW or the handle to
%      the existing singleton*.
%
%      MAINWINDOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAINWINDOW.M with the given input arguments.
%
%      MAINWINDOW('Property','Value',...) creates a new MAINWINDOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MainWindow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MainWindow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MainWindow

% Last Modified by GUIDE v2.5 20-Jun-2016 19:26:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MainWindow_OpeningFcn, ...
                   'gui_OutputFcn',  @MainWindow_OutputFcn, ...
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


% --- Executes just before MainWindow is made visible.
function MainWindow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MainWindow (see VARARGIN)

% Choose default command line output for MainWindow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

set(gcf,'windowkeypressfcn',@keypressfcn); 
% set(gcf,'WindowButtonMotionFcn',@ButtonMotionFcn)
set(gcf,'MenuBar','figure');
set(gcf,'ToolBar','figure');
set(gca,'Box','on');

classes = importdata('classes.txt', '%s');
setappdata(0, 'classes', classes);
setappdata(0, 'oncroping', 0);
[n_classes, ~] = size(classes);
mat = 1:n_classes;
ids = num2cell(mat');
class_map = containers.Map(classes,ids);
setappdata(0,'class_map',class_map);
% UIWAIT makes MainWindow wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MainWindow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function keypressfcn(hObject, eventdata, handles)
ctrl0=eventdata.Modifier;
if isempty(ctrl0)
    ctrl='';
else
    ctrl=ctrl0{1};
end
key=eventdata.Key;
switch ctrl
    case ''
        switch key
            case 'e'
                SaveBb();
                index = getappdata(0,'index');
                reload(index - 1);
            case 'd'
                SaveBb();
                index = getappdata(0,'index');
                reload(index + 1);
            case 'c'
                oncroping = getappdata(0, 'oncroping');
                if oncroping == 1
                    return;
                end
                setappdata(0, 'oncroping', 1);
                setappdata(0, 'changed', 1);
                setappdata(0, 'bb_delete', 1);
                classes = getappdata(0, 'classes');
                hrect = imrect;
                hrect_child = get(hrect, 'Children');
                hcmenu = get(hrect_child(1), 'UIContextMenu');
                hcmenu_child = get(hcmenu, 'Children');
                delete(hcmenu_child);
                for i = 1 : size(classes, 1)
                    uimenu(hcmenu, 'Label', classes{i, 1}, 'Callback', {@class_menu_cb, i});
                end
                uimenu(hcmenu, 'Label', 'Delete', 'Callback', {@class_menu_cb, -1});
                position = wait(hrect);
                position = int32(position);
                bb_delete = getappdata(0, 'bb_delete');
                if bb_delete ~= 1
                    rectangle('Position', position, 'edgecolor', 'r', 'LineWidth',4');
                    selected_class = getappdata(0, 'selected_class');
                    class_map = getappdata(0, 'class_map');
                    text(double(position(1)+5),double(position(2)+25), int2str(class_map(selected_class)), 'color', 'r', 'LineWidth',6', 'fontsize', 25);
                    bb_obj.classname = selected_class;
                    bb_obj.position = position;
                    bb_obj_all = getappdata(0, 'bb_obj_all');
                    bb_obj_all = [bb_obj_all bb_obj];
                    setappdata(0, 'bb_obj_all', bb_obj_all);
                end
                delete(hrect);
                setappdata(0, 'oncroping', 0);
            case 's'
                SaveBb();
                index = getappdata(0, 'index');
                reload(index);
        end

end

function class_menu_cb(hObject, callbackdata, selected_class)
classes = getappdata(0, 'classes');
if selected_class ~= -1
    setappdata(0, 'bb_delete', 0);
    setappdata(0, 'selected_class', classes{selected_class});
end
 
 
% --- Executes on button press in open.
function open_Callback(hObject, eventdata, handles)
% hObject    handle to open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname]=uigetfile({'*.bmp;*.jpg;*.gif;*.png','(*.bmp;*.jpg;*.gif;*.png)';'*.*','All Files'},'Open','Multiselect','on');
if  iscell(filename)==0 && filename == 0
    return;
end
if iscell(filename)==0
    filename={filename};
end

label_pathname = [pathname(1:(end-1)) '-bb/'];
if ~exist(label_pathname, 'dir'), mkdir(label_pathname);end
tmp_dir = [pathname(1:(end-1)) '-to-be-delete/'];
if ~exist(tmp_dir, 'dir'), mkdir(tmp_dir);end

setappdata(0, 'filename', filename);
setappdata(0, 'pathname', pathname);
setappdata(0, 'label_pathname', label_pathname);
setappdata(0, 'tmp_dir', tmp_dir);
setappdata(0, 'axes1', handles.axes1);
setappdata(0, 'text1', handles.text1);
setappdata(0, 'text2', handles.text2);

index = 1;
reload(index);

guidata(hObject,handles);


% --- Reload image of index
function reload(index)

pathname = getappdata(0, 'pathname');
filename = getappdata(0, 'filename');
label_pathname = getappdata(0, 'label_pathname');
axes1 = getappdata(0, 'axes1');
text1 = getappdata(0, 'text1');
text2 = getappdata(0, 'text2');

if index < 1.
    index = 1;
end
if index > length(filename)
    index = length(filename);
end
setappdata(0, 'index', index);

current_image = imread([pathname, filename{index}]);
[~, filename_i, ~] = fileparts(filename{index});
full_filename_i = [label_pathname filename_i '.txt'];
bb_obj_all = [];
if exist(full_filename_i,'file')
    bb_obj_all = load_bb(full_filename_i);
end
setappdata(0, 'bb_obj_all', bb_obj_all);

cla(axes1);
axes(axes1);
imshow(current_image);
class_map = getappdata(0, 'class_map');
for i = 1 : length(bb_obj_all)
	rectangle('Position', bb_obj_all(i).position, 'edgecolor', 'g', 'LineWidth',4' );
    text(double(bb_obj_all(i).position(1)+5),double(bb_obj_all(i).position(2)+25), int2str(class_map(bb_obj_all(i).classname)), 'color', 'g', 'LineWidth',6', 'fontsize', 25);
%     text(bb_obj_all(i).position(1),bb_obj_all(i).position(2),'horiz','center','color','r');
end
set(text1,'string',filename{index});
cntStr = [num2str(index) '/' num2str(length(filename))];
set(text2,'string',cntStr);
% guidata(hObject,handles);


% --- Save
function SaveBb()
changed = getappdata(0, 'changed');
if changed == 1
    index = getappdata(0, 'index');
    label_pathname = getappdata(0, 'label_pathname');
    filename = getappdata(0, 'filename');
    bb_obj_all = getappdata(0, 'bb_obj_all');
    [~, filename_i, ~] = fileparts(filename{index});
    label_filename = [label_pathname filename_i '.txt'];
    fid = fopen(label_filename, 'wt');
    for i = 1 : length(bb_obj_all)
        fprintf(fid, '%s %d %d %d %d\n', bb_obj_all(i).classname, bb_obj_all(i).position(1), bb_obj_all(i).position(2), bb_obj_all(i).position(3), bb_obj_all(i).position(4));
    end
    fclose(fid);
    setappdata(0, 'changed', 0);
end


% --- Load bounding-boxes
function bb_obj_all = load_bb(filename)
bb_obj_all = [];
fid = fopen(filename);
data = textscan(fid, '%s%d%d%d%d');
fclose(fid);
for i = 1 : size(data{1, 1}, 1)
    bb_obj.classname = data{1, 1}{i, 1};
    bb_obj.position = [data{1, 2}(i) data{1, 3}(i) data{1, 4}(i) data{1, 5}(i)];
    bb_obj_all = [bb_obj_all bb_obj];
end




% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setappdata(0, 'changed', 1);
bb_obj_all = [];
setappdata(0, 'bb_obj_all', bb_obj_all);
SaveBb();
index = getappdata(0, 'index');
reload(index);


% --- Executes on button press in delete_img.
function delete_img_Callback(hObject, eventdata, handles)
% hObject    handle to delete_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
index = getappdata(0, 'index');
filename = getappdata(0, 'filename');
pathname = getappdata(0, 'pathname');
tmp_dir = getappdata(0, 'tmp_dir');

current_image = imread([pathname, filename{index}]);
delete([pathname, filename{index}]);
imwrite(current_image, [tmp_dir, filename{index}]);

filename = [filename(1:index-1) filename(index+1:end)];
setappdata(0, 'filename', filename);
reload(index);


