First an apology. When looking back at the source files for part one of
this series, I noted with horror that is has been two years since I
wrote that first installment. Evidently, my assertion that part two
would follow "in next quarter's OSJ" was somewhat optimistic.

Further, it would appear I was even more optimistic with the scope of
the second installment. The promise to cover both types and monads
in a single short article seems rather ridiculous in hindsight!

However, the second part is now here and we'll be looking at lots of
interesting topics including lazy evaluation, infinite lists, types and
polymorphism.

Discussion of monads will have to wait for part three, but the extra
space afforded by a third installment will allow for a much more
thorough treatment.

For those of you who haven't read the first part of this series, you can
find the article source on GitHub at:
https://github.com/robharrop/osj-code/blob/master/april-2010/article.md.

## Lazy Evalution

Let us start with lazy evaluation. The most popular programming
languages are eagerly-evaluated languages. Languages such as C, Java, C#
and Objective-C are all eagerly-evaluated.

In fact, of the top ten languages listed in the TIOBE Programming
Community Index, only Python can claim to have some semblance of support
for lazy evaluation (through its notion of generators).

The semantics of eagerly-evaluated languages are probably second nature
to most of the people reading this article. It is worth then, taking a
detailed look at exactly how evaluation in a language like Java works so
we can this evaluation model at the front of our minds.

Consider this snippet of Java code:

    public class LazyEvaluation {

        public static void main(String[] args) {
            LazyEvaluation eval = new LazyEvaluation();
            System.out.printf("%s\n", eval.fancy_if(true, 1 + 2, 3 + 4 ));
        }

        public <T> T fancy_if(boolean condition, T trueCase, T falseCase) {
            return condition ? trueCase : falseCase;
        }
    }

The `LazyEvaluation` class attempts to define a custom control structure
`fancy_if`, mimicking the standard Java `if` construct. When passing
`true` to `fancy_if` the value of the `trueCase` argument is returned,
otherwise the value of the `falseCase` argument is returned.

All looks good with this, except, there is a flaw: the expressions `1 +
2` and `3 + 4` that are passed to the `fancy_if` method as the
`trueCase` and `falseCase` arguments are always evaluated in full. With
a normal `if` statement, only the case matching the boolean condition is
evaluated.

The difference between `fancy_if` and `if` is essentially unimportant
when considering expressions that are just simple arithmetic, but
consider the case when those expressions are more complicated, perhaps
some expensive computation:

    boolean condition = calculateCondition();
    return fancy_if(condition, nthPrime(1000000), nthPrime(2000000));

Here, we're returning either the 1,000,000th or 2,000,000th prime
depending on the outcome of `calculateCondition`. Of course, while we
might only be _returning_ one of these calculated primes, we are in fact
calculating both.

Java, like all eager languages, will evaluate expressions as soon as
they are bound to a variable - in this case evaluating both of the
expressions for the `trueCase` and `falseCase` arguments.

Now, let's consider this in Haskell:

    fancy_if True x _ = x
    fancy_if False _ y = y

This code defines a function, `fancy_if` that takes three arguments
matching those of the `fancy_if` method from the Java example.

If we load this into `ghci` we can easily test it:

    Prelude> :load lazy_if.hs
    *Main> fancy_if True (1 + 2) (3 + 4)
    3
    *Main> fancy_if False (1 + 2) (3 + 4)
    7

Thus far, the Haskell `fancy_if` function appears to operate just like
the Java example. Let's change our example now so that the `False` case
is expensive to compute, but the `True` case is just a constant:

    *Main> fancy_if True 1 (nthPrime 40000)
    1

This will return `1` immediately, the expression `(nthPrime 40000)` is
not evaluated, because there is no dependent expression to be
evaluated.

If we look back at the definition of the `fancy_if` function:

    fancy_if True x _ = x
    fancy_if False _ y = y

