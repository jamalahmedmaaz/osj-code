#Learn Functional Programming with Haskell, Part One

In this article, I hope to set out a few of the reasons why you should
learn functional programming and then to lead you further into the
discovery of what functional programming is all about.

As you've all no doubt noticed, functional programming (FP) is one of
the hot topics of late. The growing popularity of languages such as
F#, Clojure and Scala is helping to make FP an acceptable solution in
the enterprise. This is, in my opinion, _a good thing_.

With this increasing popularity and the growing acceptance of polyglot
programming, it seems sensible to assume that some day soon, we might
all be writing portions of our application code in a functional
language. This too, is _a good thing_.

The increase in popularity alone might be enough to entice you to take
the plunge. However, I think there is another, more immediately
applicable, reason why you should learn FP: learning FP will make you
a better programmer. That's a rather bold statement but its borne out
both by my own experiences and the experiences of countless others.

FP is suitably different from imperative programming that it enforces
a different mental model on you. At first this might be difficult to
deal with, especially if your day job involves coding in an imperative
language and you're hacking on FP at night. Eventually though, this
different mental model becomes a _complementary_ model and you learn
to switch seamlessly between the FP and IP modes.

I found this to be a moment of great enlightenment, and it is a
powerful tool when trying to crack a thorny problem. You can approach
problems with either an FP or an IP mindset as the occasion demands.

I often approach new problems with an FP mindset only to go off and
implement the final solution in Java. Indeed, thinking of a problems
in terms of data structures and functions on those structures is often
easier than thinking in terms of complex domain entities. This is
especially the case when the problem you are dealing with is
especially abstract.

There are many languages you can choose from if you wish to
learn FP. On the .NET platform there is F#, on Java there is Scala and
Clojure, and then standalone there is Clean, Scheme, Haskell and many
more. Why then, choose Haskell? I think Haskell is the best language
in which to learn FP for two reasons: practicality and motivation.

From a practical point of view, Haskell embodies most of
what FP is all about. Recursion, pure functions, algebraic data types,
lazy-evaluation; all these things and more are to be found when working
in a Haskell environment. The end result is, that if you learn
Haskell, you learn most of what FP is about. 

Haskell is completely different to any imperative language you have
used. This difference of approach is both exciting and engaging. I
found that learning Haskell was both educating and entertaining in
almost equal measure.

Importantly, Haskell has a vibrant community. This is especially
important during the learning phase because there is nothing more
demotivating than hitting a problem and not being able to get any
help.

Should you learn other functional languages? Absolutely, but I
strongly recommend you make Haskell one of, if not the, first that you
approach.

##Getting Started with Haskell

Before you can start coding in Haskell, you need to install a Haskell
environment. The two most popular ones are GHC and Hugs. Most
development and innovation around Haskell is done in the GHC project
and it is the most popular environment. For this article, I'm going to
use GHC. If you are on Linux you'll probably find a ready-made package
in your package manager. On Mac OSX, GHC is most easily installed
using MacPorts. On Windows there is an MSI from which you can install.

Once Haskell is installed, fire up the interactive shell using the
`ghci` command. You'll be presented with a prompt like this:

    Prelude> 

Let's start with some basic arithmetic:

    Prelude> 1 + 1
    2
    Prelude> 2 * 4
    8
    Prelude> 6 / 7
    0.8571428571428571

As you can see, the familiar operators are available. These operators
are actually functions. The examples above are applying these
functions using *infix* notation. As with all functions, you can apply
the arithmetic functions using *prefix* notation:

    Prelude> (+) 1 1
    2
    Prelude> (*) 2 4
    8
    Prelude> (/) 6 7
    0.8571428571428571

Arithmetic is quite basic so let's move on to see how Haskell handles
the canonical "Hello World" example. In `ghci` we can start by just
entering the string value `"Hello World"`:

    Prelude> "Hello World"
    "Hello World"

Here we enter a string value and it is returned as-is, including the
enclosing quotes. For a more traditional approach, we can print the
text without the enclosing quotes:

    Prelude> putStrLn "Hello World"
    Hello World

