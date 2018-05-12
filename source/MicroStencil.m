function varargout = MicroStencil(varargin)
% MICROSTENCIL M-file for MicroStencil.fig
%      MICROSTENCIL, by itself, creates a new MICROSTENCIL or raises the existing
%      singleton*.
%
%      H = MICROSTENCIL returns the handle to a new MICROSTENCIL or the handle to
%      the existing singleton*.
%
%      MICROSTENCIL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MICROSTENCIL.M with the given input arguments.
%
%      MICROSTENCIL('Property','Value',...) creates a new MICROSTENCIL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MicroStencil_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MicroStencil_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MicroStencil

% Last Modified by GUIDE v2.5 30-Jan-2012 14:18:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MicroStencil_OpeningFcn, ...
                   'gui_OutputFcn',  @MicroStencil_OutputFcn, ...
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


% --- Executes just before MicroStencil is made visible.
function MicroStencil_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MicroStencil (see VARARGIN)

% Choose default command line output for MicroStencil
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MicroStencil wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MicroStencil_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Begin of user Generated Code:

function button_loadimage_Callback(hObject, eventdata, handles)
    [FileName,PathName,FilterIndex] = uigetfile({'*.png';'*.jpg';'*.jpeg';'*.gif';'*.bmp'},'Select an Image file');
    if(~strcmp(FileName,''))
        global I;
        I = imread(strcat(PathName, FileName));
        imshow(I); axis image; hold on;
        imsz = size(I);
        global deltaX deltaY;
        numlines = floor(str2double(get(handles.txt_gridLines,'String')));
        if numlines > 0
            hpixels = imsz(2);
            vpixels = imsz(1);
            deltaY = round(vpixels/numlines);
            deltaX = round(hpixels/numlines);
            Y = 0:deltaY:deltaY*numlines;
            X = 0:deltaX:deltaX*numlines;
            for i=1:length(Y)
                plot([0,hpixels],[Y(i),Y(i)],'g','LineWidth',1); hold on;
                plot([X(i),X(i)],[0,vpixels],'g','LineWidth',1); hold on;
            end
        else
            deltaX=0;
            deltaY=0;
        end
    end
       
    % creation of global matrices
    % to hold the list of points for all the lines
    global Xpnts Ypnts linecount;
    Xpnts = 0;
    Ypnts = 0;
    linecount = 0;
    
    listenForLines()
 
    guidata(hObject, handles);
%End of Load Image


function button_startstopline_Callback(hObject, eventdata, handles)
    
    listenForLines();
    
    guidata(hObject,handles);
% End of start stop line

function listenForLines()

stopTriggers = 0;

while(1)
   [x,y] = ginput;
   
   if(size(x,1) == 0)
       
       stopTriggers = stopTriggers + 1;
       
       if(stopTriggers >= 3)
           % User is done with lines for now.
           break;
       end
       

   elseif(size(x,1) == 2)
       
       stopTriggers = 0;

       global deltaX deltaY Xsnap Ysnap;
        if deltaY > 0
            for i=1:length(y)
                if(Xsnap)
                    x(i) = deltaX*round(x(i)/deltaX);
                end
                if(Ysnap)
                    y(i) = deltaY*round(y(i)/deltaY);
                end
            end
        end
        plot(x,y,'r*-','LineWidth',2);hold on;
        % Appending these to the global x and y points:
        global Xpnts Ypnts linecount OldXpnts OldYpnts;

        OldXpnts = Xpnts;
        OldYpnts = Ypnts;

        linecount = linecount + length(x) - 1;
        growsize = length(Xpnts);
        if(growsize == 1)
            Xpnts = x;
            Ypnts = y;
        else
            % separating the lines using an infinty:
            Xpnts(growsize+1,1) = inf;
            Ypnts(growsize+1,1) = inf;
            % Just appending to the global:
            Xpnts(growsize+2:growsize+1+length(x),1) = x;
            Ypnts(growsize+2:growsize+1+length(x),1) = y;
        end 
   end
