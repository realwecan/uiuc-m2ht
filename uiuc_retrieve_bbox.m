function [bboxes] = uiuc_retrieve_bbox(thismap, conf)

%
maxval = max(thismap(:));
thval = maxval * conf.model.peakth;

[ty, tx] = find(thismap>thval);
tind = sub2ind(size(thismap), ty, tx);

ty1 = ty-conf.train.img_height/2+1;
ty2 = ty+conf.train.img_height/2;

tx1 = tx-conf.train.img_width/2+1;
tx2 = tx+conf.train.img_width/2;

bboxes = [ty1 tx1 ty2 tx2 thismap(tind)];

bboxes = bboxes(nms(bboxes, conf.model.nms),:);