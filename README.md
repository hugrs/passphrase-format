# passphrase-format

```
Usage: generate.rb [options] <format>

<format>: Specify the format of the generated passphrase (default: "(/w )*6")
Available tokens are:
  /w => a word from the wordlist
  /d => a digit [0-9]
  /s => a symbol from the string SYMBOLS
  /S => a symbol or a digit
  /a => a random character (letter digit or symbol)
Example: "pass/d/d/d_/w" yields "pass107_recopy"

Tokens or groups of tokens can be repeated using the syntax ()*N 
where N is the amount of repetitions.
Example: "(/w/d)*3" yields "faster4employer0rectified3"

Options:
    -w path/to/wordlist              Pick words from the specified wordlist
                                     	(default: /home/hugo/Workspace/passphrase-format/eff_large_wordlist.txt)
    -s symbols                       Specify a string of symbols to pick from
                                     	(default: !@#$%^&*-_=+;:'",./<>?~)
    -c N                             Number of passphrases to generate
    -h, --help                       Show this message
```

This tool generates passphrases based on a format string, similar to the printf syntax.

Examples:
```
./generate.rb "/w /w /w /w /w /w"
pancake salute ducky corral uncloak graded
```

```
./generate.rb "(/w/s )*4"
creasing% emoticon& humped" overrun&
```

```
./generate.rb "/d*10"
4276471160
```
