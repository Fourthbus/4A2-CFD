      subroutine apply_bconds

      use common_block

      implicit none

! Local stuff
      integer ::  j
      real ::  rfin, rfin1, rostagin, gm1
      real ::  tstat, eke, vel

! This subroutine applies the boundary conditions that p = pdown
! at i = ni. At the inlet boundary the change in density is relaxed
! to obtain roinlet(j) which is then used to obtain the other properties
! at inlet assuming isentropic flow from stagnation conditions "pstagin"
! and tstagin" together with the specified inlet flow angle "alpha1".

! Because the inlet condition may become unstable, it is safer to
! relax the changes in inlet density by a factor "rfin"
! Typically "rfin" = 0.25 as set below. Reduce this if the inlet
! becomes unstable.

! It is also worth checking if "roinlet" is greater than "rostagin"
! and setting roinlet to 0.9999*rostagin if it is.
! This saves the program crashing during severe transients.

      rfin     = 0.25
      rfin1    = 1.0-rfin
      rostagin = pstagin/(rgas*tstagin)
      gm1      = gamma - 1.0

      do j=1,nj

         if (nstep==1) then
            roinlet(j) = ro(1,j)
         else
            roinlet(j) = rfin*ro(1,j) + rfin1*roinlet(j)
         endif

         if ( roinlet(j) > 0.9999*rostagin ) then
            roinlet(j) = 0.9999*rostagin
         endif

! INSERT your code here to calculate p(1,j), rovx(1,j), rovy(1,j)
! and roe(1,j)  from roinlet(j), pstagin, tstagin  and alpha1.
! Also set vx(1,j), vy(1,j) and hstag(1,j)

         tstat      = tstagin * (roinlet(j)/rostagin)**(gm1)
         p(1,j)     = roinlet(j) *rgas*tstat ! pstagin * (tstat/tstagin)**(gamma/gm1)
         vel        = sqrt(2. * cp * (tstagin - tstat))
         vx(1,j)    = vel * cos(alpha1)
         vy(1,j)    = vel * sin(alpha1)
         rovx(1,j)  = roinlet(j) * vx(1,j)
         rovy(1,j)  = roinlet(j) * vy(1,j)
         ! eke        = cv * tstat + 0.5 * vel**2.0
         ! roe(1,j)   = roinlet(j) * eke
         hstag(1,j) = cp * tstagin ! (roe(1,j) + p(1,j)) / roinlet(j) !all above can go wrong DO CHECK!!!

      enddo
   
! Set the pressure at the downstream boundary i = ni to the exit
! static pressure "pdown" for all j values.

      ! INSERT your code here

      do j = 1,nj
         p(ni,j) = pdown
      enddo

      end
