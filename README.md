# The lambda-n Language

## Is This a Serious Language?

My gosh, no. There's a giant imaginary `/s` around the whole
thing. But someone always misunderstands these things (especially on
social media), which is why I'm putting this at the top.

Though it *is* a cute programming *exercise*, illustrating Racket
macros.

## Motivation

In [Bicameral, Not Homoiconic](https://parentheticallyspeaking.org/articles/bicameral-not-homoiconic/)
I give an example of a term that is well-formed but not valid:
```
(lambda 1)
```
As I note there, though, it doesn't *have* to be a syntax error; “nothing prevents us from creating a new language where that term has some meaning”, I wrote.

This is that language.

## Language

The file [`lambda-n.rkt`](lambda-n.rkt) provides an extension of Racket's `lambda`.

For the most part, ordinary uses of `lambda` should remain unchanged. But if you write
```
(lambda N)
```
where `N` is a number…

First of all, it needs to be a non-negative integer; any other number is a syntax error. So let's suppose it's a valid number.

In that case, the variables `$0`, `$1`, `$2`, …, all the way through to `$N` are bound as positional parameters in the body of the `lambda`. That is, instead of referring to the parameters by *name*, you refer to them by *position*; the names are automatically made up for you.

There is, of course, a long tradition of (especially Unix-y) programming languages (awk, bash, etc.; now also Swift) using such names. There's no reason for Racket programmers to be left out. (Well, there may be reasons. Good reasons, even.)

## Examples

The function
```
(lambda 1 (* $0 $0))
```
consumes one parameter (see how clear it is: it says `1` right there!). This parameter is referred to as `$0`. The body multiplies `$0` by itself. Thus, this is a squaring function. For example:
```
(define square (lambda 1 (* $0 $0)))
```
Thus `(square 5)` will produce `25`.

If you need to work with right triangles a lot, you can write
```
(define hypotenuse
  (lambda 2
    (sqrt (+ (square $0)
             (square $1)))))
```
See how nicely this relieves you the bother of deciding what to call the parameters: should they be `a` and `b`? or `x` and `y`? or `s1` and `s2`? No more stress!

Be sure to see [the test suite](client.rkt) for more glorious examples of the merits of getting rid of parameter names.

## How Does It Work?

You might be tempted to pursue a strategy like this:

* Bind all the parameters into a single data structure (say an array), using a "varargs"-like mechanism.

* Turn every `$N` into a bounds check, followed by a dereference or error.

That would work. Of course, you would need to be able to write `$N` (like `$0`) as a stand-alone sigil in your language. In Racket, you can use identifier macros for this purpose. But that is messy: from a performance(!) perspective both function calls and variable references are now **much** more expensive; and managing scope becomes your problem (you shouldn't be able to write `$N` outside the syntactic body of one of these `lambda`s).

This implementation uses a much simpler strategy. It instead turns, say, `(lambda 2 BODY)` into `(lambda ($0 $1) BODY)`. There is no need to construct a data structure or to dereference it. It just means that “out-of-bounds” accesses — e.g., `(lambda 1 $5)` — are reported just as unbound variables, rather than as special errors referring to the number of parameters. But in turn, you don't even have to do any extra work to get an error, and the resulting error message is sensible (as opposed to if you had forgotten to do a bounds-check, in which case you would be leaking the data structure used to capture the parameters).

The key steps of this strategy are therefore:

* Racket variable names can begin with `$`. We don't need to do any extra work to enable that.

* So given `N`, the `lambda-n` macro just makes up the appropriate variable names and bind them as the (positional) parameters.

* The names are manufactured by the `make-names` function in [`lambda-n.rkt`](lambda-n.rkt).

* However, hygienic macros preclude these made-up names from actually capturing the same-named variables in the body. This is as it should be, usually.

* But in this case, the entire purpose of making up those names *was* so that they could be used in the body.

* Therefore, we have to override hygiene to capture the body variables. That is, we have to make it seem as if the manufactured names were written by the same entity that wrote the body. This is what the `datum->syntax` part does.

And that's it! The heart of the implementation is the three-line function that generates the names and the two lines that embed them in the new function (offset by blank lines for readability).

## Is it *Ever* Useful?

No, you should never use this! It's just meant to illustrate the power of Racket macros.

However, there are times, during debugging, when it's useful to have a placeholder function that just “soaks up” its parameters, whose arity is determined by the context: e.g., in a `for-each` context, you need a one-parameter function. You could write, say, `(lambda (x) (void))`; or even `(lambda x (void))`; or you *could* use this feature there: e.g., `(lambda 1)`. But you shouldn't.

## Extensions

* Why only constants? Why not permit positional *arithmetic* to reference parameters?
* Why decimal syntax and not Church numerals? For instance, instead of writing `$0`, we could write `$(λ (f) (λ (x) x))`.
* Heck, why not do this recursively? Use lambda-n to reference parameters: `$(λ 1 (λ 1 $0))`, for instance.
* Naturally, then—do you see why?—we would need to extend this to de Bruijn notation.

## Best Alternate Names

beka valentine on [Mastodon](https://mastodon.social/@beka_valentine@kolektiva.social/114748525078322647): 
“bash.sh”

Vaishnavi S on [Bluesky](https://bsky.app/profile/vaishs.bsky.social/post/3lsiqgv2m7222):
“Maybe you should call it John McEnroe, since you’re adding a little
bash to your racket”

## Bugs?

Oh, I really don't want to know.
