function outFile = screen2png(figHandle, outFile, dpi)
% Minimal screen2png: export current figure to PNG.

if nargin < 1 || isempty(figHandle)
    figHandle = gcf;
end
if nargin < 2 || isempty(outFile)
    outFile = fullfile(pwd, "figure_" + string(datetime("now","Format","yyyyMMdd_HHmmss")) + ".png");
end
if nargin < 3 || isempty(dpi)
    dpi = 300;
end

[folder, base, ext] = fileparts(outFile);
if strlength(folder) == 0
    folder = pwd;
end
if ~exist(folder, "dir")
    mkdir(folder);
end
if isempty(ext)
    ext = ".png";
end
outFile = fullfile(folder, base + ext);

try
    exportgraphics(figHandle, outFile, "Resolution", dpi);
catch
    set(figHandle, "PaperPositionMode", "auto");
    print(figHandle, outFile, "-dpng", "-r" + string(dpi));
end
end
