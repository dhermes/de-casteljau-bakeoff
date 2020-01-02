! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     https://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.

module do_

  use, intrinsic :: iso_c_binding, only: c_double, c_int
  use types, only: dp
  implicit none
  public do1, do2, do3

contains

  subroutine do1( &
       num_nodes, dimension_, nodes, num_vals, s_vals, evaluated) &
       bind(c, name='BAKEOFF_do1')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    integer(c_int), intent(in) :: num_vals
    real(c_double), intent(in) :: s_vals(num_vals)
    real(c_double), intent(out) :: evaluated(dimension_, num_vals)
    ! Variables outside of signature.
    real(c_double) :: one_less(num_vals)
    real(c_double) :: workspace(num_vals, dimension_, num_nodes)
    integer(c_int) :: i, j

    one_less = 1.0_dp - s_vals

    do j = 1, num_vals
       workspace(j, :, :) = nodes
    end do

    do i = num_nodes - 1, 1, -1
       do j = 1, num_vals
          workspace(j, :, 1:i) = ( &
               one_less(j) * workspace(j, :, 1:i) + &
               s_vals(j) * workspace(j, :, 2:i + 1))
       end do
    end do
    evaluated = TRANSPOSE(workspace(:, :, 1))

  end subroutine do1

  subroutine do2( &
       num_nodes, dimension_, nodes, num_vals, s_vals, evaluated) &
       bind(c, name='BAKEOFF_do2')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    integer(c_int), intent(in) :: num_vals
    real(c_double), intent(in) :: s_vals(num_vals)
    real(c_double), intent(out) :: evaluated(dimension_, num_vals)
    ! Variables outside of signature.
    real(c_double) :: one_less(num_vals)
    real(c_double) :: workspace(dimension_, num_vals, num_nodes)
    integer(c_int) :: i, j

    one_less = 1.0_dp - s_vals

    do j = 1, num_vals
       workspace(:, j, :) = nodes
    end do

    do i = num_nodes - 1, 1, -1
       do j = 1, num_vals
          workspace(:, j, 1:i) = ( &
               one_less(j) * workspace(:, j, 1:i) + &
               s_vals(j) * workspace(:, j, 2:i + 1))
       end do
    end do
    evaluated = workspace(:, :, 1)

  end subroutine do2

  subroutine do3( &
       num_nodes, dimension_, nodes, num_vals, s_vals, evaluated) &
       bind(c, name='BAKEOFF_do3')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    integer(c_int), intent(in) :: num_vals
    real(c_double), intent(in) :: s_vals(num_vals)
    real(c_double), intent(out) :: evaluated(dimension_, num_vals)
    ! Variables outside of signature.
    real(c_double) :: one_less(num_vals)
    real(c_double) :: workspace(dimension_, num_nodes, num_vals)
    integer(c_int) :: i, j

    one_less = 1.0_dp - s_vals

    do j = 1, num_vals
       workspace(:, :, j) = nodes
    end do

    do i = num_nodes - 1, 1, -1
       do j = 1, num_vals
          workspace(:, 1:i, j) = ( &
               one_less(j) * workspace(:, 1:i, j) + &
               s_vals(j) * workspace(:, 2:i + 1, j))
       end do
    end do
    evaluated = workspace(:, 1, :)

  end subroutine do3

end module do_
