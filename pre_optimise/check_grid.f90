      subroutine check_grid


      use common_block


      implicit none

! Local stuff
      integer :: i, j,test
      real :: xSum, ySum,small

! Check your grid and areas for both the "bump" and the "bend"
! test data.

! First check that all areas are positive (by program or writing out)

! INSERT your code here

      do i = 1,ni-1
         do j = 1,nj-1
            if (area(i,j).LT.0) then
               write(6,*) 'Negative area!'
               stop
            endif
         end do
      end do

! Next check that the sum of the length vectors of the 4 faces
! of every element is very nearly zero in each coordinate direction.
! It is absolutely essential that this is correct !
! If not go back and check your subroutine "generate_grid".

! Careful with a test of the form
!          if( a == 0.0 ) then .....
! This will probably never be true.  Computers work to a finite number of
! Significant figures and "a" will probably be +0.0000001 or -0.0000001.
! Test for something like
!          if( abs(a) <= small_number ) then ...

! Insert your code here

      do i = 1,ni-1
         do j = 1,nj-1
            xSum = dli(i,j)-dli(i+1,j)
            ySum = dlj(i,j)-dlj(i,j+1)
         end do
      end do

      small = 1E-6 !small_number threshold

      if (abs(xSum).GT.small) then
         write(6,*) 'X-grid not zero!'
         stop
      endif

      if (abs(ySum).GT.small) then
         write(6,*) 'Y-grid not zero!'
         stop
      endif
      !print *, 'xSum =',xSum,'ySum =',ySum !debug only

! Any other tests that you can think of. For example you could plot
! contours of  "area(i,j)" by using  --  call output_hg(area) .

      end
