%  
%							AUTHORS
%							IIT BOMBAY STUDENTS :
%
%							ARPIT MALANI (10305901)
%							HERMESH GUPTA (10305080)
%							RAHUL NIHALANI (10305003)
%							VIVEK V VELANKAR (10305050)
%
% 							Last Modified : 9 Nov 2010

%Setting resolution of your Camera
RESOLUTION_X=640;
RESOLUTION_Y=480;

fid = fopen('Camera.txt', 'w');
%Set camera Def is one it is generally 1 is for default webcam
vid = videoinput('winvideo', 2);
% Set the properties of the video object
set(vid, 'FramesPerTrigger', Inf);
%Setting the color space
set(vid, 'ReturnedColorspace', 'rgb')
%Time between two frames in millseconds
vid.FrameGrabInterval = 5;

%start the video aquisition here
start(vid)

% Set a loop that stop after 100 frames of aquisition
while(vid.FramesAcquired<=2000)
    
    global RED_X;
    global RED_Y;
    global GREEN_X;
    global GREEN_Y;
    global BLUE_X;
    global BLUE_Y;

    % Get the snapshot of the current frame
    data = getsnapshot(vid);
    
    % Now to track red objects in real time
    % we have to subtract the red component 

    % from the grayscale image to extract the red components in the image.
    diff_im_RED = imsubtract(data(:,:,1), rgb2gray(data));
    % from the grayscale image to extract the green components in the image.
    diff_im_GREEN = imsubtract(data(:,:,2), rgb2gray(data));
    % from the grayscale image to extract the blue components in the image.
    diff_im_BLUE = imsubtract(data(:,:,3), rgb2gray(data));
     
    % Convert the resulting grayscale image into a binary image.
    diff_im_RED = im2bw(diff_im_RED,0.18);
    % Convert the resulting grayscale image into a binary image.
    diff_im_GREEN = im2bw(diff_im_GREEN,0.08);
    % Convert the resulting grayscale image into a binary image.
    diff_im_BLUE = im2bw(diff_im_BLUE,0.18);
    
    % Remove all those pixels less than 300px
    diff_im_RED = bwareaopen(diff_im_RED,300);
    % Remove all those pixels less than 300px
    diff_im_GREEN = bwareaopen(diff_im_GREEN,300);
    % Remove all those pixels less than 300px
    diff_im_BLUE = bwareaopen(diff_im_BLUE,300);

    % Label all the connected components in the image.
    bw_RED = bwlabel(diff_im_RED, 8);
    % Label all the connected components in the image.
    bw_GREEN = bwlabel(diff_im_GREEN, 8);
    % Label all the connected components in the image.
    bw_BLUE = bwlabel(diff_im_BLUE, 8);
    
    % Here we do the image blob analysis.
    % We get a set of properties for each labeled region.
    stats_RED = regionprops(bw_RED, 'BoundingBox');
    % We get a set of properties for each labeled region.
    stats_GREEN = regionprops(bw_GREEN, 'BoundingBox');
    % We get a set of properties for each labeled region.
    stats_BLUE = regionprops(bw_BLUE, 'BoundingBox');
    
    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats_RED)
        bb = stats_RED(object).BoundingBox;
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
        %Finding out the centroid of the red circle 
        RED_X=bb(1)+bb(3)/2;
        RED_Y=bb(2)+bb(4)/2;
    end
     RED_X
     RED_Y

    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats_GREEN)
        bb = stats_GREEN(object).BoundingBox;
        rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
        %Finding out the centroid of the green circle 
        GREEN_X=bb(1)+bb(3)/2;
        GREEN_Y=bb(2)+bb(4)/2;
    end
      GREEN_X
      GREEN_Y
   
    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats_BLUE)
        bb = stats_BLUE(object).BoundingBox;
        rectangle('Position',bb,'EdgeColor','b','LineWidth',2)
        %Finding out the centroid of the blue circle 
        BLUE_X=bb(1)+bb(3)/2;
        BLUE_Y=bb(2)+bb(4)/2;
    end
        BLUE_X
        BLUE_Y
    
    % Display the image
    imshow(data)
    
    %This is a loop to bound the red objects in a rectangular box.
    for object = 1:length(stats_RED)
        bb = stats_RED(object).BoundingBox;
        %Bound Red Circle 
        rectangle('Position',bb,'EdgeColor','r','LineWidth',2)
    end
    
    for object = 1:length(stats_GREEN)
        bb = stats_GREEN(object).BoundingBox;
        %Bound Green Circle 
        rectangle('Position',bb,'EdgeColor','g','LineWidth',2)
    end
    
    for object = 1:length(stats_BLUE)
        bb = stats_BLUE(object).BoundingBox;
        %Bound Blue Circle 
        rectangle('Position',bb,'EdgeColor','b','LineWidth',2)
    end
    
    
    
        if(isempty(BLUE_X)|| isempty(BLUE_Y) || isempty(GREEN_X)|| isempty(GREEN_Y)||isempty(RED_X)|| isempty(RED_Y) )
        %if unable to find any of the above variable should do nothing.
        else
            
            %Finding out the centroid of the triangle formed by three circles
            CENTROID_X = (RED_X+GREEN_X+BLUE_X)/3.0;
            CENTROID_Y = (RED_Y+GREEN_Y+BLUE_Y)/3.0;
            %Finding out the angle by which bot has rotated
            theata=atand( (GREEN_Y-BLUE_Y)/(GREEN_X-BLUE_X));
            %Cases based on four Quadrents
            if( (BLUE_Y>=GREEN_Y ) && (BLUE_X>=GREEN_X) )
                 theata=theata
            end

            if(BLUE_X<GREEN_X) 
                theata=theata+180
            end

            if( (BLUE_Y<GREEN_Y ) && (BLUE_X>GREEN_X) )
                theata=theata+360
            end
            %Interpolate view coordinate to world coordinate
            position=[CENTROID_X-RESOLUTION_X/2 , RESOLUTION_Y/2-CENTROID_Y , 1]'
            %Applying Rotation Transformation
            rotate_theata=[cosd(theata),-sind(theata),0;sind(theata),cosd(theata),0;0,0,1];
            %Getting Absolute Position
            abs_position=rotate_theata*position;
            %Again shifting back world coordinate to view coordinate System
            image_position=[RESOLUTION_X/2+abs_position(1),RESOLUTION_Y/2-abs_position(2)];
            %convert time to string
            ts=datestr(now,'HHMMSSFFF');
            %convert time string to long
            t=(ts(1)-48)*100000000+(ts(2)-48)*10000000+(ts(3)-48)*1000000+(ts(4)-48)*100000+(ts(5)-48)*10000+(ts(6)-48)*1000+(ts(7)-48)*100+(ts(8)-48)*10+(ts(9)-48)
            %Writing timestamp ,centroid and positions to Camera.txt
            fprintf(fid, '%d,%f,%f,%f\n',t,theata,image_position(1),image_position(2))
        
        end
    %Clearing the pipe
    flushdata(vid);

end
% Both the loops end here.

% Stop the video aquisition.
stop(vid);

% Flush all the image data stored in the memory buffer.
flushdata(vid);

% Clear all variables
clear all