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

> [Precedence & Associativity](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Operator_Precedence) reference doc

```javascript
var a = 2, b = 3, c = 4;

a = b = c;

console.log(a); // 4
console.log(b); // 4
console.log(c); // 4
// `=` has right-to-left associativity, thus all values are `4`
```

### Conceptual Aside: 

**Coercion**: Converting a value from one type to another. (happens often with dynamically typed languages)

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

> [Equality & Sameness](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Equality_comparisons_and_sameness) reference doc

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

greet();  // Hello undefined
```

In the code above, `name`s default value is `undefined` because it hasn't been set with invoking the `greet` method. The code below shows a common way to set a default value (changed in ES6) in legacy code in the case where no value exists or it is undefined.

```javascript
function greet(name) {
  name = name || "<your name here>"; // name is `undefined` but this sets a default
  console.log("Hello " + name);
}

greet();  // Hello <your name here>
```

In the above code, the `||` method returns the value that *could be coerced* to true.

### Framework Aside:

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
console.log(person.lastname);           // Brennan

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

### Framework Aside:

*Faking NameSpaces*: 

Namespace = a container for variables & functions. It's typically used to keep variables & functions w/the same name separate.

```javascript
var greet = "hello.";
var greet = "hola";

console.log(greet); // hola

var english = {};
var spanish = {}; // these objects are just used as a container

english.greet = "hello.";
spanish.greet = "hola";

console.log(english); // Object {greet: "hello."};
// This is a way to "contain" methods, variables, etc - to prevent namespace collisions.
// This could go as many levels "deep" as you need.

// The below code doesn't work because `english.greetings` would be returned as undefined:

english.greetings.greet = "hello."; // can't call `greet` from `undefined`
english.greetings = {}; // must instantiate the object first & it must come first
// lexically in the code.
```

**JSON & Object Literals**

*JSON* = Javascript Object Notation

It's similar to a Js Object syntax, but it is not an Object. It's just a string of data. The syntax is slightly different:

```javascript
var objectLiteral = {
  firstName: "patrick",
  lastName: "brennan",
}

console.log(objectLiteral);

{
  "firstname": "patrick",   // JSON properties MUST be wrapped in quotes. It is also valid 
  "lastname": "brennan",    // object literal syntax, but is required for JSON.
  "isAProgrammer": true,
}
```

All JSON is valid Js Object literal syntax, but not all Object literal syntax is valid JSON. JSON has stricter rules. JavaScript has some built-in functionality for dealing / handling JSON:

```javascript
console.log(JSON.stringify(objectLiteral)); // converst object into JSON format

var jsonValue = JSON.parse('{ "firstname": "patrick", "lastname": "brennan", }');
// This will be converted to a Js Object
```

**Function are Objects**:

*First Class Functions* = everything you can do with other "types" you can do with functions. Assign them to variables, pass them around, create them on the fly.

Functions reside in memory as a special type of object. They have two special properties:
- NAME (optional, can by anonymous)
- CODE (actual lines of code written)
  - This is "Invocable" (). You can tell Js engine to "run" that code.
  - This is just one of the properties of the function!

```javascript
function greet() {
  console.log('hi');
}

greet.language = 'english'; // adds a property to a function because the function 
// is an object.
console.log(greet); // logs the text of the function you wrote.
console.log(greet.language); // english
```

**Function Expression**: A unit of code that evaluates in a value. It doesn't have to be saved to a variable. Whereas a *statement* does work.

```javascript
var a;

a = 3; // = is an operator, or function. This will return 3. This is an expression.
1 + 2; // a valid expression. Returns the result of the `+` function.
a = { greeting: 'hi';} // also an expression.

if (a === 3) { // the `if` is just a statement and the (a === 3) is an expression.
  // code...
}
```

In Js, you have `function statements` and `function expressions`, which are very powerful. To illustrate the difference:

```javascript
// function statement - function placed in memory, but doesn't return a value or result in a value.
function greet() {
  console.log('hi');
}

