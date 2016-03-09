# TLC - A compiler for the Teal programming language

(Work in progress...)

## What is Teal?
Teal is a modern statically typed programming language with type inference, structural typing, and algebraic data types.

### Declarations
```
let a: int // a will refer to an int, once assigned this a will always refer to that same int
var b: int // b will refer to an int, b's reference may be updated to refer to a different int
var c:= 7 // c refers to an int with the value of 7
let d:= mutable<int>(7)
```

### Type Inference
The rules are simple: anywhere you might declare a type, you also have the option of not declaring a type. If the compiler can figure out something that'd work from context, great. Otherwise there will be a compilation error.


### Types:
* Int - an integer type
* Number - a double precision floating point numbers
* Bool - an enum with two levels: {true, false}
* Bit - an enum with two levels: {on, off}
* Byte - an 8-tuple of bits
* Unit - a type with only one value
* Procedure - a function that may have side effects


### Algebraic Data Types
* Record - think c "struct", each member has a name
* Tuple - like a Record, but members are ordered and names are optional
* Option - a tagged-union, each variant has a name

### Collections
* Map - a collection of (key, value) pairs, where keys must be unique
* Sequence - an ordered collection with zero or more elements


### Procedures
Procedures take zero or more named values as arguments, and produce a single value as their result. Calling a procedure may have side effects. Procedures with only one argument can be called without naming that argument.
