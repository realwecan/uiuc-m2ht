startup;
load sandbox_train.mat
data = uiuc_data_test(conf);

%% reproduce fig 7 (left) in CVPR09 paper
%testmode = {'uniform', 'naive', 'max-margin'};
%colors = {'r','g', 'b', 'cyan', 'magenta'};
%% add additional results i.e., IKSVM
testmode = {'iksvm', 'm2ht-iksvm'};
colors = {'r', 'b'};
%%
testmode = uiuc_expand_testmode(testmode); % split max-margin to that of different bigC values
clf;

for itest = 1: length(testmode)
    
    %% read ground-truth
    all_grdtr = [];

    fp = fopen(conf.path_grdtr);
    tline = fgets(fp);
    while ischar(tline) % read until eof
        imgid = regexp(tline, '^\d{1,}', 'match');
        imgid = str2double(imgid{1})+1; % convert from 0-based to 1-based imgid
        coordinates = regexp(tline, '\((-?\d{1,}),(-?\d{1,})\)', 'tokens');
        for jj = 1 : length(coordinates)
            yy = str2double(coordinates{jj}{1}); % y coordinate for upperleft
            xx = str2double(coordinates{jj}{2}); % x coordinate for upperleft
            all_grdtr = [all_grdtr; imgid yy xx];
        end
        tline = fgets(fp);
    end
    fclose(fp);

    %% read detection results
    all_det = textread(strcat('results_single_',testmode{itest},'.txt'));

    %% not needed to prune out-of-image detections as there are some in grdtr
    %{
    all_idx = [];
    % prune out-of-image detections
    for ii = 1 : size(all_det,1)
        flag = true;
        imgsize = size(data.test.imgs{all_det(ii,1)});
        if ( ( all_det(ii,2) < 1 ) || (all_det(ii,3) < 1 ) )
            flag = false;
        else
            if ( ( all_det(ii,2)+conf.train.img_width-1>imgsize(2) ) || ...
                 ( all_det(ii,3)+conf.train.img_height-1>imgsize(1) ) )
                flag = false;
            end
        end
        if (flag == true)
            all_idx = [all_idx; ii];
        end
    end

    all_det = all_det(all_idx, :);
    %}
    %%

    % last column added to indicate whether a ground-truth has been detected
    all_grdtr = [all_grdtr zeros(length(all_grdtr),1)];

    % last column added to indicate whether the detection is TP or FP
    all_det = [all_det zeros(length(all_det),1)];

    % sort detections
    [~,srt_idx] = sort(all_det(:,4),'descend');
    all_det = all_det(srt_idx,:);

    for ii = 1 : length(all_det)
        thisdet = all_det(ii,:);
        % find ground-truth for this detection
        thisidx1 = find(all_grdtr(:,1) == thisdet(1)); % imgid match
        thisidx2 = find(all_grdtr(:,4) == 0); % not detected yet
        thisidx = intersect(thisidx1, thisidx2);

        thisgtr = all_grdtr(thisidx,:);
        [istp, thisgtr] = uiuc_ioutest(thisdet, thisgtr, conf);
        all_det(ii,5) = istp;
        all_grdtr(thisidx,:) = thisgtr;
    end

    %% prec-recall curve

    npos = length(all_grdtr);
    tp = all_det(:,5);
    fp = ~tp;
    fp=cumsum(fp);
    tp=cumsum(tp);
    rec=tp./npos;
    prec=tp./(fp+tp);
    % draw recall/(1-prec) curve instead of prec/recall curve
    prec=1-prec;
    
    hold on;
    plot(prec,rec,'--','Color',colors{itest}, 'LineWidth', 3);
   
end

%% figure/graph completion
testmode = uiuc_legend_humanize(testmode);
legend(testmode);
grid on;
xlabel '1-precision'
ylabel 'recall'
xlim([0 0.5]);
ylim([0.5 1]);
set(gca,'xtick',[0:0.05:0.5]);
set(gca,'ytick',[0.5:0.05:1]);