// the function is an object. It's `name` property is `greet` & it's `code` property is the code inside the curly braces.

// function expression
var anonymousGreet = function() {
  console.log('hi');
}

// creating an object on the fly, and setting it equal to the variable. The reference
// in memory will contain a function object.
// the `name` property of the function object in this case is anonymous (anonymous function).
// to invoke this function, use the variable name & parens:
anonymousGreet(); // hi
```

The reason it's an expression is because we are assigning a value to a variable. The anonymous function returns a function object that is then assigned to the `anonymousGreet` variable. In the function statement, the function is simply put in memory during the *execution phase*, but with an expression an *object is returned*.

If you were to call `anonymousGreet();` above (or first, lexically), before the anonymous function was assigned to the variable, what would happen? `Uncaught TypeError: undefined is not a function`

In the code below, we are creating a function that takes a parameter - in this case - another function. Inside that function, we are invoking the function that was passed in as a parameter. This illustrates that function as *first class functions* can be created on the fly, passed around, and used like variables, and are simply objects themselves. This is essentialy called `functional` programming.

```javascript
function log(a) {
  a();
}

log(function() {
  console.log('hi');
});
```

### Conceptual Aside: 

**Pass by value vs. Pass by reference (variables)**:

*By Value* example: When variables point to a primitive type, they receive a reference, or address, to that value in memory. If another variable is then set equal to the initial variable, with primitives, it receives a new reference to a *copy* of that value. I.E., pass by value.

```javascript
var a = 3;  // address is 0x001 for example, referring to the value 3 in memory
var b = a;  // address is 0x002, referring to a copy of the primitive value.
```

*By Reference* example: With objects, Js is a bit different. Whether one variable is set equal to another that references an object, or the variable that references an object is passed into a function, the new variable uses the same *reference* spot in memory, referencing the exact same object. No copies are made.

More examples:

```javascript
// by value (primitives)
var a = 3;
var b;

b = a;  // `=` sees they are primitives, and creates a new copy, with a new reference.
a = 2;

console.log(a); // 2
console.log(b); // 3

// by reference (objects - including functions)
var c = { greeting: 'hi' };
var d;

d = c;  // `=` sets the reference of d to the same location in memory as c; same object.
c.greeting = 'hello'; // mutates the object for all references to it.

console.log(c); // { greeting: 'hello' }
console.log(d); // { greeting: 'hello' }

// even as parameters to functions, primitives are passed by value; objects by reference.

// The equals operator sets up new memory space (new address) when used:
c = { greeting: 'howdy' };
console.log(c); // { greeting: 'howdy' } - sets a new space & reference
console.log(d); // { greeting: 'hello' } - retains the old reference to original object.
```

**Objects, Functions, and `this`**:

`this` keyword: can change depending on how a function is called. (there are more complex examples as the notes go on...)

```javascript
console.log(this); // available at the global execution context level, Shows `Window`

function a() {
  console.log(this);
  this.newVariable = 'hello'; // sets a new property on the global object.
}

a();  // also the `Window` Object if you're simply invoking the function.
console.log(newVariable); // don't need dot operator on global variables

var b = function() {
  console.log(this);
}

b();  // `Window`

var c = {
  name: 'The c object',
  log: function() {
    this.name = 'updated c object'; // changes the name property of the object.
    console.log(this);
  }
}

c.log();  // logs `c` object - `this` refers to the object that the method 
// sits inside of.
```

Many people feel that the following is a bug in Js. In this case, we have a nested function inside a function. What does the `this` keyword reference?

```javascript
var d = {
  name: 'The d object',
  log: function() {
    this.name = 'updated d object'; // changes the name property of the object.
    console.log(this);
    
    var setName = function(newName) {
      this.name = newName;  // we expect `this` to reference the `d` object. It doesn't!
    }   // This internal function points to the global object...! name property
        // is created on the global object.
    setName('Updated the D object again!');
    console.log(this);
  }
}