Here we are calling the `putStrLn` function passing in the string
`"Hello World"` and the text from our string object is printed to the
console. You may be wondering at this point how IO is possible in a
pure functional language in which functions with side-effects are
banned. For now it is enough to know that Haskell has a sophisticated
system for dealing with functions that would normally have
side-effects.

So far all our examples have been written interactively in the `ghci`
shell. For a Haskell program to be truly useful we need a mechanism by
which we can store our program for later execution. We have two
options in Haskell for running stored programs, the first of which is
to use `runghc`. Start by creating a source file named `helloworld.hs`
that contains the following code:

    main = putStrLn "Hello World"

This code defines a function called `main`, the body of which is the
exact same code we entered into `ghci` in the previous example. Just
like in a Java or .NET program we need an entry function for our
program and in Haskell that is `main`. Once the script is saved you
can run it from the command line using `runghc`

    bash> runghc helloworld.hs 
    Hello World
    
If you are running on a Unix platform you can wrap up your Haskell in
a shell script using `runghc` as shown below

    #!/usr/bin/env runghc
    main = putStrLn "Hello World"

Save this file as `helloworld.sh` and then execute it from the command
line (remembering to make sure it is executable):

    bash> chmod +x helloworld.sh 
    bash> ./helloworld.sh 
    Hello World

For any serious projects you will probably want to compile
your Haskell code to machine code rather than run it under an
interpreter. For this you can use the `ghc` tool:

    [milhouse]: ghc helloworld.hs 
    
On Unix this will produce a file called `a.out` and on Windows
`Main.exe`. Running either of these files will give the same, familiar
`Hello World` output.

##Creating Simple Functions

So far, the examples haven't shown much use of functions. A real,
non-trivial Haskell program will be made up of many functions, each
ideally having a small, well-defined responsibility.

Let's see this in action by starting with some simple function
definitions. To start with we'll define a function that adds two
numbers together

    add x y = x + y

For these examples, you might find it most useful to save your code
into a source file, such as `add.hs` and then load this source file
inside `ghci`. You can then interact with your functions interactively

    Prelude> :load add
    [1 of 1] Compiling Main             ( add.hs, interpreted )
    *Main> add 1 2
    3

Using the `:load` command you can load your source files into `ghci`
environment. Any function you have defined in your source files can
then be called from within that environment. You might also find it
handy to know that `ghci` will give you tab-completion on file and
function names.

Returning to the definition of the `add` function, we can look at
the syntax in some more detail

    add x y = x + y

The first part of the definition is the function name, in this case
`add`. Following the name you'll see the parameter list, declaring two
parameters: `x` and `y`. The actual implementation of the function
comes after the `=` sign and here the implementation is trivial.

##Recursion and pattern matching

One of the aspects of functional programming that newcomers find
immediately confusing is the lack of looping constructs. In imperative
languages, it is natural to perform repetitive processing using some
kind of looping construction, but in functional languages it is much
more natural to define repetition using recursion.

To see this in action let's consider the fairly simple recursive
process of generating Fibonacci numbers. In Java this might look
something like this:

    public static int fib(int n) {
      int f = 0, g = 1;

      for (int i = 1; i <= n; i++) {
         f = f + g;
         g = f - g;
      }
      return f;
    }

In Haskell, we have don't have a looping construct so instead we turn
to recursion. Defining recursive functions typically starts by
defining the base cases. These cases are defined without performing
any recursive calls. For the Fibonacci process these are the `fib 0`
and `fib 1` cases:

    fib 0 = 0
    fib 1 = 1

Notice how we are able to define each base case separately and
declaratively. There is no need to write a single function definition
and use `if` statements to act conditionally depending on which value
is passed in. This is one of the aspects in which functional
programming can be more elegant than imperative programming.

Enter these definitions into a source file and load it into
`ghci`. You can test them out as you would any other function:

    *Main> fib 0
    0
    *Main> fib 1
    1
    
Now, try asking Haskell to calculate `fib 2`

	*Main> fib 2
	*** Exception: fibonacci.hs:(1,0)-(2,8): Non-exhaustive patterns in function fib

