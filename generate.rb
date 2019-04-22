#!/usr/bin/env ruby
require 'securerandom'
require 'optparse'
require 'ostruct'
require 'stringio'


DLM = '\\'  # Token delimiter
DEFAULTS = {
  wordlist: 'eff_large_wordlist.txt',
  symbols: %q(!'@#$%&*-_=+/:.,";?),
  format: "#{DLM}w #{DLM}w #{DLM}w #{DLM}w #{DLM}w #{DLM}w",
  count: 1
}


def nb_lines(filename)
  File.foreach(filename).inject(0) {|acc, line| acc += 1}
end

def dice_roll
  1 + SecureRandom.random_number(6)
end


class TokenError < RuntimeError
end

# Inherit this class to define new tokens
class Token
  def replace
    # Default behaviour is to pick a random element from the subclass
    pick_random
  end
end

# A token that is replaced by a constant string, for literal values or escaping
class ConstantToken < Token
  def initialize(value)
    @value = value
  end

  def replace
    @value.to_s
  end
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

  # Only works with a dice based wordlist
  def pick_random_with_dice
    result = ''
    File.open(@wordlist, 'r') {|file|
      # Roll the dices!
      dice_result = ''
      5.times do
        dice_result << dice_roll.to_s
      end

      file.each do |line|
        # match the line with the rolled number
        result = line.split("\t")[1].strip if line[0..4] == dice_result
      end
    }
    result
  end
end

class PassphraseGenerator
  def initialize(options)
    @format = options.format
    # Change this to support more tokens
    @tokens = {
      'w' => WordList.new(options.wordlist),
      's' => SymbolList.new(options.symbol_list),
      'd' => RandomDigit.new,
      DLM => ConstantToken.new(DLM)
    }
  end

  def generate
    result = ''
    StringIO.open(@format) {|formatIO|
      formatIO.each_char do |char|
        # look for token delimiters in the format string
        if char == DLM
          token = formatIO.readchar
          # Raise an error if the token is not supported
          raise TokenError.new("Unrecognized token: #{DLM}#{token}\n"\
              "See --help for supported format flags.") if !@tokens.key?(token)
          result << @tokens[token].replace
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
    options.count       = DEFAULTS[:count]

    puts "WARNING: No options provided! Using default parameters.\n"\
      "See --help for more information.\n\n" if ARGV.empty?

    opt_parser = OptionParser.new {|opts|
      opts.banner = "Usage: #{File.basename($0)} [options]"
      opts.separator ""
      opts.separator "Options:"

      opts.on("-F", "--format FORMAT",
          "Specify the format of the generated passphrase",
          "\t(default\: #{options.format})",
          "available flags are:",
          "#{DLM}w => a word from the wordlist",
          "#{DLM}d => a digit [0-9]",
          "#{DLM}s => a symbol from the string SYMBOLS",
          "Example: 'pass#{DLM}d#{DLM}d#{DLM}d_#{DLM}w #{DLM}w #{DLM}w'") do |format|
        options.format = format
      end

      opts.on("-w", "--wordlist PATH/TO/WORDLIST",
          "Pick words from the specified wordlist",
          "\t(default\: #{options.wordlist})") do |list|
        options.wordlist = list
      end

      opts.on("-s", "--symbols SYMBOLS",
          "Specify a string of symbols to pick from",
          "\t(default\: #{options.symbol_list})") do |list|
        options.symbol_list = list
      end

      opts.on("-c", "--count N",
          "Number of passphrases to generate") do |count|
        options.count = count.to_i
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
begin
  generator = PassphraseGenerator.new(options)
  # Generate <count> passphrases
  options.count.times do
    puts generator.generate
  end
rescue TokenError => e
  puts "ERROR: #{e.message}"
end