d.log(); // Object {name: "updated d object", log: function}
```

The following is a common pattern that developers use to work around this. Remember pass-by-reference:

```javascript
var d = {
  name: 'The d object',
  log: function() {
    var self = this;  // self points to same location in memory as `this`, which 
                      // points to the `d` object. Now, everywhere else we'd use `this`
                      // we will use `self`.
  
    self.name = 'updated d object';
    console.log(self);
    
    var setName = function(newName) {
      self.name = newName;
    }
    
    setName('Updated the D object again!'); // now this mutates the object `d`
    console.log(self);  // name: 'Updated the D object again!'
  }
}

d.log()
```

In the above code, `self` is pointing to the same object in memory because of *pass by reference*. Therefore, whenever `self` is mutated, so is the same `this` object. This reduces confusion as to what `this` is referring to.

### Conceptual Aside: 

**Arrays - collections of anything**

Since Js is dynamically typed, the elements of the array can be any type of data / value / object, including functions.

```javascript
var arr = [
  1,
  false,
  {
    name: 'Patrick',
    occupation: 'Coder / Pilot',
  },
  function(name) {
    var greeting = 'Hello';
    console.log(greeting + ' ' + name);
  },
  "hello"
];

arr[0]; // 1

console.log(arr); // lists all primitive values & typeOf for objects
arr[3](arr[2].name); // 'Hello Patrick' - note you can actually invoke the function like this.
```

**`arguments` & SPREAD**:

`arguments` is set up in the execution context each time a function is executed. The `arguments` is just an object that holds the parameters you pass to a function. It's array-like, but not an array. 

```javascript
function greet(firstName, lastName, language) {
  language = language || 'en';  // how to set a default parameter in ES5 & earlier

  console.log(firstName);
  console.log(lastName);
  console.log(language);
  console.log(arguments);
}

greet(); // all logged as `undefined` except language. Hoisting set up the variables.
greet('John'); // Js uses parameters left to right. Now `firstName` is defined
greet('John', 'Doe'); 
```

What is a `SPREAD` parameter? It is the `...` notation that wraps all other parameters in an array. This is an ES6 feature, and isn't available as of yet in all browsers as of this writing. Example:

```javascript
function greet(firstName, lastName, ...other) {
  // code
}
```

### Framework Aside:

**Function Overloading (Js doesn't have)**

What is it? You can have functions of the same name that have different numbers of parameters. The following is a pattern to simplify things a bit that you will see some frameworks use:

```javascript
function greet(firstname, lastname, language) {
      
  
  if (language === 'en') {
      console.log('Hello ' + firstname + ' ' + lastname);   
  }
  
  if (language === 'es') {
      console.log('Hola ' + firstname + ' ' + lastname);   
  }
}

function greetEnglish(firstname, lastname) {
  greet(firstname, lastname, 'en');   
}

function greetSpanish(firstname, lastname) {
  greet(firstname, lastname, 'es');   
}

greetEnglish('John', 'Doe');
greetSpanish('John', 'Doe');
```

### Conceptual Aside:

**Syntax Parsers**

The Js engine goes through your code character by character, and makes certain assumptions & does certain things based on a set of rules. Sometimes Js can even change code as it goes. This all happens before the code is even executed.

### Dangerous Aside: 

***Automatic Semicolon Insertion***

Anywhere the syntax parser expects a semicolon to be, it will put one there for you. *Always put your own semicolons*. This can cause major problems!

In the code below, if there were a carriage return after the `return` keyword, Js would insert a semicolon automatically & simply return `undefined`. To fix it, you must put the curly brace on the same line as the `return` statement. **Tip**: *Always put your opening curly brace on the same line as the previous statement / declaration.*

```javascript
function getPerson() {
 
    return {
        firstname: 'Tony'
    }
    
}