As you no-doubt expected, Haskell is raising an exception complaining
that it can't calculate `fib 2`. You might not have expected this
exception to be because of 'non-exhaustive patterns'.

When Haskell evaluates our call to `fib 2` it performs pattern
matching, comparing the arguments supplied with the different cases
defined for each function. We have only specified two cases for the
`fib` function and they are both specified strictly, each handling
only one specific input value.

To make `fib 2` work we could just define another case like `fib 2 =
1`, but what about `fib 3` and `fib 4`? To capture these cases, we
provide a general case, `fib n` that is defined recursively

	fib n = fib (n - 1) + fib (n - 2)

Now we can evaluate `fib 2` and `fib 3` in `ghci`

	*Main> fib 2
	1
	*Main> fib 3
	2

In the case of generating Fibonacci numbers, the recursive definition
is nowhere near the fastest mechanism, but for many algorithms,
recursive definitions are both natural and efficient.

##Working with Lists

The examples so far have only demonstrated basic string and integer
types. One of the most important types in functional languages is the
list type. Haskell has sophisticated features for writing programs
that process lists, and for ensuring these programs are efficient.

Lists in Haskell are declared using square brackets, `[]` is an empty
list and `[1]` is a list containing the number one. Like all data
types in Haskell, lists are immutable. Once you've constructed a list,
the only way to change it is to create a new list that embodies that
change. Haskell has a lot of smarts to ensure that this creation of
new lists is fast and efficient, but it can be quite a mind-shift for
imperative programmers at first!

You can play around with some basic lists in `ghci`

	Prelude> let x = [1, 2, 3]
	Prelude> x
	[1,2,3]
	Prelude> let y = x ++ [4..6]
	Prelude> y
	[1,2,3,4,5,6]
	Prelude> let z = 0 : x
	Prelude> z
	[0,1,2,3]
	Prelude> head z
	0
	Prelude> tail z
	[1,2,3]

Here we're using the `let` construct in `ghci` to declare
variables. Two lists can be concatenated using the `++` operator and a
new element can be added to the beginning of a list using `:` (called
the cons operator). The `..` (range) operator allows you to construct
a list that is the range of two integers. The `head` and `tail`
functions are self-explanatory.

Using recursion, pattern matching and lists we can start to construct
some elegant functions, most of which would require loops and/or
conditionals in imperative languages.

Let's start by defining a function to sum all the numbers in a list:

	sum_list [] = 0
	sum_list (x:xs) = x + sum_list xs

We start with the base case, in this case summing the empty list and
then we define the case for a non-empty list. The expression `(x:xs)`
is a special pattern that binds `x` to the head of the list passed in and
`xs` to the tail. 

We could avoid using pattern matching and define our second case as

	sum_list l = (head l) + sum_list (tail l)

In this case, I think this actually reads quite nicely: the sum of a
list is equal to the item at its head plus the sum of its tail. That
said, the approach using pattern matching is usually more succinct and
you are more likely to encounter it when reading other Haskell code.

##Higher-order functions

So far, everything we have seen is not that different to what can be
done in an imperative language. Sure the syntax is different, but the
approaches are similar.

Where functional languages come into their own is in their treatment
of functions as first-class constructs. Functions can be passed as
arguments to other functions. Functions can return other functions
instead of just simple values. To see how this might come in useful,
let's consider another example of processing the values in a list.

In this scenario, we want to calculate the product of all numbers in a
list. Using the knowledge we have so far this is actually quite easy:

	prod_list [] = 1
	prod_list (x:xs) = x * prod_list xs

This is quite a simple definition that closely follows the pattern
seen in the `sum_list` function. In fact, the main differences are the
result of the base case and the operator applied to the elements in
the list.

The commonality between the `sum_list` and `prod_list` functions can
be captured using a function that takes a list, a base case value and
another function. This new function will apply the input function to
all the elements in the input list, in the same recursive manner as
`prod_list` and `sum_list`. This might sound complicated, but it is
remarkably simple to transform the `prod_list` and `sum_list`
functions into this:

	list_calc [] base _ = base
	list_calc (x:xs) base f = f x (list_calc xs base f)

