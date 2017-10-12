(function(global, jQuery) {
 
 // Returns an object using the `new` keyword, which in turn sets its prototype
 var Greetr = function(firstName, lastName, language) {
   return new Greetr.init(firstName, lastName, language);
 };
 
 // These are private variables; hidden in the scope of this IIFE
 var supportedLangs = ['en', 'es', 'eb'];
 
 // informal
 var greetings = {
   en: "Hello",
   es: "Hola",
   eb: "Sup, Little",
 };
 
 // formal
 var formalGreetings = {
   en: "Greetings",
   es: "Saludos",
   eb: "Yo Yo Yo, Big",
 };
 
 // logger for the console
 var logMessages = {
   en: "Logged in",
   es: "Inicio sesion.",
   eb: "Lil Boo logged in, yo."
 };

 Greetr.prototype = {
    fullName: function() {
      return this.firstName + " " + this.lastName;
    },
    
    // make sure selected language is actually supported
    validate: function() {
      if (!supportedLangs.includes(this.language)) {
        throw "Invalid Language";
      }
    },
    
    greeting: function() {
      return greetings[this.language] + " " + this.firstName + "!";
    },
    
    formalGreeting: function() {
      return formalGreetings[this.language] + ", " + this.fullName();
    },
    
    greet: function(formal) {
      var msg;
      
      // if undefined or null it will be coerced to 'false'
      if (formal) {
        msg = this.formalGreeting();
      } else {
        msg = this.greeting();
      }
      
      if (console) {
        console.log(msg);
      }
      
      // `this` refers to the calling object at execution time, which makes
      // the method chainable.
      return this;
    },
    
    log: function() {
      if (console) {
        console.log(logMessages[this.language] + ":" + this.fullName());
      }
      
      return this;
    },
    
    setLang: function(lang) {
      this.language = lang;
      
      this.validate();
      return this;
    },
    
    // Uses jQuery to select an element & insert the greeting
    insertGreeting: function(cssSelector, formal) {
      if (!jQuery) {
        throw "jQuery not loaded";
      }
      if (!cssSelector) {
        throw "Missing jquery selector.";
      }
      
      jQuery(cssSelector).innerText = this.greet(formal);
      return this;
    },
 };
 
 // Returns a function so that it can be used as such... G$(params);
 Greetr.init = function(firstName, lastName, language) {
   var self = this;
   
   self.firstName = firstName || "";
   self.lastName = lastName || "";
   self.language = language || "en";
   
   self.validate();
 };
 
 // The prototype of the init function is the Greetr proto, where all functionality
 // is defined.
 Greetr.init.prototype = Greetr.prototype;
 
 // Exposes the Greetr Object ( and G$ alias ) to the global scope
 global.Greetr = global.G$ = Greetr;
  
})(window, $);