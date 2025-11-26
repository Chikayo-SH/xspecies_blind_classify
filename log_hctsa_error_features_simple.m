function log_hctsa_error_features_simple(hctsaFile, outLogFile)
% log_hctsa_error_features_simple
%   hctsaFile に含まれる TS_Quality を調べて、
%   「errorCode=1（error）」を出した operation の一覧を outLogFile に書き出す。
%
%   入力:
%       hctsaFile  : 計算済み HCTSA ファイル (.mat)
%       outLogFile : ログを書き出すテキストファイルパス
%
%   出力:
%       なし（ログファイルへの書き出しのみ）

    % --- 1) 必要な変数を読み込み ---
    S = load(hctsaFile, "TS_Quality", "Operations");
    TS_Quality = S.TS_Quality;   % timeSeries x operations
    Operations = S.Operations;   % operationメタデータ

    % TS_Quality のコード定義:
    % 0: good, 1: error, 2: NaN, 3: Inf, 4: -Inf, 5: complex, 6: empty, 7: link error
    errorCode = 1;

    % --- 2) 「errorを含むoperation」を取得 ---
    hasErrorPerOp = any(TS_Quality == errorCode, 1);  % 1 x nOp logical
    errorOpIdx = find(hasErrorPerOp);                 % Operations内の行インデックス

    if isempty(errorOpIdx)
        fprintf("No operations with errorCode=%d found in %s\n", errorCode, hctsaFile);
        return;
    end

    % --- 3) ログファイルを開く ---
    fid = fopen(outLogFile, "w");
    if fid == -1
        error("Could not open log file: %s", outLogFile);
    end

    fprintf(fid, "Operations with errorCode=%d in %s\n", errorCode, hctsaFile);
    fprintf(fid, "============================================================\n\n");

    % --- 4) 各operationごとに、何本のTSでerrorかを記録 ---
    nTS = size(TS_Quality,1);

    for k = 1:numel(errorOpIdx)
        opInd = errorOpIdx(k);           % Operations テーブルの行インデックス
        opID  = Operations.ID(opInd);    % Operation ID
        opName = Operations.Name{opInd}; % Operation 名

        % このoperationでerrorを出しているTSのindex
        tsError = find(TS_Quality(:,opInd) == errorCode);
        nErr = numel(tsError);

        fprintf(fid, "[%d] opInd=%d, ID=%d, Name=%s\n", ...
            k, opInd, opID, opName);
        fprintf(fid, "    #TS with error: %d / %d\n", nErr, nTS);

        % 全TSでerrorなら明示
        if nErr == nTS
            fprintf(fid, "    (All time series have error for this operation)\n");
        end

        % 代表として最初の数本だけTS IDを書く（多すぎると読みにくいので）
        maxList = min(10, nErr);
        fprintf(fid, "    Example TS IDs with error: ");
        fprintf(fid, "%d ", tsError(1:maxList));
        if nErr > maxList
            fprintf(fid, "... (total %d)\n\n", nErr);
        else
            fprintf(fid, "\n\n");
        end
    end

    fclose(fid);

    fprintf("Logged %d operations with errorCode=%d to %s\n", ...
        numel(errorOpIdx), errorCode, outLogFile);
end