There are two things of interest here. The first is the use of `_` as
a wildcard in the definition of the base case. The base case makes no
use of the calculation function so it can be ignored. When an argument
is ignored in a case, it is considered good practice to use the `_`
wildcard.

The second thing of interest is the argument `f`. This is the function
that actually does the calculation on the list elements. Notice how we
in `prod_list` we call `*` passing in the current list head and the
result of the recursive call on the current list tail. For `list_calc`
we simply call `f` passing in the current list head and the result of
the recursive call.

We can now define `prod_list` and `sum_list` using `list_calc`:

	prod_list2 list = list_calc list 1 (*)
	sum_list2 list = list_calc list 0 (+)

The most interesting thing here is notice that we are passing the `*`
and `+` functions as arguments to our `list_calc` function.

You might like to check for yourselves that these functions are
equivalent to the ones given earlier by loading them up in
`ghci`. 

##Tail Recursion

If you have read anything about functional languages already, then you have probably heard
much about tail recursion. A function is said to be tail-recursive if the last operation in
the function is the recursion. All the functions we have defined so far are not
tail-recursive because the perform some further processing on the value returned from the
recursive call.

Tail-recursive functions are important because they can be compiled like a loop and will run
with radically reduced stack space. The Haskell compiler is smart enough to apply this
optimisation so if you write a tail recursive function you can rely on it running in a
space-efficient manner.

Making a function tail-recursive generally involves carrying the result value along the
recursive call stack rather than calculating as the result of the recursive call. The value
that is being carried is often referred to as the accumulator. We can see how this works by
updating the `sum_list` function to be tail-recursive:

	sum_list_recursive list = calc list 0
		where 
			calc [] acc = acc
			calc (x:xs) acc = calc xs (acc + x)

There a three important aspects of this declaration. First, notice the introduction of the
`where` construct. Using `where` we can declare a local function definition that is private
to the enclosing function. This is quite useful when defining tail recursive functions
because you can keep the accumulator out of the public API for the function.

The second important thing to note is that the base case of `calc` doesn't need a hard-coded
value, we can use the accumulator instead. In the case where an empty list is passed in, the
initial accumulator value is used. If a non-empty list is passed in, then whatever value has
been calculated so far is passed to the base case as the accumulator and will be returned.

The third thing to notice is that we are not applying `+` to a list element and the result of
the recursive call. Instead we are applying `+` to a list element and the *accumulator*. The
result of this calculation is then passed along in the recursion as the new accumulator. It
is for this reason that we don't need to specify a static value for the base case of `calc`.

From looking at this you might now start thing that we should make `list_calc` tail
recursive. In fact, doing so it quite easy

	list_calc_recursive list base f = calc list base
		where 
			calc [] acc = acc
			calc (x:xs) acc = calc xs (f x acc)

Notice how the base case value passed to `list_calc_recursive` becomes the accumulator value
in the `calc` function. Notice also, that `calc` has access to `f` from the scope of its
enclosing function.

Defining `sum_list` and `prod_list` in terms of `list_calc_recursive` is trivial:

	prod_list3 list = list_calc_recursive list 1 (*)
	sum_list3 list = list_calc_recursive list 0 (+)

##Folds

The process of taking a list and reducing it to a value by applying a function recursively to
its elements is called folding. The notion of folding is built into Haskell so we don't need
to define our own `list_calc` process we can instead use the built-in `foldr` and `foldl`.

With `foldr` the evaluation starts with the first element and moves towards the last, with
`foldl` the evaluation happens in the opposite direction. For our `sum_list` and `prod_list`
functions this difference is essentially unimportant. The reason for this, of course, is that
both `+` and `*` are associative so `a + b == b + a` and `a * b == b + a`. If a
non-associative function is used in the fold then the direction of evaluation will be
important.

Re-writing the `prod_list` and `sum_list` functions using `foldr` is simple:

	prod_list4 list = foldr (*) 1 list
	sum_list4 list = foldr (+)  0 list

##Lambda Expressions

So far all the functions we have defined have been named entities, either at the top-level of
the program or as local entities inside an enclosing function. This is fine for many of the
functions that we want to use, but sometimes we just need to define a simple function for
one-off usage. Lambda expressions allow just this.

