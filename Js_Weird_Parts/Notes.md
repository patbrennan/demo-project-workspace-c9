# JavaScript - Understanding the Weird Parts
---

## Section 2

### Conceptual Aside
**Syntax Parser** - Program that reads your code and determines what it does and if its grammar is valid. It's an intermediate program that interfaces with the computer. I.E., compiler / interpreter.

**Lexical Environment** - Where something sits physically in the code you write. Also, what surrounds it.

**Execution Context** - A wrapper to help manage the code that is running. There are lots of lexical environments. Which one is currently running is managed via execution contexts. It can contain things beyond what you've written in your code.

### Conceptual Aside
**name/value pairs** - a name which maps to a unique value. May be defined more than once, but only can have one value in any given *context*. That value may be more name/value pairs.

**object** - A collection of name-value pairs (when talking about *JavaScript*)

**Global Execution Context:**
- Creates global object (the window is the global object)
- Creates 'this' (the window at the global level)

*Global* in Js means "not inside a function".

**Outer Environment**:
- Null at the global level.

**Hoisting**: During the *creation* phase of the execution context, Js engine sets up memory space for variables & functions. (this is called "hoisting").
- Variables are assigned a placeholder (undefined) during this phase. It isn't until the second phase (execution) that values are assigned to variables.
- Best not to rely on hoisting!

### Conceptual Aside
**undefined** in Js: a special value (keyword) in Js. Never set your variables manually to `undefined`.

**Execution Phase**
```javascript
function b() {
  console.log('Called b!');
}

b();

console.log(a);

var a = 'Hello World!';

console.log(a);
```

In the above code, the output would be:
`> Called b!`
`> undefined`
`> Hello World!`
This is because `a` is set to `undefined` during the creation phase. During the execution phase, `console.log()` runs & shows that `a` is indeed undefined. After the execution phase, `a` is set to the string value and that is output to the console.

### Conceptual Aside
**Single-threaded**: One command at a time. (under the hood of the browser, maybe not. From our perspective as programmers, yes.)

**Synchronous**: One at a time, and in order. Code executed one line at a time, in the order it appears.

---
*invocation* - run the funtion. In Js, using the `()` invokes a function.

```javascript
function b() {
}

function a() {
  b();
}

a();
```
When the execution phase is run, `a` is invoked. A new execution context is created, and placed on the *execution stack*. Whichever context is on top, it's the one that is running. Every function creates this new execution context. *NOTE*: The order (or lexical characteristics) of the code does not matter. 

**Variable Environment**: Where variables live & how they relate to each other in-memory. Every execution context has its own variable environment.

Each time a function is invoked, a new execution context is created, and variables would not affect each other - even if they are seemingly mutated. This is different than Ruby, where variables can be declared in one scope & mutated in another.

*However*, when we *request* or *do something* with a variable, Js does more than just look in the currently executing context for that variable. **Remember that every execution context has a reference to its outer environment.**

```javascript
function b() {
	console.log(myVar); // Would actually return 1! Outter reference to global environment.
}

function a() {
	var myVar = 2;
	b();
}

var myVar = 1;
a();            
```

So in the code above, invoking `a()` actually returns `1`, because `b()`'s outer environment is actually the global execution context. This is also the case in function `a()`. They are *lexically* similar, so they have the same outer environment. `b()` lexically sits in the global environment.

When Js can't find a variable, it will look in the outer reference. This depends on where the function sits *lexically*. This chain keeps happening until the global environment is reached or the variable is found. This is called the ***scope chain***.

In the code below, we've changed the lexical environment of `b()`, which will change the *scope chain*, thus:

```javascript
function a() {

  function b() {
      console.log(myVar); // when invoked, returns 2.
  }
  
  var myVar = 2;  
	b();
}

var myVar = 1;
a();
// if b(); were invoked here, you'd get an uncaught reference error. Not defined in global
// execution context.
```

**Scope**: Where a variable is available in your code (or a new copy of it).

`let` in ES6:
- allows for block scoping.
- Doesn't replace `var`, but can be used in place of.
- Still "hoists" and values are `undefined` in the creation phase.
- would create a new value in memory for the variable in each iteration of a loop.


**Asynchronous**: more than one at a time. 

The Js engine is always synchronous. What happens is that the Js code requests or affects something outside the Js engine (HTTP request / rendering engine, etc).

Js engine has an *event queue* (for clicks, http requests, etc). Once the execution stack is empty, events in the event queue will "trigger" certain functions. Subsequently, a new execution context is created & placed in the execution stack. That function (handler) finishes, and subsequent events are then handled from the event queue.

The *browser* is putting things into the event queue asynchronously with the Js engine running. Js is still running line-by-line.

```javascript
// long running function
function waitThreeSeconds() {
    var ms = 3000 + new Date().getTime();
    while (new Date() < ms){}
    console.log('finished function');
}

function clickHandler() {
    console.log('click event!');   
}

// listen for the click event
document.addEventListener('click', clickHandler);


waitThreeSeconds();
console.log('finished execution');
// Js won't process the clickHandler() function until the execution stack is empty.
// You will see click events at the end. They are processed in the order they happened.
```

---

## Section 3

### Conceptual Aside

**Types & JavaScript**

**Dynamic Typing**: You don't tell the engine what type of data a variable holds. It figures it out while your code is running. Variables can hold different types of values because it's all figured out during execution.

**Primitive Types**: a type of data that represents a *single* value. i.e., not an object.