console.log(getPerson());
```

### Framework Aside:

**Whitespace**

*Defition*: Invisible characters that create literal 'space' in your written code. I.E., carriage returns, tabs, spaces.

They make code more readable. The syntax parser is very liberal in what it allows. You will see a lot of usage of this with comments & white space in frameworks & source code.

```javascript
var 
  // first name of the person
  firstname, 
  
  // last name of the person
  lastname, 
  
  // the language
  // can be 'en' or 'es'
  language;             // same as: var firstname, lastname, language;

var person = {
  // the first name
  firstname: 'John',
  
  // the last name
  // (always required)
  lastname: 'Doe'
}

console.log(person);
```

**Immediately Invoked Function Expressions (IIFE)**:

```javascript
// a function statement
function greet(name) {
  console.log('Hello ' + name);
}

greet('John');

// a function expression
var greetFunc = function(name) {
  console.log('Hello ' + name);
}

greetFunc('Bill');

// This is immediately invoked. It is executed immediately after it is created.
// (IIFE)
var greeting = function(name) {
  return 'Hello ' + name;
}('Dilbo');
```

In the above code, whatever the return value of the anonymous IIFE is what `greeting` will be set to.

Just writing an anonymous function statement without invoking it isn't valid Js! But what if you wanted your function to just sit in the code without getting an error? The most common / accepted way is to simply wrap it in paratheses. *Remember*, you don't put simple statements in parentheses. You put expressions (that return something).

```javascript
var firstName = 'Shanendoa'

(function(name) {
  var greeting = 'Inside IIFE: Hello'
  console.log(greeting + ' ' + name);
}(firstName));
// also an IIFE
```

### Framework Aside:

**IIFEs & Safe Code**

When the code above is run, we first have the *global* execution context. When Js sees the invoking parentheses, a new anonymous execution context is created. The `greeting` variable is scoped to that anonymous execution context, and is not "touching" the global environment. 

As an example, if you have the code above in one file, and the code below in another, recall that they are actually combined into one file. This could cause a collision as before. However, there are no collisions in this code now. 

```javascript
var greeting = 'Hola';
// Still calls 'Hello John';
```

*Why?* - There is a new execution context created in the IIFE. The variables do not collide because they are defined & scoped in different execution contexts.

**NOTE**: By wrapping the code in an IIFE, you ensure your code doesn't collide with or interfere with any other code in the application. You will see this in a lot of frameworks - there will be an opening parenthese at the beginning of the file, and a closing parenthese at the end. *All of its code is wrapped in an IIFE*

This is very useful - you can immitate this in your own code, and not put something into the global object! This makes your code *safe*.

*But what if you want access to the global object in your IIFE?* If you wanted to make it available everywhere else in your code... Simply pass in the global object to the function:

```javascript
var firstName = 'J-dawg'

(function(global, name) {
  var greeting = 'Inside IIFE: Hello'
  global.greeting = 'Hello';        // this would overwrite the globally scoped 
                                    // variable `greeting`;
  
  console.log(greeting + ' ' + name);
}(window, firstName));
```

**Understanding Closures**

Start with an example. 

```javascript
function greet(whattosay) {
  return function(name) {
    console.log(whattosay + ' ' + name);
  }
}

