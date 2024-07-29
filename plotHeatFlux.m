function [] = plotHeatFlux(x1, x2, x3, y1, y2, y3, connect, coord, q)
  % Plot heat flow vectors with background mesh
  xcentre = (x1 + x2 + x3)/3;
  ycentre = (y1 + y2 + y3)/3;
  figure()
  quiver(xcentre,ycentre,q(:,1),q(:,2));
  title('$Heat \; flux \; W/m^2 $','Interpreter','latex')
  hold on
  triplot(connect,coord(:,1),coord(:,2),'k');
  saveas(gcf, fullfile("gfx", "heatFluxOverDomain.png"));
 end
