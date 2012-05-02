First an apology. When looking back at the source files for part one of
this series, I noted with horror that is has been two years since I
wrote that first installment. Evidently, my assertion that part two
would follow "in next quarter's OSJ" was somewhat optimistic.

Further, it would appear I was even more optimistic with the scope of
the second installment. The promise to cover both types and monads
in a single short article seems rather ridiculous in hindsight!

However, the second part is here and we'll be looking at lots of
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
we can have this evaluation model at the front of our minds.

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
noting that, even if the third argument of the `True` branch was named,
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

Lazy evalution is a critical part of the Haskell experience. Lazy
evalution frees us from having to worry about the details of when
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
evaluation, we can define the list of primes as an infinite list that
can, for the most part, be treated like a normal list.

It should be noted that there are numerous ways to calculate the list of
prime numbers, the approach given here is not recommended if you are
looking for efficency, but it is very easy to understand.

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

In `ghci` we can test this:

    *Main> primes !! 1
    3
    *Main> primes !! 2
    5
    *Main> primes !! 3
    7

Try evaluating `primes` in `ghci`. This evaluation will not terminate
normally, and will just keep on listing odd numbers until interrupted
with `Ctrl-C`.

Any expression we write involving `primes` that requires evaluating the
entire list will never terminate. For example, calling `length` or
`reverse` for `primes` will just hang until execution is interrupted.

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
a list and will return `True` if the predicate evaluates to `True` for
all items in the list, otherwise it returns `False`.

We can test this in `ghci` by listing the first ten primes:

    *Main> take 10 primes
    [2,3,5,7,11,13,17,19,23,29]

We can improve this further by remembering that, to check for the
primality of a number `n` by trial division, we only need to check
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

For completeness, we can now define the `nthPrime` function we used
earlier, using our `primes` list:

    nthPrime = (!!) primes

The `!!` function is the list index function taking the list to index as
its first argument and the index itself as the second argument. The
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
up a wealth of options for creating elegant abstractions in our
programs.

Let's start by looking at the basic types and some basic type inference.

In `ghci` we can see the type of an expression using the `:t` command:

    *Main> :t True
    True :: Bool
    *Main> :t "Hello World"
    "Hello World" :: [Char]

Here, we run the command `:t True` to find out that `True` has the type
`Bool`. Running `:t "Hello World:"` tells us that `"Hello World"` has
the type `[Char]`, that is a list of elements of type `Char`.

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
functions_. Such functions allow arguments to take on arbitrary
types. Further, polymorphic functions allow the types of arguments and
return values to be linked together.

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
inference engine doesn't have enough information to work from, or when
you specify your types to ensure correctness.

Type signatures are also excellent tools for documentation and for
development. When building Haskell software, I like to sketch out my
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

Now, let's explore the type system in some more detail and start
introducing our own types.

### Type Synonyms

The easiest way to define a type is with a _type synonym_.

    type FirstName = String
    type LastName = String
    type Name = (FirstName, LastName)

Here we define three synonyms: `FirstName`, `LastName` and `Name`. We
can inspect these types in `ghci` using the `:info` command:

    *Main> :info FirstName
    type FirstName = String         -- Defined at types.hs:1:6-14
    *Main> :info LastName
    type LastName = String  -- Defined at types.hs:2:6-13
    *Main> :info Name
    type Name = (FirstName, LastName)       -- Defined at types.hs:3:6-9

The `:info` command allows us to dereference the type alias to the type
it was defined against.

Type synonyms _do not_ introduce new types, they are just
aliases. Synonyms are useful for grouping types together into a
frequently used structure, such as with the `Name` type.

One interesting point to note here is that `String` is actually a type
synonym itself:

    *Main> :info String
    type String = [Char]    -- Defined in GHC.Base

As you can see, strings are just lists of chars in Haskell.

### Type Renaming and Safety

Whilst type aliasing is a nice feature, it doesn't help to constrain the
type space in any way - it is mostly a convenience feature.

Another way of introducing types, is to introduce a renaming of an
existing type. The newly renamed type is distinct from the type it was
renamed from and the two _cannot_ be used interchangeably.

