module ProjectEuler where

import EulerInputs
import Char (digitToInt, intToDigit, isAlpha)
import List (sort, nub, tails, transpose)
import Data.List (foldl1')
import Data.Array

-------------
-- Problem #1
-- Answer: 233168 (Confirmed)
--
-- If we list all the natural numbers below 10 that are multiples of 3
-- or 5, we get 3, 5, 6 and 9. The sum of these multiples is 23.
--
-- Find the sum of all the multiples of 3 or 5 below 1000.
euler1 :: Integer
euler1 = sum [x | x <- [0..999], mod x 3 == 0 || mod x 5 == 0]


-------------
-- Problem #2
-- Answer: 4613732 (Confirmed)
--
-- Each new term in the Fibonacci sequence is generated by adding the
-- previous two terms. By starting with 1 and 2, the first 10 terms
-- will be: 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, ...  Find the sum of
-- all the even-valued terms in the sequence which do not exceed four
-- million.
euler2 :: Integer
euler2 = sum [x | x <- takeWhile (< 4000000) fibs, mod x 2 == 0]


-- Nice alternative solution from PE forum.
euler2Alt :: Integer
euler2Alt = sum . takeWhile (< 4000000) . filter even $ fibs


-- The fibonacci sequence.  I originally did a naive implementation,
-- then ganked this rather clean implementation from the intarwebs:
--
--     fibs = 0 : 1 : zipWith (+) fibs (tail fibs)
--
-- But ultimately these were too slow for some of the more advanced
-- problems so I found and included the following memoized version
-- from http://www.haskell.org/pipermail/haskell-cafe/2007-February/022590.html.
fibs = map fib [1..]
fib = ((map fib' [0 ..]) !!)
    where
      fib' 0 = 0
      fib' 1 = 1
      fib' n = fib (n - 1) + fib (n - 2)


-------------
-- Problem #3
-- Answer: 6857 (Confirmed)
--
-- The prime factors of 13195 are 5, 7, 13 and 29.
-- What is the largest prime factor of the number 600851475143 ?
euler3 :: Integer
euler3 = maximum (primeFactors 600851475143)


-- Find the prime factors of n as quickly as possible.
--
-- I'm sure there are faster methods but for now this'll do.
primeFactors :: Integer -> [Integer]
primeFactors n =
    let first = firstPrimeFactor n
    in
      if first < n
      then nub (1:first:(primeFactors (div n first)))
      else [1,n]


-- Find the first prime factor of n.
firstPrimeFactor :: Integer -> Integer
firstPrimeFactor n =
    head [x | x <- [y | y <- takeWhile (< (fromIntegral (maxLowFactor n))) primes] ++ [n], factor n x]


-- Find the maximum number we have to check to find all the factors of
-- a number.
--
-- Is this really the cleanest way to do this in Haskell? I imagine
-- not.
maxLowFactor :: Integer -> Integer
maxLowFactor n = fromIntegral (ceiling (sqrt (fromIntegral n)))


-- The prime numbers.
primes :: [Integer]
primes = 2:3:[nextPrime n | n <- [3..]]


-- Find the next prime after n.
nextPrime :: Int -> Integer
nextPrime n =
    let
        previousPrimes :: [Integer]
        previousPrimes = take (n - 1) primes
    in
      head [x | x <- [(last previousPrimes)..],
                      odd x,
                      notDivisibleByAny (filter (< (square x)) previousPrimes) x]


-- transliterated from http://blog.functionalfun.net/2008/04/project-euler-problem-7-and-10.html
-- Determine if n is divisible by any of xs (short circuiting as soon
-- as a match is found).
divisibleByAny :: [Integer] -> Integer -> Bool
divisibleByAny xs n = length (take 1 (filter (factor n) xs)) > 0


-- Determine if n is NOT divisible by any of xs (no short circuit possible).
notDivisibleByAny :: [Integer] -> Integer -> Bool
notDivisibleByAny xs n = not (divisibleByAny xs n)


-- Square n.  Mostly to keep expressions pretty.
square :: Integer -> Integer
square n = n * n


-------------
-- Problem #4
-- Answer: 906609 (Confirmed)
--
-- A palindromic number reads the same both ways. The largest
-- palindrome made from the product of two 2-digit numbers is 9009 =
-- 91 99.
--
-- Find the largest palindrome made from the product of two 3-digit
-- numbers.
--

-- Since we know we are checking numbers we don't have to worry about
-- spaces or puncutation.
euler4 :: Integer
euler4 =
    let three_digit_numbers = [100..999]
    in maximum
           (filter
            palindromicNumber
            [x * y | x <- three_digit_numbers, y <- three_digit_numbers ])


-- Test n for palindromicity.
palindromicNumber :: Integer -> Bool
palindromicNumber n = s == reverse s
    where s = show n


-------------
-- Problem #5
-- Answer: 232792560 (Confirmed)
-- NOTE: Current solution too slow - took 32 minutes or something.
--
-- 2520 is the smallest number that can be divided by each of the
-- numbers from 1 to 10 without any remainder.
--
-- What is the smallest number that is evenly divisible by all of the
-- numbers from 1 to 20?
euler5 :: Integer
euler5 = let numsToCheck = reverse [11..20]
         in head (filter (divisibleByAll numsToCheck) [20..])


-- Determine if n is divisible by all xs.
divisibleByAll :: [Integer] -> Integer -> Bool
divisibleByAll xs n = length (takeWhile (factor n) xs) == length xs


-------------
-- Problem #6
-- Answer: 25164150 (Confirmed)
--
-- The sum of the squares of the first ten natural numbers is,
--     1² + 2² + ... + 10² = 385
-- The square of the sum of the first ten natural numbers is,
--     (1 + 2 + ... + 10)² = 55² = 3025
-- Hence the difference between the sum of the squares of the first
-- ten natural numbers and the square of the sum is 3025 385 = 2640.
--
-- Find the difference between the sum of the squares of the first one
-- hundred natural numbers and the square of the sum.
euler6 =
    let xs = take 100 naturalNumbers
    in (squareOfSum xs) - (sumOfSquares xs)


-- The natural numbers.  Purely for readability
naturalNumbers :: [Integer]
naturalNumbers = [1..]


-- The square of the sum of xs.
squareOfSum :: [Integer] -> Integer
squareOfSum xs = square (sum xs)


-- The sum of the squares of xs.
sumOfSquares :: [Integer] -> Integer
sumOfSquares xs = sum (map square xs)


-------------
-- Problem #7
-- Answer: 104743 (Confirmed)
-- NOTE: Current solution is too slow.
--
-- By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we
-- can see that the 6th prime is 13.
--
-- What is the 10001st prime number?
euler7 :: Integer
euler7 = nthPrime 10001


-- Find the nth prime.
nthPrime :: Int -> Integer
nthPrime n = primes !! n


-------------
-- Problem #8
-- Answer: 40824 (Confirmed)
--
-- Find the greatest product of five consecutive digits in the
-- 1000-digit number.
euler8 :: Int
euler8 = maximum (productsOfNConsecutiveDigits 5 euler8_input)


-- From the PE forum (adapted to use my equivalent functions)... very nice.
--
-- Cheats in that it also looks at products of strings less than 5
-- when it gets near the end of the list but that doesn't *really*
-- matter for this problem.
euler8Alt :: Int
euler8Alt = maximum . map (product . take 5) . tails $ stringDigits euler8_input

-- The definition of stringDigits does not immediately follow because
-- it was not originally created until much later, and this function
-- was refactored later to use it.


-- Map a String of digits to a list of the products of each successive
-- n digits from the String.
productsOfNConsecutiveDigits :: Int -> String -> [Int]
productsOfNConsecutiveDigits n s
                             | length s >= n = (product
                                  (getFirstNConsecutiveDigits n s)):
                                  (productsOfNConsecutiveDigits n (tail s))
                             | otherwise     = []


-- Take the first n digits from a String of digits.
getFirstNConsecutiveDigits :: Int -> String -> [Int]
getFirstNConsecutiveDigits n s = map digitToInt (take n s)


-------------
-- Problem #9
-- Answer: 31875000 (Confirmed)
--
-- A Pythagorean triplet is a set of three natural numbers, a b c, for
-- which,
--
--   a² + b² = c²
--
-- For example, 3² + 4² = 9 + 16 = 25 = 5².
--
-- There exists exactly one Pythagorean triplet for which a + b + c =
-- 1000.
-- Find the product abc.
euler9 :: Integer
euler9 =
    let target = 1000
        (a, b) = head ([(a,b) | a <- [1..target],
                                b <- [1..target],
                                a < b,
                                (square a) + (square b) == (square (target - a - b))])
        c = target - (a + b)
    in a * b * c


-------------
-- Problem #10
-- Answer: Unknown
--
-- The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.
--
-- Find the sum of all the primes below two million.
euler10 :: Integer
euler10 = sum (takeWhile (< 2000000) primes)


-------------
-- Problem #11
-- Answer: Unknown
--
-- In the 2020 grid below, four numbers along a diagonal line have
-- been marked in red.
--
-- [grid redacted, see module EulerInputs]
--
-- The product of these numbers is 26 * 63 * 78 * 14 = 1788696.
--
-- What is the greatest product of four adjacent numbers in any
-- direction (up, down, left, right, or diagonally) in the 20x20 grid?
euler11 :: Int
euler11 = maximum [e11MaxColProduct, e11MaxRowProduct] --, e11_max_diag_product]


-- Find the maximum of all the maximum products from all of the rows.
e11MaxRowProduct :: Int
e11MaxRowProduct = maximum e11RowMaxes


-- Find the maximum of all the maximum products from all of the columns.
e11MaxColProduct :: Int
e11MaxColProduct = maximum e11ColMaxes


-- Find the maximum of all of the maximum products from all of the diagonals.
e11_max_diag_product :: Int
e11_max_diag_product = maximum e11DiagMaxes


-- Find the maximum product of each 5 values for each row.
e11RowMaxes :: [Int]
e11RowMaxes = map maxProductsOfFiveAtATime euler11_rows


-- Find the maximum product of each 5 values for each column.
e11ColMaxes :: [Int]
e11ColMaxes = map maxProductsOfFiveAtATime euler11_cols


-- Find the maximum product of each 5 values for each diagonal.
e11DiagMaxes :: [Int]
e11DiagMaxes = map maxProductsOfFiveAtATime euler11_diagonals


-- Rows from the input
-- sort of cheating, but whatever...
euler11_rows :: [[Int]]
euler11_rows = euler11_input


-- The input organized as columns.
euler11_cols :: [[Int]]
euler11_cols = transpose euler11_rows


-- The input organized as diagonals.
euler11_diagonals :: [[Int]]
euler11_diagonals = [[0]] -- TODO: This


-- Find the largest product of 5 successive elements in xs.
maxProductsOfFiveAtATime :: [Int] -> Int
maxProductsOfFiveAtATime = maximum . productsOfFiveAtATime


-- Find the products of each group of 5 successive elements in xs.
productsOfFiveAtATime :: [Int] -> [Int]
productsOfFiveAtATime xs = map product (fiveAtATime xs)

nAtATime :: Int -> [Int] -> [[Int]]
nAtATime n xs = filter ((>= n) . length) (map (take n) (tails xs))

-- Return all of the unique sets of 5 successive elements from xs.
fiveAtATime :: [Int] -> [[Int]]
fiveAtATime = nAtATime 5


-------------
-- Problem #12
-- Answer: Unknown
--
-- The sequence of triangle numbers is generated by adding the natural
-- numbers. So the 7th triangle number would be 1 + 2 + 3 + 4 + 5 + 6
-- + 7 = 28. The first ten terms would be:
--
-- 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, ...
--
-- Let us list the factors of the first seven triangle numbers:
--
--  1: 1
--  3: 1,3
--  6: 1,2,3,6
-- 10: 1,2,5,10
-- 15: 1,3,5,15
-- 21: 1,3,7,21
-- 28: 1,2,4,7,14,28
--
-- We can see that 28 is the first triangle number to have over five divisors.
--
-- What is the value of the first triangle number to have over five hundred divisors?
euler12 :: Integer
euler12 = head [x | x <- triangleNumbers, ((numFactors x) > 500)]


numFactors :: Integer -> Int
numFactors n = (length (factors n))


-- An infinite sequence of triangle numbers.
triangleNumbers :: [Integer]
triangleNumbers = map triangleNumber [1..]


-- Calculate the nth triangle number.
triangleNumber :: Integer -> Integer
triangleNumber 1 = 1
triangleNumber n
               | n < 2     = n
               | otherwise = n + triangleNumber (pred n)


-------------
-- Problem #13
-- Answer: 5537376230 (Confirmed)
--
-- Work out the first ten digits of the sum of the following
-- one-hundred 50-digit numbers.
euler13 :: Int
euler13 = read (take 10 (show (sum euler13_input)))


-------------
-- Problem #14
-- Answer: Unknown
--
-- The following iterative sequence is defined for the set of positive
-- integers:
--
-- n -> n/2 (n is even)
-- n -> 3n + 1 (n is odd)
--
-- Using the rule above and starting with 13, we generate the
-- following sequence:
--
-- 13 ->  40 -> 20 -> 10 -> 5 -> 16 -> 8 -> 4 -> 2 -> 1
--
-- It can be seen that this sequence (starting at 13 and finishing at
-- 1) contains 10 terms. Although it has not been proved yet (Collatz
-- Problem), it is thought that all starting numbers finish at 1.
--
-- Which starting number, under one million, produces the longest
-- chain?
--
-- NOTE: Once the chain starts the terms are allowed to go above one
-- million.
euler14 :: Int
euler14 = euler14' 3 0 0

euler14' :: Int -> Int -> Int -> Int
euler14' n res len =
    if n > 999999
    then
        res
    else
        let newLen = collatzLength (fromIntegral n)
        in
          if newLen > len
          then
              euler14' (succ n) n newLen
          else
              euler14' (succ n) res len


-- Find the length of the (terminating) collatz sequence starting with n.
collatzLength :: Integer -> Int
collatzLength n = length (terminatingCollatzSequence n)


-- Generate the (terminating) collatz sequence starting with n.
terminatingCollatzSequence :: Integer -> [Integer]
terminatingCollatzSequence n = (takeWhile (/= 1) (collatzSequence n)) ++ [1]


-- Generate the (infinite) collatz sequence starting with n.
collatzSequence :: Integer -> [Integer]
collatzSequence n = n:map collatz (collatzSequence n)


-- Generate the next collatz number given the current number n.
collatz n
        | even n    = div n 2
        | otherwise = ((3 * n) + 1)


-----------
-- Problem #15
-- Answer: 137846528820
--
--  Starting in the top left corner of a 22 grid, there are 6 routes
-- (without backtracking) to the bottom right corner.
--
-- [diagram]
--
-- How many routes are there through a 20 x 20 grid?

e15values = array ((0, 0), (20, 20)) [((x, y), e15 x y) | x <- [0..20],
                                                          y <- [0..20]]
    where
      e15 0 0 = 1
      e15 x 0 = 1
      e15 0 y = 1
      e15 x y = (e15values!((pred x), y)) + (e15values!(x, (pred y)))

euler15 = e15values!(20, 20)

-------------
-- Problem #16
-- Answer: 1366
--
-- 2^15 = 32768 and the sum of its digits is 3 + 2 + 7 + 6 + 8 = 26.
--
-- What is the sum of the digits of the number 2^1000?
euler16 :: Int
euler16 = sumOfDigits (2 ^ 1000)


-- Find the sum of the digits in a number.
-- Refactored out commonality from #16 and #20.
sumOfDigits :: Integer -> Int
sumOfDigits n = sum (integerDigits n)


-- Generate a list of the individual digits of a number.
integerDigits :: Integer -> [Int]
integerDigits = stringDigits . show


-- Generate a list of the individual digits in a String (of digits
-- obviously).  Can we enforce that the String is a String of digits
-- with Haskell's type system?
stringDigits :: String -> [Int]
stringDigits = map digitToInt


----
-- Problem #17
--
-- If the numbers 1 to 5 are written out in words: one, two, three,
-- four, five, then there are 3 + 3 + 5 + 4 + 4 = 19 letters used in
-- total.
--
-- If all the numbers from 1 to 1000 (one thousand) inclusive were
-- written out in words, how many letters would be used?
--
-- NOTE: Do not count spaces or hyphens. For example, 342 (three
-- hundred and forty-two) contains 23 letters and 115 (one hundred and
-- fifteen) contains 20 letters. The use of "and" when writing out
-- numbers is in compliance with British usage.



euler17 :: Int
euler17 = letters_in_numbers [1..1000]


letters_in_numbers :: [Int] -> Int
letters_in_numbers xs = sum $ map (length . alpha_only . num_in_words) xs
    where
      alpha_only = filter isAlpha


num_in_words n = w n
    where
      lows = ["", "one", "two", "three", "four", "five", "six", "seven",
              "eight", "nine", "ten", "eleven", "twelve", "thirteen",
              "fourteen", "fifteen", "sixteen", "seventeen", "eighteen",
              "nineteen"]
      tens = ["twenty", "thirty", "forty", "fifty", "sixty", "seventy",
                          "eighty", "ninety"]
      w 1000 = "one thousand"
      w n | n <= 19 = lows !! n
      w n | n > 19 && n <= 99 = (tens !! ((div n 10) - 2)) ++
                                if not (r == 0) then
                                    " " ++ (lows !! r)
                                else
                                    ""
                                        where r = rem n 10
      w n = (lows !! (div n 100)) ++ " hundred" ++
            if not (r == 0) then
                " and " ++ (w r)
            else
                ""
                    where r = rem n 100

-------------
-- Problem #20
-- Answer: 648 (Confirmed)
--
-- n! means n  (n x 1) x ...  3 x 2 x 1
--
-- Find the sum of the digits in the number 100!
euler20 :: Int
euler20 = sumOfDigits (fac 100)

fac :: Integer -> Integer
fac 0 = 1
fac 1 = 1
fac n = n * fac (pred n)


-------------
-- Problem #21
-- Answer: 31626 (Confirmed)
-- NOTE: This solution is too slow.
--
-- Let d(n) be defined as the sum of proper divisors of n (numbers
-- less than n which divide evenly into n).
--
-- If d(a) = b and d(b) = a, where a =/= b, then a and b are an
-- amicable pair and each of a and b are called amicable numbers.
--
-- For example, the proper divisors of 220 are 1, 2, 4, 5, 10, 11, 20,
-- 22, 44, 55 and 110; therefore d(220) = 284. The proper divisors of
-- 284 are 1, 2, 4, 71 and 142; so d(284) = 220.
--
-- Evaluate the sum of all the amicable numbers under 10000.
euler21 :: Integer
euler21 = sum (filter amicable [1..9999])


-- Determine if n is an amicable number.
amicable :: Integer -> Bool
amicable n =
    let d n = sum (tail (factors n))
    in n == d(d(n)) && d(n) /= n


-------------
-- Problem #25
-- Answer: 4782 (Confirmed)
--
-- What is the first term in the Fibonacci sequence to contain 1000 digits?
euler25 = succ
          (length
           (takeWhile
            (< 1000)
            (map (length . show) fibs)))


-------------
-- Problem #29
-- Answer: 9183 (Confirmed)
--
-- Consider all integer combinations of a^b for 2 <= a <= 5 and 2 <= b
-- <= 5:
--
-- 2^2=4, 2^3=8, 2^4=16, 2^5=32
-- 3^2=9, 3^3=27, 3^4=81, 3^5=243
-- 4^2=16, 4^3=64, 4^4=256, 4^5=1024
-- 5^2=25, 5^3=125, 5^4=625, 5^5=3125
--
-- If they are then placed in numerical order, with any repeats
-- removed, we get the following sequence of 15 distinct terms:
--
-- 4, 8, 9, 16, 25, 27, 32, 64, 81, 125, 243, 256, 625, 1024, 3125
--
-- How many distinct terms are in the sequence generated by ab for 2
-- <= a <= 100 and 2 <= b <= 100?
euler29 :: Int
euler29 = length (euler29Numbers 2 100)


euler29Numbers :: Int -> Int -> [Integer]
euler29Numbers low high = nub [intPow a b | a <- [low..high], b <- [low..high]]


intPow :: Int -> Int -> Integer
intPow a b = (fromIntegral a) ^ b


-------------
-- Problem #30
-- Answer: 443839
--
-- Surprisingly there are only three numbers that can be written as
-- the sum of fourth powers of their digits:
--
-- 1634 = 1^4 + 6^4 + 3^4 + 4^4
-- 8208 = 8^4 + 2^4 + 0^4 + 8^4
-- 9474 = 9^4 + 4^4 + 7^4 + 4^4
-- As 1 = 1^4 is not a sum it is not included.
--
-- The sum of these numbers is 1634 + 8208 + 9474 = 19316.
--
-- Find the sum of all the numbers that can be written as the sum of
-- fifth powers of their digits.
--
-- I found "6" by trying take 1, take 2, etc until it seemed to be
-- taking too long and then just tried the sum and it worked on the
-- site... need a more mathy approach in general.
euler30 = sum(take 6 e30Numbers)


-- An infinite list of the numbers that qualify for inclusion in the
-- e30 problem.
e30Numbers = [x | x <- naturalNumbers, isSumOfNthPowerOfDigits x 5]


-- Tests whether n qualifies for this problem.
isSumOfNthPowerOfDigits n p = n > 1 && (sumOfPthPower n p) == n


-- Find the sum of the pth power of each digit in n.
sumOfPthPower :: Integer -> Int -> Integer
sumOfPthPower n p = sum (map (`intPow` p) (integerDigits n))




-- -------------- TODO: Finish cleaning up from here down -------------------- --

----
-- Problem #53
-- Answer: Unknown
--
-- There are exactly ten ways of selecting three from five, 12345:
--
-- 123, 124, 125, 134, 135, 145, 234, 235, 245, and 345
--
-- In combinatorics, we use the notation, 5C3 = 10.
--
-- In general,
--
-- nCr =
--    n!
-- --------
-- r!(n-r)!
-- ,where r <= n, n! = n * (n - 1)...3 * 2 * 1, and 0! = 1.
--
-- It is not until n = 23, that a value exceeds one-million: 23C10 =
-- 1144066.
--
-- How many, not necessarily distinct, values of nCr, for 1 <= n <=
-- 100, are greater than one-million?
-- euler53 =
--     length (filter (> 1000000) valuesOfNCR)
--         where
--           valuesOfNCR =

--     let range = [1..100]
--     in map something range
--         where



-- nextCombos n r =
--     if r > n
--     then nextCombos (succ n) 1
--     else combinationsOf r [1..n]


-- combinationsOf 0 _ = [[]]
-- combinationsOf _ [] = []
-- combinationsOf k (x:xs) = map (x:) (combinationsOf (k-1) xs) ++ combinationsOf k xs


-- Test n for primality.
prime :: Integer -> Bool
prime n = length (take 3 (factors n)) == 2


-- Determine if m is a factor of n.
factor :: Integer -> Integer -> Bool
factor n m = mod n m == 0


-- Return all the factors of a number
--
-- We have to do the nub because in the case of perfect squares we get
-- the factor in both the low and high halves (e.g. 3 x 3 = 9).
-- There's probably a cleaner way to do this, but it'll do for now.
factors :: Integer -> [Integer]
factors n =
    let low_factors = takeWhile (<= maxLowFactor n) . filter (factor n) $ [1..]
        high_factors = map (div n) low_factors
    in nub (low_factors ++ high_factors)


-- euler #34
--
-- 145 is a curious number, as 1! + 4! + 5! = 1 + 24 + 120 = 145.
--
-- Find the sum of all numbers which are equal to the sum of the
-- factorial of their digits.
--
-- Note: as 1! = 1 and 2! = 2 are not sums they are not included.
--

isE34Number n = sum (map (fac . fromIntegral) (integerDigits n)) == n

e34Numbers = filter isE34Number [3..]

-- arrived at "take 2" by doing "take 5" and observing that it took
-- forever after 2... so kind of cheating... but oh well.
-- "40730"
euler34 = sum (take 2 e34Numbers)


-- euler #35
--
-- The number, 197, is called a circular prime because all rotations
-- of the digits: 197, 971, and 719, are themselves prime.
--
-- There are thirteen such primes below 100: 2, 3, 5, 7, 11, 13, 17,
-- 31, 37, 71, 73, 79, and 97.
--
-- How many circular primes are there below one million?

nextRotation s = tail s ++ [head s]

rotations :: Integer -> [Integer]
rotations n =
    let s = (show n)
    in map read (take (length s) (iterate nextRotation s))

isCircularPrime = (all prime) . rotations

-- too slow or some other problem keeps it from finishing even over an
-- hour+ I think I basically just need a faster prime generator.  Need
-- to look into seives, etc.
euler35 = length (filter isCircularPrime (takeWhile (< 1000000) primes))


-- euler #36
--
-- The decimal number, 585 = 1001001001v2 (binary), is palindromic in
-- both bases.
--
-- Find the sum of all numbers, less than one million, which are
-- palindromic in base 10 and base 2.
--
-- (Please note that the palindromic number, in either base, may not
-- include leading zeros.)

toBinaryString :: Integer -> String
toBinaryString n = toBinaryString' n ""
    where
      toBinaryString' :: Integer -> String -> String
      toBinaryString' n acc =
          if n == 0
          then acc
          else
              let (t, r) = divMod n 2
              in
                let rc = (fromIntegral r)
                in toBinaryString' t ((intToDigit rc):acc)


is_palindromic_in_binary :: Integer -> Bool
is_palindromic_in_binary n = palindromicNumber (read (toBinaryString n))

-- 872187
euler36 :: Integer
euler36 = sum [n | n <- [1..999999], palindromicNumber n, is_palindromic_in_binary n]


-- euler #40
--
-- An irrational decimal fraction is created by concatenating the
-- positive integers:
--
--              v-- 12th digit
-- 0.123456789101112131415161718192021...
--
-- It can be seen that the 12th digit of the fractional part is 1.
--
-- If dvn represents the nth digit of the fractional part, find the
-- value of the following expression.
--
-- dv1 * dv10 * dv100 * dv1000 * dv10000 * dv100000 * dv1000000

-- My original brute-force approach (old and busted):
-- e40_frac_part_string :: Int -> String
-- e40_frac_part_string n = e40_frac_part_string' "" 1 n

-- e40_frac_part_string' :: String -> Int -> Int -> String
-- e40_frac_part_string' acc_s acc_n len =
--     if (length acc_s) > len
--     then acc_s
--     else e40_frac_part_string' (acc_s ++ show acc_n) (succ acc_n) len

-- e40_full_str = e40_frac_part_string 1000000

-- euler40 :: Integer
-- euler40 = (fromIntegral . product)
--           (map
--            (digitToInt . (e40_full_str !!))
--            [1,10,100,1000,10000,100000,1000000])

-- new hotness:  (also busted... sigh)

-- there are 9 single digits numbers, 1 is less than 9, so it's just
-- the index into those: (yes, obviously it's also just 1 from the
-- definition and/or the definition of the problem, but I'm just
-- trying to be consistent...)
-- e40_single_digit_numbers = [1..9]
-- e40_1 = e40_single_digit_numbers !! (pred 1)
-- e40_single_digit_numbers_total_length = (length e40_single_digit_numbers) -- * 1 .. don't actually need to do it


-- there are 99 two digit numbers, so, we can remove the
-- e40_two_digit_numbers = [10..99]
-- e40_10 = e40_two_digit_numbers !! (pred (99 - e40_single_digit_numbers_total_length))


-- 0.123456789101112131415161718192021...
-- 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
-- 1 2 3 4 5 6 7 8 9  1  0  1  1  1  2  1  3  1  4  1  5  1  6
-- n..
-- n mod 10 to get the number of digits grouped together that we need to skip

-- euler #48
--
-- The series, 1^1 + 2^2 + 3^3 + ... + 10^10 = 10405071317.
--
-- Find the last ten digits of the series, 1^1 + 2^2 + 3^3 + ... + 1000^1000.

self_pow n = n ^ n
e48_series = map self_pow [1..]
e48_sum = sum (take 1000 e48_series)
-- "9110846700"
euler48 = reverse (take 10 (reverse (show e48_sum)))

-- euler #52
--
-- It can be seen that the number, 125874, and its double, 251748,
-- contain exactly the same digits, but in a different order.
--
-- Find the smallest positive integer, x, such that 2x, 3x, 4x, 5x,
-- and 6x, contain the same digits.

have_same_digits :: Integer -> Integer -> Bool
have_same_digits a b = sort (integerDigits a) == sort (integerDigits b)

is_e52_num :: Integer -> Bool
is_e52_num n = all (have_same_digits n) (map (*n) [2..6])

-- 142857
euler52 :: Integer
euler52 = head (filter is_e52_num naturalNumbers)
