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
