      program euler

      use common_block

      implicit none



! Local stuff
      integer i,j
      ! makeinteger ncorr,ncorrs ! DCF debug stuff

! Open files to store the convergence history. Plotting is done via a separate
! program. "euler.log" is for use by pltconv. "pltcv.csv" is for use by paraview.

      indir  = '../../'
      outdir = trim(indir) // 'output/Optimise/DCF/'

! ask use to input test number
      print*, 'Enter test number (one digit): '
      ! testno = '1'
      read (*,*) testno

! DCF corr debugging
! This section allows code to log variation with iteration and DCF correction factor, saved in fcorr_x.csv
      ! open(unit=32,file=trim(outdir) // 'fcorr_test' // trim(testno) // '.csv')
      ! ncorrs = 50
      ! do ncorr = 0,ncorrs

! "read_data": to read in the data on the duct and geometry and flow conditions.
      call read_data

      open(unit=3,file=trim(outdir) // 'euler_test' // trim(testno) // '.log')
      open(unit=31,file=trim(outdir) // 'pltcv_test' // trim(testno) // '.csv')

       !mak fcorr = ncorr * 1./ncorrs ! DCF debug

! "generate_grid": to set up the grid coordinates, element areas and projected
! lengths of the sides of the elements.

      call generate_grid

! You can call subroutines "output*" here to plot out the grid you have generated.
! "output" writes "euler.csv" for paraview, "ouput_hg" write "euler.plt" for eulplt,
! "output_mat" writes "euler.mat" for matlab.

      call output(0)
      call output_hg(p,0)
      call output_mat(0)

! "check_grid": to check that the areas and projected lengths are correct.

      call check_grid

! "crude_guess" is what its name says. it enables you to
! start a calculation and obtain a solution but it will take longer than
! necessary. when your program is working you should replace it
! with "flow_guess" to obtain a better guess and a faster solution.

      ! call crude_guess
      call flow_guess

! You can call "output" here to plot out your initial guess of
! the flow field.

      call output(1)
      call output_mat(1)

! "set_timestep": to set the length of the timestep.
! initially this is a constant time step based on a conservative guess
! of the mach number.

      call set_timestep

!************************************************************************
!     start the time stepping do loop for "nsteps" loops.
!************************************************************************

      do nstep = 1, nsteps

        do i=1,ni
          do j=1,nj
            ro_start(i,j) = ro(i,j)
            ! roe_start(i,j) = roe(i,j)
            rovx_start(i,j) = rovx(i,j)
            rovy_start(i,j) = rovy(i,j)
          end do
        end do

! Runge-Kutta loop start
        nrkuts = 4
        do nrkut=1,nrkuts

          ! RK fraction
          frkut=1./(1.+nrkuts-nrkut)

! "set_others" to set secondary flow variables.

          call set_others

! "apply_bconds" to apply inlet and outlet values at the boundaries of the domain.

          call apply_bconds

! "set_fluxes" to set the fluxes of the mass, momentum, and energy throughout the domain.

          call set_fluxes

! "sum_fluxes" applies a control volume analysis to enforce the finite volume method
! for each cell (calculates the residuals) and sets the increments for the nodal values.

          call sum_fluxes(fluxi_mass,fluxj_mass,delro  , ro_inc,frkut)
          ! call sum_fluxes(fluxi_enth,fluxj_enth,delroe ,roe_inc)
          call sum_fluxes(fluxi_xmom,fluxj_xmom,delrovx,rovx_inc,frkut)
          call sum_fluxes(fluxi_ymom,fluxj_ymom,delrovy,rovy_inc,frkut)
!
! Update solution

          do i=1,ni
            do j=1,nj
              ro  (i,j) = ro_start  (i,j) + ro_inc  (i,j)
              ! roe (i,j) = roe_start (i,j) + roe_inc (i,j)
              rovx(i,j) = rovx_start(i,j) + rovx_inc(i,j)
              rovy(i,j) = rovy_start(i,j) + rovy_inc(i,j)
            end do
          end do

! Smooth the problem to ensure it remains stable.

          call smooth(ro, corr_ro)
          call smooth(rovx, corr_rovx)
          call smooth(rovy, corr_rovy)
          ! call smooth(roe)

! Runge-Kutta end here
        enddo

! Check convergence and write out summary every 5 steps

        if(mod(nstep,5)==0) then
          call check_conv
        end if

! Stop looping if converged to the input tolerance "conlim"

        if( emax < conlim .and.  eavg < (0.5*conlim) ) then
          write(6,*) ' Calculation converged in ',nstep,' iterations'
          write(6,*) ' To a convergence limit of ', conlim
          write(6,*) nstep
          ! write(32,"(i6,a1,1x,f5.4,)")  & ! previously write(31,"(i5,a1,1x,4(f13.6,a1,1x))") nstep,',',fcorr ! ,',',delroeavg! DCF debug use only
          exit
        endif
      end do
      ! end do ! DCF debug only

      !call output(1)
      !call output_mat(1)

!************************************************************************
!  end of time stepping do loop for "nsteps" loops.
!************************************************************************

! Calculation finished. call "output" to write the plotting file.
! N.B. Solution hasn't necessarily converged.

      ! call output(1)
      ! call output_hg(p,1)
      call output_mat(1)
!
      close(3)
      close(31)
      ! close(32) ! DCF debug onlu


      end
