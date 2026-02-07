module particle_data
    use mf_datatypes
    use particle_utils, only: init_random_seed ! i was getting erros before doing this, i guess because of module dependencies

    implicit none

    type :: particle_system
        integer(ik) :: n_particles
        real(dp) :: x_min, x_max
        real(dp) :: y_min, y_max
        ! real(dp) :: z_min, z_max ! we will not use 3D, as the unit box is 2D
        real(dp) :: v0
        real(dp) :: rmin
        real(dp) :: rmax
        real(dp) :: dt
        real(dp), allocatable :: pos(:,:)
        real(dp), allocatable :: vel(:,:)
        real(dp), allocatable :: r(:)
    end type particle_system

contains

subroutine allocate_particle_system(psys, n)

    ! TODO:
    ! Allocate the pos, vel and r arrays
    ! Initialise the other variables in the particle system

    integer(ik), intent(in) :: n
    type(particle_system), intent(inout) :: psys

    psys%n_particles = n

    ! Box boundaries for 2D
    psys%x_min = 0.0_dp
    psys%x_max = 1.0_dp
    psys%y_min = 0.0_dp
    psys%y_max = 1.0_dp

    ! We set default values for velocity, minumum and maximum particle radius and time step
    psys%v0  = 0.0_dp
    psys%rmin = 0.0_dp
    psys%rmax = 0.0_dp
    psys%dt  = 0.0_dp

    ! we allocate the 2D positions array, the 2D velocities array and the 1D radius array and give default values
    allocate(psys%pos(n,2), psys%vel(n,2), psys%r(n))

    psys%pos = 0.0_dp
    psys%vel = 0.0_dp
    psys%r   = 0.0_dp

end subroutine allocate_particle_system

subroutine deallocate_particle_system(psys)

    ! TODO:
    ! Deallocate the pos, vel and r arrays
    ! Set the n_particles variable in psys to -1

    type(particle_system), intent(inout) :: psys

    deallocate(psys%pos, psys%vel, psys%r)
    psys%n_particles = -1 ! we set it to minus 1 to make the system invalid after deallocation

end subroutine deallocate_particle_system

subroutine init_particle_system(psys, r_min, r_max, v_max)

    ! TODO:
    ! Set the initial state of7 the particle system
    !
    ! Random number generator can be initialised with
    !
    !     call init_random_seed()
    !
    ! Random number can be generated using the following subroutine
    !
    !     call random_number(v)
    !
    ! You can pass an entire array to this functionas well.

    type(particle_system), intent(inout) :: psys
    real(dp), intent(in) :: r_min, r_max, v_max ! we only need one velocity as all particles will have the same initial speed
    integer(ik) :: i
    real(dp) :: u, alpha, speed ! u is a random number, alpha is a random number in [0,2*pi] to compute the speed vector, and speed, is well... the speed : )
    real(dp) :: xsafe, ysafe ! we determine a safe distance that a particle can be placed in the box. This ensures we will not have a particle overlap with the edges

    ! Store inputs and choose a safe timestep.
    psys%rmin = r_min
    psys%rmax = r_max
    psys%v0   = v_max
    psys%dt   = psys%rmin / (3.0_dp * psys%v0)

    call init_random_seed()    ! Initialise random number generator for the simulation seed

    do i = 1, psys%n_particles ! loop over particles
        ! Randomise radius between r_min and r_max
        call random_number(u)
        psys%r(i) = r_min + u * (r_max - r_min)

        ! randomise alpha variable controlling direction of velocity
        call random_number(u)
        alpha = u * 2.0_dp * acos(-1.0_dp) !! we call random number again because we need a different random number than the one called above

        ! time for speed, which will be the same for all particles in the beginning
        speed = psys%v0
        psys%vel(i,1) = speed * cos(alpha) ! randomised direction for velocity of particle i and coodinate x
        psys%vel(i,2) = speed * sin(alpha) ! randomised direction for velocity of particle i and coordinate y

        ! positioning the particles randomly inside the box by respecting the radius of each particle
        xsafe = psys%x_max - psys%x_min - 2.0_dp * psys%r(i)
        ysafe = psys%y_max - psys%y_min - 2.0_dp * psys%r(i)

        ! generate the random central position of each particle in the array
        call random_number(u)
        psys%pos(i,1) = psys%x_min + psys%r(i) + xsafe * u
        call random_number(u)
        psys%pos(i,2) = psys%y_min + psys%r(i) + ysafe * u
    end do

end subroutine init_particle_system

subroutine print_particle_system(psys)

    type(particle_system), intent(inout) :: psys
    !integer(ik) :: i

    print *, 'Max particle x coord = ', maxval(psys%pos(:,1))
    print *, 'Min particle x coord = ', minval(psys%pos(:,1))
    print *, 'Max particle y coord = ', maxval(psys%pos(:,2))
    print *, 'Min particle y coord = ', minval(psys%pos(:,2))
   ! print *, 'Max particle z coord = ', maxval(psys%pos(:,3)) these have been commented out as we are working in 2D
   ! print *, 'Min particle z coord = ', minval(psys%pos(:,3)) these have been commented out as we are working in 2D

    !write(*,*) '----- Particle postion - velocity -----------------------------'
    !do i=1,psys%n_particles
    !   write(*,'(2F12.5,A5,2F12.5)') psys%pos(i,:), '-', psys%vel(i,:)
    !end do

    !write(*,*) '----- Particle size -------------------------------------------'
    !do i=1,psys%n_particles
    !        write(*,'(F12.5)') psys%r(i)
    !end do

end subroutine print_particle_system

subroutine write_particle_sizes(psys)

    type(particle_system), intent(inout) :: psys
    integer(ik) :: i

    open(unit=15, file='particle.state', access='APPEND')
    write(15, '(I10)') psys%n_particles
    do i = 1, psys%n_particles
        write(15, '(F12.5)') psys%r(i)
    end do
    close(unit=15)
end subroutine write_particle_sizes

subroutine write_particle_positions(psys)

    type(particle_system), intent(inout) :: psys
    integer(ik) :: i

    open(unit=15, file='particle.state', access='APPEND')
    write(15, '(I10)') psys%n_particles
    do i = 1, psys%n_particles
        write(15, '(2F12.5)') psys%pos(i,:)
    end do
    close(unit=15)
end subroutine write_particle_positions

end module particle_data
