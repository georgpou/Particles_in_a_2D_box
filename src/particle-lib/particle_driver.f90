module particle_driver

    use mf_datatypes
    use particle_data
    use particle_sim
    use particle_state

    implicit none

contains

subroutine init_system(n, r_min, r_max, v_max)
    integer(4), intent(in) :: n                      ! number of particles from Python
    real(8), intent(in) :: r_max, r_min              ! min/max particle radii
    real(8), intent(in) :: v_max                     ! single speed (v_min removed)
    integer(ik) :: n_ik
    real(dp) :: r_min_dp, r_max_dp, v_max_dp

    print *, 'Allocating particle system...'         ! log allocation start
    n_ik = n
    call allocate_particle_system(psys, n_ik)        ! allocate particle storage

    print *, 'Initialising particle system...'       ! log init start
    r_min_dp = r_min
    r_max_dp = r_max
    v_max_dp = v_max
    call init_particle_system(psys, r_min_dp, r_max_dp, v_max_dp) ! init uses one speed; v_min not needed
end subroutine init_system

subroutine get_positions(coords)
    real(8), intent(inout) :: coords(:,:)            ! caller-provided array for positions
    coords = psys%pos                                ! copy all positions out
end subroutine get_positions

subroutine get_sizes(sizes)
    real(8), intent(inout) :: sizes(:)               ! caller-provided array for radii
    sizes = psys%r                                   ! copy all radii out
end subroutine get_sizes

subroutine write_sizes()
    call write_particle_sizes(psys)
end subroutine write_sizes

subroutine collision_check()
    call check_collision(psys)
end subroutine collision_check

subroutine boundary_check()
    call check_boundary(psys)
end subroutine boundary_check

subroutine update()
    call update_particle_system(psys)
end subroutine update

subroutine write_positions()
    call write_particle_positions(psys)
end subroutine write_positions

subroutine deallocate_system()
    call deallocate_particle_system(psys)
end subroutine deallocate_system

end module particle_driver