We see here that, in the `True` clause, the `nthPrime` expression is not
bound to a variable at all, hence it cannot be evaluated. It is worth
noting that, even if the third argument of the `True` branch was  named,
perhaps like this `fancy_if True x y = x`, since the `y` argument is
never evaluated, the expression bound to it will not be evaluated.

If we return to `ghci` and change the boolean to `False`, we'll see a
different story.


    *Main> fancy_if False 1 (nthPrime 40000)
    479939

There is a noticeable pause now before the result `479939` is
returned. Looking at the definition of the `False` branch of the
`fancy_if` function:

    fancy_if False _ y = y

Now we see that the `(nthPrime 40000)` expression is bound to the `y`
variable and that variable is used as the return expression for the
function clause. This means that Haskell will evaluate `y` and then in
turn evaluate `(nthPrime 40000)`.

Lazy evalution is a critical part of the Haskell experience. With lazy
evalution we are freed from having to worry about the details of when
particular expressions are evaluated, relying on the runtime to evaluate
in a just-in-time fashion.

This freedom allows us to focus on describing our solutions in the most
elegant and comprehendable fashion - we need not make too many
concessions to the performance gods.

A further benefit of lazy evaluation is that it opens up a new set of
data structures that are not available in eager languages: infinite data
structures.

## Infinite Data Structures

Infinite data structures are data structures that abstract the details
of some infinite stream of data. Take for example, the set of all prime
numbers. In Haskell, it is nice to work with such sets of data using the
list primitive, and thanks to Haskell's support for recursion and lazy
evaluation, we can define an infinite list and we can work with just the
portions that we need.

One of the nicest things about Haskell code is that you can build up
your functions in small chunks. It should be noted that there are
numerous ways to calculate the list of prime numbers, the approach given
here is not recommended if you are looking for efficency, but it is very
easy to understand.

We start by defining a list containing the first three primes:

    primes = [2, 3, 5]

In `ghci` we can test this:

    *Main> primes
    [2, 3, 5]

    *Main> primes !! 1
    3

Other, than `2`, all primes are odd numbers. We can tweak our list to
contain `2` and all the odd numbers greater than `2` - this is our first
infinite list but it is, of course, not actually a list of primes.

    primes = 2 : [3, 5..]

In `ghci` we can test this too:

    *Main> primes !! 1
    3
    *Main> primes !! 2
    5
    *Main> primes !! 3
    7

Try evaluating `primes` in `ghci`. As you might expect. this evaluation
will not terminate normally, and will just keep on listing odd numbers
until you stop it with `Ctrl-C`.

Any expression we write involving `primes` that requires evaluating the
entire list will never terminate. For example, calling `length` or
`reverse` for `primes` will just hang until you interrupt execution.

Now, we want to filter out the odd numbers that aren't primes so let's
tweak our list definition and add in a filter, the details of which we
can fill in next:

    primes = 2 : (filter isPrime [3, 5..])
      where
      isPrime n = True

In this small step we just introduced the dummy filter, using the
built-in `filter` function which takes a predicate and a list and
returns a new list containing only the elements for which the predicate
evaluates to `True`. Notice that the `filter` function is quite happy
working with the infinite list of odd numbers that we give it.

Now let's fill that filter in. We simply going to filter out any number
that has a divisor other than one and itself:

    primes = 2 : (filter isPrime [3, 5..])
      where
      isPrime n = all (not . divides n) [2 .. (n-1)]
      divides n p = (mod n p) == 0

Here we say that a number `n` is prime if it is not divisible by any
number between `2` and `n - 1`. The `all` function takes a predicate and
a list and will return `True` if the predicate evaluates to true for all
items in the list, otherwise it returns `False`.

We can test this in `ghci` by listing the first ten primes:

    *Main> take 10 primes
    [2,3,5,7,11,13,17,19,23,29]

We can improve this further by remembering that, to check for the
primality of a number `n` by trial division we only need to check that
numbers up to `sqrt(n)`. So rather than check all numbers up to `n - 1`
let's check all numbers `p` where `p * p <= n`:

    primes = 2 : (filter isPrime [3, 5..])
      where
      isPrime n = all (not . divides n) (takeWhile (\p -> p*p <= n) [2..])
      divides n p = (mod n p) == 0

