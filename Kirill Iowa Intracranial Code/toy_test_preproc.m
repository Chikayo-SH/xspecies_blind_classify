%% toy_test_preproc.m
% おもちゃデータで
%  1) raw
%  2) raw + mean subtraction
%  3) raw + mean subtraction + line noise removal
% の違いを確認する

clear; clc;

%% 1. おもちゃデータを作る
Fs = 1000;          % サンプリングレート [Hz]
T  = 0.2;           % エポック長 [s]
N  = Fs * T;        % サンプル数 (= 200)
t  = (0:N-1)/Fs;    % 時間軸

f_signal = 10;      % 「脳波っぽい」10 Hz 成分
f_line   = 50;      % ラインノイズ 50 Hz
dc_level = 1.0;     % DC オフセット
noise_sd = 0.3;     % ガウスノイズの標準偏差

nTrials  = 60;      % trial 数

% time x trial の行列を作成
awake_data = zeros(N, nTrials);
for tr = 1:nTrials
    awake_data(:,tr) = ...
        dc_level + ...                          % DC
        sin(2*pi*f_signal*t)' + ...             % 10 Hz 正弦波
        0.5*sin(2*pi*f_line*t)' + ...           % 50 Hz ラインノイズ
        noise_sd * randn(N,1);                  % 白色ノイズ
end

% preprocess_kirill で使っている形に合わせて
% time x trial x condition (ここでは condition 1 = awake のみ、本物らしく 2 条件にしておく)
data_raw = zeros(N, nTrials, 2);
data_raw(:,:,1) = awake_data;   % condition 1: awake（おもちゃ）
data_raw(:,:,2) = awake_data;   % condition 2: ダミー（使わない）

%% 2. Chronux 用 params を設定（本番コードと同じ形）
params = struct();
params.Fs         = Fs;
params.tapers     = [5 9];   % time-bandwidth=5, 9 本のターパー
params.pad        = 2;
params.removeFreq = [];

%% 3. 図の保存先など（カレントディレクトリに保存）
thisCh          = 999;                % ダミーのチャネル番号
save_dir        = pwd;                % 今のフォルダ
savedata_prefix = "toy_human_376_ch999";

%% 4. plot_awake_raw_vs_preproc を呼ぶ
% 注意: preprocessOneCh.m と plot_awake_raw_vs_preproc.m が path 上にあること
plot_awake_raw_vs_preproc(data_raw, params, ...
                          thisCh, save_dir, savedata_prefix);

disp("toy test finished. Check the PNG file in:");
disp(save_dir);
