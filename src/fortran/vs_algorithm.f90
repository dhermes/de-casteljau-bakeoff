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

module vs_algorithm

  use, intrinsic :: iso_c_binding, only: c_double, c_int, c_int64_t
  use types, only: dp
  implicit none
  public vs_algorithm64

contains

  subroutine vs_algorithm64( &
       num_nodes, dimension_, nodes, num_vals, s_vals, evaluated) &
       bind(c, name='BAKEOFF&
       &OPT&
       &_vs_algorithm64')

    integer(c_int), intent(in) :: num_nodes, dimension_
    real(c_double), intent(in) :: nodes(dimension_, num_nodes)
    integer(c_int), intent(in) :: num_vals
    real(c_double), intent(in) :: s_vals(num_vals)
    real(c_double), intent(out) :: evaluated(dimension_, num_vals)
    ! Variables outside of signature.
    real(c_double) :: one_less(num_vals), s_pow(num_vals)
    integer(c_int) :: i, j
    integer(c_int64_t) :: binom_val

    one_less = 1.0_dp - s_vals
    s_pow = 1.0_dp
    binom_val = 1

    forall (i = 1:num_vals)
       evaluated(:, i) = one_less(i) * nodes(:, 1)
    end forall

    do i = 2, num_nodes - 1
       s_pow = s_pow * s_vals
       binom_val = (binom_val * (num_nodes - i + 1)) / (i - 1)
       forall (j = 1:num_vals)
          evaluated(:, j) = ( &
               evaluated(:, j) + &
               binom_val * s_pow(j) * nodes(:, i)) * one_less(j)
       end forall
    end do

    forall (i = 1:num_vals)
       evaluated(:, i) = ( &
            evaluated(:, i) + &
            s_pow(i) * s_vals(i) * nodes(:, num_nodes))
    end forall

  end subroutine vs_algorithm64

end module vs_algorithm