Again, we can test this in `ghci` by listing the first ten primes:

    *Main> take 10 primes
    [2,3,5,7,11,13,17,19,23,29]

Now, for one last trick to make this a bit faster and to see some of the
true power of Haskell. We can further improve the trial division by
remembering that we need only check for divisors that are themselves
primes. This is trivial to do by making `primes` refer back to itself in
the `isPrime` check rather than using the list `[2..]`:

    primes = 2 : (filter isPrime [3, 5..])
      where
      isPrime n = all (not . divides n) (takeWhile (\p -> p*p <= n) primes)
      divides n p = (mod n p) == 0

For a good solid check, let's list the first 100 primes in `ghci`:

    *Main> take 100 primes
    [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,
    79,83,89,97,101,103,107,109,113,127,131,137,139,149,151,157,
    163,167,173,179,181,191,193,197,199,211,223,227,229,233,239,
    241,251,257,263,269,271,277,281,283,293,307,311,313,317,331,
    337,347,349,353,359,367,373,379,383,389,397,401,409,419,421,
    431,433,439,443,449,457,461,463,467,479,487,491,499,503,509,
    521,523,541]

For completeness, we can now define the `nthPrime` function used earlier
on top of our `primes` list:

    nthPrime = (!!) primes

The `!!` function is the list index function taking the list to index as
its first argument and index itself as the second argument. The
`nthPrime` function is simply a partial application of `!!` with
`primes` as the first argument.

## Types

So far in this series, I've hardly mentioned the notion of types, which
is strange since the sophisticated type system is such a large part of
the Haskell experience.

One feature of the type system: type inference, means that we can do
meaningful work without having to worry about the details of
typing. Indeed, in the previous section, we defined a lazily-evaluated,
infinite list of primes without a type in sight.

Whilst much can be achieved without worrying about types, a thorough
understanding of the features available in the Haskell type system opens
up a wealth of options for creating elegant abstractions in your
programs.

Let's start by looking at the basic types and some basic type inference.

In `ghci` we can see the type of an expression using the `:t` command:

    *Main> :t True
    True :: Bool
    *Main> :t "Hello World"
    "Hello World" :: [Char]

Here, we can run the command `:t True` to find out that `True` has the
type `Bool`. Running `:t "Hello World:"` tells us that `"Hello World"`
has the type `[Char]`, that is a list of elements of type `Char`.

You can also discover the type signature of a function using `:t`:

    *Main> :t nthPrime
    nthPrime :: Int -> Integer

This tells us that `nthPrime` takes an `Int` as its argument and returns
a value of type `Integer`. An `Int` is a fixed-size integer with the
size being platform-dependent. An `Integer` is an arbitrary precision
integer, with size limited only by the memory you have.

You may now be wondering where `nthPrime` got its type from, and this is
where type inference comes into play. In most cases, Haskell is able to
infer the types for your values and functions based on existing
knowledge. To see this in action, let's revisit the definition of `nthPrime`

    nthPrime = (!!) primes

Here we're applying the `!!` function to the `primes` value. Let's find
out the types of `!!` and `primes`:

    *Main> :t primes
    primes :: [Integer]

So `primes` is a list of `Integer` values.

    *Main> :t (!!)
    (!!) :: [a] -> Int -> a

This signature introduces a new concept: _type variables_. In a type
signature, lowercase letters are used to denote type variables, in the
example above we see `a` being used as such a type variable.

Functions with type variables in the signature are _polymorphic
functions_. Such functions allow various arguments to take on arbitrary
types. Further, polymorphic functions allow the types of arguments and
return values to be related together.

The signature for `!!` tells us that it accepts as its first argument a
list containing values of any type, and binds this type to the type
variable `a`. The second argument is a value of type `Int`. The
return value is a value of the type bound to the type variable `a`.

