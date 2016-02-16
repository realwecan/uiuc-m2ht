startup;

data = uiuc_data(conf);

numpos = length(data.train.pimgs);
numneg = length(data.train.nimgs);

imgW = conf.train.img_width;
imgH = conf.train.img_height;

img_cache = zeros(numpos+numneg, imgW*imgH);

for ii = 1 : length(data.train.pimgs)
    img_cache(ii,:) = reshape(data.train.pimgs{ii},1,imgW*imgH);
end

for ii = numpos+1 : numpos+numneg
    img_cache(ii,:) = reshape(data.train.nimgs{ii-numpos},1,imgW*imgH);
end

% normalize to 0~1 (0~255 grayscale beforehand)
img_cache = img_cache ./ 255;

sphog_feat = compute_sphog_features(img_cache);

save('sphog.mat','sphog_feat');