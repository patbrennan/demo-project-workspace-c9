function greet(name) {
  console.log("Hello " + name); // coerces the variable `name` to a string of `undefined`
}

greet();


function greet(name) {
  name = name || "<your name here>"; // name is `undefined`
  console.log("Hello " + name);
}

greet();

