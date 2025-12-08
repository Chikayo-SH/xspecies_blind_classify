%% macaqueGeorge_select30epochs_demo.m
% 前提:
%   C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify\preprocessed\macaque\George\
%   に、 preprocess_toru_CHLocalPC で作った
%   macaque_George_ch005_subtractMean_removeLineNoise.mat がある。
%
% 出力:
%   awake_30  (200 x 30)  % awake の 30 epoch
%   anesth_30 (200 x 30)  % anesth の 30 epoch

%% 1. 前処理済みデータを読み込み
preprocFile = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify\preprocessed\macaque\George\macaque_George_ch005_subtractMean_removeLineNoise.mat';
S = load(preprocFile);  % S.data.data_proc: [time x trial x condition]

%% 2. 各条件の全epochを取り出す
data_all = S.data.data_proc;       % [200 x 2892 x 2]
awake_all  = data_all(:, :, 1);    % awake:  [200 x 2892]
anesth_all = data_all(:, :, 2);    % anesth: [200 x 2892]

%% 3. それぞれから 30 本ずつサンプリング（乱数種を固定して再現性確保）
rng(1);  % ★ Stage1 と完全一致させる仕様は書かれていないので、ここは「自分ルール」。使う乱数種はメモしておく。

nSelect = 30;
nAwake  = size(awake_all,  2);
nAnesth = size(anesth_all, 2);

idxAwake  = randperm(nAwake,  nSelect);
idxAnesth = randperm(nAnesth, nSelect);

awake_30  = awake_all(:,  idxAwake);   % [200 x 30]
anesth_30 = anesth_all(:, idxAnesth);  % [200 x 30]

%% 4. 確認用の表示
disp(size(awake_30));   % 期待: 200   30
disp(size(anesth_30));  % 期待: 200   30
