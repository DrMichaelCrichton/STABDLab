function varargout = GUI2(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI2_OutputFcn, ...
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


% --- Executes just before GUI2 is made visible.
function GUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% Choose default command line output for GUI2
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
handles.I = "LOGO.png";
axes(handles.axes17);
imshow(handles.I);
guidata(hObject,handles);
% UIWAIT makes GUI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI2_OutputFcn(hObject, eventdata, handles) 

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
    %Brings up dialog so user can select file
    %Once file has been selected, the path and filename are stored
    global pathname
    global filename
    global Imagearray
    [filename, pathname] = uigetfile({'*.png'; '*.tif'; '*.jpg';'*.bmp'},'File Selector');
    if isempty(filename)
        errordlg('No file was selected that contains the data');
        return
    end
    handles.myImage = strcat(pathname, filename);
    Imagearray = {};
    F = imread(strcat(pathname, filename));
    Imagearray = {F};
    axes(handles.axes4);
    imshow(handles.myImage)
    set(handles.text2,'string', filename);
    guidata(hObject,handles);
    
% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
if isfield(handles,'myImage')
    global Imagearray
    global counter
    global BinImg
    global path
    global pathname
    global filename
    %Image to be used is set to the binary image created
    value1 = get(handles.checkbox9, 'Value');
    if value1 == 1
        f = Imagearray{1};
    else
        f = imread(strcat(pathname, filename));
        labImage = rgb2lab(f);
        X = length(labImage(1,:))/3;
        Y = length(labImage(:,1));
        for i=1:Y
            for j=1:X
                if labImage(i,j,3)< 0
                    labImage(i,j,3) = 0;
                end
                labImage(i,j,2)=labImage(i,j,2)+labImage(i,j,3);
            end
        end
        figure(1);
        imshow(labImage(:, :, 2), []);    
        f1 = getframe(gca);
        f = struct2array(f1);
        close(1);
        handles.lab = f;
        axes(handles.axes5);
        imshow(handles.lab);
        imwrite(f, [path, 'a_channel', '.png']);
        f = imread(strcat(path,'a_channel.png'));
        im2 = rgb2gray(f);
        im = im2 - 5;
        newim = imadjust(im,[0.2 0.8],[]);
        ma = mean(im2);
        ma2 = 0.5 * mean(ma);
        X = length(newim(1,:));
        Y = length(newim(:,1));
        for i=1:Y
            for j=1:X
                if newim(i,j) < ma2
                    newim(i,j) = 0;
                end
            end
        end
        figure(1);
        imshow(newim);
        f1 = getframe(gca);
        f = struct2array(f1);
        close(1);
        handles.lab = f;
        axes(handles.axes5);
        imshow(handles.lab);
        imwrite(f, [path, 'a_channel_enhanced', '.png']);
        f = imread(strcat(path,'a_channel_enhanced.png'));   
    end
    
    F = fft2(f);
    F = fftshift(F); % Center FFT
    
    F = abs(F); % Get the magnitude
    F = log(F+1); % Use log, for perceptual scaling, and +1 since log(0) is undefined
    F = mat2gray(F); % Use mat2gray to scale the image between 0 and 1
    X = length(F(1,:));
    f = imresize(F, [X,X]);
    counter = 2;
    Imagearray{2} = f;
    I=Imagearray{2};
    %Calls polar conversion function
    fpcimg = ImToPolar(I);
    F1 = (log(abs(fpcimg)+1));
    %Turns image into an image with varying intensities
    F = mat2gray(F1); % Use mat2gray to scale the image between 0 and 1
    handles.F = F;
    Imagearray{3} = F;
    counter = 3;
    img = getframe(gca);
    imwrite(F, [path, 'Polar', '.png']);
    f1 = imread(strcat(path,'Polar.png'));
    X = length(f1(1,:))/3;
    X1 = length(f1(1,:));
    Y1 = length(f1(:,1));
    Y = Y1;
    array1 = f1;
    filename = 'Intensities.png';
    imwrite(ind2rgb(im2uint8(mat2gray(array1)), parula(256)), strcat(path,filename));
    array = [];
    pix_vals = [];
    pix_vals2 = [];
    av = mean(f1);
    %For the first 180 degrees
    for i=1:180
        %Define a start point and end point using 2D coordinates
        x1 = 270+2-i;
        y1 = 1;
        x2 = 270+2-i;
        y2 = Y;
        xi = [x1 x2];
        yi = [y1 y2];
        
        x3 = 180+2-i;
        y3 = 1;
        x4 = 180+2-i;
        y4 = Y;
        xi2 = [x3 x4];
        yi2 = [y3 y4];
        
        %Draw a line between these points
        d = improfile(f1, xi, yi);
        d2 = improfile(f1, xi2, yi2);
        t=0;
        t2 = 0;
        %Sum up pixel intensities of all pixels which touch the line
        count = 0;
        count2 = 0;
        for j=1:Y
            pix_vals(j,i) = d(j);
            pix_vals2(j,i) = d2(j);
            q = pix_vals(j,i);
            q2 = pix_vals2(j,i);
            if q > av
                count = count+1;
            end
            if q2 > av
                count2 = count2 +1;
            end 
        end
        array(i) = count^3.3;
        array2(i) = count2^3.3;
    end
    
    tp = 0;
    for i=1:length(array)
        tp = tp + (array(i));
    end
    proparray = zeros(1,36);
    prop_array = zeros(1,36);
    
    %calculates intensities along a 5 degree bin size
    for i=1:5:length(array)
        proparray(i) = (array(i)/tp)*100+(array(i+1)/tp)*100+(array(i+2)/tp)*100+(array(i+3)/tp)*100+(array(i+4)/tp)*100 ;
    end
    count3 = 1;
    for i=1:length(array)/3
        prop_array(i) = (array(count3))+(array(count3+1))+(array(count3+2)) ;
        count3 = count3+3;
    end
    s = mean(prop_array);
    for i=1:length(prop_array)
        prop_array(i) = prop_array(i)/s;
    end   
    
    N = length(prop_array);
    d1=0;
    d2=0;
    d=0;
    for i=1:length(prop_array)
        
        for j=1:length(prop_array)
            d2 = d2+((prop_array(j)^2.5));
        end
        d2 = d2/N;
        d1 = d1+d2;
        
        d2 = 0;
    end
    
    d = (1-(N/d1))^(0.8);
    
    display(d);
    display(prop_array);

    %Obtain x-axis scale i.e 0 to 180 degrees
    step = -90;
    xaxis = [];
    for i=1:length(array)
        xaxis(i) = step;
        step = step + 1;
    end
    tp2 = 0;
    for i=1:length(array)
        tp2 = tp2 + (array2(i));
    end
    for i=1:5:length(array2)
        proparray2(i) = (array2(i)/tp2)*100+(array2(i+1)/tp2)*100+(array2(i+2)/tp2)*100+(array2(i+3)/tp2)*100+(array2(i+4)/tp2)*100 ;
    end
    
    step = -90;
    step2 = -90;
    X_axis2 = [];
    X_axis = zeros(1,180);
    for i=1:180
        X_axis(i) = step;
        
        step = step+1;
    end
    for j=1:176
        X_axis2(j) = step2;
        step2 = step2+1;
    end
    
    %Plot histogram
    handles.F = proparray2;
    display(length(proparray2));
    display(length(X_axis2));
    axes(handles.axes2);
    bar(X_axis2,handles.F)
    figure(3);
    bar(handles.F)
    img2 = getframe(gcf);
    close(3);
    imwrite(img2.cdata, [path, 'Plot1', '.png'])
    img = getframe(gcf);
    
    countr = 1;
    new_array = [];
    for i=1:length(array2)/5
        new_array(i) = array2(countr)+array2(countr+1)+array2(countr+2)+array2(countr+3)+array2(countr+4);
        countr = countr + 5;
    end
    countr = 1;
    new_array2 = [];
    for i=1:length(array)/5
        new_array2(i) = array(countr)+array(countr+1)+array(countr+2)+array(countr+3)+array(countr+4);
        countr = countr + 5;
    end
    
    filename = strcat('Intensity Values', i, '.txt' );
    fileID = fopen(strcat(path,filename), 'w');
    for z =1:length(new_array)
        fprintf(fileID, '%f\r\n', string(new_array(z)));
    end
    fclose(fileID);
    
    t=1:numel((-90:5:88));
    xy = [(-90:5:88);new_array];
    pp = spline(t,xy);
    tInterp = linspace(1,numel((-90:5:88)));
    xyInterp = ppval(pp,tInterp);
    handles.arr = new_array;
    axes(handles.axes9);
    plot(xyInterp(1,:),xyInterp(2,:))
    figure(3);
    plot(xyInterp(1,:),xyInterp(2,:))
    img = getframe(gcf);
    close(3);
    imwrite(img.cdata, [path, 'Plot3', '.png'])
    handles.G = new_array2;
    axes(handles.axes3);
    polarplot(deg2rad(1:5:176), handles.G);
    figure(3);
    polarplot(deg2rad(1:5:176), handles.G);
    img2 = getframe(gcf);
    close(3);
    imwrite(img2.cdata, [path, 'Plot2', '.png'])
    

    set(handles.text16,'string', string(d));
    
end

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
    

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)

% --- Executes during object deletion, before destroying properties.
function axes4_DeleteFcn(hObject, eventdata, handles)

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)

% --- Executes on button press in checkbox9.
function checkbox9_Callback(hObject, eventdata, handles)

function edit2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
global path
path = strcat(char(get(handles.edit2, 'String')), '\');
