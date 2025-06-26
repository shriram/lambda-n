# The lambda-n Language

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

## Extensions

* Why only constants? Why not permit positional *arithmetic* to reference parameters?
* Why decimal syntax and not Church numerals? For instance, instead of writing `$0`, we could write `$(λ (f) (λ (x) x))`.
* Heck, why not do this recursively? Use lambda-n to reference parameters: `$(λ 1 (λ 1 $0))`, for instance.
* Naturally, then—do you see why?—we would need to extend this to de Bruijn notation.

## Bugs?

Oh, I really don't want to know.