var sayHi = greet('Hi');
sayHi('Dude'); // Hi Dude
```

In the code above, the return value of `greet()` is assigned to the variable `sayHi`. When we invoke `sayHi('Dude')`, how does it remember the value of `whattosay`? Because of closures.

What is happening:
1. When code starts, we have the global execution context.
2. When the code executes the `greet()` function, a new execution context is created.
3. The variable that is passed to it is sitting in its variable environment.
4. Js creates a new *function object*, and returns it.
5. After that return, the `greet()` execution context is popped off the execution stack - it's gone.
6. Normally, when that execution context finishes, Js eventually clears off the space in memory where the variables / functions / etc live - this is called *garbage collection*.
7. However, that memory space is still there in this case.
8. Now we're in the global execution context.
9. We invoke the function `sayHi()` is pointing at (the function object in memory).
10. That creates a *new* execution context, with the `name` variable in memory.
11. When the Js engine sees the `whattosay` variable, it looks for it up the variable scope chain. It couldn't find it inside the fuction itself.
12. The `sayHi()` variable still has reference to the `whattosay` variable from the original `greet()` execution context through the scope chain.
13. Any functions created inside the `greet` function will have reference to its (greet's) memory - what was in its execution context.
14. In other words, the execution context has "enclosed" its outer variables that were previously available.

This isn't something you tell Js to do - it's a feature of the language.

In other words, even though a function has ended & returned, Js engine still retains reference to where it should - the outer variable environment.

**Part 2**:

This is a common example of closures. Examine the code. What will the 3 lines at the end of the program output?

```javascript
function buildFunctions() {
  var arr = [];
  
  for (var i = 0; i < 3; i++) {
    arr.push(
      function() {
        console.log(i);
      }
    );
  }
  
  return arr;
}

var fs = buildFunctions();

fs[0]();
fs[1]();
fs[2]();
```

When you look at this code, you might first expect `0, 1, 2`. However, it will actually log `3, 3, 3`.

Under the hood, here is what's happening:

1. `buildFunctions` is pushing the *functions* into the array, so that `fs` is assigned the value of an array of functions.
2. The global execution context is there.
3. With `buildFunctions` invoked - it's own context is created, with two variables, `i` & `arr`.
4. The `for` loop runs, and `i` is first set to 0. Realize however, *the `console.log` isn't actually being run at this time*. We're just creating a new *function object*, and putting the line of code as its code property.
5. `i` is incremented and another *function object* is added, and so forth, until there are 3 function objects inside the `arr` variable.
6. By the time the `return arr` is executed, the `i` variable is set to 3.
7. When we go back to the global execution context, `buildFunctions` context is "popped" off the execution stack, *but the memory space to its variables remains*.
8. We go to the first `fs[0]();` call, and create a new execution context.
9. There is no variable `i` in it's scope, so it goes up the variable scope chain, looking in its outer reference.
10. Here, it finds `i` as the value 3, and the `console.log(i)` statement logs 3.
11. Subsequently, the remaining functions inside the `fs` array are invoked, and they retained the **same** reference to the outer environment, since they were created during the same execution context as `buildFunctions`.
12. Each of the functions that were invoked "enclosed" the same reference to the outer variables when they were created. They logged the value of `i` as of the time they were invoked. This is the closure.

But what if you *did* want it to work the way most people think it works, outputting `0, 1, 2`?

ES6 allows us to use the `let` keyword to scope a variable to the block level. Each time the `for` loop runs, `j` is reinstantiated & the value is assigned.

```javascript
function buildFunctions2() {
  var arr = [];
  
  for (var i = 0; i < 3; i++) {
    let j = i;
    arr.push(
      function() {
        console.log(j);
      }
    );
  }
  
  return arr;
}

var fs2 = buildFunctions2();

fs2[0]();
fs2[1]();
fs2[2]();
```

How do we accomplish the same task with ES5? In order to preserve the value of `i` for the function, we would need a separate execution context for each of the functions we're pushing into the `arr`. In other words, you could use an **IIFE**.

```javascript
function buildFunctions3() {
  var arr = [];
  
  for (var i = 0; i < 3; i++) {
    arr.push(
      (function(j) {
      return function() {
        console.log(j);
      }
      }(i));    // IIFE - new execution context is created each time this is invoked.
    );
  }
  
  return arr;
}

var fs3 = buildFunctions3();

