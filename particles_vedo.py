#!/usr/bin/env python

from vedo import Plotter, Cube, Sphere, settings
from particle import particle_driver
import numpy as np


class Particle:
    """
    Class implementing a single particle. Uses a vedo Sphere to represent the particle.
    """

    def __init__(self, plt, pos, radius=0.1, color='gray', res=8, use_trail=False):
        """Class constrcutor
        
        Initialises variables and creates a vedo Sphere object attribute and adds
        it to the vedo plotter object.
        """
        self.__pos = pos
        self.__plt = plt
        self.__r = radius
        self.__color = 'gray'
        self.__res = res
        self.use_trail = use_trail

        self.vsphere = Sphere(self.__pos, r=self.__r,
                              c=self.__color, res=self.__res)

        if self.use_trail:
            self.vsphere.addTrail(alpha=1, maxlength=1, n=50, c="g")

        # Add the sphere to the scene; newer vedo versions do not accept render= here
        self.__plt.add(self.vsphere)

    @property
    def pos(self):
        return self.__pos

    @pos.setter
    def pos(self, pos):
        self.__pos = pos
        self.vsphere.pos(self.__pos)

    @property
    def r(self):
        return self.__r

    @r.setter
    def r(self, r):
        self.__r = r

    @property
    def color(self):
        return self.__color

    @color.setter
    def color(self, color):
        self.__color = color

    @property
    def res(self):
        return self.__res

    @res.setter
    def res(self, res):
        self.__res = res


class Particles:
    """
    Class implementing a set of Particle objects. Contains methods for 
    updating all particles from the positions and sizes arrays.
    """

    def __init__(self, plt, positions, sizes):
        self.__positions = positions
        self.__sizes = sizes
        self.__plt = plt

        self.__particles = []
        for pos, size in zip(self.__positions, self.__sizes):
            # Pass only position and size; color should remain the default unless specified
            self.__particles.append(Particle(self.__plt, pos, size))

    def update(self):
        """Updates the sphere particles with positions from the positions array."""
        for i, p in enumerate(self.__particles):
            p.pos = self.__positions[i]


class ParticleSimulation:
    """
    A class to manage a particle simulation. 
    """

    def __init__(self, plt=None, n_particles=50, r_min=0.035, r_max=0.085, v_max=0.009):
        """ParticleSimulation constructor
        
        Initalises default values and initialises the particles system.
        """
        self.__n_particles = n_particles
        self.__r_min = r_min
        self.__r_max = r_max
        self.__v_max = v_max
        self.__plt = plt
        self.__initialised = False
        self.__particles = None

        self.__init_system()

    def __init_system(self):
        """Initialises the particles system and calls the fortran extension modules."""

        if self.initialised:
            particle_driver.deallocate_system()

        # Store 2D positions from Fortran (x, y), but keep a 3D buffer for vedo (x, y, z=0)
        self.__positions = np.zeros([self.n_particles, 2], 'd', order='F')
        self.__positions_3d = np.zeros([self.n_particles, 3], 'd')
        self.__sizes = np.zeros([self.n_particles], 'd', order='F')

        print("Initialise system...")

        particle_driver.init_system(
            self.__n_particles, self.__r_min, self.__r_max, self.__v_max)
        particle_driver.get_sizes(self.__sizes)
        particle_driver.get_positions(self.__positions)
        # Copy 2D positions into 3D buffer so vedo can render in 3D space
        self.__positions_3d[:, :2] = self.__positions
        self.__positions_3d[:, 2] = 0.0

        self.__particles = Particles(
            self.__plt, self.__positions_3d, self.__sizes)

        self.initialised = True

    def run(self):
        """Runs the actual simulations.
        
        The method returns when ESC has been pressed.
        """

        print("Run simulation...")

        reset_cam = True

        while True:
            particle_driver.collision_check()
            particle_driver.boundary_check()
            particle_driver.update()
            particle_driver.get_positions(self.__positions)
            # Keep the 3D buffer in sync with the latest 2D simulation positions
            self.__positions_3d[:, :2] = self.__positions

            self.__particles.update()

            self.__plt.show(resetcam=reset_cam, axes=1)

            if reset_cam:
                reset_cam = False
            # Some vedo versions do not expose an `escaped` flag; default to False
            if getattr(self.__plt, "escaped", False):
                break  # stop if ESC is detected

    def __del__(self):
        """Destructor
        
        Asks the fortran extension module to deallocate memory."""

        print("End simulation...")

        particle_driver.deallocate_system()

    @property
    def n_particles(self):
        return self.__n_particles

    @n_particles.setter
    def n_particles(self, n):
        self.__n_particles = n
        self.__init_system()

    @property
    def r_min(self):
        return self.__r_min

    @r_min.setter
    def r_min(self, v):
        self.__r_min = v
        self.__init_system()

    @property
    def r_max(self):
        return self.__r_max

    @r_max.setter
    def r_max(self, v):
        self.__r_max = v
        self.__init_system()

    @property
    def v_max(self):
        return self.__v_max

    @v_max.setter
    def v_max(self, v):
        self.__v_max = v
        self.__init_system()

    @property
    def plt(self):
        return self.__plt

    @plt.setter
    def plt(self, plt):
        self.__plt = plt

    @property
    def initialised(self):
        return self.__initialised

    @initialised.setter
    def initialised(self, flag):
        self.__initialised = flag


if __name__ == "__main__":

    # Disable depth peeling for compatibility across vedo versions
    if hasattr(settings, "use_depth_peeling"):
        settings.use_depth_peeling = False
    elif hasattr(settings, "useDepthPeeling"):
        settings.useDepthPeeling = False

    plt = Plotter(title="Particle Simulator",
                  bg="black", axes=0, interactive=False)

    part_sys = ParticleSimulation(plt, 20, 0.015, 0.045)
    part_sys.run()

    plt.show(interactive=True, resetcam=False).close()
