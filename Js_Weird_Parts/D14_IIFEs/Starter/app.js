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
// in the above code, whatever the return value of the anonymous IIFE is what
// `greeting` will be set to.

3; // perfectly valid code (but looks strange) - a valid Js expression





