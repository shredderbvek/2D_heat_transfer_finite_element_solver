

% Clear screen, workspace and close open figures
clc; clear all; close all;

%==========================================================================
% Set some basic variables
%==========================================================================
nOfElemNodes=3;

%==========================================================================
% Data input phase. Read information from data file
%==========================================================================
fileName = input('Input data file name -------> ','s');
fileID = fopen(fileName, 'r');
title = fscanf(fileID, 'TITLE = %s',1);

% Total number of elements in the mesh
nOfElements = fscanf(fileID, '\nELEMENTS = %d', 1);

%--------------------------------------------------------------------------
% Read element information
%--------------------------------------------------------------------------
% Table of connectivities (also read conductivities and heat source data)
connect = fscanf(fileID, '\n%d %d %d %d %f', [nOfElemNodes+2,nOfElements]);
connect = connect';

% Extract element conductivity (isotropic conductivity assumed)
conductivity = connect(:,nOfElemNodes+2);

% Extract connectivity table
elementOrder = connect(:,1);
connect = connect(:,2:nOfElemNodes+1);

%connect(elementOrder,:) = connect;

%--------------------------------------------------------------------------
% Read nodal coordinates
%--------------------------------------------------------------------------
nOfNodes = fscanf(fileID, '\nNODE_COORDINATES = %d', 1);
coord = fscanf(fileID, '\n%d %f %f %f', [4, nOfNodes]);
coord = coord';

% Extract nodal coordinates and heat source values

nodeOrder = coord(:,1);
NodalHeatSource = coord(:, 4);
coord = coord(:,2:3);
coord(nodeOrder,:) = coord;
NodalHeatSource(nodeOrder) = NodalHeatSource;

% First, second and third vertexes of all elements
x1 = coord(connect(:,1),1);
x2 = coord(connect(:,2),1);
x3 = coord(connect(:,3),1);
y1 = coord(connect(:,1),2);
y2 = coord(connect(:,2),2);
y3 = coord(connect(:,3),2);

% Calculate element areas
elemArea = zeros(nOfElements,1);
for iElem=1:nOfElements
    elemArea(iElem) = ( (x1(iElem)-x3(iElem))*(y2(iElem)-y3(iElem))-...
        (y1(iElem)-y3(iElem))*(x2(iElem)-x3(iElem)))/2;
    if  elemArea(iElem) < 0
        error('element nodes numbered clock-wise in data file')
    end
end

%--------------------------------------------------------------------------
% Read prescribed temperature
%--------------------------------------------------------------------------
nOfNodesDirichlet = fscanf(fileID,'\nNODES_WITH_PRESCRIBED_TEMPERATURE = %d',1);
dirichletData = fscanf(fileID, '\n%d %f', [2, nOfNodesDirichlet]);
dirichletData = dirichletData';

% Set fixed dof's information arrays
nodesDirichlet = dirichletData(:,1);
valueDirichlet = dirichletData(:,2);

% Create a vector of lentgh nOfNodes and set 1 if the node has a imposed
% temperature or 0 otherwise
isNodeFixed = zeros(nOfNodes,1);
isNodeFixed(nodesDirichlet) = ones(nOfNodesDirichlet,1);

% Store a list of nodes with no imposed temperature (this is used in the
% elimintation process)
nOfNodesFree = nOfNodes - nOfNodesDirichlet;
nodesFree = zeros(nOfNodesFree,1);
counterNodesFree = 0;
for iNode = 1:nOfNodes
    if isNodeFixed(iNode)==0
        counterNodesFree = counterNodesFree + 1;
        nodesFree(counterNodesFree) = iNode;
    end
end

%--------------------------------------------------------------------------
% Read convection data
%--------------------------------------------------------------------------
nOfEdgesConvection = fscanf(fileID,'\nEDGES_WITH_PRESCRIBED_CONVECTION = %d',1);

