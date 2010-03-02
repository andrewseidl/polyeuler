#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Project Euler in Python (2.5)
# John Evans <john@jpevans.com>


import sys
import math

from operator import attrgetter


def memoize(method):

    def make_key_from_args(args, kwargs):
        return (args, repr(kwargs))

    def find_or_create_cache(obj, method):
        name = "memo_cache_for_%s" % method.__name__
        if not hasattr(obj, name):
            setattr(obj, name, {})
        return getattr(obj, name)

    def memoized(self, *args, **kwargs):
        cache = find_or_create_cache(self, method)
        key = make_key_from_args(args, kwargs)
        if not key in cache:
            cache[key] = apply(method, [self] + list(args), kwargs)
        return cache[key]

    return memoized


def read_input(problem_number, filename):
    with open("inputs/%d/%s" % (problem_number, filename)) as f:
        return f.read()


def euler1():
    """Euler #1
    Answer: 233168

    If we list all the natural numbers below 10 that are multiples of 3 or 5,
    we get 3, 5, 6 and 9. The sum of these multiples is 23.

    Find the sum of all the multiples of 3 or 5 below 1000.

    """

    return sum(i for i in range(1, 1000) if i % 3 == 0 or i % 5 == 0)


def euler2():
    """Euler #2
    Answer: 4613732

    Each new term in the Fibonacci sequence is generated by adding the previous
    two terms. By starting with 1 and 2, the first 10 terms will be:

    1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...

    Find the sum of all the even-valued terms in the sequence which do not
    exceed four million.

    """

    n, a, b = 2, 1, 2
    while True:
        c = a + b
        if c > 4000000:
            break
        if c % 2 == 0:
            n = n + c
        a, b = b, c
    return n


def slow_is_prime(n):
    for x in range(2, int(math.ceil(math.sqrt(n)))):
        if n % x == 0:
            return False
    return True


def euler3():
    """Euler #3:
    Answer: 6857

    The prime factors of 13195 are 5, 7, 13 and 29.
    What is the largest prime factor of the number 600851475143 ?

    """

    X = 600851475143
    n = math.ceil(math.sqrt(X))
    while True:
        if X % n == 0 and slow_is_prime(n):
            return n
        n -= 1


def euler4():
    """Problem #4
    Answer: 906609

    A palindromic number reads the same both ways. The largest
    palindrome made from the product of two 2-digit numbers is 9009 =
    91 99.

    Find the largest palindrome made from the product of two 3-digit
    numbers.

    """

    r = 0
    for a in range(100, 1000):
        for b in range(100, 1000):
            c = a * b
            s = "%d" % c
            if s == s[::-1]:
                r = max(c, r)
    return r


def divisible_by_all(n, ds):
    for d in ds:
        if n % d != 0:
            return False
    return True


def euler5():
    """Problem #5
    Answer: 232792560

    2520 is the smallest number that can be divided by each of the
    numbers from 1 to 10 without any remainder.

    What is the smallest number that is evenly divisible by all of the
    numbers from 1 to 20?

    """

    r = [20, 19, 18, 17, 16, 15, 14, 13, 12, 11]

    i = 2520
    while True:
        if divisible_by_all(i, r):
            return i
        i += 1


def euler6():
    """Problem #6
    Answer: 25164150

    The sum of the squares of the first ten natural numbers is,
      1² + 2² + ... + 10² = 385
    The square of the sum of the first ten natural numbers is,
      (1 + 2 + ... + 10)² = 55² = 3025
    Hence the difference between the sum of the squares of the first
    ten natural numbers and the square of the sum is 3025 - 385 = 2640.

    Find the difference between the sum of the squares of the first one
    hundred natural numbers and the square of the sum.

    """

    r = range(1, 101)
    s = sum(r)
    return (s * s) - sum([(i * i) for i in r])


def euler7():
    """Problem #7
    Answer: 104743

    By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we
    can see that the 6th prime is 13.

    What is the 10001st prime number?

    """

    n = 2
    primes = [2]
    result = 0
    while True:
        for prime in primes:
            if n % prime == 0:
                break
        else:
            if len(primes) >= 10000:
                result = n
                break
            primes.append(n)
        n += 1
    return result


def euler18():
    """Problem #18
    Answer:

    By starting at the top of the triangle below and moving to
    adjacent numbers on the row below, the maximum total from top to
    bottom is 23.

    3
    7 4
    2 4 6
    8 5 9 3

    That is, 3 + 7 + 4 + 9 = 23.

    Find the maximum total from top to bottom of the triangle below:

    (Triangle reproduced in input file problem18.txt)

    NOTE: As there are only 16384 routes, it is possible to solve this
    problem by trying every route. However, Problem 67, is the same
    challenge with a triangle containing one-hundred rows; it cannot
    be solved by brute force, and requires a clever method! ;o)

    """

    class Node(object):

        def __init__(self, value):
            self.value = int(value)
            self.parents = []

        @property
        @memoize
        def max_parent_cost(self):
            if len(self.parents) < 1:
                return 0
            return max(self.parents, key=attrgetter("full_cost")).full_cost

        @property
        def full_cost(self):
            return self.max_parent_cost + self.value

        def __repr__(self):
            return "Node(%d)" % self.value

        def __str__(self):
            return repr(self)

    def make_graph(contents):
        root = None
        previous_line = None
        for line in contents.split("\n"):
            if not line:
                break
            nums = line.strip().split(" ")
            if not root:
                if len(nums) > 1:
                    raise Exception("Expected a single root.")
                root = Node(nums[0])
                previous_line = [root]
            else:
                line_nodes = [Node(n) for n in nums]
                for index, node in enumerate(line_nodes):
                    if index > 0:
                        node.parents.append(previous_line[index - 1])
                    if index < len(previous_line):
                        node.parents.append(previous_line[index])
                previous_line = line_nodes
        return previous_line

    last_row = make_graph(read_input(18, "triangle.txt"))
    max_terminal = max(last_row, key=attrgetter("full_cost"))
#    import ipdb; ipdb.set_trace()
    return max_terminal.full_cost


EULERS = [euler1,
          euler2,
          euler3,
          euler4,
          euler5,
          euler6,
          euler18]


def main():
    if len(sys.argv) > 1:
        for n in sys.argv[1:]:
            n = int(n)
            print "%d: %d" % (n, eval("euler%d()" % n))
    else:
        for index, euler in enumerate(EULERS):
            print "%d: %d" % (index + 1, euler())


if __name__ == "__main__":
    main()
