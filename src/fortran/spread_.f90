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

module spread_

  use, intrinsic :: iso_c_binding, only: c_double, c_int
  use types, only: dp
  implicit none
  public spread1, spread2, spread3

contains

  subroutine spread1( &
       num_nodes, dimension_, nodes, num_vals, s_vals, evaluated) &
       bind(c, name='BAKEOFF&
       &OPT&
       &_spread1')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    integer(c_int), intent(in) :: num_vals
    real(c_double), intent(in) :: s_vals(num_vals)
    real(c_double), intent(out) :: evaluated(dimension_, num_vals)
    ! Variables outside of signature.
    real(c_double) :: one_less(num_vals)
    real(c_double) :: broadcast_s(num_vals, dimension_, num_nodes)
    real(c_double) :: broadcast_one_less(num_vals, dimension_, num_nodes)
    real(c_double) :: workspace(num_vals, dimension_, num_nodes)
    integer(c_int) :: i

    one_less = 1.0_dp - s_vals
    ! s_vals:                        [num_vals]
    ! SPREAD(s_vals, 2, dimension_): [num_vals, dimension_]
    ! broadcast_s:                   [num_vals, dimension_, num_nodes]
    broadcast_s = SPREAD(SPREAD(s_vals, 2, dimension_), 3, num_nodes)
    broadcast_one_less = SPREAD(SPREAD(one_less, 2, dimension_), 3, num_nodes)

    workspace = SPREAD(nodes, 1, num_vals)
    do i = num_nodes - 1, 1, -1
       workspace(:, :, 1:i) = ( &
            broadcast_one_less(:, :, 1:i) * workspace(:, :, 1:i) + &
            broadcast_s(:, :, 2:i + 1) * workspace(:, :, 2:i + 1))
    end do
    evaluated = TRANSPOSE(workspace(:, :, 1))

  end subroutine spread1

  subroutine spread2( &
       num_nodes, dimension_, nodes, num_vals, s_vals, evaluated) &
       bind(c, name='BAKEOFF&
       &OPT&
       &_spread2')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    integer(c_int), intent(in) :: num_vals
    real(c_double), intent(in) :: s_vals(num_vals)
    real(c_double), intent(out) :: evaluated(dimension_, num_vals)
    ! Variables outside of signature.
    real(c_double) :: one_less(num_vals)
    real(c_double) :: broadcast_s(dimension_, num_vals, num_nodes)
    real(c_double) :: broadcast_one_less(dimension_, num_vals, num_nodes)
    real(c_double) :: workspace(dimension_, num_vals, num_nodes)
    integer(c_int) :: i

    one_less = 1.0_dp - s_vals
    ! s_vals:                        [num_vals]
    ! SPREAD(s_vals, 1, dimension_): [dimension_, num_vals]
    ! broadcast_s:                   [dimension_, num_vals, num_nodes]
    broadcast_s = SPREAD(SPREAD(s_vals, 1, dimension_), 3, num_nodes)
    broadcast_one_less = SPREAD(SPREAD(one_less, 1, dimension_), 3, num_nodes)

    workspace = SPREAD(nodes, 2, num_vals)
    do i = num_nodes - 1, 1, -1
       workspace(:, :, 1:i) = ( &
            broadcast_one_less(:, :, 1:i) * workspace(:, :, 1:i) + &
            broadcast_s(:, :, 2:i + 1) * workspace(:, :, 2:i + 1))
    end do
    evaluated = workspace(:, :, 1)

  end subroutine spread2

  subroutine spread3( &
       num_nodes, dimension_, nodes, num_vals, s_vals, evaluated) &
       bind(c, name='BAKEOFF&
       &OPT&
       &_spread3')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    integer(c_int), intent(in) :: num_vals
    real(c_double), intent(in) :: s_vals(num_vals)
    real(c_double), intent(out) :: evaluated(dimension_, num_vals)
    ! Variables outside of signature.
    real(c_double) :: one_less(num_vals)
    real(c_double) :: broadcast_s(dimension_, num_nodes, num_vals)
    real(c_double) :: broadcast_one_less(dimension_, num_nodes, num_vals)
    real(c_double) :: workspace(dimension_, num_nodes, num_vals)
    integer(c_int) :: i

    one_less = 1.0_dp - s_vals
    ! s_vals:                        [num_vals]
    ! SPREAD(s_vals, 1, dimension_): [dimension_, num_vals]
    ! broadcast_s:                   [dimension_, num_nodes, num_vals]
    broadcast_s = SPREAD(SPREAD(s_vals, 1, dimension_), 2, num_nodes)
    broadcast_one_less = SPREAD(SPREAD(one_less, 1, dimension_), 2, num_nodes)

    workspace = SPREAD(nodes, 3, num_vals)
    do i = num_nodes - 1, 1, -1
       workspace(:, 1:i, :) = ( &
            broadcast_one_less(:, 1:i, :) * workspace(:, 1:i, :) + &
            broadcast_s(:, 2:i + 1, :) * workspace(:, 2:i + 1, :))
    end do
    evaluated = workspace(:, 1, :)

  end subroutine spread3

end module spread_
