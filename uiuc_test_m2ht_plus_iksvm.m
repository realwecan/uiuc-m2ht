startup;
load svmmodel.mat
data = uiuc_data_test(conf);

%% read max-margin results and sample nearby locations
fp = fopen(sprintf('./results_single_max-margin-%d.txt',conf.model.bigc_foriksvm),'r');

num_test = conf.test.id_end - conf.test.id_start + 1;
bboxes = cell(num_test,1);
curimgid = 0;
nb_grid = [ conf.model.nb_grid(:,1) conf.model.nb_grid(:,2) ...
    conf.model.nb_grid(:,1) conf.model.nb_grid(:,2)];
tline = fgets(fp);
    while ischar(tline) % read until eof
        tdata = sscanf(tline, '%d %d %d %f');
        imgid = tdata(1); tx1 = tdata(2); ty1 = tdata(3); %score = tdata(4);
        if (imgid ~= curimgid)
            windows_count = 1;
        else
            windows_count = windows_count+1;
        end
        if (windows_count <= conf.model.num_topwindows)
            ty2 = ty1 + conf.train.img_height - 1;
            tx2 = tx1 + conf.train.img_width - 1;
            % proliferated neighbouring bboxes
            nb_bboxes = nb_grid + repmat([ty1 tx1 ty2 tx2],size(nb_grid,1),1);
            bboxes{imgid} = [bboxes{imgid}; nb_bboxes];
        end
        tline = fgets(fp);
    end

fclose(fp);

%% remove detections truncated by image boundaries

for ii = 1 : length(bboxes)
    imgsize = size(data.test.imgs{ii});
    valid_idx = [];
    % prune out-of-image detections
    for jj = 1 : size(bboxes{ii},1)
        flag = true;
        if ( ( bboxes{ii}(jj,1) < 1 ) || (bboxes{ii}(jj,2) < 1 ) )
            flag = false;
        else
            if ( ( bboxes{ii}(jj,3)>imgsize(1) ) || ( bboxes{ii}(jj,4)>imgsize(2) ) )
                flag = false;
            end
        end
        if (flag == true)
            valid_idx = [valid_idx; jj];
        end
    end
    bboxes{ii} = bboxes{ii}(valid_idx, :);
end

%% run iksvm on selected locations

imgW = conf.train.img_width;
imgH = conf.train.img_height;

parfor ii = 1 : length(bboxes)
    fprintf('\n Running IKSVM near M2HT peaks image %04d/%04d ...', ii, length(bboxes));
    thisimg = data.test.imgs{ii};
    tboxes = bboxes{ii};
    iksvm_scores = zeros(size(tboxes,1), 3);
    for jj = 1 : size(tboxes,1)
        box = tboxes(jj,:);
        cropimg = thisimg(box(1):box(3),box(2):box(4));
        cropimg = double(cropimg) ./ 255;
        cropimg = reshape(cropimg,1,imgW*imgH);
        thisfeat = compute_sphog_features(cropimg, 0); % 0 = no verbose
        thisscore = fiksvm_predict(1,thisfeat,model.svm,'-b 1');
        iksvm_scores(jj,:) = [tboxes(jj,1) tboxes(jj,2) thisscore];
    end
    safeSave(sprintf('./m2ht_iksvm_scores/scores_%04d.mat',ii),iksvm_scores);
end