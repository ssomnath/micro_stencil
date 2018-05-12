function pattern = ExtractPattern(filepath)

    newData1 = importdata(filepath, '\t', 1);
    vars = fieldnames(newData1);
    pattern = newData1.(vars{1});
    pattern = pattern(:,1:2);
    
end