% main_hctsa_2_compute_macaqueGeorge_ch005_local.m

%% Settings
addDirPrefs_COS;
dirPref = getpref('cosProject','dirPref');
species = 'macaque';
subject = 'George';
preprocessSuffix = '_subtractMean_removeLineNoise';

load_dir = fullfile(dirPref.rootDir, 'preprocessed',species,subject);
save_dir = fullfile(dirPref.rootDir, ['hctsa' preprocessSuffix],species,subject);

%% load channels to process
load(fullfile(load_dir,['detectChannels_' subject]) ,'tgtChannels');

% ★ ここで ch005 だけに絞る
tgtChannels = 5;  % detectChannels の値に関わらず ch005 のみ

%% prepare parallel computation
nCores = feature('numcores');
p = gcp('nocreate');
if isempty(p)
    parpool(nCores);
end
add_toolbox;  % ← ここは Daisukeコードのまま（hctsa への path など）

% Macaque / George ch005 を計算
for ich = 1:numel(tgtChannels)
    disp([num2str(ich), '/' num2str(numel(tgtChannels))]);
    thisCh = tgtChannels(ich);

    savedata_prefix = sprintf('%s_%s_ch%03d', species, subject, thisCh);
    hctsaName = fullfile(save_dir, [savedata_prefix '_hctsa.mat']);

    tic;
    TS_Compute(true, [], [], [], hctsaName);
    t = toc;
    fprintf('TS_Compute finished in %.2f seconds\n', t);
end
