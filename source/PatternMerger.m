%% Pattern Merger:
% Merges two patterns to find their union.
% Sorting of the union is not performed here.
function Driver = PatternMerger(Driver,SubPattern)

%% Loop over Sub and search in Driver
for i=1:3:size(SubPattern,1)-1
    
    Sslope = (SubPattern(i+1,2)-SubPattern(i,2))/(SubPattern(i+1,1)-SubPattern(i,1));
    if(abs(Sslope) > 100)
        sline = [Inf, Inf];
        refpt = [SubPattern(i,1),0];
    else
        sline = polyfit([SubPattern(i,1),SubPattern(i+1,1)],[SubPattern(i,2),SubPattern(i+1,2)],1);
        refpt = [0,polyval(sline,0)];
    end
    
    s1 = PointDistance(refpt(1),refpt(2),SubPattern(i,1),SubPattern(i,2));
    s2 = PointDistance(refpt(1),refpt(2),SubPattern(i+1,1),SubPattern(i+1,2));
    
    for j=1:3:size(Driver,1)-1
        
        Dslope = (Driver(j+1,2)-Driver(j,2))/(Driver(j+1,1)-Driver(j,1));
        if(abs(Dslope) > 100)
            dline = [Inf, Inf];
        else
            dline = polyfit([Driver(j,1),Driver(j+1,1)],[Driver(j,2),Driver(j+1,2)],1);
        end
        
        vert = abs(sline(1)) == Inf && abs(dline(1)) == Inf;
        if(vert && abs(Driver(j,1)-SubPattern(i,1)) < 50E-9)
        	vert = 1;
            refpt = [Driver(j,1),0];
        end
        arb = abs(sline(1)-dline(1))<1E-3 && abs(sline(2)-dline(2))<50E-9;
        if(arb)
            refpt = [0,polyval(dline,0)];
        end
        
        if(~vert && ~arb)
            % This segment is not on the same line as that of current
            % driver line.
            continue;
        end
        
        % Both segments on the same line
        
        d1 = PointDistance(refpt(1),refpt(2),Driver(j,1),Driver(j,2));
        d2 = PointDistance(refpt(1),refpt(2),Driver(j+1,1),Driver(j+1,2));
        
        hit=0;
        temp = zeros(2,2);
        if(max(d1,d2) >= min(s1,s2) && max(d1,d2) < max(s1,s2) && min(d1,d2) < min(s1,s2))
            % Case 1a: elongate Driver.
            % farther point on SubPattern goes to Driver j 
            temp(1,:) = SubPattern(i+(s2>s1),:);
            % closer point on Driver goes to Driver j+1
            temp(2,:) = Driver(j+(d1>d2),:);
            hit=1;
        elseif(max(s1,s2) >= min(d1,d2) && max(s1,s2) < max(d1,d2) && min(s1,s2) < min(d1,d2))
            % Case 1b: elongate Driver.
            % farther point on Driver goes to Driver j
            temp(1,:) = Driver(j+(d2>d1),:);
            % closer point on SubPattern goes to Driver j+1
            temp(2,:) = SubPattern(i+(s1>s2),:);
            hit=1;
        elseif(min(d1,d2) <= min(s1,s2) && max(d1,d2) >= max (s1,s2))
            % Case 2a: Mark as hit. Do nothing else
            % farther point on Driver goes to Driver j
            temp(1,:) = Driver(j+(d2>d1),:);
            % closer point on Driver goes to Driver j+1
            temp(2,:) = Driver(j+(d1>d2),:);
            hit=1;
        elseif(min(s1,s2) <= min(d1,d2) && max(s1,s2) >= max (d1,d2))
            % Case 2b: Replace Driver line with SubPattern line. 
            % farther point on SubPattern goes to Driver j
            temp(1,:) = SubPattern(i+(s2>s1),:);
            % closer point on SubPattern goes to Driver j+1
            temp(2,:) = SubPattern(i+(s1>s2),:);
            %Driver(j:j+1,:) = SubPattern(i:i+1,:);
            hit=1;
        end
        
        if(hit)
            % Mark that this line in the SubPattern was in some manner,
            % absorbed into the Driver Pattern and must not be added onto
            % the Driver again:
            Driver(j:j+1,:) = temp(:,:);
            SubPattern(i:i+1,:) = Inf;
            % Matching Driver line has been found. Break Driver loop. 
            break;
        end
    end
    
    % Sort the line IF it hasn't already been absorbed:
    if(SubPattern(i,1) ~= Inf)
        temp = zeros(2,2);
        % farther point on SubPattern goes to SubPattern i
        temp(1,:) = SubPattern(i+(s2>s1),:);
        % closer point on SubPattern goes to Driver i+1
        temp(2,:) = SubPattern(i+(s1>s2),:);
        SubPattern(i:i+1,:) = temp(:,:);
    end
end

clear('i','j','temp','hit','sline','dline','Sslope','Dslope','vert','arb');
clear('refpt','d1','d2','s1','s2');

% All the common lines have been absorbed into Driver
% Just need to add those lines in SubPattern that were not in Driver

% Some times the Driver does NOT have a NaN as the last line.
j=size(Driver,1);
if(Driver(j,1) ~= NaN)
    j=j+1;
    Driver(j,1) = NaN;
    Driver(j,2) = NaN;
end

j=j+1;
for i=1:3:size(SubPattern,1)-1
    if(SubPattern(i,1) ~= Inf)
        Driver(j:j+1,:) = SubPattern(i:i+1,:);
        Driver(j+2,:) = [NaN, NaN];
        j=j+3;
    end
end