function ppc0 = ppc(phases)
    % INPUT: phases: Vector of phases (radians, single-precision)
    % OUTPUT:ppc0: pairwise phase consistency of the phases in `phases`.

    % Ensure phases is a vector
    if ~isvector(phases) || ~isnumeric(phases)
        error('phases must be a numeric vector.');
    end

    % Number of phasesa=
    N = length(phases);

    % Scale factor for PPC calculation
    scale_factor = (2 / (N * (N - 1)));

    % Precompute sine and cosine of phases to avoid recalculating
    [sphases, cphases] = sincos(phases);
    sphases = double(sphases); % Force to double to prevent overflow
    cphases = double(cphases);


    % Calculate PPC using serial computation
    ppc0 = 0;
    for ii = 1:(N-1)
        ppc0 = ppc0 + scale_factor * sum((cphases(ii) * cphases((ii+1):N)) + (sphases(ii) * sphases((ii+1):N)));
    end
end

function [s, c] = sincos(x)
    % Compute sine and cosine of x
    s = sin(x);
    c = cos(x);
end
