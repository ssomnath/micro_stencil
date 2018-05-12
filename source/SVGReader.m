clear;clc;
[FileName,PathName,FilterIndex] = uigetfile({'*.svg'},'Select the SVG file');
fprintf('Opened: %s\n',FileName);
fileToRead = strcat(PathName,FileName);%'50ums.txt';
basename = fileToRead(1:max(strfind(fileToRead,'.svg')-1));

fid = fopen(fileToRead);

clear('FilterIndex','PathName','FileName','fileToRead');

%% Parse Text

W1LineType = '#000000';% Black
W2LineType = '#ED1C24';% Red

tline = fgetl(fid);

i=1;j=1;
while ischar(tline)
    TargetVar = regexp(tline,'"','split');
    if(length(TargetVar)==11)
        scanheight = TargetVar{4};
        scanheight = scanheight(1:max(strfind(scanheight,'px')-1));
        scanheight = sscanf(scanheight,'%f');
    end
    if(length(TargetVar)==13)
        if(strcmp(TargetVar{2},'none'))
            if(strcmp(TargetVar{4},W1LineType))
                W1(i,1) = sscanf(TargetVar{6},'%f');
                % SVG inverts the y coords in the file for some reason.
                W1(i,2) = scanheight-sscanf(TargetVar{8},'%f');
                W1(i+1,1) = sscanf(TargetVar{10},'%f');
                W1(i+1,2) = scanheight-sscanf(TargetVar{12},'%f');
                W1(i+2,1) = NaN;
                W1(i+2,2) = NaN;
                i=i+3;
            elseif(strcmp(TargetVar{4},W2LineType))
                W2(j,1) = sscanf(TargetVar{6},'%f');
                W2(j,2) = scanheight-sscanf(TargetVar{8},'%f');
                W2(j+1,1) = sscanf(TargetVar{10},'%f');
                W2(j+1,2) = scanheight-sscanf(TargetVar{12},'%f');
                W2(j+2,1) = NaN;
                W2(j+2,2) = NaN;
                j=j+3;
            end
        end
    end
    tline = fgetl(fid);
end

fclose(fid);
disp('Parsed SVG');
clear('i','j','tline','TargetVar','fid','ans','W1LineType','W2LineType','scanheight');

%% Convert from pixel to um:

% Subtract x and y mins (of top left mesh box)
xmin = 91.505; ymin=503.26;
W1(:,1) = W1(:,1)-xmin;
W1(:,2) = W1(:,2)-ymin;
W2(:,1) = W2(:,1)-xmin;
W2(:,2) = W2(:,2)-ymin;

% Scale to microns:
scaleDX = 337.504E-9/8.31;
W1 = W1.*scaleDX;
W2 = W2.*scaleDX;

disp('Offsetted the scan and scaled to microns');
clear('xmin','ymin','scaleDX');

%% Snap to intersections:
% First see the differences in the x and y coordinates. Snap to 337.504/2 nm
intersects = 0.5 .* 337.504E-9;
W1(:,1) = round(W1(:,1)./intersects).* intersects;
W1(:,2) = round(W1(:,2)./intersects).* intersects;
W2(:,1) = round(W2(:,1)./intersects).* intersects;
W2(:,2) = round(W2(:,2)./intersects).* intersects;
disp('Snapped intersections to grid');
clear('intersects');

%% Write Sorted arrays to file.

file_1 = fopen(strcat(basename,'_W1.txt'),'w');
fprintf(file_1,'XLitho\tYLitho\twavelength\n');

fixedsize = ceil(size(W1,1)/3)*3;

fprintf(file_1,'%8.6E\t%8.6E\t%d\n',W1(1,1),W1(1,2),fixedsize);
clear('fixedsize');
fprintf(file_1,'%8.6E\t%8.6E\n',W1(2,1),W1(2,2));
fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');

% That completes the first line
% Now write the rest
for i=4:3:size(W1,1)
    fprintf(file_1,'%8.6E\t%8.6E\n',W1(i,1),W1(i,2));
    fprintf(file_1,'%8.6E\t%8.6E\n',W1(i+1,1),W1(i+1,2));
    fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');
end

% End of file writing. Close file:
fclose(file_1);
fprintf('Finished writing W1 pattern to file:\n%s\n',strcat(basename,'_W1.txt'));
clear('file_1','i','ans');



file_1 = fopen(strcat(basename,'_W2.txt'),'w');
fprintf(file_1,'XLitho\tYLitho\twavelength\n');

fixedsize = ceil(size(W2,1)/3)*3;

fprintf(file_1,'%8.6E\t%8.6E\t%d\n',W2(1,1),W2(1,2),fixedsize);
clear('fixedsize');
fprintf(file_1,'%8.6E\t%8.6E\n',W2(2,1),W2(2,2));
fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');

% That completes the first line
% Now write the rest
for i=4:3:size(W2,1)
    fprintf(file_1,'%8.6E\t%8.6E\n',W2(i,1),W2(i,2));
    fprintf(file_1,'%8.6E\t%8.6E\n',W2(i+1,1),W2(i+1,2));
    fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');
end

% End of file writing. Close file:
fclose(file_1);
fprintf('Finished writing W2 pattern to file:\n%s\n',strcat(basename,'_W2.txt'));
clear('file_1','i','ans');
disp('----------------------------------------------');