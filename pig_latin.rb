class PigLatin
  VOWELS = %w{a e i o u}

  def self.translate(words)
    pig_latin_words = []

    words.split(" ").each do |word|
      pig_latin_words << pig_latin(word)
    end

    pig_latin_words.join(" ")
  end

  def self.pig_latin(word)
    letter_array = word.chars
    first_letter = letter_array.first

    if VOWELS.include? first_letter
      word + "ay"
    else
      (shift_consonants(letter_array) << "ay").join("")
    end
  end

  def self.shift_consonants(letter_array)
    counter = 0

    letter_array.each do |letter|
      break if VOWELS.include? letter
      counter += 1
    end
    letter_array.rotate(counter)
  end
end

# Rule 1: If a word begins with a vowel sound, add an "ay" sound to the end of the word.
# Rule 2: If a word begins with a consonant sound, move it to the end of the word, and then add an "ay" sound to the end of the word.