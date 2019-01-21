%% Prepare data for learning train_VXFmodel

global extComments 

extComments = true;
load 'ProcessedDataNew.mat';
VocNum = categorical([1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31;32;33;34]);

%% Reshape arrays
idx = tagLenArray~=0;
targetsClean= targets(idx)';
featuresClean =  features(idx)';


 %% Plot lenths
%  [sentLen,idx] = sort(featLenArray);
z = cellfun(@numel,targetsClean);
[sentLen,idx] = sort(z);
figure
bar(sentLen)
% ylim([0 30])
xlabel("Features")
ylabel("Length")
title("Sorted Data")

featuresTable = featuresClean(idx);
targetsTable = targetsClean(idx);

%% Transformation of Targets to categorical & Normalization of Features
targetsTable = cellfun(@categorical,targetsTable,'UniformOutput',false );
featuresTable = cellfun(@zscore,featuresTable,'UniformOutput',0); % 
clearvars -except featuresTable targetsTable sentLen
  

%% Binning
[~,b1] = histcounts(sentLen,'BinMethod','fd');
[~,b2] = histcounts(sentLen,'BinMethod','scott');
miniBatchNum = round(max(b1(2) - b1(1),b2(2) - b2(1)));

%% Prepare Multi-GPU Env
%% Prepare Multi-GPU Env
disp(['Number of GPUs:' num2str(gpuDeviceCount)])
gpuIndices=[1 2 3];
delete(gcp('nocreate'))
parpool('local', numel(gpuIndices));
spmd, gpuDevice(gpuIndices(labindex)); end

%%
inputSize = 13;
numClasses = 34;
numHiddenUnits = 128;
maxEpochs = 300;
miniBatchNum = 1;

% define TimeDistributed
ctcClasslayer = ctcClassificationLayer('ctcClass',VocNum);
netLayers = [sequenceInputLayer(inputSize)
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    bilstmLayer(numHiddenUnits,'OutputMode','sequence')
    fullyConnectedLayer(numClasses)
    softmaxLayer
    ctcClasslayer];

netOptions = trainingOptions('adam', ...
    'ExecutionEnvironment','multi-gpu', ...
    'GradientThreshold',1, ...
    'MaxEpochs',maxEpochs, ...
    'MiniBatchSize',miniBatchNum, ...
    'SequenceLength','longest', ...
    'Shuffle','never', ...
    'Verbose',0, ...
    'Plots','training-progress');



%% Train on  data
netVXF = trainNetwork(featuresTable,targetsTable,netLayers,netOptions);               
