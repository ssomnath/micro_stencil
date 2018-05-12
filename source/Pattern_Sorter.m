%% Excel paste to get pattern:
Driver = zeros(2,2);
SubPattern = zeros(2,2);
SubPatternV = zeros(2,2);

% Paste data into Driver & Subpattern now

%% Scale to microns & Add NaNs
Driver = Driver .* 1E-6;
SubPattern = SubPattern .* 1E-6;
SubPatternV = SubPatternV .* 1E-6;

for i=3:3:size(Driver,1)
    Driver(i,1) = NaN;
    Driver(i,2) = NaN;
end
for i=3:3:size(SubPattern,1)
    SubPattern(i,1) = NaN;
    SubPattern(i,2) = NaN;
end
for i=3:3:size(SubPatternV,1)
    SubPatternV(i,1) = NaN;
    SubPatternV(i,2) = NaN;
end
disp('Scaled to microns & Formatted NaNs');
clear('i');

%% Load Files

clear;clc;
[FileName,PathName,FilterIndex] = uigetfile({'*.txt'},'Select the Driver pattern file');
fprintf('Loaded Driver: %s to memory\n',FileName);
MainFileName = strcat(PathName,FileName);
newData1 = importdata(MainFileName, '\t', 1);
vars = fieldnames(newData1);
Driver = newData1.(vars{1});
clear('vars','newData1','FilterIndex','FileName','PathName','MainFileName');
Driver = Driver(:,1:2); % delete the 3rd column. All new lines are deleted on load.
% Assume that there exist no chains of segments. ie - disjoint segments

[FileName,PathName,FilterIndex] = uigetfile({'*.txt'},'Select the Sub-pattern file');
SubFileName = strcat(PathName,FileName);
fprintf('Loaded SubPattern: %s to memory\n',FileName);
newData1 = importdata(SubFileName, '\t', 1);
vars = fieldnames(newData1);
SubPattern = newData1.(vars{1});
basename = SubFileName(1:max(strfind(SubFileName,'.txt')-1));
clear('vars','newData1','FilterIndex','SubFileName','FileName','PathName');
SubPattern = SubPattern(:,1:2);

%% Load Y as well:

[FileName,PathName,FilterIndex] = uigetfile({'*.txt'},'Select the Y Driver pattern file');
fprintf('Loaded Y Driver: %s to memory\n',FileName);
MainFileName = strcat(PathName,FileName);
newData1 = importdata(MainFileName, '\t', 1);
vars = fieldnames(newData1);
DriverV = newData1.(vars{1});
clear('vars','newData1','FilterIndex','FileName','PathName','MainFileName');
DriverV = DriverV(:,1:2); % delete the 3rd column. All new lines are deleted on load.
% Assume that there exist no chains of segments. ie - disjoint segments

[FileName,PathName,FilterIndex] = uigetfile({'*.txt'},'Select the Y Sub-pattern file');
SubFileName = strcat(PathName,FileName);
fprintf('Loaded Y SubPattern: %s to memory\n',FileName);
newData1 = importdata(SubFileName, '\t', 1);
vars = fieldnames(newData1);
SubPatternV = newData1.(vars{1});
basename = SubFileName(1:max(strfind(SubFileName,'.txt')-1));
clear('vars','newData1','FilterIndex','SubFileName','FileName','PathName');
SubPatternV = SubPatternV(:,1:2);

%%  Scale subpattern so that lines match (Raster only):

% Scale data (for parallel lines in raster scan):
Driver_dY = abs(Driver(4,2) - Driver(1,2));
SubPat_dY = abs(SubPattern(4,2) - SubPattern(1,2)); % VERY WRONG LINE!!!
SubPattern(:,2) = (Driver_dY/SubPat_dY).* SubPattern(:,2);
clear('SubPat_dY');
fprintf('dY line rescaling applied\n');

%%  Scale subpattern so that lines match (Raster only):

% Scale data (for parallel lines in raster scan):
Driver_dX = abs(Driver(4,1) - Driver(1,1));
SubPat_dX = abs(SubPattern(4,1) - SubPattern(1,1)); % VERY WRONG LINE!!!
SubPattern(:,1) = (Driver_dX/SubPat_dX).* SubPattern(:,1);
clear('SubPat_dX');
fprintf('dX line rescaling applied\n');

%% Y-Offset Subpattern

% Move data up by ? lines:
moveUpLines = 1;
Driver_dY = abs(Driver(4,2) - Driver(1,2));
for i=1:size(SubPattern,1)
    if(isnan(SubPattern(i,2)) == 0)
        SubPattern(i,2) = SubPattern(i,2) + moveUpLines * Driver_dY;
    end
end

fprintf('moved up by %d lines\n',moveUpLines);
clear('i','moveUpLines');

%% Y-Offset VERTICAL Subpattern

