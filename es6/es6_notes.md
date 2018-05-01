# ES6 Notes from Udemy course: Stephen Grider

### Helper Methods

Use the [Js Playground](https://stephengrider.github.io/JSPlaygrounds/) for illustrations & testing.

These include `forEach`, `map`, `filter`, `some`, `reduce`, `find`, & `every`. These are themed around preventing writing `for` loops.

Example cases:

- `map` = display a list of data, like post updates or data in a table.
- `filter` = return a list of comments associated with a post.
- `find` = search through array & look for element with criteria, return the *first* matching arg.
- `every` = checks array and returns true if provided excpression evaluates to `true` for every element in the array. Otherwise returns `false`.
- `some` = checks every element and returns `true` if the provided expression evalutates to `true` for at least one element in the collection, otherwise returns `false`.
- `reduce` = given an initial value, iterates through a collection and performs the provided function with two arguments: initial val & current el, then assigns the current val to the result of the provided function on each subsequent iteration. Returns the ending val. You must `return` the accumulated value so it can be used in each subsequent function iteration.

Example: Coding interview question - Balanced Parens

Tell us if there are balanced parentheses given a string.

```javascript
function balancedParens(string) {
  var arr = string.split("");

  return !arr.reduce(function(prev, char) {
    if (prev < 0) { return prev; }
    if (char === "(") { return ++prev; }
    if (char === ")") { return --prev; }
    return prev;
  }, 0);
}

balancedParens("(((");      // false
balancedParens("((()))");   // true
balancedParens("((()())");  // false
balancedParens(")(");       // false
balancedParens("()())(");   // true
```

### Variable declarations with `const` & `let`:

In ES6, we NEVER use the `var` keyword. We use:

- `const` = value of a variable that we expect to never change.
- `let` = we expect the value of the variable to change over time.

Normally, we might have:

```javascript
var name = "Jane";
var title = "Software Engineer";
var hourlyWage = 40;

// ES6
const name = "Jane";              // probably won't change
let title = "Software Engineer";  // may change
let hourlyWage = 40;              // will probably change

// This would produce an error:
name = "Janet" // TypeError: Assignemnt to constant variable

title = "Senior Software Engineer";
hourlyWage = 45;
```

**Why were these changes made?**

A developer's intentions are much clearer & easier to understand when reading code. It's obvious when looking at a glance what is mutating and what is not.

### Template Strings / **Template Literals** / **String Interpolation**:

This is just a nicer way of joining together Js variables into a string. Instead of using any quotes, replace them with backticks (`).

```javascript
// Instead of:
return "The year is " + year;

// Write:
return `The year is ${year}`;

// Can also use ANY valid JavaScript expression
return `The year is ${new Date().getFullYear()}`;
```

### Fat Arrow Functions

```javascript
// ES5 way, the old way, which still works:
const add = function(a, b) {
  return a + b;
}
// ES6:
const add = (a, b) => {
  return a + b;
}

add(1, 2);

// When we have a SINGLE expression:
const func = (a, b) => a + b; // uses implicit return, must omit curly braces
```

### Advanced Use - Fat Arrow Functions:

```javascript
// With a SINGLE argument, you can omit parens
const double = number => 2 * number;

double(8);  // 16
// NOTE: Function w/NO arguments = you must still put the parentheses.

// Another example of refactoring:
const numbers = [1, 2, 3];

numbers.map(function(number) {
  return 2 * number;
});

// Becomes:
numbers.map( number => 2 * number );
```

### When to Use Fat Arrow Functions:

What are they really for? What do they solve?

```javascript
// This would normally throw an error - `this` loses context
const team = {
  members: ["Jane", "Bill"],
  teamName: "Super Squad",
  teamSummary: function() {
    return this.members.map(function(member) {
      return `${member} is on team ${this.teamName}`;
    });
  },
};

team.teamSummary(); // TypeError: Cannot read property 'teamName' of undefined.

// Arrow functions to the rescue:
const team = {
  members: ["Jane", "Bill"],
  teamName: "Super Squad",
  teamSummary: function() {
    return this.members.map( member => {
      return `${member} is on team ${this.teamName}`;
    });
  },
};

team.teamSummary(); // Jane is on team Super Squad. ...etc

// Here, we'd expect to be able to use an arrow function, but cannot:
// If we do, Js would throw an error, so we must use function:
const profile = {
  name: 'Alex',
  getName: function() {
    return this.name;
  }
};
```

Essentially, fat arrow functions are making use of **lexical `this`**. This is how we would expect `this` to act.

### Enhanced Object Literals:

```javascript
// ES5 way:
function createBookShop(inventory) {
  return {
    inventory: inventory,       // writing this twice
    inventoryValue: function() {
      return this.inventory.reduce((total, book) => total + book.price, 0);
    },

    priceForTitle: function(title) {
      return this.inventory.find( book => book.title === title).price;
    },
  };
}

// ES6 Way:
function createBookShop(inventory) {
  return {
    inventory, // condensed - just syntax. Must be identical name for key/value
    inventoryValue() {
      return this.inventory.reduce((total, book) => total + book.price, 0);
    },

    // When you have a value that is a function, you can omit `function` and `:`
    priceForTitle(title) {
      return this.inventory.find( book => book.title === title).price;
    },
  };
}

const inventory = [
  { title: "Harry Potter", price: 10, },
  { title: "Eloquent Js", price: 15, },
];

const bookShop = createBookShop(inventory);

bookShop.inventoryValue(); // 25
bookShop.priceForTitle("Harry Potter"); // 10
```

### Specifying Default Function Arguments:

Example:

```javascript
// Old way
function makeAjaxRequest(url, method) {
  if (!method) {
    method = "GET";
  }

  // logic to make request
}

// ES6 way:
function makeAjaxRequest(url, method="GET") {
  // If logic is not specified, defaults to "GET"
}

// If you NEED to use a value that isn't specified, use `null`
makeAjaxRequest("google.com", null);
```

A very useful case in which you'd want to use default arguments might be when the argument could be any valid Js expression. In the example below, we have a very flexible function that can take an existing user, or if one isn't provided as an argument, automatically creates a new one & returns it.

```javascript
// ...code above omitted

function createAdminUser(user = new User(generateId())) {
  user.admin = true;
  return user;
}
// this code is making it so that you can simply call the function name
createAdminUser();

// instead of this every time:
createAdminUser(new User(generateId()));
```

### Capturing Arguments with Rest & Spread:

The `rest` operator (`...`) tells us that we don't know how many arguments there will be, but it will capture them all in an array for use in a function.

```javascript
function addNumbers(numbers) {
  return numbers.reduce((sum, number) => {
    return sum + number;
  }, 0);
}

addNumbers([1,2,3,4,5]); // 15

// what if our arguments were not in an array? What if they were provided like
// a, b, c, d, e..., or we wanted to be able to pass in as many arguments as we
// pleased, and let it be flexible?
addNumbers(1, 2, 3, 4, 5, 6, 7);

function addNumbers(...numbers) {
  // ...code
}
```

The `spread` operator (`...array`) concatenates two arrays - flattening them out into one array with no nested arrays. This allows us to create clearer code that is a bit more obvious. It also allows for easier concatenation of more than 2 arrays, rather than chaining a bunch of `concat` methods. You can also add in single elements that aren't arrays.

```javascript
// let's say we want to join a list of things into a single array
const defaultColors = ['red', 'green'];
const userFavoriteColors = ['orange', 'yellow'];

defaultColors.concat(userFavoriteColors); // ['red', 'green', 'orange', 'yellow']

// ES6 equivalent:
[ ...defaultColors, ...userFavoriteColors ];

// also valid:
[ ...defaultColors, ...userFavoriteColors, "blue", "orange" ];
```

Another useful case might be as follows:

```javascript
// Always make sure we have "milk" on our shopping list.
function validateShoppingList(...items) {
  if (!items.includes("milk")) {
    return [ "milk", ...items ];
  }

  return items;
}

validateShoppingList("oranges", "bread", "eggs"); // ["milk", "oranges", "bread", "eggs"]
```

### Destructuring:

Destructuring is simply a new way to assign & declare variables based on an object's property names. It saves space & allows us to type less characters.

```javascript
// ES5 code
var expense = {
  type: "Business",
  amount: "$45 USD",
};

var type = expense.type;
var amount = expense.amount;

// ES6 - assigning properties from an object eliminating duplicate code
const { type } = expense;
const { amount } = expense;
// this is NOT creating new objects. The object must have identical property.

// Combined into a single line:
const { type, amount } = expense;
```

Another featuer of destructuring:

```javascript
// ES5
var savedFile = {
  extension: "jpg",
  name: "repost",
  size: 14040,
};

function fileSummary(file) {
  return `The file ${file.name}.${file.extension} is of size ${file.size}.`;
}

fileSummary(savedFile);

// ES6 w/destructuring:
// Pulls properties off of FIRST object that is passed in:
function fileSummary({ name, extension, size }) {
  return `The file ${name}.${extension} is of size ${size}.`;
}

// Use it with multiple objects:
function fileSummary({ name, extension, size }, { color }) {
  return `The ${color} file ${name}.${extension} is of size ${size}.`;
}
```

**Destructuring Arrays**

When we destructure object, we are pulling out properties. When we destructure arrays, we pull off inidividual elements.

```javascript
const companies = [
  "google",
  "facebook",
  "uber"
];

// use square brackets, not curly braces for elements.
const [name, name2] = companies; // "google"..."facebook" - the first result. The order remains

// Can also use it with properties of the arrays, since arrays are objects:
const { length } = companies; // 3

// Combine spread operator to get remaining elements:
const [ name, ...rest ] = companies;
rest; // ["facebook", "uber"]
```

**Destructuring Arrays / Objects At the Same Time**:

```javascript
const companies = [
  { name: "google", location: "mountain view", },
  { name: "facebook", location: "menlo park", },
  { name: "uber", location: "san francisco", },
];

// ES5
var location = companies[0].location;
location; // mountain view - not very pretty

// ES6
const [{ location }] = companies;
location; // mountain view

const Google = {
  locations: ["mountain view", "new york", "london"];
};

// getting an element from an array on a property inside an object:
const { locations: [ location ] } = Google;
locations; // mountain view
```

When might you use this?

When you destructure an object, the order of the arguments doesn't matter. With this in mind, if, for example, you had a function that took a lot of arguments, which over time could change, you could simply supply a destructured object to that function so that the function will still reference variable names inside itself, and you wouldn't need to remember what order to put the arguments. You could simply pass an object with the key/value pairs to the function upon invocation anywhere in the application, and modify the function to work with destructuring.

Another example problem with arrays: Using destructuring, take the given data structure of an array of arrays, and return an array of objects that contain the corresponding x/y coordinates, represented like `[ {x: 1, y: 1}, ...etc]`.

```javascript
const points = [
  [4, 5],
  [10, 1],
  [0, 40]
];

points.map(([x, y]) pair => { // destructure the data as arguments to the function
  return { x, y };  // improved object literal syntax to return the new object
});
```
**PROBLEM SET:**

This one is probably the hardest exercise in the entire course!

Use array destructuring, recursion, and the rest/spread operators to create a function 'double' that will return a new array with all values inside of it multiplied by two.  Do not use any array helpers! Sure, the map, forEach, or reduce helpers would make this extremely easy but give it a shot the hard way anyways :)

Input:

`double([1,2,3])`

Output

`[2,4,6]`

Hint: Don't forget that with recursion you must add a base case so you don't get an infinite call stack.  For example, if 'const [ number, ...rest ] = numbers' and number is undefined do you need to keep walking through the array?

```javascript
// my first solution:
const numbers = [1, 2, 3];

function double([ num1, ...rest ]) {
  let doubled = [];

  if (num1) {
    doubled = [ ...doubled, num1 * 2, ...double(rest) ];
  }

  return doubled;
}

double(numbers); // [2, 4, 6]

// Best one-line solution:
const double = ([ number, ...rest ]) => (rest.length ? [number*2, ...double(rest)] : [number*2]);

// solution:
const numbers = [1,2,3];

function double([num, ...rest]) {
    if (!num) { return []; }

    return [num * 2, ...double(rest) ];
}
```

### Classes

```javascript
// ES5 OOP
function Car(options) {
  this.title = options.title;
}

Car.prototype.drive = function() {
  return "vroom";
}

function Toyota(options) {
  Car.call(this, options);
  this.color = options.color;
}

Toyota.prototype = Object.create(Car.prototype);
Toyota.prototype.constructor = Toyota;

Toyota.prototype.honk = function() {
  return "beep";
}

const car = new Car({ title: "Focus" });
car.drive(); // vroom

const toyo = new Toyota({ color: "red", title: "Daily Driver" });
console.log(toyo) // {"color":"red", "title":"Daily Driver"}
toyo.honk     // "beep"
toyo.drive    // "vroom"

// ES6 Refactoring w/classes:
// use enhanced object literal syntax...no comma between elements / method def's
class Car {
  constructor(options) {  // or constructor ({ title }) - destructuring
    this.title = options.title; // or this.title = title;
  }

  drive() {
    return "vroom";
  }
}

class Toyota extends Car {
  constructor(options) {  // must provide all parameters needed for all classes up the "chain"
    super(options);       // calls Car's constructor method first with params
    this.color = options.color;
  }

  honk() {
    // super(); - could also call Car's same method name first
    return "beep";
  }
}

const car = new Car({ title: "Toyota" }); // instance of Car
car.drive(); // vroom

const toyo = new Toyota({ color: "red", title: "Daily Driver" });
toyo.honk();      // beep
toyo.drive();     // vroom
```

When would we use classes? ALL THE DAMNED TIME!

### Generators

More ways to iterate through collections

`for...of` = iterate through arrays of data. These have a tie into generators. Other helper methods are recommended for normal use. Stay tuned to see how these can tie together...

```javascript
const colors = ['red', 'green', 'blue'];

for (let color of colors) {
  console.log(color);
}
```

**Generators**: can be difficult to understand. A function that can be entered & exited multiple times. Normally, function run & return something & are done. With generators, we can run SOME code, return a value, then return to the function at the same place we left it.

Example syntax:

```javascript
function* numbers() { // notice the asterisk. It can also be `function *funcName`
  yield;
}

const gen = numbers();
gen.next();   // {"done": false}
gen.next();   // {"done": true}
```

An analogy of generators:

You're sitting there, hungry, so you decide to eat, but you need to get the food from the store.

- Start walking to the store
- Still walking...
- At the store. Going in w/some money...
  - Transition to the sidewalk into the store, with the money
  - Inside the store, you walk, check prices, buy some groceries
- Go back out of the store to the sidewalk. Now instead of cash, you have groceries.
- Walk back home on the sidewalk.

Note the transition from money into the store, then coming back out w/groceries...

```javascript
function* shopping() {
  // stuff on the sidewalk

  // walking down the sidewalk

  // go into the store w/cash
  const stuffFromStore = yield 'cash';

  // walking back home
  return stuffFromStore // final value = "groceries"
}

// stuff in the store
// No code is invoked here! Important to know. It's just returning an object!
const gen = shopping();

// First time this is called is when the function begins execution.
gen.next(); // leaving our house
// walked into store
// up & down isles
// purchase our stuff

gen.next('groceries'); // leaving the store w/groceries
```

As a further example, say you wanted to make a stop on your way home at the dry cleaner's. You can use multiple `yield`s inside the generator function. Note that you need to add another `gen.next();` in order to return execution back to the generator function.

**So why do we use this?**



```javascript
function* colors() {
  yield "red";
  yield "blue";
  yield "green";
}

const gen = colors();
// gen.next(); // execute code
// gen.next(); // value red, done: false
// gen.next(); // value blue, done: false
// gen.next(); // value green, done: true

const myColors = [];
for (let color of colors()) { // executed colors right away
  myColors.push(color);       // execute this code each time there's a yield
}

myColors; // ["red", "green", "blue"]
```

In the code above, you don't have to worry about the `.next()` call or anything. It just works. This structure allows us to iterate through **any type of data structure that we want**.

Practical Example: We want to interate over particular properties of an object, not all of them.

```javascript
// Object that represents engineering team
const engineeringTeam = {
  size: 3,
  department: "Engineering",
  lead: "Jill",
  manager: "Alex",
  engineer: "Dave",
};

// We want to iterate through all different employees (not other properties).
function* TeamIterator(team) {
  yield team.lead;
  yield team.manager;
  yield team.engineer;
}

const names = [];
for (let name of TeamIterator(engineeringTeam)) {
  names.push(name);
}
// ["Jill", "Alex", "Dave"]
```

### Combining multiple generators together - delegation of generators.

Going w/the example above, imagine we now have another property on the engineeringTeam object called `TestingTeam`, that has it's own `lead` & `tester`. We still want to be able to get a list of all employee names.

```javascript
const testingTeam = {
  lead: "Amanda",
  tester: "Bill",
};

const engineeringTeam = {
  testingTeam, // same as testingTeam: testingTeam. Convention is to keep at top of obj
  size: 3,
  department: "Engineering",
  lead: "Jill",
  manager: "Alex",
  engineer: "Dave",
};

// How might we combine these generator function to allow us to use 1 for..of loop?
// We use what's called generator delegation
function* TeamIterator(team) {
  yield team.lead;
  yield team.manager;
  yield team.engineer;

  const testingTeamGen = TestingTeamIterator(team.testingTeam);
  yield* testingTeamGen;
}

function* TestingTeamIterator(team) {
  yield team.lead;
  yield team.tester;
}

const names = [];
for (let name of TeamIterator(engineeringTeam)) {
  names.push(name);
}
// ["Jill", "Alex", "Dave", "Amanda", "Bill"]
```

The `yield*` syntax is saying "I'm inside a generator, and there is another generator with yield statements to see." The `yield*` is like a "trap door" that passes execution to the other generator you specify.

### Cleaning Up the Generator Code: symbol.interator

**Symbol Interator**: a tool that teaches objects how to respond to the `for..of` loop.

```javascript
const testingTeam = {
  lead: "Amanda",
  tester: "Bill",
  [Symbol.iterator]: function* () { // teach this object how to iterate using `for..of`
    yield this.lead;
    yield this.tester;
  },
};

const engineeringTeam = {
  testingTeam, // same as testingTeam: testingTeam. Convention is to keep at top of obj
  size: 3,
  department: "Engineering",
  lead: "Jill",
  manager: "Alex",
  engineer: "Dave",
  [Symbol.iterator]: function* () {
    yield this.lead;
    yield this.manager;
    yield this.engineer;
    yield* this.testingTeam; // better syntax, more concise. for..of falls into that object
  },
};

// don't need TeamIterator anymore!
// don't need TestingTeamIterator anymore!

const names = [];
for (let name of engineeringTeam) {
  names.push(name);
}
// ["Jill", "Alex", "Dave", "Amanda", "Bill"]
```

Notice the `[Symbol.iterator]` key above. With ES6, we can use *key interpolation* by wrapping a key with `[]`. What that does is create a dynamic key name. Then, using the `function*` makes it a generator function inside the object, so it knows how to handle a `for..of` loop.

### EX: Iterating through a DOM tree

This type of construct can be very useful for iterating through the DOM with the use of recursion. Take a nested comment structure on a site like Reddit, for example. We may want to iterate through a DOM with a tree that has an arbitrary depth:

> **NOTE**: array helpers / iterators DO NOT WORK inside generator functions. Whenever iterating through a collection, you need to use a `for..of` loop in a generator again.

```javascript
class Comment {
  constructor(content, children) {
    this.content = content;
    this.children = children;
  }

  *[Symbol.iterator]() {  // improved obj literal syntax for method inside class
    yield this.content;
    for (let child of this.children) {
      yield* child;
    }
  }
}

const children = [
  new Comment("good comment", []);
  new Comment("bad comment", []);
  new Comment("meh", []);
];
const tree = new Comment("great post!", children);

let values = [];
for (let value of tree) {
  values.push(value);
}

console.log(values); // Contains all the comments.
```

### Promises

Promises have been implemented by many 3rd-party libraries for a long time in Js, but now ES6 implements them natively. Remember that Js will execute code line-by-line, one after another *without waiting*. In cases where there might be long-executing code (like an AJAX request to an external URL), code immediately after that AJAX request would normally execute right away. This can cause undesired behaviors, like logging a `null` value of the AJAX return, since that request & variable assignment takes longer & the variable value hasn't yet been assigned.

This is what promises resolve. We want to access the result of a long-running operation after it's finished, and only then.

First, some terminology: Promise states:

- `unresolved`: waiting for something to finish (default)
- `resolved`: something finished & all went OK (success)
  - `then`: keyword to execute a callback(s) (is a property on an object)
- `rejected`: something finished, but something went bad (maybe request didn't execute, etc)
  - `catch`: keyword to execute callback(s)

Some example code:

```javascript
// create a new promise
// we decide when it's resolved or rejected w/two automatically provided
// arguments that are functions we can call.
const promise = new Promise( (resolve, reject) => {
  const request = new XMLHTTPRequest();
  // make request
  request.onLoad = () => {
    resolve();
  };
});
// Promise {<pending>}__proto__: Promise[[PromiseStatus]]: "pending"[[PromiseValue]]: undefined

// use `then` to execute one or more callbacks when Promise is "resolved"
promise
  .then( () => {  // could also be written as: then(() => console.log("this"))
    console.log("I'm finished.");
  }).then( () => {
    console.log("I ran, too, in order.");
  }).catch( () => {
    console.log("uh oh. rejected.");
  });
```

The most common way to use Promises is with the `fetch` handler in ES6. There are several complaints about this interface, so experienced devs recommend using a different AJAX library to handle requests.

```javascript
const url = "https://jsonplaceholder.typicode.com/posts/";

fetch(url) // returns a promise object that we can register .then/.catch on
  .then(response => response.json())
  // there is some amount of data passed to .then (response object)
  // doesn't contain the actual data OF the response, just the resp obj
  // You must manipulate the response to get the data.
  .then(data => console.log(data)) // do something w/data
  .catch(error => console.log(error)); // do something w/error data
```

> One of the big complaints, other than having to call `.json()` on the response object, is that when a request fails, the `fetch` interface DOES NOT enter the `.catch` method & execute code inside it. This is dissimilar to almost every other AJAX library. The only time it will enter `catch` is if the network request completely FAILS.
















