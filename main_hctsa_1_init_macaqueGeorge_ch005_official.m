% main_hctsa_1_init_macaqueGeorge_ch005_official.m

%% 0. path 前提（セッション開始時に1回だけ）
% restoredefaultpath; rehash toolboxcache;
% addpath(genpath('C:\Users\chikayo\lab\hctsa_proj\00_repos\hctsa'));
% addpath(genpath('C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify'));

%% 1. 入力となる 30x30 のファイルをロード
preprocFile = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify\preprocessed\macaque\George\HCTSA_macaqueGeorge_ch005_30x30.mat';

S = load(preprocFile, 'TS_DataMat', 'TimeSeries');
tsData    = S.TS_DataMat;    % 60 x 200
TimeSeries = S.TimeSeries;   % table（ラベルやキーワード付き）

%% 2. 出力する HCTSA ファイル名（clean 版）
outFile = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify\hctsa_subtractMean_removeLineNoise\macaque\George\macaque_George_ch005_hctsa_official.mat';

%% 3. 使う operations 定義ファイル（公式 INP_mops / INP_ops）
hctsaDir = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\hctsa';
mopsFile = fullfile(hctsaDir, 'Database', 'INP_mops.txt');
opsFile  = fullfile(hctsaDir, 'Database', 'INP_ops.txt');

%% 4. TS_Init を「.mat + INP_mops/ops」モードで実行

TS_Init('hctsaFilename', outFile, ...
        'INP_ts', tsData, ...
        'TimeSeries', TimeSeries, ...
        'operationsFile', mopsFile, ...
        'opsFile', opsFile, ...
        'useDB', false);
