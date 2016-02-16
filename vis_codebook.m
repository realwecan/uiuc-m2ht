for ii = 1 : conf.model.kmeansk
    mask = (kmidx == ii);
    nummem = sum(mask);
    numpos = sum(mask&gbpos(:,3));
    
    fprintf('\n Cluster %3d has %4d members, in which %4d (%.2f) are positive members.', ...
        ii, nummem, numpos, numpos/nummem);
    
    memids = find(mask);
    
    for jj = 1 : min(nummem, 100)
        posinfo = gbpos(memids(jj),:);
        if ( posinfo(3) == 1 )
            thisimg = data.train.pimgs{posinfo(4)};
        else
            thisimg = data.train.nimgs{posinfo(4)};
        end
        cropimg = thisimg(max(1,posinfo(1)-5):min(posinfo(1)+5,40), ...
            max(1,posinfo(2)-5):min(posinfo(2)+5,100));
        figure(1);
        subplot(10,10,jj);
        imshow(cropimg);
    end
    
    pause;
    
end