1. *undefined* = represents lack of existence. Js engine sets this value. Don't set variables to `undefined`!
2. *null* = also represents lack of existence. Better to use when *you* want to say something doesn't exist yet or is unknown.
3. *boolean* = `true` or `false`.
4. *number* = floating point number (always some decimals). The only numeric type in Js. Can sometimes make math weird.
5. *string* = sequence of characters. Both single & double quotes can be used.
6. *symbol* = used in ES6...look up in MDN.

### Conceptual Aside

**Operators**: a special function that is syntactically different. Generally, take two parameters, return one result.

```javascript
var a = 3 + 4;    // `+` is actually a function like (3).+(4); or +(3, 4);
console.log(a);   // 7
```

The above is called "infix" notation - where the function is between the two parameters.

**Operator precedence**: which operator function gets called first. Called in order of precedence. (higher wins)

**Operator associativity**: what order operator functions get called in: left-to-right or right-to-left. (when functions have the same precedence)

> [Precedence & Associativity](/Js_Weird_Parts/Operator-Precedence-In-Javascript.pdf) reference doc

```javascript
var a = 2, b = 3, c = 3;

a = b = c;

console.log(a); // 4
console.log(b); // 4
console.log(c); // 4
// `=` has right-to-left associativity, thus all values are `4`
```

**Conceptual Aside: Coercion**: Converting a value from one type to another. (happens often with dynamically typed languages)

**Comparison Operators Example**:

```javascript
console.log(1 < 2 < 3);     // true, as expected.
console.log(3 < 2 < 1);     // true, because associativity is left-to-right, and Js engine
// is actually comparing (false < 1). Because of coercion, `false` is coerced to `0`
// and `true` is returned.
```

`NaN` = Not a Number. Js tried to coerce something to a number, and it couldn't.

`null` = coerced to `0`, HOWEVER, `null == 0; // false`. Some things don't do what you'd expect.

`null < 1` = `true`. This is weird. This is one of the "bad" parts of Js.

`"" == 0; // true` & `"" == false; // true` = both are true!

**How do we solve this???**

`===` = strict equality & `!==` = strict inequality. These compare two things but *do not* try to coerce values. Using strict equality / inequality will save us from having strange bugs or weird values that are coerced.

**See reference**:

> [Equality & Sameness](/Js_Weird_Parts/Equalty-Comparison-And-Sameness.pdf) reference doc

**Existence & Booleans**:

*Note*: `undefined`, `null`, `0` and `""` all coerce to `false` in Js.

```javascript
var a;

// goes to internet & looks for a value

if (a) {      // Js attemptes to convert `a` to a boolean value
  console.log("Something is there.");
}

// if no value is found, the `if` statement fails.
```

Be careful that what you're testing for in the `if` statement doesn't evaluate to `0`, or it will not run! Instead, you could use `if (a || a === 0)`.

**Default Values**:

```javascript
function greet(name) {
  console.log("Hello " + name); // coerces the variable `name` to a string of `undefined`
}

greet();
```

In the code above, `name`s default value is `undefined` because it hasn't been set with invoking the `greet` method. The code below shows a common way to set a default value (changed in ES6) in legacy code in the case where no value exists or it is undefined.

```javascript
function greet(name) {
  name = name || "<your name here>"; // name is `undefined` but this sets a default
  console.log("Hello " + name);
}

greet();
```

In the above code, the `||` method returns the value that *could be coerced* to true.

**Framework Aside**:

If you had several libraries included in your app, such as:

```html
<html>
  <head>
  
  </head>
  <body>
    <script src="lib1.js"></script>
    <script src="lib2.js"></script>
    <script src="app.js"></script>
  </body>
</html>
```

These different files are not creating separate execution contexts. They are quite literally "stacking" the code and running it as if they were a single file. It's important those files don't collide with each other! For example, if they had the same variable or function names. They are put together in the order they appear in your markup from top to bottom.

To prevent these collisions from happening, code in each Js file could include:

```javascript
window.libraryName = window.libraryName || "Lib 2";
```

## Section 4

**Objects & Functions**:

Remember: An object in Js is a collection of name/value pairs. Also, a *method* is simply a function on an object.

An object is sitting in memory in a certain spot, and it has references to it's properties (i.e., *primitive*, *objects*, or *methods*). There are different ways to access these properties & set them:

```javascript
var person = new Object();

person["firstname"] = "Patrick";
// firstname property set to a primitive string.
// computed member access = [] - this is one way to access properties.
person["lastname"] = "Brennan";

var firstNameProperty = "firstname";

console.log(person);                    // Object
console.log(person[firstNameProperty]); // Patrick

console.log(person.firstname);          // Patrick
// This is the 'dot' notation - or member access.
console.log(person.lastname);

person.address = new Object();
// another object sitting inside an object
person.address.street = "9892 Serona Heights Ct";
person.address.city = "Las Vegas"
// Another way to set another property/value.

console.log(person.address.street); // 9892 Serona Heights Ct
```

**Objects & Object Literals**:

```javascript
var person = {};
// this is object literal notation; the same as `new Object();`

var person = { 
  firstname: "Patrick", 
  lastname: "Brennan",
  address: {
    street: "9892 Serona Heights Ct",
    city: "Las Vegas",
    state: "NV"
  }
};
// you can have multiple lines & Js treats it as one line of code
// This is the same as the previous example, creating the object, and setting 
// each property individually.
```

You can also create an object on the fly, or pass an object to a function, as well as assign new properties with their own values to a previously assigned variable that references an object:

```javascript
function greet(person) {
  console.log("Hi " + person.firstname);
}

greet(patrick);
greet({ 
  firstname: "Mary",
  lastname: "Doe"
});

patrick.dob = {
  year: "1985",
  month: "06",
  day: "22"
}
// the variable `patrick` referenced an abject, and now we are creating a new
// property & assigning it's value as another object.
```










