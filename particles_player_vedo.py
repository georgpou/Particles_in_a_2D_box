#!/usr/bin/env python

from os import stat
import sys

from vedo import Plotter, Cube, Sphere, Spheres, Box, mag2, versor, vector, settings
from vedo.pointcloud import Points

from particle import *
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

        self.__vsphere = Sphere(self.__pos[0], r=self.__r,
                              c=self.__color, res=self.__res)

        self.__plt.add(self.__vsphere, render=False)

    def update(self, step):
        self.__vsphere.pos(self.__pos[step])

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
    """Particles class - Holds a complete set of particles"""

    def __init__(self, plt, filename=""):
        """Class constructor"""

        self.plt = plt
        self.filename = filename
        self.steps = 0
        
    def read(self):
        """Read particles from state file"""
        
        state_file = open(self.filename, 'r')
        n_particles = int(state_file.readline())
        
        self.__particle_dict = {}
        self.__particles = []
        self.__particle_radius = []
        
        # Read particle size
        
        print("Reading particle sizes...")
        
        for i in range(n_particles):
            self.__particle_radius.append(float(state_file.readline()))

        n_particles = int(state_file.readline())
        line = state_file.readline()
        
        print("Reading particle traces...")
        
        j = 0
        
        while line:
            j+=1
            for i in range(n_particles):
                pos = [float(item) for item in line.strip().split()]
                if i in self.__particle_dict:
                    self.__particle_dict[i].append(pos)
                else:
                    self.__particle_dict[i] = []
                    self.__particle_dict[i].append(pos)
                
                line = state_file.readline()
        
            if line:
                n_particles = int(line.strip())
                line = state_file.readline()
            
        state_file.close()    
        
        self.steps = j    
        
        # Convert to arrays and store in dict
        
        print("Converting particle traces to arrays...")
        
        for i in range(n_particles):
            p = np.asarray(self.__particle_dict[i])
            self.__particle_dict[i] = p
            self.__particles.append(Particle(self.plt, p, self.__particle_radius[i]))
            
    def update(self, step):
        for p in self.__particles:
            p.update(step)


class ParticleViewer:
    """
    A class to manage a particle simulation. 
    """

    def __init__(self, plt=None, state_filename='particle.state'):
        """ParticleViewer constructor
        """
        self.__plt = plt
        self.__particles = Particles(plt, state_filename)
        self.__particles.read()

    def run(self):
        """Runs the actual simulations.
        
        The method returns when ESC has been pressed.
        """

        print("Run simulation...")

        step = 0

        reset_cam = True

        while True:

            if step == self.__particles.steps:
                step = 0

            self.__particles.update(step)

            step += 1

            self.__plt.show(resetcam=reset_cam, axes=1)

            if reset_cam:
                reset_cam = False

            if self.__plt.escaped:
                break  # if ESC is hit during the loop


if __name__ == "__main__":

    settings.useDepthPeeling = False

    plt = Plotter(title="Particle Simulator",
                  bg="black", axes=0, interactive=False)

    part_viewer = ParticleViewer(plt)
    part_viewer.run()

    plt.show(interactive=True, resetcam=False).close()