So, when we evaluate the expression `(!!) primes`, we're calling `!!`
passing `primes` as the first argument. The type of `primes` is
`[Integer]` so this causes the type variable `a` defined in `!!` to be
bound to the type `Integer`. Thusly, `(!!) primes` returns a function
that accepts an `Int` as its argument (from the definition of `!!`) and
returns an `Integer` (from the type variable `a` bound to the value of
the list elements of `prime`).

The type inference engine is very smart, and will fit type variables in
where it can, making our functions as generic as possible without
requiring extra effort.

As an example, consider this basic implementation of a function to
reverse lists:

    rev [] = []
    rev (x:xs) = rev(xs) ++ [x]

Obviously, the type of values in the list is unimportant, so we expect
to be able to use this function against any list. A quick check in
`ghci` will show that Haskell has obliged by giving us a suitably
generic type signature:

    *Main> :t rev
    rev :: [a] -> [a]

If we _wanted_ to constrain the type of `rev` we can do so by specifying
our own type signature:

    rev :: [Integer] -> [Integer]
    rev [] = []
    rev (x:xs) = rev(xs) ++ [x]

Notice the first line of this example defines the type signature. The
format of signature is identical to the format used by `ghci`.

It is quite unusual to use type signatures to constrain a function like
`rev`. Typically, explicit type signatures are used when the type
inference engine doesn't have enough information to work from.

Type signatures are also excellent tools for documentation and for
development. We building Haskell software, I like to sketch out my
functions using signatures and I like to leave these signatures in as
documentation.

For example, we can add a type signature to `rev` that doesn't constrain
it, but rather just defines and documents it:

    rev :: [a] -> [a]
    rev [] = []
    rev (x:xs) = rev(xs) ++ [x]

## Creating new types

We've seen how to interact with the built-in types provided by the
Haskell runtime. Along with this, we've seen how some of the basic
polymorphism and inference features work.

Now, let's explore the type system some more and start introducing our
own types.

### Type Synonyms

The easiest way to define a type is with a _type synonym_.

    type FirstName = String
    type LastName = String
    type Name = (FirstName, LastName)

Here we define three type synonyms: `FirstName`, `LastName` and
`Name`. We can inspect these types in `ghci` using the `:info` command:

    *Main> :info FirstName
    type FirstName = String         -- Defined at types.hs:1:6-14
    *Main> :info LastName
    type LastName = String  -- Defined at types.hs:2:6-13
    *Main> :info Name
    type Name = (FirstName, LastName)       -- Defined at types.hs:3:6-9

The `:info` command allows us to dereference the type alias to type it
was defined against. Type synonyms _do not_ introduce new types, they
are just aliases. The main use for synonyms is to group types together
into a frequently used structure, such as with the `Name` type.

One interesting point to note here is that `String` is actually a type
synonym itself:

    *Main> :info String
    type String = [Char]    -- Defined in GHC.Base

As you can see, strings are just lists of chars in Haskell.

### Type Renaming and Safety

Whilst type aliasing is a nice feature, it doesn't help to constrain the
type space in any way - it is mostly a convenience feature.

Another way of introducing types, is to introduce a renaming of an
existing type. The new type is distinct from the type it was renamed
from and the two cannot be used interchangeably.

Let's see a simple example first and then look at a use case where this
is especially useful.

    newtype FileName = FileName String

This defines a new type `FileName` that wraps `String`. The `FirstName =
String` expression after the `=` creates a constructor function that
takes a `String` and returns a `FileName`. Let's explore the type and
the constructor in `ghci`:

    *Main> :t FileName
    FileName :: String -> FileName
    *Main> :info FileName
    newtype FileName = FileName String      -- Defined at types.hs:5:9-16

To create an instance of `FileName` we simply call the constructor:

    FileName "/Users/robharrop/article.md"

To see where `newtype` might be useful, let's try another example. In
this example, we're going to build a simple library that allows client
programs to securely execute arbitrary SQL queries.

