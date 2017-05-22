var person = {};
// this is object literal notation; the same as `new Object();`

var patrick = { 
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
