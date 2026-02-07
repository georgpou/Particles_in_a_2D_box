program particles

    use mf_datatypes
    use particle_data
    use particle_sim

    implicit none

    type(particle_system) :: psys
    integer(ik) :: i                              ! loop index for timesteps
    integer(ik) :: n_particles, n_steps            ! simulation size and duration
    real(dp) :: r_min, r_max, v0                   ! radius range and initial speed

    ! Simulation parameters (adjust as needed)
    n_particles = 200                              ! number of particles in the box
    n_steps = 500                                  ! number of timesteps to simulate
    r_min = 0.005_dp                               ! minimum particle radius
    r_max = 0.015_dp                               ! maximum particle radius
    v0 = 0.01_dp                                   ! initial speed (same for all particles)

    call allocate_particle_system(psys, n_particles)   ! allocate arrays for positions/velocities/radii
    call init_particle_system(psys, r_min, r_max, v0)   ! randomize sizes/positions and velocity directions

    ! Reset output file before writing sizes/positions
    open(unit=15, file='particle.state', status='replace') ! clear old output file
    close(unit=15)                                         ! release file handle

    print *, 'Running simulation...'

    call write_particle_sizes(psys)                    ! write radii header for the viewer

    do i = 1, n_steps                                 ! advance the simulation
        call check_collision(psys)                    ! handle particle-particle collisions
        call check_boundary(psys)                     ! handle wall collisions
        call update_particle_system(psys)             ! move particles for one timestep
        call write_particle_positions(psys)           ! write positions for visualization
    end do

    call print_particle_system(psys)                  ! print simple diagnostics

    print *, 'Deallocating particle system...'

    call deallocate_particle_system(psys)             ! release memory

end program particles