fs3[0]();
fs3[1]();
fs3[2]();
```

Each time the loop runs & the anonymous function is immediately invoked, the variable `j` is stored in that execution context (which was set to `i` at that time). Therefore, when they are run, it will `console.log(j)` which is set to `0, 1, 2`, respectively, in each execution context. NOTE that the array still contains function objects, but those functions each reference their own outer variable environments *at the time they were created* (enclosing their outer environments) - using the variable scope chain to set the value of `j`.

### Framework Aside: Function Factories

Instead of passing `language` to the inner function, we pass it to the outer function, and return the inner function. The language is "trapped" or collected in the closure. *This could be useful for creating default parameters, among other things*.

```javascript
function makeGreeting(language) {     // this is the "factory function"
  return function(firstname, lastname) {
    if (language === 'en') {
      console.log('Hello ' + firstname + ' ' + lastname);
    }
    
    if (language === 'es') {
      console.log('Hola ' + firstname + ' ' + lastname);
    }
  }
}

var greetEnglish = makeGreeting('en');  // greetEnglish is a function object
var greetSpanish = makeGreeting('es');
// the closure keeps track of its execution context, solidifying the language argument
// each time you call it.

greetEnglish('John', 'Doe');  // Hello John Doe
greetSpanish('Jose', 'Doe');  // Hola Jose Doe
```

** Closures & Callbacks**

This is actually using function expressions (passing the function made on the fly as a parameter) & closures & first-class functions.   

```javascript
function sayHiLater() {
  var greeting = 'Hi';
  
  setTimeout(function() {
    console.log(greeting);  // still has access to `greeting` because of its closure
  }, 3000);
}

sayHiLater();
```

```javascript
// jquery uses function expressions & first-class functions
$("button").click(function() {
  // ... code
});
```

A **callback** is a function you give to another function to be run when the other function is finished. The function you call (invoke) "calls back" by calling the function you gave it when it finishes.

```javascript
function tellMeWhenDone(callback) {
  var a = 1000; // some work
  var b = 2000; // some work
  
  callback(); // the callback, it runs the function you give it!
}

tellMeWhenDone(function() {
  console.log('I am done!');
});

tellMeWhenDone(function() {
  alert('I am done!');
});
```

**.call(), .apply(), & .bind()**

These functions allow you to control what the `this` keyword references.

All functions are objects, and thus have some of their own methods available to them: `call()`, `apply()`, and `bind()`. All of these have to do with the `this` variable, and the arguments passed to the function as well.

```javascript
// remember that normally, the `this` keyword points to the object that contains
// it; the person object.

var person = {
  firstName: 'John',
  lastName: 'Doe',
  getFullName: function() {
    var fullName = this.firstName + ' ' + this.lastName;
    return fullname;
  }
}

var logName = function(lang1, lang2) {
  console.log('Logged: ' + this.getFullName());
  console.log('Arguments: ') + lang1 + ', ' + lang2);
  console.log('-------------');
}

logName();
// this points to the global object, so this will fail. logName is not an object
// and the global object doesn't have the method getFullName.
```

```javascript
// ...above code

// below, notice logName is not invoked. It's being used as a function object:
// the object you pass to `bind` will be the object that `this` refers to:

var logPersonName = logName.bind(person);

logPersonName(); // Logged: John Doe
```

In the above code, when the `bind` method is invoked, it actually is referencing the function object from `logName`, creating a copy so that whenever it's run, Js sees it was created with the `person` object, so `this` refers to `person`.

Unlike `bind`, `call` actually executes / invokes the function, decides what the `this` variable should be, and the rest of the arguments are normal parameters you'd normally pass to the function you're using `call` on. No copy is created.

```javascript
logName.call(person, 'en', 'es');
// invokes the function, first argument = `this` pointer

logName.apply(person, ['en', 'es']);
// Same as call, except takes an array for the arguments, not comma-separated values

