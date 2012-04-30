nthPrime = (!!) primes

primes = 2 : (filter isPrime [3, 5..])
  where
  isPrime n = all (not . divides n) (takeWhile (\p -> p*p <= n) primes)
  divides n p = (mod n p) == 0