data = uiuc_data(conf);

gbdesc = [];
gbpos = [];

% gb features from positives
for ii = 1 : length(data.train.pimgs)
    
    fprintf('\n Processing positive image #%d ...', ii);
    
    [descp, pos] = uiuc_gbfeat(data.train.pimgs{ii});
    descp = reshape(descp,[size(descp,1), size(descp,2)*size(descp,3)]);
    % ii jj ispos=1 imgid
    pos = [pos ones(size(pos,1),1) ones(size(pos,1),1).*ii];
    
    
    gbdesc = [gbdesc; descp];
    gbpos = [gbpos; pos];
    
end

% gb features from negatives
for ii = 1 : length(data.train.nimgs)
    
    fprintf('\n Processing negative image #%d ...', ii);
    
    [descp, pos] = uiuc_gbfeat(data.train.nimgs{ii});
    descp = reshape(descp,[size(descp,1), size(descp,2)*size(descp,3)]);
    % ii jj ispos=0 imgid
    pos = [pos zeros(size(pos,1),1) ones(size(pos,1),1).*ii];
    
    gbdesc = [gbdesc; descp];
    gbpos = [gbpos; pos];
    
end

tic
[kmidx, kmc] = kmeans(gbdesc,conf.model.kmeansk, 'Replicates', 5);
toc