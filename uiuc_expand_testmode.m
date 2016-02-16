function [ newtestmode ] = uiuc_expand_testmode( testmode )
%UIUC_EXPAND_TESTMODE Summary of this function goes here
%   Detailed explanation goes here
startup;

newtestmode = cell(0);

for ii = 1 : length(testmode)
    if strcmp(testmode{ii},'max-margin')
        for jj = 1 : length(conf.model.bigc)
            newtestmode{length(newtestmode)+1} = ['max-margin-' num2str(jj)];
        end
    else
        newtestmode{length(newtestmode)+1} = testmode{ii};
    end
end

end

