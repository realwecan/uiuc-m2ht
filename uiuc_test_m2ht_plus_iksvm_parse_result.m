startup;

fp = fopen(strcat('results_single_m2ht-iksvm.txt'),'w');

for ii = 1 : length(data.test.imgs)
    load(sprintf('./m2ht_iksvm_scores/scores_%04d.mat',ii));
    [~, sortidx] = sort(iksvm_scores(:,3),'descend');
    iksvm_scores = iksvm_scores(sortidx,:);
    ty1 = iksvm_scores(:,1);
    tx1 = iksvm_scores(:,2);
    ty2 = ty1 + conf.train.img_height - 1;
    tx2 = tx1 + conf.train.img_width - 1;
    bboxes = [ty1 tx1 ty2 tx2 iksvm_scores(:,3)];

    bboxes = bboxes(nms(bboxes, conf.model.nms),:);
    
    for jj = 1 : size(bboxes,1)
        % format: image index(1-based), upper-left x, upper-left y, score
        fprintf(fp,'%d %d %d %f\n', ii, bboxes(jj,2), bboxes(jj,1), bboxes(jj,5));
    end
    
end

fclose(fp);