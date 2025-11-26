function log_first5_hctsa_errors(hctsaFile, outLogFile)
% log_first5_hctsa_errors
%   hctsaFile に含まれる TS_Quality を調べて、
%   「errorCode=1（error）」を出した operation のうち先頭5本について、
%   Operation情報と再評価時のエラーメッセージを outLogFile に書き出す。
%
%   入力:
%       hctsaFile  : 計算済み HCTSA ファイル (.mat)
%       outLogFile : ログを書き出すテキストファイルパス
%
%   出力:
%       なし（ログファイルへの書き出しのみ）

    % --- 1) 必要な変数を読み込み ---
    S = load(hctsaFile, "TS_Quality", "Operations");
    TS_Quality = S.TS_Quality;   % timeSeries x operations の品質ラベル
    Operations = S.Operations;   % 各 operation のメタデータ

    % TS_Quality のコード定義:
    % 0: good, 1: error, 2: NaN, 3: Inf, 4: -Inf, 5: complex, 6: empty, 7: link error
    errorCode = 1;

    % --- 2) 「どのoperationでerrorが1つ以上出ているか」を取得 ---
    hasErrorPerOp = any(TS_Quality == errorCode, 1);  % 1 x nOp の logical
    errorOpIdx = find(hasErrorPerOp);                 % Operations 内の行インデックス

    if isempty(errorOpIdx)
        fprintf("No operations with errorCode=%d found in %s\n", errorCode, hctsaFile);
        return;
    end

    % ログ対象は先頭5本（5本未満ならあるだけ）
    nToLog = min(5, numel(errorOpIdx));

    % --- 3) ログファイルを開く ---
    fid = fopen(outLogFile, "w");
    if fid == -1
        error("Could not open log file: %s", outLogFile);
    end

    fprintf(fid, "Log of first %d operations with errorCode=%d in %s\n", ...
        nToLog, errorCode, hctsaFile);
    fprintf(fid, "============================================================\n\n");

    % --- 4) 先頭から順に、operationごとに詳細を記録 ---
    for k = 1:nToLog
        opInd = errorOpIdx(k);          % Operations テーブルの行インデックス
        opID  = Operations.ID(opInd);   % Operation ID（MasterOperation_ID に対応）
        opName = Operations.Name{opInd};

        fprintf(fid, "[%d] opInd=%d, ID=%d, Name=%s\n", k, opInd, opID, opName);

        % どの time series で問題が起きたか、実データと codeEval を取得
        [ts_ind, dataCell, codeEval] = TS_WhichProblemTS(opID);

        fprintf(fid, "    Problematic TS IDs: ");
        fprintf(fid, "%d ", ts_ind);
        fprintf(fid, "\n");

        % 代表として最初のTSだけを使って codeEval を再評価する
        x = dataCell{1};  %#ok<NASGU> % codeEval 内では x を使う想定
        try
            eval(codeEval);
            fprintf(fid, "    Re-eval result: NO ERROR in current environment.\n\n");
        catch ME
            fprintf(fid, "    Re-eval ERROR message:\n");
            fprintf(fid, "    %s\n\n", ME.message);
        end
    end

    fclose(fid);

    fprintf("Logged first %d error operations to %s\n", nToLog, outLogFile);
end
