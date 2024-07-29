# 2D Heat Transfer Finite Element Solver

This repository contains a minimal implementation of a 2D heat transfer finite element solver. It is designed as an assignment to demonstrate the basic principles and application of the finite element method (FEM) for heat transfer analysis.

## Features

- **Basic Finite Element Analysis**: A simple yet effective FEM algorithm for solving 2D heat transfer problems.
- **Simple Mesh Generation**: Basic mesh setup for rectangular domains. The solver is designed for linear triangular elements. 
- **Material Properties**: Uniform material properties for thermal conductivity.
- **Boundary Conditions**: Implementation of Dirichlet, Neumann, and Cauchy boundary conditions.
- **Nodal Values of Heat Generation**: Implementation of nodal heat generation values.

## Usage

1. **Input Parameters**: Define problem parameters directly in the mesh data file, including mesh size, thermal conductivity, and boundary conditions.
2. **Solver Execution**: Run the solver to compute the temperature distribution.
3. **Output**: Basic output of temperature distribution and flux flow.

## File Description

1. **heat_2d_solver.m**: Heat transfer solver which takes mesh data file either in .dat or .txt format as an argument and returns field temperature matrix, connectivity matrix, elemental flux matrix, reaction fluxes, and local coordinate values for each element.
2. **plotTempDist.m**: Generates a trisurf plot to visualize the temperature distribution over the domain.
3. **plotHeatFlux.m**: Generates a quiver plot to visualize the heat flux over the domain.
4. **analyticalSolver.m**: Computes the approximate analytical solution for a specific heat transfer problem with left and right walls subjected to Dirilict boundary conditions, that is, the left wall is subjected to a temperature value of zero whereas the right wall is subjected to a non zero temperature value, and the top and bottom walls are subjected to zero flux Neumann boundary condition.
5. **mesh_generator.py": Generates triangular mesh and prepares mesh data file subject to the heat transfer problem defined for the analytical solver.
