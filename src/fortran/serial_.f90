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

module serial_

  use, intrinsic :: iso_c_binding, only: c_double, c_int
  use types, only: dp
  implicit none
  public serial_inner, serial_outer

contains

  subroutine serial_inner( &
       num_nodes, dimension_, nodes, s_val, evaluated) &
       bind(c, name='BAKEOFF&
       &OPT&
       &_serial_inner')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    real(c_double), intent(in) :: s_val
    real(c_double), intent(out) :: evaluated(dimension_)
    ! Variables outside of signature.
    real(c_double) :: one_less
    real(c_double) :: workspace(dimension_, num_nodes)
    integer(c_int) :: i

    one_less = 1.0_dp - s_val

    workspace = nodes
    do i = num_nodes - 1, 1, -1
       workspace(:, 1:i) = ( &
            one_less * workspace(:, 1:i) + &
            s_val * workspace(:, 2:i + 1))
    end do
    evaluated = workspace(:, 1)

  end subroutine serial_inner

  subroutine serial_outer( &
       num_nodes, dimension_, nodes, num_vals, s_vals, evaluated) &
       bind(c, name='BAKEOFF&
       &OPT&
       &_serial')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    integer(c_int), intent(in) :: num_vals
    real(c_double), intent(in) :: s_vals(num_vals)
    real(c_double), intent(out) :: evaluated(dimension_, num_vals)
    ! Variables outside of signature.
    integer(c_int) :: j

    do j = 1, num_vals
       call serial_inner( &
            num_nodes, dimension_, nodes, s_vals(j), evaluated(:, j))
    end do

  end subroutine serial_outer

end module serial_
