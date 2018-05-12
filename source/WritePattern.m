function WritePattern(filepath,pattern)

    file_1 = fopen(filepath,'w');
    fprintf(file_1,'XLitho\tYLitho\twavelength\n');

    fixedsize = ceil(size(pattern,1)/3)*3;

    fprintf(file_1,'%8.6E\t%8.6E\t%d\n',pattern(1,1),pattern(1,2),fixedsize);
    clear('fixedsize');
    fprintf(file_1,'%8.6E\t%8.6E\n',pattern(2,1),pattern(2,2));
    fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');

    % That completes the first line
    % Now write the rest
    for i=4:3:size(pattern,1)
        fprintf(file_1,'%8.6E\t%8.6E\n',pattern(i,1),pattern(i,2));
        fprintf(file_1,'%8.6E\t%8.6E\n',pattern(i+1,1),pattern(i+1,2));
        fprintf(file_1,'%8.6E\t%8.6E\n',NaN,NaN); %fprintf(file_1,'\n');
    end

    % End of file writing. Close file:
    fclose(file_1);
    fprintf('Finished writing sorted pattern to file:\n%s\n',filepath);
    disp('----------------------------------------------');
    clear('file_1','i','ans');

end