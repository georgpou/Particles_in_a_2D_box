option(BUILD_F2PY "Build F2PY module" OFF)

if (WIN32)
    add_library(particle ../common/mf_datatypes.f90 ../common/mf_utils.f90 ../common/particle_defs.f90 ../common/particle_utils.f90 ../common/particle_data.f90 ../common/particle_sim.f90 ../common/particle_state.f90 ../common/vector_operations.f90)
else()
    add_library(particle SHARED ../common/mf_datatypes.f90 ../common/mf_utils.f90 ../common/particle_defs.f90 ../common/particle_utils.f90 ../common/particle_data.f90 ../common/particle_sim.f90 ../common/particle_state.f90 ../common/vector_operations.f90)
endif()

if (BUILD_F2PY)
    add_custom_command(TARGET particle
        POST_BUILD
        COMMAND ${F2PY_COMMAND} -m particle -c ${PROJECT_SOURCE_DIR}/src/particle-lib/particle_driver.f90 -lparticle -L${CMAKE_CURRENT_BINARY_DIR}
        VERBATIM
    )
endif()