% Move data up by ? lines:
moveUpLines = 0.2;
for i=1:size(SubPatternV,1)
    if(isnan(SubPatternV(i,2)) == 0)
        SubPatternV(i,2) = SubPatternV(i,2) + moveUpLines * 1E-6;
    end
end

fprintf('moved up by Y subpattern by %d lines\n',moveUpLines);
clear('i','moveUpLines');

%% X-Offset Subpattern

% Move data up by ? lines:
moveRightLines = 2;
Driver_dX = abs(Driver(4,1) - Driver(1,1));
for i=1:size(SubPattern,1)
    if(isnan(SubPattern(i,1)) == 0)
        SubPattern(i,1) = SubPattern(i,1) + moveRightLines * Driver_dX;
    end
end

fprintf('moved up by %d lines\n',moveUpLines);
clear('i','moveRightLines');

%% X scaling (pattern is too wide but not too tall)

scaling = 0.8;
for i=1:size(SubPattern,1)
    if(isnan(SubPattern(i,2)) == 0)
        SubPattern(i,1) = SubPattern(i,1) * scaling;
    end
end

fprintf('Shrunk line widths to %3.2f times\n',scaling);
clear('i','scaling');


%% X-Offset Subpattern:

moveRightMicrons = 0.25;

for i=1:size(SubPattern,1)
    if(isnan(SubPattern(i,1)) == 0)
        SubPattern(i,1) = SubPattern(i,1) + moveRightMicrons.*1E-6;
    end
end

fprintf('Moved right by %3.2f microns\n', moveRightMicrons);
clear('i','moveRightMicrons');

%% Plot to visualize alignment issues:

figure(1); hold off;
a = isnan(Driver(:,1));
[r,c] = find(a==1);
numchains = size(r,1);
if(numchains > 1)
    % Plot first chain only:
    plot(Driver(1:r(1)-1,1),Driver(1:r(1)-1,2),'g','LineWidth',1);hold on;
    % Plot next few:
    for i = 2:numchains
        plot(Driver(r(i-1)+1:r(i)-1,1),Driver(r(i-1)+1:r(i)-1,2),'g','LineWidth',1);hold on;
    end
    % Plot last chain:
    plot(Driver(r(numchains)+1:size(Driver,1),1),Driver(r(numchains)+1:size(Driver,1),2),'g','LineWidth',1);hold on;
end

a = isnan(SubPattern(:,1));
[r,c] = find(a==1);
numchains = size(r,1);
if(numchains > 1)
    % Plot first chain only:
    plot(SubPattern(1:r(1)-1,1),SubPattern(1:r(1)-1,2),'r','LineWidth',2);hold on;
    % Plot next few:
    for i = 2:numchains
        plot(SubPattern(r(i-1)+1:r(i)-1,1),SubPattern(r(i-1)+1:r(i)-1,2),'r','LineWidth',2);hold on;
    end
    % Plot last chain:
    plot(SubPattern(r(numchains)+1:size(SubPattern,1),1),SubPattern(r(numchains)+1:size(SubPattern,1),2),'r','LineWidth',2);hold on;
end

clear('a','r','c','numchains','i');

%% Plot Y Driver only:

a = isnan(DriverV(:,1));
[r,c] = find(a==1);
numchains = size(r,1);
if(numchains > 1)
    % Plot first chain only:
    plot(DriverV(1:r(1)-1,1),DriverV(1:r(1)-1,2),'y','LineWidth',1);hold on;
    % Plot next few:
    for i = 2:numchains
        plot(DriverV(r(i-1)+1:r(i)-1,1),DriverV(r(i-1)+1:r(i)-1,2),'y','LineWidth',1);hold on;
    end
    % Plot last chain:
    plot(DriverV(r(numchains)+1:size(DriverV,1),1),DriverV(r(numchains)+1:size(DriverV,1),2),'y','LineWidth',1);hold on;
end

clear('a','r','c','numchains','i');

%% Y Sub only;

a = isnan(SubPatternV(:,1));
[r,c] = find(a==1);
numchains = size(r,1);
if(numchains > 1)
    % Plot first chain only:
    plot(SubPatternV(1:r(1)-1,1),SubPatternV(1:r(1)-1,2),'LineWidth',2);hold on;
    % Plot next few:
    for i = 2:numchains
        plot(SubPatternV(r(i-1)+1:r(i)-1,1),SubPatternV(r(i-1)+1:r(i)-1,2),'LineWidth',2);hold on;
    end
    % Plot last chain:
    plot(SubPatternV(r(numchains)+1:size(SubPatternV,1),1),SubPatternV(r(numchains)+1:size(SubPatternV,1),2),'LineWidth',2);hold on;
end

clear('a','r','c','numchains','i');

%% Actual Sorting:

% Some source files don't have the last NaN
sz = 3 * ceil(size(SubPattern,1)/3);
Transferred = zeros(sz,1);
SortedPattern = zeros(sz,2);
lastLineIndex = 1;