end

function button_generateOutput_Callback(hObject, eventdata, handles)
    global Xpnts Ypnts linecount I;
    
    % Finding the max manually:
    xmax = 0;
    ymax = 0;
    imsz = size(I);
    hpixels = imsz(2);
    vpixels = imsz(1);
    lithosize = 1e-6 * str2double(get(handles.lithoSizeBox,'String'));
    
    % Assume square image -> Introduce Aspect ratio concept if not square
    Xpnts = Xpnts.* (lithosize/hpixels);
    Ypnts = Ypnts.* (lithosize/vpixels);
    
    for i=1:length(Ypnts)
        if(Ypnts(i) < inf && ymax < Ypnts(i))
            ymax = Ypnts(i);
        end
        if(Ypnts(i) == inf)
            Ypnts(i) = -inf;
        end
    end
    
    % For some reason the y coordinates are
    % all inverted. So inverting them before
    % doing any further calculations.
    Ypnts = ymax - Ypnts;
    
    %figure(3)
    %plot(Xpnts,Ypnts)
    %Xpnts = Xpnts - min(Xpnts);
    %Ypnts = Ypnts - min(Ypnts);
    %for i=1:length(Xpnts)
    %    if(Xpnts(i) < inf && xmax < Xpnts(i))
    %        xmax = Xpnts(i);
    %   end
    %end

    %aspectratio = ymax / xmax;
    %Xpnts = Xpnts ./ xmax;
    %Ypnts = Ypnts ./ ymax;
    
    %converting all the numbers to make the desired sized image:
    %lithosize = 1e-6 * str2double(get(handles.lithoSizeBox,'String'));
    %if(ymax > xmax)
    %    Ypnts = Ypnts * lithosize;
   %     Xpnts = Xpnts * (1/aspectratio) * lithosize;
   % else
   %     Xpnts = Xpnts * lithosize;
   %     Ypnts = Ypnts * (1/aspectratio) * lithosize;
    %end
    
    figure(2)
    plot(Xpnts,Ypnts)
    
    % Providing an offset:
    %Xpnts = Xpnts + 1e-6;
    %Ypnts = Ypnts + 4e-6;
    
    % Now starting to write the file:
    % Note: Each line is separated by an empty line
    
    [FileName,PathName,FilterIndex] = uiputfile({'*.txt'},'Provide a file name to save to');
    
    file_1 = fopen(strcat(PathName, FileName),'w');

    fprintf(file_1,'XLitho\tYLitho\twavelength\n');       
    
    fprintf(file_1,'%8.6E\t%8.6E\t%d\n',Xpnts(1),Ypnts(1),linecount*3);
    if(Xpnts(2) == inf)
        %Should not be the case ideally:
        fprintf(file_1,'%8.6E\t%8.6E\n',Xpnts(1),Ypnts(1));
    else
        fprintf(file_1,'%8.6E\t%8.6E\n',Xpnts(2),Ypnts(2));
    end
    fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');
    
    % That completes the first line
    % Now write the rest
    for i=3:(length(Xpnts)-1)
        if(Xpnts(i+1) == inf || Xpnts(i) == inf)
            % That was the last point from the previous chain
            % Dont bother doing anything
            continue;
        else
            fprintf(file_1,'%8.6E\t%8.6E\n',Xpnts(i),Ypnts(i));
            fprintf(file_1,'%8.6E\t%8.6E\n',Xpnts(i+1),Ypnts(i+1));
            fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');
        end
    end
    
    % End of file writing. Close file:
    fclose(file_1);
    
% Endof generateOutput