(function(lang1, lang2) {
  console.log('Logged: ' + this.getFullName());
  console.log('Arguments: ') + lang1 + ', ' + lang2);
  console.log('-------------');
}).apply(person, ['es', 'en']);
// still works. This is just a function object & all functions can use apply
```

When would you use this in real life? Through function borrowing & currying. 

**Function Currying:** *Remember*, `bind()` does not invoke the function. So what does giving it parameters do? It sets permanent values of the parameters when the copy is made. This could also be useful for setting default parameters for custom one-off functions that share similar functionality.

```javascript
// code above continued...

// function borrowing:
var person2 = {
  firstName = 'Jane',
  lastName = 'Doe',
}

console.log(person.getFullName.apply(person2)); // Jane Doe
// this refers to `person2`, and apply invokes the function

// function currying: with bind, you're creating a new copy of the function
function multiply(a, b) {
  return a * b;
}

var multiplyByTwo = multiply.bind(this, 2);
// first parameter will always be a 2 in this copy of the function!

console.log(multiplyByTwo(3));
// 6; the parameter passed will be the second parameter
```

**Functional Programming**

Thinking & coding in terms of functions. Some examples:

```javascript
var arr1 = [1, 2, 3];
console.log(arr1);

var arr2 = [];

for (var i = 0; i < arr1.length; i++) {
  arr2.push(arr1[i] * 2);
}

console.log(arr2); // [2, 4, 6]

// This can be put as:
function mapForEach(arr, fn) {
  var newArray = [];
  
  for (var i = 0; i < arr.length; i++) {
    newArray.push(
      fn(arr[i]);
    )
  }
  
  return newArray;
}
```

This abstracts the concept of looping over an array & doing something to each element, then returning a new array from that supplied function. So you can do:

```javascript
// ..code from above

var arr3 = mapForEach(arr1, function(item) {
  return item * 2;
});

console.log(arr3); // [2, 4, 6]
```

Combining some of the previous knowledge of `bind()`, how would you could you use this technique to check against a default value? Remember bind takes first the reference for what `this` will be, then the arguments of the function you're calling `bind` on:

```javascript
// ..code from above

var checkPastLimit = function(limiter, item) {
  return item > limiter;
}

var arr4 = mapForEach(arr1, checkPastLimit.bind(this, 1));
// use `this` since you're not really using it.
// creates copy of the function on the fly, sets 1 as the default argument

console.log(arr4); // [false, true, true]
```

You might say that it's annoying that you have to call `bind()` all the time. It'd be nice to simply pass in the limiter in this case, so you don't always need to call `bind`:

```javascript
// Previous code for reference:
function mapForEach(arr, fn) {
  var newArray = [];
  
  for (var i = 0; i < arr.length; i++) {
    newArray.push(
      fn(arr[i]);
    )
  }
  
  return newArray;
}

var checkPastLimit = function(limiter) {
  return function(limiter, item) {
    return item > limiter;
  }.bind(this, limiter);  // presets the limiter value, already using .bind()
}

