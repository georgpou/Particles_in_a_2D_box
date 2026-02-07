#!/usr/bin/env python

import os
import numpy as np

from particle import *

if os.path.exists('particle.state'):
    os.remove('particle.state')

n_particles = 200

coords = np.zeros([n_particles,2],'d', order='F')
sizes = np.zeros([n_particles], 'd', order='F')

print("Initialise system...")

particle_driver.init_system(n_particles, 0.015, 0.045, 0.009)
particle_driver.get_sizes(sizes)

particle_driver.write_sizes()

print("Run simulation...")

for i in range(500):
	particle_driver.collision_check()
	particle_driver.boundary_check()
	particle_driver.update()
	particle_driver.get_positions(coords)
	particle_driver.write_positions()
	
print("End simulation...")
	
particle_driver.deallocate_system()
