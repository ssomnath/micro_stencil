function plotPattern(SubPattern, lstyle, lwidth)
    
    a = isnan(SubPattern(:,1));
    [r,c] = find(a==1);
    numchains = size(r,1);
    if(numchains > 1)
        % Plot first chain only:
        plot(SubPattern(1:r(1)-1,1),SubPattern(1:r(1)-1,2),lstyle,'LineWidth',lwidth);hold on;
        % Plot next few:
        for i = 2:numchains
            plot(SubPattern(r(i-1)+1:r(i)-1,1),SubPattern(r(i-1)+1:r(i)-1,2),lstyle,'LineWidth',lwidth);hold on;
        end
        % Plot last chain:
        plot(SubPattern(r(numchains)+1:size(SubPattern,1),1),SubPattern(r(numchains)+1:size(SubPattern,1),2),lstyle,'LineWidth',lwidth);hold on;
    end
    
end