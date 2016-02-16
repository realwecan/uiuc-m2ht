startup;
load sandbox_train.mat
data = uiuc_data_test(conf);

%testmode = {'uniform','naive','max-margin'};
testmode = {'max-margin'};
testmode = uiuc_expand_testmode(testmode); % split max-margin to that of different bigC values

for itest = testmode
    
    fp = fopen(strcat('results_single_',itest{1},'.txt'),'w');

    for ii = 1 : length(data.test.imgs)
        fprintf(strcat('Test image (',itest{1},') %3d/%3d...\n'), ii, length(data.test.imgs));
        % load this test image
        thisimg = data.test.imgs{ii};
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

        % 
        for jj = 1 : size(descp,1)
            thispos = pos(jj,:);
            clusids = find(expdist(jj,:) ~= 0);
            for kk = 1 : length(clusids)
                thisweight = expdist(jj,clusids(kk));
                thisvote = votes(clusids(kk)).map.*thisweight;
                if strcmp(itest, 'uniform')
                    thisvote = thisvote./votes(clusids(kk)).numpos;
                end
                if strcmp(itest, 'naive') % naive bayes weight
                    thisvote = thisvote.*votes(clusids(kk)).prob./votes(clusids(kk)).numpos;
                end
                if ~isempty(findstr(itest{1}, 'max-margin')) % max-margin weight
                    % TODO: max 9 different bigC values (1 digit), consider regex
                    thisbigc = str2num(itest{1}(end));
                    thisvote = thisvote.*votes(clusids(kk)).mmweight(thisbigc)./votes(clusids(kk)).numpos;
                end
                thisvote = imresize(thisvote,conf.model.binsz);
                % add vote to hough map
                thismap(thispos(1):thispos(1)+conf.train.img_height-1, ...
                    thispos(2):thispos(2)+conf.train.img_width-1) = ...
                    thismap(thispos(1):thispos(1)+conf.train.img_height-1, ...
                        thispos(2):thispos(2)+conf.train.img_width-1) + thisvote;
            end
        end
        % remove padding
        thismap = thismap(conf.train.img_height+1:conf.train.img_height+size(thisimg,1), ...
            conf.train.img_width+1:conf.train.img_width+size(thisimg,2));
        % retrieve bounding boxes
        bboxes = uiuc_retrieve_bbox(thismap, conf);
        %{
        figure(1);
        subplot(1,2,2); imagesc(thismap); axis equal; axis off;
        subplot(1,2,1); imshow(thisimg); axis equal; axis off;
        for jj = 1 : min(3,size(bboxes,1))
            rectangle('Position',[bboxes(jj,2) bboxes(jj,1) bboxes(jj,4)-bboxes(jj,2) bboxes(jj,3)-bboxes(jj,1)], ...
                'EdgeColor', 'g', 'LineWidth', 2);
            %pause;
        end
        drawnow;
        %}
        for jj = 1 : size(bboxes,1)
            % format: image index(1-based), upper-left x, upper-left y, score
            fprintf(fp,'%d %d %d %f\n', ii, bboxes(jj,2), bboxes(jj,1), bboxes(jj,5));
        end
    end

    fclose(fp);
    
end