Let's see a simple example first and then look at a use case where this
is especially useful.

    newtype FileName = FileName String

This defines a new type `FileName` that wraps `String`. The `FirstName
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

We define a module `Sql` to hold our `Query` type and associated
functions:

    module Sql (Query, parse, execute) where

    newtype Query = Query String

This defines the module `Sql` and exports the type `Query` and the
functions `parse` and `execute`. Clients of this module can only access
exported types and functions. The `Query` type is defined as a renaming
of `String`. Note that the type constructor for `Query` is _not_
exported.

Next we define the `parse` function:

    parse :: String -> Query
    parse = Query . escape

This function takes a `String` and returns a `Query`. Since the `Query`
type constructor is not exported, this is the only way client code can
create a `Query`. Note that before passing the client-supplied SQL
`String` to the `Query`, we escape it using the `escape` function.

For demo purposes we'll define `escape` as `id`. In the real world this
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

## Richer Types

Beyond the more basic type options afforded by `type` and `newtype`,
Haskell provides the `data` construct for building richer types. Let's
explore the options for building such types.

We'll start by looking at a simple example, one that looks very similar
to the `newtype` definition of `FileName`:

    data FileName = FileName String

Aside from changing `newtype` to `data`, this example looks identical to
the previous example of `FileName`. We have the type `FileName` and a
single constructor function `FileName`. If we explore the type
signatures in `ghci` we'll see that they are the same as the earlier
example:

    *Main> :t FileName
    FileName :: String -> FileName
    *Main> :info FileName
    data FileName = FileName String         -- Defined at data.hs:1:6-13

The difference between `newtype` and `data` is that `data` types can
have multiple 'slots' containing values, whereas `newtype` is limited to
just the one slot containing a value of the type being
renamed. Furthermore, as we'll see shortly, `data` types can have
multiple constructor functions whereas `newtype` can have only one.

You might wonder, if `data` can describe all the types that `newtype`
can and more, why anyone would use `newtype`. The reason is that
`newtype` declarations are only checked at compile time. At run time,
the `newtype` is treated the same as the type it renames, without any of
the indirection or overhead present in a `data` type.

Let's extend our example and add in more value slots.

    data FilePath = FilePath String String String

Here we define a `FilePath` type containing three `String` values: the
directory path, the file name and the extension. We can create a
`FilePath` using the `FilePath` constructor function:

    FilePath "/Users/robharrop" "article" "md"

Using pattern matching we can define functions that work with the values
in the different slots:

    fileExtension (FilePath _ _ ext) = ext

    isMarkdown (FilePath _ _ "md") = True
    isMarkdown _ = False

Here we define a `fileExtension` function to extract the extension value
from a `FilePath` and an `isMarkdown` function to determine whether or
not a particular `FilePath` points to a Markdown file.

We can test these out in `ghci`:

    *Main> isMarkdown (FilePath "/Users/robharrop" "article" "md")
    True
    *Main> isMarkdown (FilePath "/Users/robharrop" "article" "txt")
    False
    *Main> fileExtension (FilePath "/Users/robharrop" "article" "md")
    "md"

Now, let's expand the `FilePath` definition to handle different kinds of
paths: paths to files and paths to directories.

    data Path = File String String String
                |
                Directory String

Here, the `Path` type has two constructor functions `File` and
`Directory`. Notice that we don't need to have a constructor function
with the same name as the type.

We can construct instances of these types using the constructor
functions:

    (File "/Users/robharrop" "article" "txt")
    (Directory "/Users/robharrop")

The `Path` type is quite simple, but it isn't particularly
sophisticated. In this model, files can have any `Path` value for their
enclosing directory, possibly even a path to another file. Furthermore,
the `Directory` type doesn't provide any references to parent directory.

Let's recast this example to solve some of these problems and at the
same time explore the use of recursive data types.

We'll start with directories. In a typical file system, a directory is
either the root directory, or an entry in the tree that has a name and a
parent directory. We can easily model this with a recursive `data` type.

    data Directory = Root | Dir Directory String

This `Directory` type has two constructors `Root` and `Dir`. The `Root`
constructor is used to represent the notion of the root
directory. Constructor functions that accept no args are ideal for
representing singleton values like the root directory of a file system.

The `Dir` constructor takes two arguments, the parent `Directory` and
the name of the directory.

This simple construct enforces quite a lot of correctness in our
model. For example, all directories other than the root must have a
parent. Parent directories must also be an actual `Directory` not just
an arbitrary `String` value. Using `ghci` we can explore how this type
might be used.

We can describe the root directory:

    let rootDir = Root

We can describe a directory directly under the root:

    let usersDir = (Directory Root "Users")

We can even describe a deeply-nested directory:

    let devDir = (Directory (Directory (Directory Root "Users) "robharrop") "dev")

Defining a type for `File` that uses the `Directory` type for the parent
directory is trivial:

    data File = File Directory String String

Using `data` types we can create rich types with arbitrary shapes. The
ability to refer to types recursively allows for a variety of rich,
nested structues such as the file system hierarchy shown or a simple
tree structure like that shown below:

    data Tree a = Leaf a | Branch (Tree a) (Tree a)

This structure describes a simple tree. Notice that we're using a type
variable `a`, so that the leaf nodes of the tree can hold values of any
type.

## Type Classes

To complete our working knowledge of the Haskell type system, we move
now to looking at _type classes_. It is convenient, albeit not quite
accurate, to think of type classes as being like the interfaces found in
Java and C#.

Type classes provide a mechanism to describe common behaviours that can
be shared across arbitrary types. In this section we'll look at some of
the built in type classes and extend our file system model by creating
our type class for describing general purpose paths.

The easiest way to see how type classes work for types, is to see what
happens when a type doesn't have a particular type class.

In `ghci` try to evaluate an expression that creates a `Directory`:

    *Main> (Dir Root "Users")

    <interactive>:1:1:
        No instance for (Show Directory)
              arising from a use of `print'
                  Possible fix: add an instance declaration for (Show Directory)
                      In a stmt of an interactive GHCi command: print it

