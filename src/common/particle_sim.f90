module particle_sim

    use mf_datatypes
    use particle_data
    use vector_operations

    implicit none

contains

subroutine update_particle_system(psys, dtin)

    ! Update positions of particle system

    type(particle_system), intent(inout) :: psys
    integer(ik) :: i
    real(dp), intent(in), optional :: dtin
    real(dp) :: dt
    
    if (present(dtin)) then
        dt = dtin
    else
        dt = psys%rmin/(3.0_dp*psys%v0)
    end if 

    ! Update positions using basic Euler integration: s(new) = s(old) + v * dt
    do i = 1, psys%n_particles
        psys%pos(i,1) = psys%pos(i,1) + psys%vel(i,1) * dt
        psys%pos(i,2) = psys%pos(i,2) + psys%vel(i,2) * dt
    end do

end subroutine update_particle_system

subroutine check_boundary(psys)

    ! Check for boundary collision

    type(particle_system), intent(inout) :: psys
    integer(ik) :: i

    ! TODO: Implement boundary collision here

    do i = 1, psys%n_particles                       ! Go through each particle one by one
        ! X-direction walls
        if (psys%pos(i,1) - psys%r(i) < psys%x_min) then
            psys%pos(i,1) = psys%x_min + psys%r(i)   ! If it slips past the left wall, push it back inside
            psys%vel(i,1) = -psys%vel(i,1)           ! Flip its x speed so it bounces away from the wall
        else if (psys%pos(i,1) + psys%r(i) > psys%x_max) then
            psys%pos(i,1) = psys%x_max - psys%r(i)   ! If it slips past the right wall, push it back inside
            psys%vel(i,1) = -psys%vel(i,1)           ! Flip its x speed so it bounces away from the wall
        end if

        ! Y-direction walls
        if (psys%pos(i,2) - psys%r(i) < psys%y_min) then
            psys%pos(i,2) = psys%y_min + psys%r(i)   ! If it goes below the bottom, move it up to the edge
            psys%vel(i,2) = -psys%vel(i,2)           ! Flip its y speed to bounce upward
        else if (psys%pos(i,2) + psys%r(i) > psys%y_max) then
            psys%pos(i,2) = psys%y_max - psys%r(i)   ! If it goes above the top, move it down to the edge
            psys%vel(i,2) = -psys%vel(i,2)           ! Flip its y speed to bounce downward
        end if
    end do

end subroutine check_boundary

subroutine check_collision(psys)

    ! Check for particle particle collission.
    
    type(particle_system), intent(inout) :: psys
        
    integer(ik) :: i, j
    real(dp) :: d, r1, r2
    real(dp) :: vi(2), vj(2)
    real(dp) :: si(2), sj(2)
    real(dp) :: n(2), vdiff(2)
    real(dp) :: q
    
    !       | -------------|
    !               d
    ! | --- o --- |   | -- o -- |
    !          r1       r2
    ! 
    ! collide is true if d < (r1+r2)

    ! TODO: Implement collision algorithm here.
    
    do i = 1, psys%n_particles - 1                       ! Loop over all unique particle pairs
        si = psys%pos(i,:)                               ! Position of particle i
        vi = psys%vel(i,:)                               ! Velocity of particle i
        r1 = psys%r(i)                                   ! Radius of particle i
        do j = i + 1, psys%n_particles                   ! Only check each pair once
            sj = psys%pos(j,:)                           ! Position of particle j
            vj = psys%vel(j,:)                           ! Velocity of particle j
            r2 = psys%r(j)                               ! Radius of particle j

            n = si - sj                                  ! Vector between particle centers
            d = sqrt(dot_product(n, n))                  ! Distance between centers
            if (d <= 0.0_dp) cycle                       ! Skip if positions are identical

            if (d < (r1 + r2)) then                      ! Collision if distance < sum of radii
                vdiff = vi - vj                          ! Relative velocity
                if (dot_product(vdiff, n) < 0.0_dp) then ! Only resolve if moving towards each other
                    q = dot_product(vdiff, n) / (d*d)    ! Collision strength along the center line
                    vi = vi - q * n                      ! Update velocity for particle i
                    vj = vj + q * n                      ! Update velocity for particle j
                    psys%vel(i,:) = vi                   ! Store updated velocity for particle i
                    psys%vel(j,:) = vj                   ! Store updated velocity for particle j
                end if
            end if
        end do
    end do
	
end subroutine check_collision

end module particle_sim
