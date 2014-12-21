
class String
  def lchop
    self[1..-1]
  end
  def after(num)
    self[num..-1]
  end
  def before(num)
    self[0...num]
  end
  def last
    self[-1]
  end
  def first
    self[0]
  end
  def exists?
    !empty?
  end
end

refine String do
  def foo
    'ha ha ha'
  end
end

Nwords = Hash.new(0)

def words(text)
  text.scan(/\w+/)
end

def train(the_words)
  the_words.each do |word|
    Nwords[word] += 1
  end
end

def known(words)
  words.select{|word| Nwords[word] > 0 }
end



Alphabets = 'abcdefghijklmnopqrstuvwxyz'.split('')

def edits1(word)
  _ = deletes(word)    +
      transposes(word) +
      replaces(word)   +
      inserts(word)
  _.uniq
end

def deletes(word)
  splits2(word).map{|(p1, p2)| p1 + p2.lchop }
end

def transposes(word)
  splits12(word).map{|(p1, p2)| p1.chop + p2.first + p1.last + p2.lchop }
end

def replaces(word)
  splits2(word).map{|(p1, p2)| Alphabets.map{|al| p1 + al + p2.lchop }}.flatten
end

def inserts(word)
  splits(word).map{|(p1, p2)| Alphabets.map{|al| p1 + al + p2 } }.flatten
end



def splits12(word)
  splits(word).select{|parts| parts.first.exists? && parts.last.exists? }
end

def splits2(word)
  splits(word).select{|parts| parts.last.exists? }
end

def splits(word)
  (0..word.size).map{|i| [word.before(i), word.after(i) ] }
end



def known_edits2(word)
  known(edits2(word))
end

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
  p candidates.uniq
  candidates.max_by{|candidate| Nwords[candidate] }
end
