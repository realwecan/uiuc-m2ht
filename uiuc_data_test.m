function [data] = uiuc_data_test(conf)

data.test.imgs = cell(conf.test.id_end - conf.test.id_start,1);

% load test images
for ii = conf.test.id_start : conf.test.id_end
    curfile = fullfile(conf.path_test,['test-' num2str(ii) '.pgm']);
    data.test.imgs{ii-conf.test.id_start+1} = imread(curfile);
end