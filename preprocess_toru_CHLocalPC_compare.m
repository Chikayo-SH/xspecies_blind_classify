%% Description

%{

Data pre-processing

Line noise removal

%}

%% Common parameters
species  = 'macaque';
subject  = 'George';

% raw データ側のルート（11_data_raw 用）
raw_root  = 'C:\Users\chikayo\lab\hctsa_proj';   % <- 今までの root_dir
%root_dir = 'C:\Users\chikayo\lab\hctsa_proj'; %CH added
% プロジェクト（preprocessed 等）は dirPref.rootDir を使う
dirPref = getpref('cosProject','dirPref');
proj_root = dirPref.rootDir;


sample_rate = 1000;
%awake_file_t = fullfile(source_server, awake_dir, 'ECoGTime');
%load(awake_file_t); %ECoGTime
duration = 0.2; %[s]
frames = sample_rate * duration;

s_subtractMean = 1;
s_lineNoise = 1;

%% Path
%addDirPrefs_COS;
dirPref = getpref('cosProject','dirPref');
%save_dir = fullfile(dirPref.rootDir, 'preprocessed',species,subject);
%load_dir = fullfile(dirPref.rootDir,'Neurotycho Data');
% ★ ローカルPC用の入出力パスに変更
% preprocessed データ（detectChannels_George.mat など）がある場所
save_dir = fullfile(proj_root, 'preprocessed', species, subject);

% raw データ（11_data_raw\macaque\Stage1）がある場所
load_dir = fullfile(raw_root, '11_data_raw', 'macaque', 'Stage1');

% if exist(save_dir,'dir')
%     mkdir(save_dir);
% end

if ~exist(save_dir,'dir')   % ← 条件を反転
    mkdir(save_dir);
end

%% for spectral analysis
params = struct();
params.Fs = sample_rate;
params.tapers = [5 19]; %for monkey 
params.pad = 2;
params.removeFreq = [50];


%% load channels to process
load(fullfile(save_dir,['detectChannels_' subject]) ,'channel','tgtChannels','lobe');

% ★ 今回は代表 frontal ch として 5ch だけを処理
tgtChannels = 5;

for ich = 1:numel(tgtChannels)
    disp([num2str(ich), '/' num2str(numel(tgtChannels))]);

    thisCh = tgtChannels(ich);
    thisLobe = lobe(find(channel == thisCh));
    savedata_prefix = sprintf('%s_%s_ch%03d', species, subject, thisCh);
    data = getStats(species, subject);

    %% Load data
    data_tmp = cell(2,1);

    for icond = 1:2     %1: awake, %2: anesth

        source_dir = ['20120803PF_Anesthesia+and+Sleep_George_Toru+Yanagawa_mat_ECoG128' filesep 'Session' num2str(icond)];


        condition_file = fullfile(load_dir, source_dir, 'Condition');
        load(condition_file, 'ConditionIndex','ConditionTime','ConditionLabel');

        if icond == 1
            theseConditionIndex = [find(strcmp(ConditionLabel, 'AwakeEyesOpened-Start')) find(strcmp(ConditionLabel, 'AwakeEyesClosed-End'))];
        elseif icond == 2
            theseConditionIndex = [find(strcmp(ConditionLabel, 'Anesthetized-Start')) find(strcmp(ConditionLabel, 'Anesthetized-End'))];
        end
        theseTimeIdx = ConditionIndex(theseConditionIndex);

        chName = ['ECoG_ch' num2str(thisCh)];
        awake_file = fullfile(load_dir, source_dir, [chName '.mat']);
        tmp = load(awake_file); %ECoGData_chxx

        chDataName = ['ECoGData_ch' num2str(thisCh)];
        tmpdata=tmp.(chDataName);
        tmpdata = tmpdata(theseTimeIdx(1):theseTimeIdx(end));
        nTrials = floor(length(tmpdata)/frames);

        data_tmp{icond} = reshape(tmpdata(1:frames*nTrials), frames, nTrials);
    end

    %time x trial x condition
    data_raw = [];
    minTrials = min(size(data_tmp{1},2), size(data_tmp{2},2));
    data_tmp{1} = data_tmp{1}(:,randperm(size(data_tmp{1},2)));
    data_tmp{2} = data_tmp{2}(:,randperm(size(data_tmp{2},2)));
    data_raw(:,:,1) = data_tmp{1}(:,1:minTrials);
    data_raw(:,:,2) = data_tmp{2}(:,1:minTrials);

%%% --- 3種類の前処理でパワースペクトルを計算 --- %%%

% ① DC除去なし & rmlinescなし（完全なraw）
[~, ~, powers_raw,  ~, f_raw,  ~] = preprocessOneCh( ...
    data_raw, params, 0, 0);

% ② DC除去のみ（subtractMeanあり, rmlinescなし）
[~, ~, ~, powers_dc,   ~, f_dc] = preprocessOneCh( ...
    data_raw, params, 1, 0);

% ③ DC除去 + rmlinesc（本番と同じ設定）
[data_proc, preprocess_string, ~, powers_full, ~, f_full] = preprocessOneCh( ...
    data_raw, params, 1, 1);

