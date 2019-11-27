      subroutine smooth(prop)


      use common_block


      implicit none

! This subroutine smooths the variable "prop" (i.e. it adds the
! artificial viscosity) by taking (1-sf) x the calculated value of
! "prop" + sf x (the average of the surrounding values of "prop").
! where sf is the smoothing factor.
! It is modified if the deferred correction extension is adopted.

      real, dimension(i_max,j_max) ::  prop, corr_prop ! DCF

! Local stuff
      real, dimension(i_max,j_max) ::  store
      real  ::  sf, sfm1, avg, avg1, avgnj, corrnew ! DCF
      integer  ::  i, j, ip1, im1

! To avoid using already smoothed values for smoothing other values
! the smoothed values are initially stored in an array "store".
! Wall nodes do not have 4 neighbours, so the formula for smoothing them
! is different.
! Inlet and exit values are constrained by boundary conditions and extrapolation from
! previously smoothed nodes, so how they are smoothed has little material effect
! on the solution.  Remember that they do not have 4 neighbours.

      sf   = smooth_fac
      sfm1 = 1.0 - sf

      do i=1,ni
        ip1 = i+1
          if( i==ni ) ip1 = ni
          im1 = i-1
          if( i==1  ) im1 = 1

          do j=2,nj-1
            avg = 0.25*(prop(ip1,j)+prop(im1,j)+prop(i,j-1)+prop(i,j+1))

            corrnew = fcorr * (prop(i,j) - avg) ! DCF

! INSERT your code here
            store(i,j) = sf * avg + (sfm1) * prop(i,j)
            store(i,j) = 0.99*store(i,j) + 0.01*corrnew

          enddo

! On the surfaces j=1 and j=nj take the average as shown below.

        avg1  = (prop(im1,1)+prop(ip1,1)+2.*prop(i,2)-prop(i,3))/3.0
        avgnj = (prop(im1,nj) + prop(ip1,nj) + 2.*prop(i,nj-1)    &
              -  prop(i,nj-2))/3.0
        ! WHY these are calculated as this, write in report

! INSERT your code here to smooth the surface values
        corrnew = fcorr * (prop(i,1) - avg1) ! DCF
        store(i,1) = sf * avg1 + (sfm1) * prop(i,1)
        store(i,1) = 0.99*store(i,1) + 0.01*corrnew

        corrnew = fcorr * (prop(i,nj) - avgnj) ! DCF
        store(i,nj) = sf * avgnj + (sfm1) * prop(i,nj)
        store(i,nj) = 0.99*store(i,nj) + 0.01*corrnew

      enddo

! Reset the smoothed value to "prop" before returning to the main program.

      do i=1,ni
        do j=1,nj
          prop(i,j) = store(i,j)
        end do
      end do

      end