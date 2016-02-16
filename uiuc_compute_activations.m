startup;
load sandbox_train.mat
data = uiuc_data(conf);

numpos = conf.train.pid_end - conf.train.pid_start+1;
numneg = conf.train.nid_end - conf.train.nid_start+1;
activations = zeros(conf.model.kmeansk,numpos+numneg);

%% get activation vectors for each positive image
for ii = 1 : length(data.train.pimgs)
    fprintf(strcat('Positive training image %3d/%3d...\n'), ii, length(data.train.pimgs));
    thisimg = data.train.pimgs{ii};
    thismap = zeros(size(thisimg));
    % add padding to hough map
    thismap = padarray(thismap, [conf.train.img_height conf.train.img_width]);
    % get descriptors at interest points
    [descp, pos] = uiuc_gbfeat(thisimg, 1000);
    descp = reshape(descp,[size(descp,1), size(descp,2)*size(descp,3)]);
    % add padding to pos
    pos = pos + repmat([conf.train.img_height conf.train.img_width],length(pos),1);
    % move pos from centre point to upperleft point
    pos = pos - repmat([conf.train.img_height conf.train.img_width],length(pos),1)./2;
    % compute distance and p(C_i|f) weight
    thisdist = dist2(descp, kmc);
    expdist = (1/conf.model.bigz).*exp(-conf.model.gamma.*thisdist);
    expdist(thisdist > conf.model.smallt) = 0;
    
    for jj = 1 : size(descp,1)
        thispos = pos(jj,:);
        clusids = find(expdist(jj,:) ~= 0);
        for kk = 1 : length(clusids)
            thisweight = expdist(jj,clusids(kk));
            thisvote = votes(clusids(kk)).map.*thisweight;
            thisvote = thisvote./votes(clusids(kk)).numpos;
            thisvote = imresize(thisvote,conf.model.binsz);
            % clear hough map
            thismap = zeros(size(thismap));
            % add vote to hough map
            thismap(thispos(1):thispos(1)+conf.train.img_height-1, ...
                thispos(2):thispos(2)+conf.train.img_width-1) = ...
                thismap(thispos(1):thispos(1)+conf.train.img_height-1, ...
                    thispos(2):thispos(2)+conf.train.img_width-1) + thisvote;
            activations(clusids(kk), ii) = activations(clusids(kk), ii) + ...
                thismap(round(size(thismap,1)/2), round(size(thismap,2)/2));
        end
    end
end

%% get activation vectors for each negative image
for ii = 1 : length(data.train.nimgs)
    fprintf(strcat('Negative training image %3d/%3d...\n'), ii, length(data.train.nimgs));
    thisimg = data.train.nimgs{ii};
    thismap = zeros(size(thisimg));
    % add padding to hough map
    thismap = padarray(thismap, [conf.train.img_height conf.train.img_width]);
    % get descriptors at interest points
    [descp, pos] = uiuc_gbfeat(thisimg, 1000);
    descp = reshape(descp,[size(descp,1), size(descp,2)*size(descp,3)]);
    % add padding to pos
    pos = pos + repmat([conf.train.img_height conf.train.img_width],length(pos),1);
    % move pos from centre point to upperleft point
    pos = pos - repmat([conf.train.img_height conf.train.img_width],length(pos),1)./2;
    % compute distance and p(C_i|f) weight
    thisdist = dist2(descp, kmc);
    expdist = (1/conf.model.bigz).*exp(-conf.model.gamma.*thisdist);
    expdist(thisdist > conf.model.smallt) = 0;

    for jj = 1 : size(descp,1)
        thispos = pos(jj,:);
        clusids = find(expdist(jj,:) ~= 0);
        for kk = 1 : length(clusids)
            thisweight = expdist(jj,clusids(kk));
            thisvote = votes(clusids(kk)).map.*thisweight;
            thisvote = thisvote./votes(clusids(kk)).numpos;
            thisvote = imresize(thisvote,conf.model.binsz);
            % clear hough map
            thismap = zeros(size(thismap));
            % add vote to hough map
            thismap(thispos(1):thispos(1)+conf.train.img_height-1, ...
                thispos(2):thispos(2)+conf.train.img_width-1) = ...
                thismap(thispos(1):thispos(1)+conf.train.img_height-1, ...
                    thispos(2):thispos(2)+conf.train.img_width-1) + thisvote;
            activations(clusids(kk), numpos+ii) = activations(clusids(kk), numpos+ii) + ...
                thismap(round(size(thismap,1)/2), round(size(thismap,2)/2));
        end
    end
end
%%
save('activations.mat','activations');