Although we can construct an instance of `Directory` `ghci` is unable to
print this instance out to the console. A scan of the error message
tells us that `ghci` is trying to use the `print` function and can't
print the `Directory` because it can't find an instance of `(Show Directory)`.

We'll return to the `(Show Directory)` bit shortly, but first let's look
at the `print` function:

    *Main> :t print
    print :: Show a => a -> IO ()

This type signature introduces something new. We can see the usual
function name `print` followed by the `::` denoting the start of the
type signature. The bit after the `=>` is just the normal signature, a
function that takes a value of type `a` (a type variable) and returns an
IO action.

The new bit is the `Show a` bit. This defines a contstraint on the type
variable `a`, in this case that the type must be an instance of the type
class `Show`.

We have a function, `print`, that accepts arguments of any type,
provided that type is an instance of the type class `Show`. Looking back
at the error message from `ghci` we can see that this is exactly what it
was complaining about: `Directory` is not an instance of the type class
`Show`.

So, what exactly is a type class? Simply put a type class is a named
collection of functions that provide a kind of interface. Types that
want to be instances of a given type class must implement all the
functions defined by the type class to be consider an instance of that
class.

In `ghci` we explore the `Show` type class to find out what functions it
defines and what types it has as instances:

    *Main> :info Show
    class Show a where
      showsPrec :: Int -> a -> ShowS
      show :: a -> String
      showList :: [a] -> ShowS

I've omitted the list of instances because it is quite long. The `Show`
class defines three functions, but a quick read of the documentation
will tell you that only `show` is required. Default implementations of
`showPrec` and `showList` are pre-defined in terms of `show`.

Since `Show` is one of the built in type classes, there is actually a
shortcut to making our `Directory` type an instance: we simply add
`deriving Show` to the end of our `data` type declaration.

    data Directory = Root | Dir Directory String deriving Show

Now, if we return to `ghci` and evaluate a `Directory` creation
expression,  we'll see some output:

    *Main> (Dir Root "Users")
    Dir Root "Users"

