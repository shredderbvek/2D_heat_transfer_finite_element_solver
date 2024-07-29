 % Clear screen, workspace and close open figures
 clc; clear all; close all;
 %==========================================================================
 % Data input phase
 %==========================================================================
 fileName = input('Input data file name -------> ','s');
 fileID = fopen(fileName, 'r');
% initiate solver and calculate results using the given data file
[nodalCoord, connectivityMatrix, temp, reaction, flux, x1, x2, x3, y1, y2, y3] = heat_2d_solver(fileID);
%plot temperature distribution in the domain and save the figure
plotTempDist(connectivityMatrix, nodalCoord, temp);
%plot heat flux over the domain and save the figure
plotHeatFlux(x1, x2, x3, y1, y2, y3, connectivityMatrix, nodalCoord, flux );