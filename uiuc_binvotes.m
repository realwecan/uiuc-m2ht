votes = struct([]);

for ii = 1 : conf.model.kmeansk
    mask = (kmidx == ii);
    nummem = sum(mask);
    maskpos = (mask&gbpos(:,3));
    numpos = sum(maskpos);
    % naive bayes probability (propto, eq.8) in Maji's paper
    prob = ( numpos / sum(gbpos(:,3)==1) ) ./ ( nummem / length(gbpos) );
    
    posids = find(maskpos);
    
    votes(ii).map = zeros(conf.train.img_height/conf.model.binsz, ...
        conf.train.img_width/conf.model.binsz);
    votes(ii).nummem = nummem;
    votes(ii).numpos = numpos;
    votes(ii).prob = prob;
    %votes(ii).prob = 1; % uniform weight
    
    for jj = 1 : numpos
        posinfo = gbpos(posids(jj),1:2);
        offset = [ (conf.train.img_height+1)/2 (conf.train.img_width+1)/2 ] - posinfo;
        newpos = [ (conf.train.img_height+1)/2 (conf.train.img_width+1)/2 ] + offset;
        % binned estimate
        newpos = ceil(newpos ./ 4);
        votes(ii).map(newpos(1),newpos(2)) = votes(ii).map(newpos(1),newpos(2)) + 1;
    end
    
    % gaussian filtering
    h = fspecial('gaussian', 3, 0.5);
    votes(ii).map = imfilter(votes(ii).map,h);
end