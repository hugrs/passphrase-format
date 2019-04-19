require 'securerandom'
require 'optparse'
require 'ostruct'
require 'stringio'

SEP = '\\'
DEFAULTS = {
  wordlist: 'eff_large_wordlist.txt',
  symbols: %q(!'@#$%&*-_=+/:.,";?),
  format: "#{SEP}w #{SEP}w #{SEP}w #{SEP}w #{SEP}w"
}

def nb_lines(filename)
  File.foreach(filename).inject(0) {|acc, line| acc += 1}
end

class Token
  def resolve
    pick_random
  end
end

class ConstantToken < Token
  def initialize(value)
    @value = value
  end

  def resolve
    @value.to_s
  end
end

def dice_roll
  1 + SecureRandom.random_number(6)
end

class RandomDigit < Token
  def pick_random
    SecureRandom.random_number(10).to_s
  end
end

class SymbolList < Token
  def initialize(list)
    @symbol_list = list
  end

  def pick_random
    @symbol_list[SecureRandom.random_number(@symbol_list.length)]
  end
end

class WordList < Token
  def initialize(wordlist)
    @wordlist = wordlist
  end

  def pick_random
    File.open(@wordlist, 'r') {|file|
      # Pick a random number N then read N lines from the file
      SecureRandom.random_number(nb_lines @wordlist).times { file.readline }
      # Return the next line
      file.readline.split("\t")[1].strip
    }
  end

  def pick_random_with_dice
    result = ''
    File.open(@wordlist, 'r') {|file|
      # Roll the dices!
      dice_result = ''
      5.times do
        dice_result << dice_roll.to_s
      end

      file.each do |line|
        result = line.split("\t")[1].strip if line[0..4] == dice_result
      end
    }
    result
  end
end

class PassphraseGenerator
  def initialize(options)
    @format = options.format
    @tokens = {
      'w' => WordList.new(options.wordlist),
      's' => SymbolList.new(options.symbol_list),
      'd' => RandomDigit.new,
      SEP => ConstantToken.new(SEP)
    }
  end

  def generate
    result = ''
    StringIO.open(@format) {|formatIO|
      formatIO.each_char do |char|
        if char == '\\'
          ### TODO: handle format error
          # Consume the next character
          token = formatIO.readchar
          result << @tokens[token].resolve
        else
          result << char
        end
      end
    }
    result
  end
end

class CommandParser
  def self.parse(args)
    options = OpenStruct.new
    options.format      = DEFAULTS[:format]
    options.wordlist    = DEFAULTS[:wordlist]
    options.symbol_list = DEFAULTS[:symbols]

    puts "WARNING: No options provided! Using default parameters.\nSee --help for more information.\n\n" if ARGV.empty?

    opt_parser = OptionParser.new {|opts|
      opts.banner = "Usage: #{File.basename($0)} [options]"

      #opts.separator ""
      #opts.separator "Specific options:"

      # Mandatory argument.
      opts.on("-F", "--format FORMAT",
          "Specify the format of the generated passphrase",
          "\tdefault\: #{options.format}",
          "available flags are:",
          "#{SEP}w => a word from the wordlist",
          "#{SEP}d => a digit [0-9]",
          "#{SEP}s => a symbol from the string SYMBOLS") do |format|
        options.format = format
      end

      opts.on("-W", "--wordlist PATH/TO/WORDLIST",
          "Pick words from the specified wordlist") do |list|
        options.wordlist = list
      end

      opts.on("-s", "--symbols SYMBOLS",
          "Specify a string of symbols to pick from",
          "\tdefault\: #{options.symbol_list}") do |list|
        options.symbol_list = list
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    }
    opt_parser.parse!(args)
    options
  end
end

options = CommandParser.parse(ARGV)
puts PassphraseGenerator.new(options).generate
