function outFiles = savePaperFigure(varargin)
% Minimal savePaperFigure: save figure to PNG (default) and optionally PDF.
%
% Supported calls:
%   savePaperFigure(fig, "C:\path\name")                 -> name.png
%   savePaperFigure(fig, "C:\path\name", "both")         -> name.png + name.pdf
%   savePaperFigure(fig, "C:\path\name", "pdf")          -> name.pdf
%   savePaperFigure("C:\path\name")                      -> gcf -> name.png
%   savePaperFigure(fig, "C:\path\name.png")             -> name.png
%   savePaperFigure(fig, "C:\path\name.pdf")             -> name.pdf

% 1) figure handle
argi = 1;
if nargin >= 1 && (ishghandle(varargin{1}) || isa(varargin{1}, "matlab.ui.Figure"))
    fig = varargin{1};
    argi = 2;
else
    fig = gcf;
end

% 2) base path
if nargin < argi
    basePath = fullfile(pwd, "figure_" + string(datetime("now","Format","yyyyMMdd_HHmmss")));
else
    basePath = string(varargin{argi});
    argi = argi + 1;
end

% 3) mode
mode = "png";
if nargin >= argi
    mode = lower(string(varargin{argi}));
end

% If basePath includes extension, infer mode
[folder, base, ext] = fileparts(basePath);
if strlength(folder) == 0
    folder = pwd;
end
if ~exist(folder, "dir")
    mkdir(folder);
end

if ext == ".png"
    mode = "png";
elseif ext == ".pdf"
    mode = "pdf";
elseif ext ~= ""
    % unknown ext -> treat as png
    mode = "png";
end

baseNoExt = fullfile(folder, base);
dpi = 300;

outFiles = strings(0,1);
if mode == "png" || mode == "both"
    pngFile = baseNoExt + ".png";
    try
        exportgraphics(fig, pngFile, "Resolution", dpi);
    catch
        set(fig, "PaperPositionMode", "auto");
        print(fig, pngFile, "-dpng", "-r" + string(dpi));
    end
    outFiles(end+1,1) = pngFile;
end

if mode == "pdf" || mode == "both"
    pdfFile = baseNoExt + ".pdf";
    try
        exportgraphics(fig, pdfFile, "ContentType", "vector");
    catch
        set(fig, "PaperPositionMode", "auto");
        print(fig, pdfFile, "-dpdf");
    end
    outFiles(end+1,1) = pdfFile;
end
end