var arr4 = mapForEach(arr1, checkPastLimit(1));
console.log(arr4); // [false, true, true]
```

There is a lot happening in the above code. The `checkPastLimit` function object is passed in a limiter. `checkPastLimit` returns a function which uses that limiter as the default value using the `bind()` method. THEN this function is passed in to the `mapForEach` function & the work is done on the array, returning the boolean value after evaluating the expression. 

Note that you should try not to mutate data - try to return something new. Or if you have to, do it as high up in these function chain as possible.

**Functional Programming Part II:**

*Underscore.js* - [underscore.js](http://underscorejs.org) :: You can learn a whole lot by looking through some open-source libraries, and this is one of them. If you look at the "annotated source" link, it will show comments & code side-by-side. This is very useful for looking at & learning advanced code. To use the library, include it first in your html code. Then in the `app.js` file, you literally use just the `_` character to use the library. I.E.: `_.map(// ... code);`.

*lodash* - [lodash.com](http://www.lodash.com) :: also a good library.

Try using some underscore.js library functionality. Download the underscore library first.

**Object-Oriented JavaScript & Prototypal Inheritance**

### Conceptual Aside: Classical vs Prototypal Inheritance

*Inheritance* = One object gets access to the properties & methods of another object.

**Classical Inheritance** = The way it's been done for a long time (most popular). It's very verbose. Sometimes can get very complicated / perplexing as programs get larger.

**Prototypal Inheritance** = Flexible, extensible, and easy to understand. Simple. Not perfect, but can be very powerful & easy.

**Understanding the Prototype**

All objects in Js have a prototype property. It's simply a reference to another object. We'll call this `proto`. THAT object is its prototype. If you use the dot operator on an object and that object doesn't have the property, Js looks in the `proto` property (object) for the property you're looking for. It looks like it is on the object, but it's on the prototype. Similarly, that prototype object iteself can point to another prototype object, and so on. This is called the ***prototype chain***. This "chain" is relatively hidden to us, because we can simply type `obj.prop3` instead of `obj.proto.proto.prop3`. See an illustration of this [here](https://preview.c9users.io/patbrennan/demo-project/Js_Weird_Parts/js_prototype_chain.png?_c9_id=livepreview0&_c9_host=https://ide.c9.io).

```javascript
var person = {
  firstName: 'Default',
  lastName: 'Default',
  getFullName: function() {
    return this.firstName + ' ' + this.lastName;
  }
}

var john = {
  firstName: 'John',
  lastName: 'Doe',
}

// NEVER use this in real-life!!! This is simply for illustrative purposes:
john.__proto__ = person;          // john now inherits from person
console.log(john.getFullName());  // John Doe
console.log(john.firstName);      // John
```

Notice also that when `getFullName` was invoked, it knew what `this` referred to. It referred to `john`, not `person`. It's whatever object *originated* the call. Also, you don't get `Default` when logging the `firstName` because it goes up the prototype chain & finds it first in the `john` object, then stops.

```javascript
// ... code above

var jane = {
  firstName: 'Jane'
}

// REMEMBER: Don't ever do this in real life!
jane.__proto__ = person;
console.log(jane.getFullName());  // Jane Default
```

Since `jane` only has a firstName, the prototype chain runs & looks for each property until it finds it. That's why `default` is returned - it isn't contained in the `jane` object, so it looks up the chain & finds it in the `person` object, which is its prototype.

**Everything is an Object (or a primitive)**

**Reflection & Extend**

*Reflection*: An object can look at itself, listing and changing its properties & methods. We can use this to implement *extend* patterns.

```javascript
var person = {
  firstName: 'Default',
  lastName: 'Default',
  getFullName: function() {
    return this.firstName + ' ' + this.lastName;
  }
}

var john = {
  firstName: 'John',
  lastName: 'Doe',
}

// NEVER use this in real-life!!! This is simply for illustrative purposes:
john.__proto__ = person;

for (var prop in john) {  // loops over every member in the object
  console.log(prop + ': ' + john[prop]);
}
// actually retrieves all property / methods through the prototype chain

for (var prop in john) {
  if (john.hasOwnProperty(prop)) {      // checks if prop is actually on `john`
    console.log(prop + ': ' + john[prop]);
  }
}
// only logs `firstName` & `lastName`.
```

If you use the `underscore.js` library you could easily extend objects:

```javascript
var jane = {
  address: '111 Main St',
  getFormalFullName: function() {
    return this.lastName + ', ' + this.firstName;
  }
}

var jim = {
  getFirstName = function() {
    return firstName;
  }
}

_.extend(john, jane, jim); 
// combines these objects' properties & adds them to 
// the `john` object
console.log(john); // has everything plus the jane & jim properties / methods
```

The above extension is different than the prototype chain. It physically placed the properties / methods from the supplied arguments into the `john` object. This `extend` could somewhat be thought of *multiple inheritance* in classical OOP.

























