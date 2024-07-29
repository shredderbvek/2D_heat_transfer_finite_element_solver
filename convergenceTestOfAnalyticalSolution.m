% Parameters
a = 0.4;
b = 0.6;
T0 = 180;
max_N = 100;

% Generate meshgrid
x = linspace(0, a, 200);
y = linspace(0, b, 200);
[X, Y] = meshgrid(x, y);

% Initialize error storage and previous solution
errors = [];
prev_solution = zeros(size(X));

% Iterate over the number of terms
for N = 1:max_N
    current_solution = analyticalSolver(X, Y, a, b, T0, N);
    error = norm(current_solution - prev_solution, 'fro'); % Using Frobenius norm for 2D arrays
    errors = [errors, error];
    prev_solution = current_solution;
    fprintf('N = %d, Error = %e\n', N, error);
end

% Plot the error in log scale
figure;
plot(1:max_N, errors, '-o');
set(gca, 'YScale', 'log');
title('Convergence of the Analytical Solution');
xlabel('Number of Terms (N)');
ylabel('Error (log scale)');
grid on;

% Plot the final solution
figure;
contourf(X, Y, current_solution, 50, 'LineColor', 'none');
colormap("jet");
colorbar;
title('Analytical Solution to 2D Heat Equation: All Dirilicht boundary conditions');
xlabel('x');
ylabel('y');
