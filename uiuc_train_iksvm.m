startup;

% load SPHOG features
load('sphog.mat');

numpos = conf.train.pid_end - conf.train.pid_start + 1;
numneg = conf.train.nid_end - conf.train.nid_start + 1;
wpos = numneg/numpos;

% LIBSVM params. For details refer to mnist-sphog code from S. Maji.
svmstr = sprintf('-t %i -d %i -r %.2f -g %.2f -c %.1f -w2 %.2f -b 1',...
                         conf.svm.kerneltype, conf.svm.degree, conf.svm.r,...
                         conf.svm.gamma, conf.svm.bigc, wpos);

class_labels = [ zeros(numpos,1); ones(numneg,1) ]+1;

% train model
tic;
model.svm = svmtrain(class_labels,sphog_feat,svmstr);
model.Label = model.svm.Label;
model.svm = precomp_model(model.svm,'-m 1 -n 300');
fprintf('\t %.2fs to train model\n',toc);

save('svmmodel.mat', 'model');

% TODO: evaluate training error
trainprob = fiksvm_predict(class_labels,sphog_feat,model.svm,'-b 1');