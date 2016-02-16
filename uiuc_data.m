function [data] = uiuc_data(conf)

data.train.pimgs = cell(conf.train.pid_end - conf.train.pid_start,1);
data.train.nimgs = cell(conf.train.nid_end - conf.train.nid_start,1);

% load training images
for ii = conf.train.pid_start : conf.train.pid_end
    curfile = fullfile(conf.path_train,['pos-' num2str(ii) '.pgm']);
    data.train.pimgs{ii-conf.train.pid_start+1} = imread(curfile);
end

for ii = conf.train.nid_start : conf.train.nid_end
    curfile = fullfile(conf.path_train,['neg-' num2str(ii) '.pgm']);
    data.train.nimgs{ii-conf.train.nid_start+1} = imread(curfile);
end

