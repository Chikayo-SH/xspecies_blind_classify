% main_hctsa_3_postProcess_macaqueGeorge_ch005.m
% Macaque George ch005 用 HCTSA 後処理
%
% ・TS_Quality を使って TS_DataMat に NaN / Inf を戻す
% ・getValidFeatures で valid_features を決める
% ・BF_NormalizeMatrix('mixedSigmoid') で TS_Normalised を作成
%
% 前提：
%   cd("...\00_repos");
%   setup_cosProject_local;
%   setup_paths_local;
% を実行済みで、path に HCTSA が通っていること。

% Input（前提）
% 
% C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify に cd 済み
% 
% setup_cosProject_local, setup_paths_local 済み（dirPref が使える）
% 
% ...\hctsa_subtractMean_removeLineNoise\macaque\George\macaque_George_ch005_hctsa.mat が存在し、
% 
% TS_DataMat（60×7770）
% 
% TS_Quality（60×7770）が入っている
% 
% Output（このスクリプトの成果）
% 
% 同じ .mat（または v2 ファイル）に
% 
% special 値を戻した TS_DataMat
% 
% valid_features（1×7770 logical）
% 
% TS_Normalised（60×7770, mixedSigmoid 正規化）
% が追加・更新される。



%% Settings
dirPref = getpref('cosProject','dirPref');   % setup_cosProject_local で設定済み

species = 'macaque';
subject = 'George';
ch = 5;  % ch005
preprocessSuffix = '_subtractMean_removeLineNoise';

% 入出力ファイルの場所
base_dir = fullfile(dirPref.rootDir, ['hctsa' preprocessSuffix], species, subject);

orig_file = fullfile(base_dir, ...
    sprintf('%s_%s_ch%03d_hctsa.mat', species, subject, ch));

v2_file = fullfile(base_dir, ...
    sprintf('%s_%s_ch%03d_hctsa_v2.mat', species, subject, ch));

fprintf('Post-processing HCTSA file (v2 output):\n');
fprintf('  input : %s\n', orig_file);
fprintf('  output: %s\n', v2_file);

%% 元ファイルを読み込み
tic;
S = load(orig_file);   % 必要に応じて変数を絞っても OK

TS_DataMat = S.TS_DataMat;
TS_Quality = S.TS_Quality;

%% TS_Quality に応じて TS_DataMat に special 値を戻す
% Fatal errors → NaN
TS_DataMat(TS_Quality == 1) = NaN;
% Special value NaN
TS_DataMat(TS_Quality == 2) = NaN;
% Special value +Inf
TS_DataMat(TS_Quality == 3) = Inf;
% Special value -Inf
TS_DataMat(TS_Quality == 4) = -Inf;
% Special value complex
TS_DataMat(TS_Quality == 5) = NaN;
% Special value empty
TS_DataMat(TS_Quality == 6) = NaN;

% 必要ならコード確認用：
% if any(TS_Quality(:) > 6)
%     disp('TS_Quality has unexpected codes:');
%     disp(unique(TS_Quality(:))');
% end

% 構造体 S を更新
S.TS_DataMat = TS_DataMat;
S.TS_Quality = TS_Quality;

%% 有効 feature の判定 & 正規化

% 1) 有効 feature のインデックス（NaN/Inf なし＆非定数など）
valid_features = getValidFeatures(TS_DataMat);
S.valid_features = valid_features;

fprintf('Valid features: %d / %d\n', nnz(valid_features), size(TS_DataMat, 2));

% 2) mixedSigmoid で正規化（全列に対して実行）
TS_Normalised = BF_NormalizeMatrix(TS_DataMat, 'mixedSigmoid');
S.TS_Normalised = TS_Normalised;

%% v2 ファイルとして保存（元ファイルはそのまま）
save(v2_file, '-struct', 'S', '-v7.3');

toc;
fprintf('Post-processing complete. Saved v2 file.\n');