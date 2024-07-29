%parameter
width = 0.4;
height = 0.6;
nOfIteration = 100;
T0 = 180;
%computation of simulation results for the given data file
fileName = "Mesh3.dat";
fileID = fopen(fileName, 'r');
% initiate solver and calculate results using the given mesh file
[nodalCoord, connectivityMatrix, t_fem, reaction, flux, x1, x2, x3, y1, y2, y3] = heat_2d_solver(fileID);
%computation of analytical results for the given mesh file
T_analytical = zeros(size(t_fem));

for i = 1:size(t_fem)
    x = nodalCoord(i, 1);
    y = nodalCoord(i, 2);
    T_analytical(i) = analyticalSolver(x, y, width, height, T0, nOfIteration);
end
%computation of error
[error, meanError, minError, maxError, stdDev] = computeError(t_fem, T_analytical, fileName);
figure();
%contour plot of error
trisurf(connectivityMatrix, nodalCoord(:, 1), nodalCoord(:, 2), error, 'facecolor','interp','facelight','phong');
colorbar;
colormap("cool");
title(["Error contour for ", fileName]);