function text3_DeleteFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function txt_gridLines_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txt_gridLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txt_gridLines_Callback(hObject, eventdata, handles)
% hObject    handle to txt_gridLines (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txt_gridLines as text
%        str2double(get(hObject,'String')) returns contents of txt_gridLines as a double'
input = str2double(get(hObject,'String'));
%checks to see if input is empty. if so, default editText to zero
if (isempty(input))
     set(hObject,'String','0')
end
guidata(hObject, handles);



function lithoSizeBox_Callback(hObject, eventdata, handles)
% hObject    handle to lithoSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lithoSizeBox as text
%        str2double(get(hObject,'String')) returns contents of lithoSizeBox as a double


% --- Executes during object creation, after setting all properties.
function lithoSizeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lithoSizeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in UndoButton.
function UndoButton_Callback(hObject, eventdata, handles)
% hObject    handle to UndoButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Xpnts Ypnts OldXpnts OldYpnts;
    
Xpnts = OldXpnts;
Ypnts = OldYpnts;

% Erase all points
hold off;

% Redraw figure
global I;
imshow(I); axis image; hold on;

% Redraw grid:
numlines = floor(str2double(get(handles.txt_gridLines,'String')));
if numlines > 0
    imsz = size(I);
    hpixels = imsz(2);
    vpixels = imsz(1);
    deltaY = round(vpixels/numlines);
    deltaX = round(hpixels/numlines);
    Y = 0:deltaY:deltaY*numlines;
    X = 0:deltaX:deltaX*numlines;
    for i=1:length(Y)
        plot([0,hpixels],[Y(i),Y(i)],'g','LineWidth',1); hold on;
        plot([X(i),X(i)],[0,vpixels],'g','LineWidth',1); hold on;
    end
else
    deltaX=0;
    deltaY=0;
end

% Redraw lines:
[r,c] = find(Xpnts==Inf);
numchains = size(r,1);

if(numchains > 1)
    % Plot first chain only:
    plot(Xpnts(1:r(1)-1),Ypnts(1:r(1)-1),'r*-','LineWidth',2);hold on;
    % Plot next few:
    for i = 2:numchains
        plot(Xpnts(r(i-1)+1:r(i)-1),Ypnts(r(i-1)+1:r(i)-1),'r*-','LineWidth',2);hold on;
    end
    % Plot last chain:
    plot(Xpnts(r(numchains)+1:size(Xpnts,1)),Ypnts(r(numchains)+1:size(Xpnts,1)),'r*-','LineWidth',2);hold on;
end

guidata(hObject, handles);


% --- Executes on button press in ClearPatternsButton.
function ClearPatternsButton_Callback(hObject, eventdata, handles)
% hObject    handle to ClearPatternsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global Xpnts Ypnts OldXpnts OldYpnts;

OldXpnts = Xpnts;
OldYpnts = Ypnts;
Xpnts = zeros(1,1);
Ypnts = zeros(1,1);

% Erase all points
hold off;

% Redraw figure
global I;
imshow(I); axis image; hold on;

% Redraw grid:
numlines = floor(str2double(get(handles.txt_gridLines,'String')));
if numlines > 0
    imsz = size(I);
    hpixels = imsz(2);
    vpixels = imsz(1);
    deltaY = round(vpixels/numlines);
    deltaX = round(hpixels/numlines);
    Y = 0:deltaY:deltaY*numlines;
    X = 0:deltaX:deltaX*numlines;
    for i=1:length(Y)
        plot([0,hpixels],[Y(i),Y(i)],'g','LineWidth',1); hold on;
        plot([X(i),X(i)],[0,vpixels],'g','LineWidth',1); hold on;
    end
else
    deltaX=0;
    deltaY=0;
end

guidata(hObject, handles);


% --- Executes on button press in Chk_XSnap.
function Chk_XSnap_Callback(hObject, eventdata, handles)
% hObject    handle to Chk_XSnap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Chk_XSnap
global Xsnap;

Xsnap = get(hObject,'Value');

guidata(hObject, handles);

% --- Executes on button press in Chk_YSnap.
function Chk_YSnap_Callback(hObject, eventdata, handles)
% hObject    handle to Chk_YSnap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Chk_YSnap
global Ysnap;

Ysnap = get(hObject,'Value');

guidata(hObject, handles);