if nOfEdgesConvection > 0
  convectionTable = fscanf(fileID,'\n%d %d %f %f', [4, nOfEdgesConvection]);
  convectionTable = convectionTable';

  % Extract the connectivities and convection coefficients
  convectionNodes = convectionTable(:,1:2);
  hCoeff = convectionTable(:,3);
  Tinfinity = convectionTable(:,4);

  % First and second vertexes of all edges
  xa = coord(convectionNodes(:,1),1);
  xb = coord(convectionNodes(:,2),1);
  ya = coord(convectionNodes(:,1),2);
  yb = coord(convectionNodes(:,2),2);

  % Compute the length of the edges on a convection boundary
  edgeLengthCauchy = zeros(1, nOfEdgesConvection);
  for iEdge = 1:nOfEdgesConvection
      edgeLengthCauchy(iEdge) = sqrt((xb(iEdge)-xa(iEdge))^2+(yb(iEdge)-ya(iEdge))^2);
  end
end
%--------------------------------------------------------------------------
% Read non zero heat flux data (Neumann boundary condition)
%--------------------------------------------------------------------------
nOfEdgesFlux = fscanf(fileID,'\nEDGES_WITH_PRESCRIBED_NON_ZERO_HEAT_FLUX = %d',1);
if nOfEdgesFlux > 0
  fluxTable = fscanf(fileID,'\n%d %d %f', [3, nOfEdgesFlux]);
  fluxTable = fluxTable';

  % Extract the connectivities and convection coefficients
  fluxNodes = fluxTable(:,1:2);
  elementalFlux = fluxTable(:,3);

  % First and second vertexes of all edges
  xa = coord(fluxNodes(:,1),1);
  xb = coord(fluxNodes(:,2),1);
  ya = coord(fluxNodes(:,1),2);
  yb = coord(fluxNodes(:,2),2);

  % Compute the length of the edges on a convection boundary
  edgeLengthNeumann = zeros(1, nOfEdgesFlux);
  for iEdge = 1:nOfEdgesFlux
      edgeLengthNeumann(iEdge) = sqrt((xb(iEdge)-xa(iEdge))^2+(yb(iEdge)-ya(iEdge))^2);
  end
end
%==========================================================================
% Solution phase. Assemble stiffness, forcing terms and solve system
%==========================================================================

%--------------------------------------------------------------------------
% Assemble global heat rate vector (internal heat sources contribution)
%--------------------------------------------------------------------------
RQ = zeros(nOfNodes,nOfNodes);
for iElem = 1:nOfElements
    % Compute element heat source
    rQ = elemArea(iElem)/12*[2 1 1; 1 2 1; 1 1 2];

    % Assembly: Add element contribution to global vector
    globalElementNodes = connect(iElem,:);
    RQ(globalElementNodes, globalElementNodes) = RQ(globalElementNodes, globalElementNodes) + rQ;
end

RQ_nodal = RQ * NodalHeatSource;

