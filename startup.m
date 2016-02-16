% paths
conf.path_gb = '/home/twang/work/uiuc-m2ht/gbfeat';
conf.path_sphog = '/home/twang/work/uiuc-m2ht/sphog';
conf.path_train = '/media/Documents/dataset/CarData/TrainImages';
conf.path_test = '/media/Documents/dataset/CarData/TestImages';
conf.path_grdtr = '/media/Documents/dataset/CarData/trueLocations.txt';
% conf.path_test2 = '/data/dataset/CarData/TestImages_Scale';

% classifiers (e.g., liblinear for linear SVM and modified libsvm for
% IKSVM). For details refer to mnist-sphog code from S Maji.
addpath classifiers/liblinear-1.5-dense/matlab;
addpath classifiers/libsvm-mat-2.84-1-fast.v3;

% training data specs
conf.train.pid_start = 0;
conf.train.pid_end   = 549;
conf.train.nid_start  = 0;
conf.train.nid_end    = 499;
conf.train.img_width = 100;
conf.train.img_height = 40;

% test data specs
conf.test.id_start = 0;
conf.test.id_end = 169;
conf.test.iouthreshold = 0.5; % IoU threshold in PASCAL criterion

% model specs
%conf.model.szpart = 10;
conf.model.kmeansk = 100;
conf.model.binsz = 4;
% for gamma, bigZ and small t refer to eq.7 in Maji's CVPR09 paper
conf.model.gamma = 5; % gamma
conf.model.bigz = 1; % big Z
conf.model.smallt = 0.5; % distance threshold
conf.model.peakth = 0.3; % peak threshold (0~1)
conf.model.nms = 0.7; % non-maxima suppression threshold
% big C, Eq.14, CVPR'09 paper
conf.model.bigc = [25 50 75];
conf.model.bigc_foriksvm = 1; % use the first bigc for M2HT+IKSVM
% how many top detections per image to use from M2HT results when sampling nearby region for IKSVM verification
conf.model.num_topwindows = 10;
% nearby sampling grid
%conf.model.nb_grid = [0 0; -4 -8; 0 -8; 4 -8; -4 0; 4 0; -4 8; 0 8; 4 8;
%                      ];
conf.model.nb_grid = [];
for yy = -24:8:24
    for xx = -48:16:48
        conf.model.nb_grid = [conf.model.nb_grid; yy xx];
    end
end

% geometric blur features
addpath(conf.path_gb);
addpath(fullfile(conf.path_gb,'descriptor_code'));
addpath(fullfile(conf.path_gb,'correspondence_code'));
addpath(fullfile(conf.path_gb,'feature_code'));
addpath(fullfile(conf.path_gb,'visualization_code'));

% sphog features
addpath(conf.path_sphog);
conf.sphog.blocks = [20, 10, 5; 20, 10, 5]; % block sizes for histogramming
conf.sphog.overlap  = true; % have overlapping blocks
conf.sphog.nori = 12; % number of orientations
conf.sphog.gradtype = 2; % gradient type: 0 - tap, 1-sobel, 2 - gaussian filters
conf.sphog.gradsigma = 2; % sigma of the gaussian filter

% (ik)svm classifier
conf.svm.kerneltype = 4; % 0 -- linear SVM; 4 -- IKSVM
conf.svm.bigc       = 10; % C parameter for SVM  
conf.svm.liblinearb = 10; % LIBLINEAR (-B)
conf.svm.degree     = 5; % LIBSVM poly degree
conf.svm.r          = 1; % LIBSVM r (coefficient)
conf.svm.gamma      = 1; % LIBSVM gamma for rbf kernel  
