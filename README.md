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