%--------------------------------------------------------------------------
% Compute global stiffness matrix
%--------------------------------------------------------------------------
K = zeros(nOfNodes,nOfNodes);
for iElem = 1:nOfElements
    % Compute element conductivity stiffness
    Bmatx = 1/(2*elemArea(iElem))*...
            [y2(iElem)-y3(iElem)  y3(iElem)-y1(iElem)  y1(iElem)-y2(iElem);
             x3(iElem)-x2(iElem)  x1(iElem)-x3(iElem)  x2(iElem)-x1(iElem)];
    ke = conductivity(iElem)*elemArea(iElem)*(Bmatx'*Bmatx);

    % Assembly: Add element contribution to global stiffness
    globalElementNodes = connect(iElem,:);
    K(globalElementNodes,globalElementNodes) = K(globalElementNodes,globalElementNodes) + ke;
end

%--------------------------------------------------------------------------
% Add convection contributions to stiffness and forcing term
%--------------------------------------------------------------------------
Rinfty = zeros(nOfNodes,1);
if nOfEdgesConvection > 0
  for iEdge = 1:nOfEdgesConvection
    % Compute convection contribution to global stiffness matrix
    hTe = hCoeff(iEdge)*edgeLength(iEdge)/6*[ 2  1 ; 1  2 ];

    % Assembly: Add convection contribution to global stiffness matrix
    globalEdgeNodes = convectionNodes(iEdge,:);
    K(globalEdgeNodes,globalEdgeNodes) = K(globalEdgeNodes,globalEdgeNodes) + hTe;

    % Compute contribution to global convection forcing vector
    rinfty = hCoeff(iEdge)*Tinfinity(iEdge)*edgeLengthCauchy(iEdge)/2*[1; 1];

    % Assembly: Add contribution to global convection forcing vector
    Rinfty(globalEdgeNodes) = Rinfty(globalEdgeNodes) + rinfty;
  end
end
%--------------------------------------------------------------------------
% Add non zero flux contributions to forcing term
%--------------------------------------------------------------------------
Rq = zeros(nOfNodes, 1);
if nOfEdgesFlux > 0
  for iEdge = 1: nOfEdgesFlux
    rq = 0.5 * elementalFlux(iEdge) * edgeLengthNeumann(iEdge)*[1 ; 1];
    globalEdgeNodes = fluxNodes(iEdge,:);
    Rq(globalEdgeNodes) = Rq(globalEdgeNodes) + rq;
  end
end
%--------------------------------------------------------------------------
% Global right hand side of the system
%--------------------------------------------------------------------------
F = RQ_nodal + Rinfty - Rq;

%--------------------------------------------------------------------------
% Apply the elimination process to account for Dirichlet boundaries
%--------------------------------------------------------------------------
% Retain only equations for nodes that are NOT in a Dirichlet boundary
Kstar = K(nodesFree,nodesFree);
Fstar = F(nodesFree);

% Modify the right hand side with prescribed values
for iRow = 1:nOfNodesFree
    nodeRow = nodesFree(iRow);
    Krow  = K(nodeRow,nodesDirichlet);
    Fstar(iRow) = Fstar(iRow) - Krow*valueDirichlet;
end

%--------------------------------------------------------------------------
% Solve the reduced system
%--------------------------------------------------------------------------
Tstar = Kstar\Fstar;

%--------------------------------------------------------------------------
% Add to the global vector the solution at Dirichlet nodes (known values)
%--------------------------------------------------------------------------
ngdof = nOfNodes;
T = zeros(ngdof,1);
T(nodesFree)= Tstar;
T(nodesDirichlet) = valueDirichlet;

% Compute reactions (heat flux) at nodes with prescribed temperature
R = zeros(ngdof,1);
for iRow = 1:nOfNodesDirichlet
    nodeRow = nodesDirichlet(iRow);
    Krow  = K(nodeRow,:);
    R(nodeRow) = Krow*T-F(nodeRow);
end

% Compute fluxes
% Plot mesh with heat flow vector distribution
xcentre = (x1 + x2 + x3)/3;
ycentre = (y1 + y2 + y3)/3;
q = zeros(nOfElements, 2);
for iElem = 1:nOfElements
    % Compute element heat flow vector
    Bmatx = 1/(2*elemArea(iElem))*...
            [y2(iElem)-y3(iElem)  y3(iElem)-y1(iElem)  y1(iElem)-y2(iElem);
             x3(iElem)-x2(iElem)  x1(iElem)-x3(iElem)  x2(iElem)-x1(iElem)];
    q(iElem,:) = -conductivity(iElem)*Bmatx*T(connect(iElem,:));
end

% Plot mesh with temperature distribution
figure(1)
trisurf(connect,coord(:,1),coord(:,2),T,'facecolor','interp','facelight','phong');
colorbar;

% Plot heat flow vectors with background mesh
figure(2)
quiver(xcentre,ycentre,q(:,1),q(:,2));
hold on
triplot(connect,coord(:,1),coord(:,2),'k');

%==========================================================================
% Close file(s) before terminating program
%==========================================================================
status = fclose(fileID);







