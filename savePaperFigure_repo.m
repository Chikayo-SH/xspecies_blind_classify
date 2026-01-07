function savePaperFigure(fig, filenameBase)
% savePaperFigure  Simple wrapper to save figures as PNG for xspecies code.
%
%   savePaperFigure(fig, filenameBase)
%     fig          : figure handle (matlab.ui.Figure)
%     filenameBase : string/char, 拡張子なしのベース名
%
%   例:
%     savePaperFigure(gcf, 'results/my_figure')
%     → 'results/my_figure.png' として保存される

    if nargin < 2 || isempty(filenameBase)
        error('savePaperFigure:NotEnoughInputs', ...
              'savePaperFigure(fig, filenameBase) の2引数が必要です。');
    end

    % 文字列に変換
    if ~ischar(filenameBase) && ~isstring(filenameBase)
        error('savePaperFigure:InvalidFilename', ...
              'filenameBase は char または string で指定してください。');
    end
    filenameBase = char(filenameBase);

    % 末尾に .png がついていなければ足す
    [folder, name, ext] = fileparts(filenameBase);
    if isempty(ext)
        ext = '.png';
    end
    outFile = fullfile(folder, [name ext]);

    % 実体は単純な saveas
    saveas(fig, outFile);
end
