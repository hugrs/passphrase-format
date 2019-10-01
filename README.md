# passphrase-format

```
Usage: generate.rb [options]

Options:
    -F FORMAT                        Specify the format of the generated passphrase
                                     	(default: '(/w )*6)'
                                     available flags are:
                                     /w => a word from the wordlist
                                     /d => a digit [0-9]
                                     /s => a symbol from the string SYMBOLS
                                     /S => a symbol or a digit
                                     /a => a random character (letter, digit or symbol)
                                     Example: 'pass/d/d/d_/w /w /w'
    -w PATH/TO/WORDLIST              Pick words from the specified wordlist
                                     	(default: eff_large_wordlist.txt)
    -s SYMBOLS                       Specify a string of symbols to pick from
                                     	(default: !'@#$%&*-_=+/:.,";?~)
    -c N                             Number of passphrases to generate
    -h, --help                       Show this message
```

This tool generates passphrases based on a format string, similar to the printf syntax.

Examples:
```
./generate.rb -F '/w /w /w /w /w /w'
pancake salute ducky corral uncloak graded
```

```
./generate.rb -F '(/w/s )*4'
creasing% emoticon& humped" overrun&
```

```
./generate.rb -F '/d*10'   
4276471160
```
