# Particle Simulation Project Guide

This guide explains the project structure, how each task works, and how to build/run it. It is
written to be approachable for readers who are new to the codebase.

---

## Environment Setup (Conda)

1. Create the environment from the provided file:
   ```
   conda env create -f environment.yml
   ```
2. Activate it:
   ```
   conda activate compute-project
   ```
3. If the environment already exists and you want to refresh packages:
   ```
   conda env update -f environment.yml --prune
   ```

This environment includes NumPy (F2PY), vedo, and build tools needed for Task 2 and Task 3.

---

## Task 1: Fortran Particle Engine (Core Simulation)

### 1) Module skeleton

**Core modules (src/common):**
- `mf_datatypes.f90`
  - Defines numeric kinds (`dp`, `ik`) and constants like `pi`.
  - Keeps floating point precision consistent across the codebase.

- `particle_utils.f90`
  - Provides `init_random_seed()` to randomize the simulation.
  - Used in initialization so each run produces new positions/directions.

- `particle_data.f90`
  - Defines `type :: particle_system` containing:
    - number of particles, box bounds, radii, time step, positions, velocities.
  - Implements:
    - `allocate_particle_system` (allocates arrays)
    - `init_particle_system` (randomizes sizes, positions, and directions)
    - `write_particle_sizes` and `write_particle_positions` (creates `particle.state`)

- `particle_sim.f90`
  - Implements the physics for each time step:
    - `check_boundary` for wall collisions
    - `check_collision` for particle-particle collisions
    - `update_particle_system` to advance positions by `v * dt`

- `particle_state.f90`
  - Holds a module-level `particle_system` instance (`psys`).
  - Used later by the F2PY interface (Task 2).

- `vector_operations.f90`
  - Generic vector helpers (kept for completeness; not required by the current 2D code).

**Main program (src/particles/main.f90):**
- Defines simulation parameters (number of particles, radii, speed, steps).
- Calls `allocate_particle_system` and `init_particle_system`.
- Loops over time steps and applies the physics routines.
- Writes `particle.state` for visualization.

### 2) How modules communicate in Task 1

1. `main.f90` creates a `particle_system` and sets parameters.
2. `particle_data.f90` stores arrays and manages memory.
3. `particle_sim.f90` reads/writes the arrays to apply the physics.
4. `particle_data.f90` writes the output file (`particle.state`).

This is a simple flow: **main -> data -> simulation -> output**.

### 3) Scientific formulas used (Task 1)

- **Initial velocity direction:**
  - Direction angle `alpha` is random in `[0, 2*pi]`.
  - Velocity is: `v = (v0*cos(alpha), v0*sin(alpha))`.

- **Time step:**
  - `dt = r_min / (3*v0)` to avoid particles skipping through walls.

- **Wall collisions:**
  - If a particle center gets closer to a wall than its radius, flip the corresponding
    velocity component and clamp its position inside the box.

- **Particle collisions:**
  - Detect overlap when `distance < r_i + r_j`.
  - Resolve the collision along the line between centers using the elastic collision
    formula (dot product based update).

---

## Task 2: F2PY Interface (Python Driver)

### 1) Interface module
File: `src/particle-lib/particle_driver.f90`

This module wraps the core Fortran code in a Python-friendly API:
- `init_system` (create and initialize the system)
- `get_positions` / `get_sizes`
- `collision_check`, `boundary_check`, `update`
- `write_positions`, `deallocate_system`

Important detail: the interface uses `integer(4)` and `real(8)` so F2PY can generate wrappers
without special mapping files. Internally, values are converted to the project kinds (`ik`, `dp`).

### 2) Build flow for Task 2
1. CMake builds a shared library from the core Fortran modules.
2. F2PY wraps only `particle_driver.f90` and links to that library.
3. A Python extension module is produced: `particle.cpython-...-darwin.so`.

### 3) Python driver logic
File: `particles.py`

The Python driver mirrors the Fortran main loop:
1. Allocate NumPy arrays for positions and sizes.
2. Call `particle_driver.init_system(...)`.
3. Loop:
   - `collision_check`, `boundary_check`, `update`
   - `get_positions` (and optionally `write_positions`)
4. Deallocate.

The output file `particle.state` can still be generated from Python.

---

## Task 3: Vedo Visualization

### 1) Visualization script
File: `particles_vedo.py`

This script:
- Uses the same F2PY interface as Task 2.
- Creates vedo `Sphere` objects to draw particles.
- Updates the sphere positions every time step.

### 2) 2D simulation, 3D rendering
Vedo expects 3D coordinates, but the simulation is 2D.
The script keeps:
- a **2D array** for simulation (x, y)
- a **3D array** for rendering (x, y, z=0)

Each frame copies the 2D positions into the 3D buffer before rendering.

---

## How to Run the Particle Player

### Task 1 (Fortran output)
1. Build and run the Fortran simulation:
   ```
   ./configure_build.sh
   ./run_fortran.sh
   ```
2. Copy the output file where the player expects it:
   ```
   mkdir -p build
   cp particle.state build/particle.state
   ```
3. Run:
   ```
   python particle_player.py
   ```

### Task 2 (Python driver output)
1. Build the F2PY interface and Python extension:
```
conda activate compute-project
rm -rf build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_F2PY=ON
cmake --build build
cp build/src/particle-lib/particle*.so .
cp build/src/particle-lib/libparticle.dylib .
```
2. Run the Python driver:
   ```
   python particles.py
   ```
3. Copy `particle.state` to `build/` as above.
4. Run the player:
   ```
   python particle_player.py
   ```

### Task 3 (Vedo visualization)
- The visualization runs directly from the F2PY interface:
  ```
  python particles_vedo.py
  ```

---

## How to Change the Number of Particles

### Task 1 (Fortran)
Edit in `src/particles/main.f90`:
```
n_particles = 200
```
Rebuild and rerun.

### Task 2 (Python)
Edit in `particles.py`:
```
n_particles = 1000
```
Run `python particles.py`.

### Task 3 (Vedo)
Edit the first number in ParticleSimulation in `particles_vedo.py`:
```
part_sys = ParticleSimulation(plt, 1000, 0.015, 0.045)
```
Run `python particles_vedo.py`.

---
