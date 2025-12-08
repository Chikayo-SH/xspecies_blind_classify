%% Description

%{

Data pre-processing

Line noise removal

%}

%% Common parameters
species  = 'macaque';
subject  = 'George';

% root_dir = 'C:\Users\chikayo\lab\hctsa_proj'; %CH added
root_dir = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify';

% ★ ここで両方定義する（コマンドウィンドウではなくスクリプト内）
root_data = 'C:\Users\chikayo\lab\hctsa_proj'; % 11_data_raw がある場所
root_repo = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify'; % このリポジトリ


sample_rate = 1000;
%awake_file_t = fullfile(source_server, awake_dir, 'ECoGTime');
%load(awake_file_t); %ECoGTime
duration = 0.2; %[s]
frames = sample_rate * duration;

s_subtractMean = 1;
s_lineNoise = 1;

%% Path
dirPref = getpref('cosProject','dirPref');  % ここはそのままでもOK

% ★ 保存先はリポジトリ配下
save_dir = fullfile(root_repo, 'preprocessed', species, subject);

% ★ 読み込み元は「00_repos」の外側
load_dir = fullfile(root_data, '11_data_raw', 'macaque', 'Stage1');

if ~exist(save_dir,'dir')
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

% ★ 今回は代表 frontal ch として 17 ch だけを処理
tgtChannels = 17;

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

    [data_proc, preprocess_string, powers_before, powers_after , faxis_before, faxis_after] ...
        = preprocessOneCh(data_raw, params, s_subtractMean, s_lineNoise);
 
    %% Plot and check power spectra for each fly
    figure;

    ax(1)=subplot(211);hold on;
    plot(faxis_before, squeeze(mean(log(powers_before(:, :, 1)),2)), 'r'); % wake
    plot(faxis_before, squeeze(mean(log(powers_before(:, :, 2)),2)), 'k'); % anest
    title('before preprocessing');

    ax(2)=subplot(212);hold on;
    plot(faxis_after, squeeze(mean(log(powers_after(:, :, 1)),2)), 'r'); % wake
    plot(faxis_after, squeeze(mean(log(powers_after(:, :, 2)),2)), 'k'); % anest
    title('after preprocessing');

    xlim([1 120]);
    linkaxes(ax(:));

    xlabel('Hz');
    ylabel('log(power)');
    legend('awake', 'anesthetized');

    % ★ taper情報をファイル名に埋め込む
    taperStr_fig = sprintf('tapers%d-%d', params.tapers(1), params.tapers(2)); % 例: tapers5-19
    figName      = sprintf('%s_%s_powerspectra.png', savedata_prefix, taperStr_fig);
    % 例: macaque_George_ch017_tapers5-19_powerspectra.png
    
    saveas(gcf, fullfile(save_dir, figName));
    close;

    %% Save (データ)

    data.data_raw           = data_raw;
    data.data_proc          = data_proc;
    data.preprocess_params  = params;
    data.preprocess_string  = preprocess_string;
    data.channel            = thisCh;
    data.lobe               = thisLobe;

    % もともとのファイル名（パイプライン互換）
    out_file = [savedata_prefix preprocess_string];

    % ★ taper入りのファイル名も別途つくる
    taperStr = sprintf('_tapers%d-%d', params.tapers(1), params.tapers(2)); % 例: _tapers5-19
    out_file_withTaper = [savedata_prefix taperStr preprocess_string];

    tic;
    % ① これまでの名前（main_hctsa_1_init が読む用）
    save(fullfile(save_dir, out_file), 'data', '-v7.3', '-nocompression');

    % ② taper入りの名前（人間が識別しやすい用）
    save(fullfile(save_dir, out_file_withTaper), 'data', '-v7.3', '-nocompression');
    toc;

    disp(['data saved (original): '      fullfile(save_dir, out_file)]);
    disp(['data saved (with taper): '    fullfile(save_dir, out_file_withTaper)]);

end   % ★ for ich = 1:numel(tgtChannels) を閉じる end

