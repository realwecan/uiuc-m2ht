function [istp, thisgtr] = uiuc_ioutest(thisdet, thisgtr, conf)

istp = 0; % default to NOT true positive

for ii = 1 : size(thisgtr,1)
    if (iou_overlap(thisdet, thisgtr(ii,:), conf) > conf.test.iouthreshold)
        istp = 1; % is true positive
        thisgtr(ii,4) = 1; % mark as detected
        break;
    end
end



function [overlap] = iou_overlap(thisdet, thisgtr, conf)

% thisdet [imgid ulxx ulyy score]
% thisgtr [imgid ulyy ulxx isDetected]

rect1 = [thisdet([2,3]) conf.train.img_width conf.train.img_height];
rect2 = [thisgtr([3,2]) conf.train.img_width conf.train.img_height];
selfarea = conf.train.img_width*conf.train.img_height;
intarea = rectint(rect1, rect2);
overlap = intarea / (2*selfarea - intarea);