startup;
load svmmodel.mat
data = uiuc_data_test(conf);

imgW = conf.train.img_width;
imgH = conf.train.img_height;

parfor ii = 1 : length(data.test.imgs)
    fprintf('\n Running sliding window detector on test image %04d ...',ii);
    thisimg = data.test.imgs{ii};
    iksvm_scores = [];
    for yy = 1 : 4 : size(thisimg,1) - conf.train.img_height + 1
        for xx = 1 : 4 : size(thisimg,2) - conf.train.img_width + 1
            cropimg = thisimg(yy:yy+conf.train.img_height-1, ...
                xx:xx+conf.train.img_width-1);
            cropimg = double(cropimg) ./ 255;
            cropimg = reshape(cropimg,1,imgW*imgH);
            thisfeat = compute_sphog_features(cropimg, 0); % 0 = no verbose
            thisscore = fiksvm_predict(1,thisfeat,model.svm,'-b 1');
            iksvm_scores = [ iksvm_scores; yy xx thisscore ];
        end
    end
    safeSave(sprintf('./iksvm_scores/scores_%04d.mat',ii),iksvm_scores);
end