To see how this works, let's start by defining a function that squares all the numbers in a
list

	squares [] = []
	squares (x:xs) = (x * x) : squares xs

This is quite simple and we can see it in action in `ghci`

	*Main> squares [1..10]
	[1,4,9,16,25,36,49,64,81,100]

There is a problem with our function though: it isn't tail recursive. We can fix this easily
by using the built-in `map` function. Given a list and a function, `map` applies the function
to each element in the input list and returns a new list containing the results. Using `map`
we can define a new version of `squares`

	squares_map list = map square list
		where square x = x * x

Notice how we've used `where` to introduce a local function `square` that we pass to the
`map` function. This works well, but it is quite verbose given the simplicity of the function
being applied. This declaration is easily simplified using a lambda

	squares_lambda list = map (\x -> x * x) list

Here the expression `(\x -> x * x)` is a lambda expression that
defines a function that takes a single argument, `x` and returns `x *
x`. 

##Currying, partial application and point-free functions

Currying is the process of converting a function that takes multiple
arguments into a function that takes one argument and returns a
function that takes the arguments that are still needed (if any).

In Haskell, all functions are considered to be curried automatically
allowing for _partial application_ of arguments to the function. This
complication is hidden from you during normal coding, but it can be
exploited to great effect when needed. To see this in action, let's
revisit the `add` function from earlier:

	add x y = x + y

If we want to define a function `addOne` that will always add one to any
number supplied, we can do so using partial application

	addOne = add 1

The expression, `add 1` is a partial application of the `add` function
that returns a function that accepts a single argument and adds one to
it.

There is something else that is interesting about the `addOne`
function: it does not specify a parameter list. This style of function
definition is referred to as _point-free_, that is the definition of
the function does not talk about the values the function is acting
on. The `addOne` function could've been defined as `addOne x = add 1
x`. This version is not as clear as the point-free one, and in general
it is considered best practice to write functions in point-free style
where possible.

##Function composition

Haskell provides a mechanism for formal composition of functions. This
kind of composition is different from simply combining two functions
in some ad-hoc way to create a third. Formal composition is composition
in the mathematical sense. 

Let's see this in action by combining two of the functions we defined
earlier `sum_list` and `squares` to calculate the sum of the squares
in a list of numbers. Composing this informally we might it approach
it this way

	sum_squares list = sum_list (squares list)

If you are from an imperative programming background this seems very
natural. We are composing the `sum_list` and `squares` functions to
create another function `sum_squares`. 

Whilst the informal approach to composition is intuitive in imperative
programming, it is non-idiomatic when programming in a functional
language. Using formal composition we can create 'pipeline' of
functions that operate on our arguments. Formal composition also
allows for more complex functions to be written in point-free
style. Re-writing the above using the `.` (composition) operator we
get

	sum_squares_composed = sum_list . squares

This function is `sum_list` composed with `squares`. It takes as its
arguments what `squares` takes, the result of `squares` is then
'pipelined' to the `sum_list` function.

Function composition can be combined with partial application and
other constructs such as folds and maps to create quite powerful
functions in succinct and simple ways. For example, we might define a
`prod_squares` function without reusing any of our previous function
definitions:

	prod_squares = foldr (*) 1 . map (\x -> x * x)

This might look quite opaque to you now, but as you gain experience
with Haskell you learn to treat composition, lambdas, maps and folds
as primitives which you'll read with the ease with which you can read
loops and conditionals in your favourite imperative language.

##Summary

Haskell is a powerful and elegant functional language. In this article
you have seen the beginnings of this elegance in the way functions be
declared and composed to create sophisticated function from small
building blocks.

There is much more to Haskell than has been shown here. In particular
this article has not touched on lazy evaluation, infinite lists, types
or monads. In next quarter's OSJ, I'll be writing a follow up to this
article to present this extra topics in detail.

In the meantime, if you are chomping at the bit to get started with
Haskell I recommend the book Real World Haskell which you can find
online at book.realworldhaskell.org.

##Code

The code for this article is available in GitHub at: http://github.com/robharrop/osj-code.
