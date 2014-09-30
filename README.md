haxe-csv
========

A Csv parser/writer for Haxe programming language.

Haxe does not have a native Csv class, so I wrote this simple class for a recent Haxe project I'm working on. CSV has a performance advantage over XML.

Supports customized seperator and line-breaking character. 

The seperator should consist of repeating character. e.g. `;;;`, `000000`, `,`

This class tries to follow the custom of Haxe.xml. 

The implementation is slightly verbose. Looking for improvement in the future.

#Defining the CSV format:

A string that is accepted as CSV format by this class should comply with the common rules of CSV:
- Every field can be wrapped by quotes.
- If the current field contains special character(namely '"', end of line character or the character used by seperator string), the field must be wrapped by quotes.
- If a '"' is wrapped by quotes, it should have an additional '"' after it. e.g.: "King James ""the Great"" of England"
- No additional character is allowed after the closing quote, a string format error will raise. e.g.: 20;;;"King James ""the Greate"" of" England;;;Male  is not allowed.

#Using Csv:

Creating new Csv object:

```
var csv = new Csv(";;;");
```

Creating a CSV format string:

```
var str = csv.create([["John Smith", "29", "Male", "2039 Peachtree Cir, Decatur, GA, 30033", "\"The Captain\""]]);
trace(str);  //John Smith;;;29;;;Male;;;2039 Peachtree Cir, Decatur, GA, 30033;;;"""The Captain"""
```

Parsing a CSV string:

```
var iterator = csv.parse(str); // returns an iterator of the iterators of each line
```

#API

`public function new(sep:String, ?endOfLine:String){}`

`sep` is the string seperator that seperates different fields. Should consist of the same character.
`endOfLine` is optional. It is one character that marks the end of a line. Default is `\n`.
The seperator string should not contain the end of line character.

`public function parse(csvString:String):Iterator<Iterator<String>>{}`

returns the an iterator of the iterators of each line. This is to follow the custom from Haxe.Xml.

`public function create(values:Array<Array<String>>):String{}`

returns a CSV format string that complied the rules defined above.
values must be a 2-D array of strings.

```
private eol:String; //end of line
private seperator:String; //seperator
```

Above two fields each have its getter and setter function. e.g.: `getEol()`, `setSeperator()`