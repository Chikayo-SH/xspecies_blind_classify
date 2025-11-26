% setup_cosProject_local.m
% ローカル環境用の dirPref を cosProject/dirPref として保存する

% 1) repo の root に移動
cd("C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify");

% 2) dirPref 構造体を作る
dirPref = struct;

% 解析結果 (preprocessed など) を置きたい場所
dirPref.rootDir = pwd;  % = C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify

% 生データがぶら下がっている場所 (11_data_raw)
dirPref.rawDir  = "C:\Users\chikayo\lab\hctsa_proj\11_data_raw";

% 3) MATLAB の preference として保存
setpref("cosProject","dirPref",dirPref);

% 4) 動作確認用に、設定内容を表示
disp("=== cosProject/dirPref を設定しました ===");
disp(dirPref);
