%Accessing video frames..
vid = videoinput('winvideo', 1, 'YUY2_320x240');
set(vid, 'FramesPerTrigger', Inf);
set(vid, 'ReturnedColorspace', 'rgb')
%This sets the Frame rate to 15fps
vid.FrameGrabInterval = 2;
    start(vid)
    %Some memory variables to avoid unwanted click errors
    count = 0;
    bc(2,5) = 0;
    bc(1,5) = 0;
    brec(1,3) = 0;
    brec(1,:) = 0;
    click = 0;
    %Importing java classes to use functions like mousemove and mouse click
    import java.awt.Robot;
import java.awt.event.*;
mouse = Robot;
%Processing the frames to find red and blue objects
while(vid.FramesAcquired<=10000)
    data = getsnapshot(vid);
    %Rotating the frame left to right
    data(:,:,1) = fliplr(data(:,:,1));
    data(:,:,2) = fliplr(data(:,:,2));
    data(:,:,3) = fliplr(data(:,:,3));
    %diff_im is data regarding Red object and diff_imb regarding Blue
    diff_im = imsubtract(data(:,:,1), rgb2gray(data));
    diff_imb = imsubtract(data(:,:,3), rgb2gray(data));
    diff_im = medfilt2(diff_im, [3 3]);
    diff_imb = medfilt2(diff_imb, [3 3]);    
    diff_im = im2bw(diff_im,0.15);
    diff_imb = im2bw(diff_imb,0.05);
    diff_im = bwareaopen(diff_im,300);    
    diff_imb = bwareaopen(diff_imb,300);    
    bw = bwlabel(diff_im, 8);
    bwb = bwlabel(diff_imb, 8);
    stats = regionprops(bw, 'Centroid');
    statsb = regionprops(bwb, 'Centroid');
    %cycling the memory variables to update the memory
    if ~isempty(stats)
        count = count+1;
        for j = 2:5
      bc(1,j-1) = bc(1,j);
      bc(2,j-1) = bc(2,j);
        end
      bc(1,5) = stats(1).Centroid(1);
      bc(2,5) = stats(1).Centroid(2); 
      %Finding number of red and blue objects
    end
    ar = size(stats);
    ab = size(statsb);
        brec(1,2) = brec(1,3);
        brec(1,1) = brec(1,2);
    brec(1,3) = ab(1,1);
    %Performing a click only if object was avaible in the previous three
    %frames
    if ( (brec(1,3) == 1)&&((brec(1,2)==1)||(brec(1,1)==1)) )
        click = 2;
    elseif ab(1,1) == 1
        click = 1;
    else click = 0;
    end
    imshow(data)
    hold on
    %Showing no of frames
    at = text(490,460,strcat('Frame count:', num2str(vid.FramesAcquired)));
   set(at, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'black');
   %Displaying Number of objects
    ared = text(5,15, num2str(ar(1,1)));
    ablue = text(15,15,num2str(ab(1,1)));
   set(ared, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'red');
   set(ablue, 'FontName', 'Arial', 'FontWeight', 'bold', 'FontSize', 12, 'Color', 'blue');
    hold off
    %Finally using the mouse move and mouse click operations when needed
     if ((~(count == 0))&&(ar(1,1)~=0))
         mouse.mouseMove(round((1366/640)*(bc(1,5))),round((768/480)*(bc(2,5))))
     end
     if ((~(count == 0)))
         if click == 1
             mouse.mousePress(InputEvent.BUTTON1_MASK)
         elseif click ==0
             mouse.mouseRelease(InputEvent.BUTTON1_MASK)
         end
     end
end
stop(vid);
flushdata(vid);
close all;
clear all;
clc;