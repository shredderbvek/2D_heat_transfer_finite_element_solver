% Parameters
width = 0.4;
height = 0.6;
nOfIteration = 100;
T0 = 180;

% List of mesh files
listMeshFiles = ["Mesh3.dat", "Mesh2.dat", "Mesh1.dat"];
errorResults = struct();

for k = 1:numel(listMeshFiles)
    fileName = listMeshFiles(k);
    fileID = fopen(fileName, 'r');
    
    % Check if the file opened successfully
    if fileID == -1
        error('Failed to open file: %s', fileName);
    end

    % Initiate solver and calculate results using the given mesh file
    [nodalCoord, connectivityMatrix, t_fem, reaction, flux, x1, x2, x3, y1, y2, y3] = heat_2d_solver(fileID);

    % Computation of analytical results for the given mesh file
    T_analytical = zeros(size(t_fem));

    for i = 1:numel(t_fem)
        x = nodalCoord(i, 1);
        y = nodalCoord(i, 2);
        T_analytical(i) = analyticalSolver(x, y, width, height, T0, nOfIteration);
    end

    % Computation of error
    [error, meanError, minError, maxError, stdDev] = computeError(t_fem, T_analytical, fileName);

    % Store the computed error results in the structure
    errorResults(k).fileName = fileName;
    errorResults(k).error = error;
    errorResults(k).meanError = meanError;
    errorResults(k).minError = minError;
    errorResults(k).maxError = maxError;
    errorResults(k).stdDev = stdDev;

    % Plot error contour
    figure;
    trisurf(connectivityMatrix, nodalCoord(:, 1), nodalCoord(:, 2), error, 'facecolor', 'interp', 'facelight', 'phong');
    colorbar;
    colormap("cool");
    title(["Error contour for ", fileName]);
    view(2);
    % Save the figure
    saveas(gcf, fullfile("gfx", sprintf('Error contour for %s.png', fileName)));
end

% Display the stored error results
disp(errorResults);
