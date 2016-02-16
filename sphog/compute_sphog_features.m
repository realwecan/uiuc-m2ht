function [sphog_feat] = compute_sphog_features(imgs, verbose)

    if (nargin < 2)
        verbose = 1;
    end
    
    startup;
    blocks = conf.sphog.blocks;
    H = conf.train.img_height;
    W = conf.train.img_width;
    
    [gw, gh, level_weights] = get_sampling_grid(W,H,blocks,conf.sphog.overlap);
    
    
    param.nori=conf.sphog.nori;
    param.ww = W; param.hh = H;
    
    dim = 0;
    breaks = 0;
    for i = 1:length(gw),
        dim = dim + (size(gw{i},1)-1)*(size(gw{i},2)-1)*param.nori;
    end
    if (verbose)
        fprintf('features are %i dimensional..\n',dim);
    end
    sphog_feat = zeros(size(imgs,1),dim);
    
    tic;
    for i = 1:size(imgs,1),
        sphog_feat(i,:) = make_sphog_features(imgs(i,:),param,gw,gh,level_weights);
        if(mod(i,100)==0),
            fprintf('%i..',i);
        end
    end
    if (verbose)
        fprintf('\n%.2fs to compute features\n',toc);
    end

end

function f=make_sphog_features(x,param,gw,gh,level_weights)
   I  = reshape(x,param.hh,param.ww);
   f = compute_features(I,param,gw,gh,1,level_weights);
end