% Will NOT limit to horizontal lines only. Lines may be of any angle
% Assume sub pattern lines fall COMPLETELY within the main pattern lines
for i=1:3:size(Driver,1)
    
    % For each line in the driver. Set up subpattern lines
    
    compareStartIndex = lastLineIndex;
    
    for j=1:3:size(SubPattern,1)
        % Don't bother checking line if already transferred
        if(Transferred(j) == 0)
        
            % Check if the line is within the main line by checking if the
            % start and end points lie within the Driver line
            
            % Point 1 within Driver line?
            d1 = pointLineDist(Driver(i,1),Driver(i,2),Driver(i+1,1),Driver(i+1,2),SubPattern(j,1),SubPattern(j,2));
            % Point 2 within Driver Line?
            d2 = pointLineDist(Driver(i,1),Driver(i,2),Driver(i+1,1),Driver(i+1,2),SubPattern(j+1,1),SubPattern(j+1,2));
            
            tolerance = 1E-8;
            
            if(abs(d1) < tolerance && abs(d2) < tolerance)
                % Place this line within new SORTED array
                

                % proximity to start 
                pNewX = min(abs(Driver(i,1) - SubPattern(j,1)), abs(Driver(i,1) - SubPattern(j+1,1)));
                pNewY = min(abs(Driver(i,2) - SubPattern(j,2)), abs(Driver(i,2) - SubPattern(j+1,2)));
                pNew = pNewX+pNewY;
                clear('pNewX','pNewY');
                % compare with existing lines on sorted array wrt
                % current Driver line. Compare ONLY with those lines
                % that were added for this Driver line only

                inserted = 0;

                k=compareStartIndex;

                while k < lastLineIndex

                    % Assuming that one subPattern line will NOT
                    % encompass another line but allowing minor
                    % overlapping to occur. Just compare proximity to
                    % start OR end point of driver line
                    pOldX = min(abs(Driver(i,1) - SortedPattern(k,1)), abs(Driver(i,1) - SortedPattern(k+1,1)));
                    pOldY = min(abs(Driver(i,2) - SortedPattern(k,2)), abs(Driver(i,2) - SortedPattern(k+1,2)));
                    pOld = pOldX + pOldY;
                    clear('pOldX','pOldY');

                    if pNew < pOld
                      % This will require moving remaining entries
                      % lower

                      for m = lastLineIndex-3:-3:k
                          SortedPattern(m+3:m+5,:) = SortedPattern(m:m+2,:);
                      end

                      % Now this new line can take the place of the kth
                      % line:
                        
                      SortedPattern(k:k+1,:) = SubPattern(j:j+1,:);
                      
                      inserted = 1;
                      break;

                    end
                    k = k+3;
                end

                if inserted == 0
                    % Could not insert before any existing line. Insert at
                    % end:

                    SortedPattern(lastLineIndex:lastLineIndex+1,:) = SubPattern(j:j+1,:);
                end
                
                clear('inserted');

                lastLineIndex = lastLineIndex + 3;

                % Mark that j has been placed in the sorted array
                Transferred(j) = 1;
            end
            
            clear('d1','d2','tolerance');
            
        end
    end
end

disp('Sorted the pattern!');
clear('sz','tolerance','pOld','pNew','m','k','j','i','compareStartIndex','Transferred');

%% RASTER ONLY: Double check Y axis to ensure that everything IS sorted:

i = 1;
j=1;
figure(2);
while i < size(SortedPattern,1)
    plot(j,SortedPattern(i,2),'bo'); hold on;
    plot(j+1,SortedPattern(i+1,2),'bo'); hold on;
    plot(j,SubPattern(i,2),'r*'); hold on;
    plot(j+1,SubPattern(i+1,2),'r*'); hold on;
    i = i+3;
    j = j+2;
end
title('Y should be monotonic'); xlabel('Line');ylabel('y position');
clear('i','j');

%% Write Sorted array to file.
% Remember to add a blank line after EACH segment

file_1 = fopen(strcat(basename,'_sorted.txt'),'w');
fprintf(file_1,'XLitho\tYLitho\twavelength\n');

fixedsize = ceil(size(SortedPattern,1)/3)*3;

fprintf(file_1,'%8.6E\t%8.6E\t%d\n',SortedPattern(1,1),SortedPattern(1,2),fixedsize);
clear('fixedsize');
fprintf(file_1,'%8.6E\t%8.6E\n',SortedPattern(2,1),SortedPattern(2,2));
fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');

% That completes the first line
% Now write the rest
for i=4:3:size(SortedPattern,1)
    fprintf(file_1,'%8.6E\t%8.6E\n',SortedPattern(i,1),SortedPattern(i,2));
    fprintf(file_1,'%8.6E\t%8.6E\n',SortedPattern(i+1,1),SortedPattern(i+1,2));
    fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');
end

% End of file writing. Close file:
fclose(file_1);
fprintf('Finished writing sorted pattern to file:\n%s\n',strcat(basename,'_sorted.txt'));
disp('----------------------------------------------');
clear('file_1','i','ans');