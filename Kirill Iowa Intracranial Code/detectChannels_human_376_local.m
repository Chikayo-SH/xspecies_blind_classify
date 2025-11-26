% detectChannels_human_376_local.m
% Human 376 / Stage1 用にローカル環境向けに調整した版

% オリジナルの addDirPrefs_COS は呼ばない
% addDirPrefs_COS;

% setup_cosProject_local でセットした dirPref を取得
dirPref = getpref("cosProject","dirPref");

% ここから下は、オリジナルをベースに最小限修正

subject = "376";  % ← 369 から 376 に変更

% 解析結果の保存先 (preprocessed フォルダ)
save_dir = fullfile(dirPref.rootDir, "preprocessed");

% 必要なら preprocessed フォルダを作成
if ~exist(save_dir,"dir")
    mkdir(save_dir);
end

% electrode Excel を読み込む
% ★ファイル名は実際のものに合わせて変更してください
uiopen(fullfile(dirPref.rawDir, "human", "Stage1", ...
    "376R_Electrode_Sites_KN_DS.xlsx"));

% 以下はオリジナルのまま（変数名 RElectrodeSitesKNDSS1 が
% ちゃんと workspace に出てくる想定です）

%channel = RElectrodeSitesKNDSS1.Channel;
%region  = RElectrodeSitesKNDSS1.region;  % 8 functional regions
%lobe    = RElectrodeSitesKNDSS1.lobe;    % 4 anatomical lobes

channel = RElectrodeSitesKNDS.Channel;
region  = RElectrodeSitesKNDS.region;
lobe    = RElectrodeSitesKNDS.lobe;


lobeNames = {'occipital','parietal','temporal','frontal'};

nChannelByLobe = 3;
channelsByLobe = [];
tgtChannels    = [];

for ilobe = 1:numel(lobeNames)
    channelsByLobe{ilobe} = find(strcmp(lobeNames{ilobe}, string(lobe)))';
    randIdx = randperm(numel(channelsByLobe{ilobe}));
    tgtChannels = [tgtChannels channelsByLobe{ilobe}(randIdx(1:nChannelByLobe))];
end

save(fullfile(save_dir, "detectChannels_" + subject), ...
    "channelsByLobe","tgtChannels","lobeNames","channel","lobe");
