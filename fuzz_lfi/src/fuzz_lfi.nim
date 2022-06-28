import argparse
import puppy
import q
import std/[strutils, xmltree, strformat]

var
  url = ""
  wordlist = ""
  needle = ""
  htmlTag = ""

proc fuzz(url, payload, needle, htmlTag: string) = 
  let req = Request(
    url: parseUrl(url & payload),
    verb: "get"
  )
  let res = fetch(req)

  if not (needle in res.body):
    # echo req.url
    # echo res.body
    var
      pay = &"[+] {payload}" 
      doc = q(res.body)
      body = doc.select(htmlTag)[0].innerText.strip()
    echo pay
    echo body
    echo ""

proc run_fuzzer(url, wordlist, needle, htmlTag: string) = 
  let f = open(wordlist)
  defer: f.close()
  var 
    line: string
  while f.read_line(line):
    fuzz(url, line, needle, htmlTag)


when isMainModule:
  var p = newParser:
    help("fuzz LFI on a url")
    option("-u", "--url", help="url to fuzz",
                          default=some(""), required=true)
    option("-w", "--wordlist", help="wordlist to fuzz", 
                          default=some(""), required=true)
    option("-n", "--needle", help="needle to exclude values from",
                          default=some(""), required=true)
    option("-t", "--tag", help="taget html tag to find in the dom",
                          default=some(""), required=true)

  try:
    var opts = p.parse()
    url = opts.url
    wordlist = opts.wordlist
    needle = opts.needle
    htmlTag = opts.tag
  except ShortCircuit as e:
    if e.flag == "argparse_help":
      echo p.help
      quit(1)
  except UsageError:
    stderr.writeLine(getCurrentExceptionMsg())
    quit(1)
  

  run_fuzzer(url, wordlist, needle, htmlTag)