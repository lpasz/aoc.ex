import os
from math import gcd
from typing import *


class MachineDescr:
    def __init__(self, s: str):
        s = s.strip()
        i = s.index("]")
        j = s.index("{")
        self.buttons = [
            [int(strnum) for strnum in parens[1:-1].split(",")]
            for parens in s[i + 1 : j].split()
        ]

        self.counters = [int(strnum) for strnum in s[j + 1 : -1].split(",")]

    def __repr__(self):
        return f"(buttons:{self.buttons} counters:{self.counters})"


with open("assets/aoc25/day10/input.txt", "r") as file:
    input = [MachineDescr(line) for line in file]

"""
initially the counters are all zero
pressing a button increments wired counters by one
we want to get counters to given state

we can view this as a set of linear equations:
let's form matrix, such that mat[cnt][btn] = how button btn affects counter cnt (1 or 0)

we want to find such vector p, where p[btn] - number of presses on the button btn such that mat * p == target
where target[cnt] is the desired final state for the counter cnt

each row in the matrix row=mat[cnt] together with target[cnt] forms a linear equation:
sum(row[btn]*p[btn] for each btn) = target[cnt]

we want to solve this set of equations to find p[btn] such that sum(p) is minimal (total number of button presses)

we can modify these equations:
we have remaining equations and modified equations
at each step we select on variable (btn) and move one equation to modified set, 
and modifying the remaining set such that row[btn] == 0 in each equation (so p[btn] is not used in this equation)
for this we select first equation that has nonzero row[btn] and for every other equation that has nonzero row[btn]
we create a new equation by multipling both by row[btn] from other equation and subtracting.

when we have the reduced equations we can try to solve them. there can be different number of free variables.

we can have a function that takes some known variables and tries to deduce other variables based on this,
the result of such operation can be some or all arguments known or there is contradiction

with such function we can have another function that calls itself recursively to guess the correct values, 
it should select values that bound minimal number of other values for this process to be effective

"""


def solve(machine: MachineDescr) -> int:
    num_btn = len(machine.buttons)
    num_cnt = len(machine.counters)

    # each row is equation, first num_btn elements are button coefficients and last element is target value
    # sum(row[btn]*p[btn]) == row[-1]
    mat = [[0] * (num_btn + 1) for _ in range(num_cnt)]

    for cnt, target in enumerate(machine.counters):
        mat[cnt][-1] = target

    for btn, wires in enumerate(machine.buttons):
        for cnt in wires:
            mat[cnt][btn] = 1

    print("mat", mat)

    # find maximum number of presses for each button
    # each press increments all connected counters
    # maximum presses is such that it exeeds the minimum target value
    bounds = [None] * num_btn
    for cnt in range(num_cnt):
        target = mat[cnt][-1]
        for btn in range(num_btn):
            if mat[cnt][btn] == 1 and (bounds[btn] is None or bounds[btn] > target):
                bounds[btn] = target

    # this will be the reduced matrix
    # it will be of form such that first row can have all non-zero coefficients
    # second row has row[0]==0
    # third row has row[0]==row[1]==0
    # etc until the last row where only some last elements are non zero
    reduced_mat = []

    # while there are still non-processed equations
    while len(mat) > 0:
        # we are going to take the last row, select one coefficient in it and make it zero in all other rows
        cur_row = mat.pop()
        # find first non-zero coefficient in the last row
        selected_btn = -1
        for btn in range(num_btn):
            if cur_row[btn] != 0:
                selected_btn = btn
                break

        if selected_btn < 0:
            # all coefficients were zero, just throw this row away and continue the loop
            assert cur_row[-1] == 0
            continue

        for row in mat:
            # make row[btn]==0
            a = cur_row[btn]
            b = row[btn]
            for i in range(num_btn + 1):
                row[i] = row[i] * a - cur_row[i] * b

            # normalize the equation
            row_gcd = gcd(*row)
            if row_gcd != 0:
                if row[-1] < 0:
                    row_gcd *= -1
                for i in range(len(row)):
                    row[i] //= row_gcd

        # move selected row to reduced_mat
        reduced_mat.append(cur_row)

    print("reduced_mat", reduced_mat)

    # takes known_values and substitutes them into matrix
    # tries to figure out other values
    # returns None if there is contradiction
    # or a new list of known_values
    def substitute(known_values: List[int | None]) -> List[int | None] | None:
        new_known = known_values[:]
        for row in reduced_mat:
            count_unknown = 0
            unknown_idx = -1
            sum_known = 0
            target = row[-1]
            for i in range(num_btn):
                if new_known[i] is None:
                    if row[i] != 0:
                        count_unknown += 1
                        unknown_idx = i
                else:
                    sum_known += new_known[i] * row[i]

            if count_unknown == 0:
                if sum_known != target:
                    return None
            elif count_unknown == 1:
                rhs = target - sum_known
                if rhs % row[unknown_idx] != 0:
                    return None
                val = rhs // row[unknown_idx]
                if val < 0:
                    return None
                new_known[unknown_idx] = val
        return new_known

    # this function recursively searches for solutions
    result = None
    result_sum = 0

    def search(known_values: List[None | int] = [None] * num_btn):
        nonlocal result, result_sum

        known_values = substitute(known_values)
        if known_values is None:
            return
        
        # optimization: early exit if current sum > already found result
        known_sum = sum(v for v in known_values if v is not None)
        if result is not None and known_sum > result_sum:
            return

        # check if all values are set
        all_known = True
        for v in known_values:
            if v is None:
                all_known = False
                break
        if all_known:
            sum_known = sum(known_values)
            if result is None or result_sum > sum_known:
                result = known_values
                result_sum = sum_known
            return

        # select least bound variable
        selected_btn = -1
        selected_count_unknown = num_btn + 1
        for row in reduced_mat:
            count_unknown = 0
            unknown_idx = -1
            for i in range(num_btn):
                if known_values[i] is None and row[i] != 0:
                    count_unknown += 1
                    unknown_idx = i
            if count_unknown > 0 and count_unknown < selected_count_unknown:
                selected_btn = unknown_idx
                selected_count_unknown = count_unknown

        # try all possible values for selected variable
        assert selected_btn >= 0
        for val in range(bounds[selected_btn] + 1):
            known_values[selected_btn] = val
            search(known_values)

    search()
    print("result", result)
    return result_sum


result = 0
for machine in input:
    print("---")
    print(machine)
    machine_result = solve(machine)
    print(machine_result)
    result += machine_result
print(result)
