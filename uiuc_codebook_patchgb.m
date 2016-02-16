data = uiuc_data(conf);

data.train.pedgs = cell(length(data.train.pimgs),1);
data.train.nedgs = cell(length(data.train.nimgs),1);

% compute edges
se = strel('disk',1);

for ii = 1 : length(data.train.pimgs)
    data.train.pedgs{ii} = edge(data.train.pimgs{ii},'canny');
    data.train.pedgs{ii} = imdilate(data.train.pedgs{ii}, se);
end

for ii = 1 : length(data.train.nimgs)
    data.train.nedgs{ii} = edge(data.train.nimgs{ii},'canny');
    data.train.nedgs{ii} = imdilate(data.train.nedgs{ii}, se);
end

% build parts vocabulary
parts = struct([]);
pp = 0;
for ii = 1 : length(data.train.pimgs)
    fprintf('\n Now processing positive image #%d ...',ii);
    for yy = 1 : 3 : size(data.train.pimgs{ii},1) - conf.model.szpart +1
        for xx = 1 : 3 : size(data.train.pimgs{ii},2) - conf.model.szpart +1
            % center point is an edge point (dilated)
            if ( data.train.pedgs{ii}(yy+conf.model.szpart/2, ...
                    xx+conf.model.szpart/2) == 1 )
                pp = pp+1;
                parts(pp).patch = data.train.pimgs{ii}(yy:yy+conf.model.szpart-1, ...
                    xx:xx+conf.model.szpart-1);
                parts(pp).loc = [yy xx];
                parts(pp).imgid = ii;
                parts(pp).ispos = 1;
            end
        end
    end
end

for ii = 1 : length(data.train.nimgs)
    fprintf('\n Now processing negative image #%d ...',ii);
    for yy = 1 : 3 : size(data.train.nimgs{ii},1) - conf.model.szpart +1
        for xx = 1 : 3 : size(data.train.nimgs{ii},2) - conf.model.szpart +1
            % center point is an edge point (dilated)
            if ( data.train.nedgs{ii}(yy+conf.model.szpart/2, ...
                    xx+conf.model.szpart/2) == 1 )
                pp = pp+1;
                parts(pp).patch = data.train.nimgs{ii}(yy:yy+conf.model.szpart-1, ...
                    xx:xx+conf.model.szpart-1);
                parts(pp).loc = [yy xx];
                parts(pp).imgid = ii;
                parts(pp).ispos = 0;
            end
        end
    end
end

% compute gb features
for ii = 1 : length(parts)
    if (mod(ii,1000) == 0)
        fprintf('\n Now processing part #%d ...',ii);
    end
    parts(ii).featgb = getGBfeatures(parts(ii).patch);
end