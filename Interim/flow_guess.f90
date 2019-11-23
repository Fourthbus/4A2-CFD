      subroutine flow_guess
 

      use common_block


      implicit none

! Local stuff
      real ::   mflow, machlim, tlim, mach_num, tdown,e,dy,dx,dxy,rodown,vdown
      real, dimension(i_max) :: Tstatic,Pstatic
      integer ::  i, j, ip

! In this subroutine we make an initial guess of the primary variables
! i.e.  ro, rovx, rovy and roe.
! The guess does not need to be very accurate but the better
! it is the faster your program will converge.
! You should assign values to ro(i,j), rovx(i,j), rovy(i,j) and roe(i,j)
! at every grid point in this subroutine.

! Work out the length of each "i" line between grid points "i,1" snd "i,nj"
! and call it  "aflow(i)" .

! INSERT your code here
      do i = 1,ni
        aflow(i) = sqrt( (x(i,nj)-x(i,1))**2.0 + (y(i,nj)-y(i,1))**2.0 )
      enddo

! Make an initial guess of the density and velocity at the exit by
! assuming isentropic flow between the inlet stagnation pressure pstagin
! and temperature tstagin and the exit static pressure pdown.
! Use these together with "aflow(ni)" to estimate the mass flow rate.
! call this "mflow".

! INSERT your code here
      tdown  = tstagin * ((pdown/pstagin)**(fga))
      rodown = pdown / rgas / Tdown
      vdown  = sqrt(2.0*cp*(tstagin - tdown))
      mflow  = rodown * aflow(ni) * vdown

! Set a limit to the maximum allowable mach number in the initial
! guess. call this "machlim". calculate the corresponding temperature.

      machlim = 1.0
      tlim = tstagin/(1.0 + 0.5*(gamma-1.0)*machlim*machlim)

! Now estimate the velocity and density at every "i" line.
! Call the velocity v_guess(i) and the density ro_guess(i).


! First assume that the density is constant and equal to the exit
! density calculated above and that the flow is perpendicular to the
! "i" = constant lines and hence occupies artea aflow(i).
! Use continuity to estimate the flow velocity v_guess(i).
! Use this velocity to calculate the static temperature assuming
! that the stagnation temperature is constant.
! Check that this temperature is not less than tlim and set = tlim
! if it is.
! Next use this temperature and isentropic flow to obtain a better
! estimate of the density, ro_guess(i).
! Use this density and continuity to obtain a better estimate of
! the velocity, set = v_guess(i).

! INSERT your code here
      do i = 1,ni-1 ! check if need 2 ~ ni-1 instead
        v_guess(i)   = mflow / rodown / aflow(i)
        tstatic(i)   = tstagin - ((v_guess(i)**2.0)/2.0/cp)
        if (tstatic(i).lt.tlim) then
          tstatic(i) = tlim
        endif
        pstatic(i)   = pstagin * ((tstatic(i)/tstagin)**(1.0/fga)) 
        ro_guess(i)  = pstatic(i) / rgas / tstatic(i)
        v_guess(i)   = mflow / ro_guess(i) / aflow(i)
      enddo

! Direct the velocity found above along the j= constant grid lines to find
! the velocity vx(i,j) in the  x  direction and vy(i,j) in the y.
! Use these and ro_guess(i) to set rovx(i,j), rovy(i,j) and roe(i,j).
! Also set ro(i,j).
! Note that roe(i,j) includes the kinetic energy component of the
! internal energy.

! INSERT your code here
      do j = 1,nj
        do i = 1,ni
          ip = i
          if (i==ni) ip=i-1
          dx  = x(ip+1,j) - x(ip,j)
          dy  = y(ip+1,j) - y(ip,j)
          dxy = sqrt(dx**2.0 + dy**2.0)
          ! work out the dx and dy value, n.b. exit value takes previous

          vx(i,j)   = v_guess(ip) * dx / dxy
          vy(i,j)   = v_guess(ip) * dy / dxy
          ro(i,j)   = ro_guess(ip)
          rovx(i,j) = ro(ip,j) * vx(ip,j)
          rovy(i,j) = ro(ip,j) * vy(ip,j)
          e         = cv * tstatic(ip) + 0.5 * v_guess(ip)**2.0
          roe(i,j)  = ro(ip,j) * e
        enddo
      enddo
     
! Store the "old" values of the variables for use in the first
! convergence check in subroutine "check_conv"

      do i=1,ni
        do j=1,nj
          ro_old(i,j)   = ro(i,j)
          rovx_old(i,j) = rovx(i,j)
          rovy_old(i,j) = rovy(i,j)
          roe_old(i,j)  = roe(i,j)
        end do
      end do      

      end
