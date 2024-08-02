function [error, meanError, minError, maxError, stdDev] = computeError(t_fem, T_analytical, file_name )
    %computation of error
    error = zeros(size(t_fem));
    for i = 1:length(t_fem)
        error(i) = abs(T_analytical(i) - t_fem(i));
    end

    %computation of values for mean, min, max and standard deviation
    meanError = mean(error);
    minError = min(error);
    maxError = max(error);
    stdDev = std(error);
end