For the sake of brevity, we'll simulate the actual execution and
security pieces, but we'll explore in detail how the type system
prevents the library from being misused.

We'll define a module `Sql` to hold our `Query` type and associated
functions:

    module Sql (Query, parse, execute) where

    newtype Query = Query String

This defines the module `Sql` and exports the type `Query` and the
functions `parse` and `execute`. Clients of this module can only access
exported types and functions. We also define the type `Query` as a
renaming of `String`. Note that the type constructor for `Query` is
_not_ exported.

Next we define the `parse` function:

    parse :: String -> Query
    parse = Query . escape

This function takes a `String` and returns a `Query`. Since the `Query`
type constructor is not exported, this is the only way client code can
create a `Query`. Note that before passing the client-supplied `String`
to the `Query`, we first escape it using the `escape` function.

For demo purposes we'll define `escape` and `id`. In the real world this
would actually do all the fancy escaping rules.

    escape = id

Finally, we'll define the `execute` function:

    execute (Query rawSql) = putStrLn rawSql

For demo purposes, we'll just print the raw SQL query to the
console. Notice that we are able to use the pattern `(Query rawSql)` to
match a `Query` argument and extract the wrapped `String` into the
`rawSql` variable.

Now let's explore this code in `ghci`. Start by loading the `Sql` module
(you'll need to store it in a file called `Sql.hs`).

    Prelude> :load Sql
    [1 of 1] Compiling Sql              ( Sql.hs, interpreted )
    Ok, modules loaded: Sql.
    *Sql>

Once the `Sql` module is loaded, notice that the prompt changes to
`*Sql>`. This is telling us that we are currently in the scope of the
`Sql` module. In this scope, we're able to access all parts of the
module, not just those that we exported.

Being in the scope of the `Sql` module is useful for exploring, but it
doesn't help us to simulate what client code would see. Let's switch
back into the `Prelude` scope and just add `Sql` into the list of
accessible modules:

    *Sql> :m Prelude
    Prelude> :m +Sql
    Prelude Sql>

The `:m Prelude` commands puts us back in the scope of the `Prelude`
module and the `:m +Sql` command makes the `Sql` module visible in the
scope.

Now let's explore what is and isn't visible to us:

    Prelude Sql> :info Sql.Query
    data Query      -- Defined at Sql.hs:3:9-13

    Prelude Sql> :t Sql.parse
    Sql.parse :: String -> Query

    Prelude Sql> :t Sql.execute
    Sql.execute :: Query -> IO ()

    Prelude Sql> :t Sql.Query

    <interactive>:1:1: Not in scope: data constructor `Sql.Query'

We can see the `Sql.Query` type and the `Sql.parse` and `Sql.execute`
functions, but the `Sql.Query` type constructor is hidden from us. This
means that a client can only obtain a `Query` using the `parse`
function.

Let's explore the usage of this library. We can create a `Query` using `parse`:

    Prelude Sql> let theQuery = Sql.parse "SELECT * FROM accounts"

This `Query` can be executed using `execute`:
    Prelude Sql> Sql.execute theQuery
    SELECT * FROM accounts

We cannot create a `Query` to execute without using `parse`:

    Prelude Sql> Sql.execute (Query "DROP TABLE accounts")

    <interactive>:1:14: Not in scope: data constructor `Query'

Nor can we execute a plain `String`:

    Prelude Sql> Sql.execute "DROP TABLE accounts"

    <interactive>:1:13:
        Couldn't match expected type `Query' with actual type `[Char]'
            In the first argument of `execute', namely `"DROP TABLE accounts"'
                In the expression: execute "DROP TABLE accounts"
                    In an equation for `it': it = execute "DROP TABLE accounts"

The `newtype` construct is just one of the ways in which correctness can
be encapsulated in the types of our programs. In the next section, we'll
look at how to define types with more interesting shapes using the
`data` construct.

## Complex Types


## Type Classes
