function h = mcolorbar(varargin)
% mcolorbar  Simple wrapper for colorbar used in COS/xspecies code.
%
%   h = mcolorbar(...) calls colorbar(...) and returns its handle.

    h = colorbar(varargin{:});
end
