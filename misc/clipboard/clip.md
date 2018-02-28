
```javascript
var $message = $('#message');
var $letters = $('#spaces');
var $guesses = $('#guesses');
var $apples = $('#apples');
var $replay = $('#replay');

var randomWord = (function() {
  var words = ['abacus', 'quotient', 'octothorpe', 'proselytize', 'stipend'];

  function without() {
    var newArr = [];
    var args = Array.prototype.slice.call(arguments);
    words.forEach(function(el) {
      if (args.indexOf(el) === -1) {
        newArr.push(el);
      }
    });

    return newArr;
  }

  return function() {
    var word = words[Math.floor(Math.random() * words.length)];
    words = without(word);
    return word;
  };
})();

var Game = {
  guesses: 6,
  createBlanks: function() {
    var spaces = (new Array(this.word.length + 1)).join('<span></span>');
    $letters.find('span').remove();
    $letters.append(spaces);
    this.$spaces = $('#spaces span');
  },
  fillBlanksFor: function(letter) {
    var self = this;
    self.word.forEach(function(l, i) {
      if (letter === l) {
        self.$spaces.eq(i).text(letter);
        self.correctSpaces++;
      }
    });
  },
  processGuess: function(e) {
    var letter = String.fromCharCode(e.which);
    if (notALetter(e.which)) {
      return;
    }

    if (this.duplicateGuess(letter)) {
      return;
    }

    if ($.inArray(letter, this.word) !== -1) {
      this.fillBlanksFor(letter);
      this.renderGuess(letter);
      if (this.correctSpaces === this.$spaces.length) {
        this.win();
      }
    } else {
      this.renderIncorrectGuess(letter);
    }

    if (this.incorrect === this.guesses) {
      this.lose();
    }
  },
  win: function() {
    this.unbind();
    this.displayMessage('You win!');
    this.toggleReplayLink(true);
    this.setGameStatus('win');
  },
  lose: function() {
    this.unbind();
    this.displayMessage('Sorry! You\'re out of guesses');
    this.toggleReplayLink(true);
    this.setGameStatus('lose');
  },
  duplicateGuess: function(letter) {
    var duplicate = this.lettersGuessed.indexOf(letter) !== -1;
    if (!duplicate) {
      this.lettersGuessed.push(letter);
    }

    return duplicate;
  },
  renderIncorrectGuess: function(letter) {
    this.incorrect++;
    this.renderGuess(letter);
    this.setClass();
  },
  setClass: function() {
    $apples.removeClass().addClass('guess_' + this.incorrect);
  },
  renderGuess: function(letter) {
    $('<span />', {
      text: letter
    }).appendTo($guesses);
  },
  displayMessage: function(text) {
    $message.text(text);
  },
  toggleReplayLink: function(which) {
    $replay.toggle(which);
  },
  emptyGuesses: function() {
    $guesses.find('span').remove();
  },
  unbind: function() {
    $(document).unbind('.game');
  },
  bind: function() {
    $(document).on('keypress.game', this.processGuess.bind(this));
  },
  setGameStatus: function(status) {
    $(document.body).removeClass();
    if (status) {
      $(document.body).addClass(status);
    }
  },
  init: function() {
    this.incorrect = 0;
    this.word = randomWord();

    if (!this.word) {
      this.displayMessage('Sorry, I\'ve run out of words!');
      this.toggleReplayLink(false);
      return this;
    } else {
      this.word = this.word.split('');
      this.lettersGuessed = [];
      this.correctSpaces = 0;
    }

    this.bind();
    this.setClass();
    this.toggleReplayLink(false);
    this.emptyGuesses();
    this.createBlanks();
    this.setGameStatus();
    this.displayMessage('');
    return this;
  }
};

function notALetter(code) {
  var aCode = 97;
  var zCode = 122;

  return code < aCode || code > zCode;
}

var game = Object.create(Game).init();

$replay.on('click', function(e) {
  e.preventDefault();
  game = Object.create(Game).init();
});
```

```javascript

        var pointA = {
          x: 30,
          y: 40,

          onXAxis: function() {
            return this.y === 0;
          },
        
          onYAxis: function() {
            return this.x === 0;
          },
        
          distanceToOrigin:  function() {
            return Math.sqrt((this.x * this.x) + (this.y * this.y));
          }
        };
        
        pointA.distanceToOrigin();      // 50
        pointA.onXAxis();               // false
        pointA.onYAxis();               // false
```

