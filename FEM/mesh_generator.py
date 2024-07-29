import numpy as np
import matplotlib.pyplot as plt

def mesh_generator(width, height, num_x_div, num_y_div):
    # Generate grid points
    x = np.linspace(0, width, num_x_div + 1)
    y = np.linspace(0, height, num_y_div + 1)
    X, Y = np.meshgrid(x, y)
    points = np.vstack((X.flatten(), Y.flatten())).T

    # Create triangular connectivity
    triangles = []
    for i in range(num_y_div):
        for j in range(num_x_div):
            p1 = i * (num_x_div + 1) + j
            p2 = p1 + 1
            p3 = p1 + (num_x_div + 1)
            p4 = p3 + 1
            triangles.append([p1, p2, p4])
            triangles.append([p4, p3, p1])

    triangles = np.array(triangles) + 1  # Convert to 1-based indexing
    return points, triangles

# generates mesh data file
def mesh_data_generator(points, triangles, num_x_div, num_y_div, width, height, filename='mesh_data'):
    with open(filename+".dat", 'w') as f:
        f.write(f"TITLE = {file_name}\n")
        f.write(f"ELEMENTS = {len(triangles)}\n")
        
        for i, tri in enumerate(triangles, start=1):
            f.write(f"{i}\t{tri[0]}\t{tri[1]}\t{tri[2]}\t1.5\n")
        
        f.write("\nNODE_COORDINATES = {}\n".format(len(points)))
        
        for i, point in enumerate(points, start=1):
            f.write(f"{i}\t{point[0]}\t{point[1]}\t0.0\n")
        
        f.write(f"\nNODES_WITH_PRESCRIBED_TEMPERATURE = {(num_y_div + 1)*2 }\n")
        
        for i, point in enumerate(points, start = 1):
            if point[0] == 0:
                f.write(f"{i}\t0.000\n")
                continue
            if point[0] == width:
                f.write(f"{i}\t180.000\n")
                continue
        
        f.write("\nEDGES_WITH_PRESCRIBED_CONVECTION = 0\n")
        f.write("\nEDGES_WITH_PRESCRIBED_NON_ZERO_HEAT_FLUX = 0\n")

    print(f"{file_name}.dat has been created\n")
        
# definiton of basic parameters
mesh_files = ["Mesh3", "Mesh2", "Mesh1"]
domain_width = 0.4
domain_height = 0.6
no_of_elem_x = 6
no_of_elem_y = 6

# generation of data files whose number of elements is double for every loop
for i, file_name in enumerate(mesh_files, start = 1):
    nodes, connectivity_matrix = mesh_generator(domain_width, domain_height, no_of_elem_x, no_of_elem_y)
    mesh_data_generator(nodes, connectivity_matrix,no_of_elem_x, no_of_elem_y, domain_width, domain_height, file_name)
    if i % 2 == 0:
        no_of_elem_x = no_of_elem_x * 2
    else:
        no_of_elem_y = no_of_elem_y * 2
    
    