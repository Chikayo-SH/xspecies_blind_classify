function fix_CodeString_from_INP_mops(hctsaFile)
    % hctsaFile: 修正対象の .mat ファイル
    %
    % 例:
    % hctsaFile = '...\macaque_George_ch005_hctsa.mat';

    %% 1. hctsaDir と INP_mops.txt の場所
    hctsaDir = 'C:\Users\chikayo\lab\hctsa_proj\00_repos\hctsa';
    mopsFile = fullfile(hctsaDir, 'Database', 'INP_mops.txt');

    %% 2. INP_mops.txt → Name→Expr の map を作成
    fid = fopen(mopsFile, 'r');
    if fid < 0
        error('INP_mops.txt を開けませんでした: %s', mopsFile);
    end

    nameToExpr = containers.Map('KeyType','char','ValueType','char');

    while true
        line = fgetl(fid);
        if ~ischar(line); break; end
        line = strtrim(line);
        if isempty(line) || startsWith(line,'#')
            continue;
        end

        parts = regexp(line, '\s+', 'split');
        if numel(parts) < 2
            continue;
        end

        expr = parts{1};
        name = parts{end};

        name = strrep(name, '.', '');
        name = strtrim(name);

        if ~isempty(name)
            nameToExpr(name) = expr;
        end
    end
    fclose(fid);

    fprintf('INP_mops から %d 個の operations を読み込みました。\n', nameToExpr.Count);

    %% 3. hctsaFile から Operations だけ読み込む
    S = load(hctsaFile, 'Operations');   % ★他の変数は触らない
    Ops = S.Operations;
    names = Ops.Name;

    %% 4. Name が map にあるものの CodeString を修正
    nChanged = 0;
    for i = 1:numel(names)
        opName = names{i};
        if isKey(nameToExpr, opName)
            exprNew = nameToExpr(opName);
            exprOld = Ops.CodeString{i};
            if ~strcmp(exprOld, exprNew)
                Ops.CodeString{i} = exprNew;
                nChanged = nChanged + 1;
            end
        end
    end

    fprintf('CodeString を更新した operations: %d 個\n', nChanged);

    %% 5. 修正した Operations だけを .mat に追記保存（他はそのまま）
    Operations = Ops;   
    save(hctsaFile, 'Operations', '-append');   % ★ここが重要（-structではなく -append）

    fprintf('更新完了: %s\n', hctsaFile);
end