There are six built-in type classes that can be used with `deriving`:
`Eq`, `Ord`, `Enum`, `Bounded`, `Read` and `Show`. More information
about these type classes can be found in the Haskell documentation.

The default output from `Show` isn't particularly exciting, but it is
quite useful if we are debugging our software before we get around to
implementing `Show` directly.

Let's create a proper implementation of the `Show` class for our
`Directory` and `File` types:

    instance Show Directory where
      show Root = "/"
      show (Dir parent name) = show(parent) ++ name ++ "/"

    instance Show File where
      show (File dir name ext) = show(dir) ++ name ++ "." ++ ext

To declare a type as being an instance of a type class we use the
`instance` keyword. In the example above we define `Show` for the
`Directory` type, being careful to define `show` for both type
constructors

We also define `Show` for `File` and can rely on `Directory`
implementing `Show` when outputting the parent directory

We can see these type class instances in action in `ghci`:

    *Main> Root
    /
    *Main> (Dir Root "Users")
    /Users/
    *Main> (File (Dir Root "Users") "article" "md")
    /Users/article.md

Let's finish this installment by creating our own type class to extract
common path functionality that can be used with both directories and
files.

Type classes are defined using the `class` keyword and include the list
of functions that need to be implemented by the instances:

    class Path a where
      abspath  :: a -> String
      dirname  :: a -> String
      basename :: a -> String
      parent   :: a -> Maybe Directory

The `Path` class has four functions: `abspath` returns the absolute path
as a `String`, `dirname` and `basename` mimicking the behaviour of the
corresponding Unix utilities and `parent` returns the actual parent
directory value.

Notice that `parent` is defined as returing `Mabye Directory`. `Maybe`
is a standard type in Haskell and is used when a computation may return
no result. `Maybe` is defined as `data Maybe = Nothing | Just
a`. Computations that do not yield a value return
`Nothing`. Computations that do return a value, wrap that value in
`Just`.

Implementing this for `Directory` is quite simple:

    instance Path Directory where
      abspath  Root                 = "/"
      abspath  (Dir parentDir name) = abspath parentDir ++ name ++ "/"
      dirname  Root                 = "/"
      dirname  (Dir parentDir _)    = abspath parentDir
      basename Root                 = "/"
      basename (Dir _ name)         = name
      parent   Root                 = Nothing
      parent   (Dir parentDir _)    = Just parentDir

This is quite a simple definition. The behaviour of `dirname` for `Root`
mimics that of the `dirname` utility in Unix.

    instance Path File where
      abspath file@(File dir name ext) = abspath dir ++ basename file
      dirname      (File dir _ _)      = abspath dir
      basename     (File _ name ext)   = name ++ "." ++ ext
      parent       (File dir _ _)      = Just dir

We can experiment with these instances in `ghci`:

    *Main> let theDir = (Dir (Dir (Dir Root "Users") "robharrop") "writing")
    *Main> let theFile = (File theDir "article" "md")

    *Main> abspath theDir
    "/Users/robharrop/writing/"

    *Main> abspath theFile
    "/Users/robharrop/writing/article.md"

    *Main> basename theDir
    "writing"

    *Main> basename theFile
    "article.md"

    *Main> dirname theDir
    "/Users/robharrop/"

    *Main> dirname theFile
    "/Users/robharrop/writing/"

As you can see, we have quite a flexible mechanism for working with
files and directories using a uniform path instance.

## Summary

The Haskell type system provides a wealth of features for creating
robust elegant abstractions in our programs. Coupling lazy evaluation
and recursion provides a natural mechanism for working with infinite
data sets.

Correct usage and security can be baked in to the types of our programs,
reducing the chance for user error and improving code quality.

The `data` construct allows us to create data types of arbitrary shapes
and richness. Using type classes we can describe and implement uniform
interfaces to disparate type structures.

In this article, we've developed a good working knowledge of the Haskell
type system.

In the next installment of this series we'll tackle the apparently
thorny problem of side effects in a pure functional language. We'll see
in detail how Haskell handles IO and finally address the topic of
monads.

##Code

The code for this article is available in GitHub at: http://github.com/robharrop/osj-code.