% 周波数軸は3つとも同じはずだが、安全のため1つにそろえる
faxis = f_raw;  % = f_dc = f_full を想定


    %%% --- 平均 log power を計算（time x trial x condition） --- %%%

    % awake = condition 1, anesthetized = condition 2
    logP_raw_awake   = squeeze(mean(log(powers_raw(:,  :, 1)), 2));
    logP_dc_awake    = squeeze(mean(log(powers_dc(:,   :, 1)), 2));
    logP_full_awake  = squeeze(mean(log(powers_full(:, :, 1)), 2));

    logP_raw_anest   = squeeze(mean(log(powers_raw(:,  :, 2)), 2));
    logP_dc_anest    = squeeze(mean(log(powers_dc(:,   :, 2)), 2));
    logP_full_anest  = squeeze(mean(log(powers_full(:, :, 2)), 2));

    %%% --- プロット --- %%%

    figure;

    % 上段：awake
    ax(1) = subplot(2,1,1); hold on;
    plot(faxis, logP_raw_awake,  'Color',[1 0 0],   'LineStyle',':');  % ① raw (赤・点線)
    plot(faxis, logP_dc_awake,   'Color',[1 0 0],   'LineStyle','--'); % ② DCのみ (赤・破線)
    plot(faxis, logP_full_awake, 'Color',[1 0 0],   'LineStyle','-');  % ③ DC+rmlinesc (赤・実線)
    title('awake');
    xlim([1 120]);
    ylabel('log(power)');

    % 下段：anesthetized
    ax(2) = subplot(2,1,2); hold on;
    plot(faxis, logP_raw_anest,  'Color',[0 0 0],   'LineStyle',':');  % ① raw (黒・点線)
    plot(faxis, logP_dc_anest,   'Color',[0 0 0],   'LineStyle','--'); % ② DCのみ (黒・破線)
    plot(faxis, logP_full_anest, 'Color',[0 0 0],   'LineStyle','-');  % ③ DC+rmlinesc (黒・実線)
    title('anesthetized');
    xlim([1 120]);
    xlabel('Hz');
    ylabel('log(power)');

    linkaxes(ax(:),'x');

    % 共通凡例（下のsubplotに付ける）
    legend(ax(2), ...
        {'raw', 'DC removed', 'DC removed + rmlinesc'}, ...
        'Location','northeast');

    % 保存
    saveas(gcf, fullfile(save_dir, [savedata_prefix, '_powerspectra_3step.png']));
    close;


    % [data_proc, preprocess_string, powers_before, powers_after , faxis_before, faxis_after] ...
    %     = preprocessOneCh(data_raw, params, s_subtractMean, s_lineNoise);
    % 
    % %% Plot and check power spectra for each fly
    % figure;
    % 
    % ax(1)=subplot(211);hold on;
    % plot(faxis_before, squeeze(mean(log(powers_before(:, :, 1)),2)), 'r'); % wake
    % plot(faxis_before, squeeze(mean(log(powers_before(:, :, 2)),2)), 'k'); % anest
    % title('before preprocessing');
    % 
    % ax(2)=subplot(212);hold on;
    % plot(faxis_after, squeeze(mean(log(powers_after(:, :, 1)),2)), 'r'); % wake
    % plot(faxis_after, squeeze(mean(log(powers_after(:, :, 2)),2)), 'k'); % anest
    % title('after preprocessing');
    % 
    % xlim([1 120]);
    % linkaxes(ax(:));
    % 
    % 
    % xlabel('Hz');
    % ylabel('log(power)');
    % legend('awake', 'anesthetized');
    % %screen2png(fullfile(save_dir, [savedata_prefix, '_powerspectra']));
    % saveas(gcf, fullfile(save_dir, [savedata_prefix, '_powerspectra.png']));
    % close;
    % 
    % % %% Plot power spectra to help find validation trial with line noise
    % %
    % % % 50Hz line noise seems to be more apparent for channel 15
    % % % There seems to be another peak for channel 14 (not at 50Hz)?
    % %
    % % ch = 15;
    % % tr = 1;
    % %
    % % figure;
    % % for ep = 1 : size(powers_v_proc, 4)
    % %     subplot(6, 10, ep);
    % %     plot(faxis_v, log(powers_v_proc(:, ch, tr, ep)));
    % %
    % %     xlim([40 60]);
    % %     xlim([0 100]);
    % %     title(num2str(ep));
    % % end

    %% Save

    data.data_raw = data_raw;
    data.data_proc = data_proc;
    data.preprocess_params = params;
    data.preprocess_string = preprocess_string;
    data.channel = thisCh;
    data.lobe = thisLobe;

    out_file = [savedata_prefix preprocess_string];
    tic;
    save(fullfile(save_dir, out_file), 'data', '-v7.3', '-nocompression');
    toc
    disp(['data saved: ' fullfile(save_dir, out_file)]);
end


% %% Save
% 
% data = struct();
% data.train = data_t_proc;
% data.validate1 = data_v_proc;
% data.preprocess_params = params;
% data.preprocess_string = preprocess_string;
% 
% out_dir = '\\storage.erc.monash.edu.au\shares\MNHS-dshi0006\Massive\COSproject\preprocessed/';
% out_file = ['macaque_data' preprocess_string];
% mkdir(out_dir);
% tic;
% save([out_dir out_file], 'data', '-v7.3', '-nocompression');
% toc
% disp(['data saved: ' out_dir out_file]);
