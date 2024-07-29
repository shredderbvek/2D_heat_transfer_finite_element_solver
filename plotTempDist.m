function [] = plotTempDist(connect, coord, T)
  % Plot mesh with temperature distribution
  figure()
  trisurf(connect,coord(:,1),coord(:,2),T,'facecolor','interp','facelight','phong');
  colorbar;
  colormap("jet");
  title('$Temperature \; distribution \; (^0C) $','Interpreter','latex')
  % Set the view to be from above (top view)
  view(2); % view(2) sets the view to be 2D, equivalent to view([0 90])
  saveas(gcf, fullfile("gfx", "temperatureDistribution.png"));
 end
