function setup_hctsa_paths()
% Setup paths for:
%  - official HCTSA
%  - its external Toolboxes
%  - Chronux
%  - xspecies_blind_classify repo

    %% 1. HCTSA official 本体
    hctsaRoot = "C:\Users\chikayo\lab\hctsa_proj\00_repos\hctsa_official";

    if ~isfolder(hctsaRoot)
        warning("HCTSA root folder not found: %s", hctsaRoot);
        return;
    end

    addpath(hctsaRoot);
    addpath(fullfile(hctsaRoot, "Database"));
    addpath(fullfile(hctsaRoot, "FeatureSets"));
    addpath(fullfile(hctsaRoot, "Operations"));
    addpath(fullfile(hctsaRoot, "PeripheryFunctions"));
    addpath(fullfile(hctsaRoot, "PlottingAnalysis"));
    addpath(fullfile(hctsaRoot, "TimeSeries"));

    %% 2. HCTSA 付属 Toolboxes（外部ライブラリ）
    extRoot = fullfile(hctsaRoot, "Toolboxes");

    extSubdirs = [ ...
        "Danny_Kaplan", ...
        "Marwan_crptool", ...
        "gpml", ...
        "ZG_hmm", ...
        "ARFIT", ...
        "Michael_Small", ...
        "MatlabCentral", ...
        "Rudy_Moddemeijer", ...
        "DVV_Toolbox", ...
        "Physionet", ...
        "Max_Little", ...    % steps_bumps_toolkit, fastdfa, rpde など
        "nsamdf", ...
        "Misc", ...
        "catch22", ...
        "OpenTSTOOL" ...
    ];

    for k = 1:numel(extSubdirs)
        d = fullfile(extRoot, extSubdirs(k));
        if isfolder(d)
            addpath(genpath(d));
        else
            % 無いものは warning にとどめる（エラーにはしない）
            warning("External toolbox folder not found (skipping): %s", d);
        end
    end

    %% 3. Chronux 本体（HCTSA外に置いてある版）
    chronuxRoot = "C:\Users\chikayo\lab\hctsa_proj\00_repos\chronux\chronux_2_12\chronux_2_12";
    if isfolder(chronuxRoot)
        addpath(genpath(chronuxRoot));
    else
        warning("Chronux folder not found: %s", chronuxRoot);
    end

    %% 4. xspecies_blind_classify repo（解析コード）
    xspeciesRoot = "C:\Users\chikayo\lab\hctsa_proj\00_repos\xspecies_blind_classify";
    if isfolder(xspeciesRoot)
        addpath(xspeciesRoot);
        % 必要ならサブフォルダも
        % addpath(genpath(fullfile(xspeciesRoot, "preprocess")));
        % addpath(genpath(fullfile(xspeciesRoot, "helper")));
    else
        warning("xspecies repo folder not found: %s", xspeciesRoot);
    end

    %% 5. 確認メッセージ
    fprintf("HCTSA / Toolboxes / Chronux / xspecies paths have been added.\n");
    fprintf("Check with:\n");
    fprintf("  which TS_Compute\n");
    fprintf("  which mtspectrumc\n");
    fprintf("  which preprocessOneCh\n");
end
