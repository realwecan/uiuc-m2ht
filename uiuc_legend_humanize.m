function [ newtestmode ] = uiuc_legend_humanize ( testmode )
%UIUC_EXPAND_TESTMODE Summary of this function goes here
%   Detailed explanation goes here
startup;

newtestmode = cell(0);

for ii = 1 : length(testmode)
    if ~isempty(findstr(testmode{ii},'max-margin'))
        thisbigc = str2num(testmode{ii}(end));
        thisbigc = conf.model.bigc(thisbigc);
        newtestmode{length(newtestmode)+1} = strcat('C=',num2str(thisbigc));
    else
        newtestmode{length(newtestmode)+1} = testmode{ii};
    end
end

end

