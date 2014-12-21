
Nwords = Hash.new(0)

# extract words from given text
def words(text)
  text.scan(/\w+/)
end

# builds a word to frequency hash using the given word
def train(the_words)
  the_words.each do |word|
    Nwords[word] += 1
  end
end

def known(words)
  words.select{|word| Nwords[word] > 0 }
end



Alphabets = 'abcdefghijklmnopqrstuvwxyz'.split('')

# All words at an edit distance of 1 from the given word
def edits1(word)
  _ = deletes(word)    +
      transposes(word) +
      replaces(word)   +
      inserts(word)
  _.uniq
end

# All words obtained by removing a letter at a time
def deletes(word)
  splits(word)
    .select {|(p1, p2)| p2.size > 0  }
    .map{|(p1, p2)| p1 + p2[1..-1] }
end

# All words obtained by transposing adjacent letters
def transposes(word)
  splits(word)
    .select{|(p1, p2)| p1.size > 0 && p2.size > 0 }
    .map{|(p1, p2)| p1.chop + p2[0].to_s + p1[-1] + p2[1..-1] }
end

# All words obtained by changing one letter at a time with another letter from alphabets
def replaces(word)
  splits(word)
    .select{|(p1, p2)| p2.size > 0 }
    .map{|(p1, p2)| Alphabets.map{|al| p1 + al + p2[1..-1]}}.flatten.uniq
end

# All words obtained by adding one letter of the alphabets at a time
def inserts(word)
  splits(word).map{|(p1, p2)| Alphabets.map{|al| p1 + al + p2 } }.flatten.uniq
end

def splits(word)
  (0..word.size).map{|i| [word[0...i], word[(i..-1)]] }
end

# known words among edits2
def known_edits2(word)
  known(edits2(word))
end

# All words at an edit distance of 2
# Call edit1 on each result of edit1(word)
def edits2(word)
  edits1(word).map{|e1_word| edits1(e1_word)}.flatten.uniq
end



def setup
  train(words(File.read('./big.txt')))
  nil
end

def correct(word)
  candidates = known([word])       +
               known(edits1(word)) +
               known_edits2(word)  +
               [word]
  p candidates
  candidates.max_by{|candidate| Nwords[candidate] }
end
