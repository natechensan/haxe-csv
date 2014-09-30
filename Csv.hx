/*
	Haxe CSV parser/writer. 

	Author: Nate Chen
	Date: 9/29/2014 11:32:02
*/

package csv;

class Csv{
	
	private var seperator:String;
	private var data:String;
	private var eol:String;
	private var i:Int;
	private var sepI:Int;
	private var buffer:StringBuf;
	private var arrayBuff:Array<String>;

	public function new(sep:String, ?endOfLine:String){
		seperator = sep;
		i = 0;
		sepI = 0;
		eol = endOfLine == null? '\n':endOfLine;   //default line breaker is \n
		buffer = new StringBuf();
		if(!validateSep()) throw "Seperator should have contain and only contain one or more than one of the same character.";
		if(sep.indexOf(eol) != -1 || sep.indexOf("\"") != -1) throw "Seperator should not contain end of line character nor quotation mark.";
		if(eol.length != 1) throw "end of line character should be just one character.";
	}

	public function setSeperator(sep:String):Void{
		seperator = sep;
	}

	public function getSeperator():String{
		return seperator;
	}

	public function setEol(eol:String):Void{
		this.eol = eol;
	}

	public function getEol():String{
		return eol;
	}

	//parse next line, return an iterator of the data
	private function parseLine():Iterator<String>{
		//initialization
		arrayBuff = new Array<String>();
		var quote = false;
		var lockCode = false;
		var codeCache = -1;
		var tmpStr = new StringBuf();
		sepI = 0;
		//iterate next line
		while(i < data.length){
			var code;
			if(!lockCode){
				code = data.charCodeAt(i++);
				codeCache = code;
			}
			else{
				code = codeCache;
				i++;
			}
			if(code == eol.charCodeAt(0)){
				if(!quote){
					pushIntoArray(buffer.toString());
					return arrayBuff.iterator();
				}
				else throw "String format error: "+buffer.toString(); //quotation unclosed
			}
			else if(code == '"'.code){
				if(quote){
					if(i < data.length && data.charCodeAt(i) == '"'.code){
						buffer.addChar('"'.code);
						i++;
					}
					else if(data.charCodeAt(i) == seperator.charCodeAt(0)){
						if(!lockCode) lockCode = true;
						if(sepI == seperator.length - 1){
							lockCode = false;
							pushIntoArray(buffer.toString());
							quote = false;
							i++;
						}
						else sepI++;
					}
					else if(data.charCodeAt(i) == eol.charCodeAt(0)){
						lockCode = false;
						pushIntoArray(buffer.toString());
						quote = false;
						i++;
					}
					else throw "String format error: "+buffer.toString(); //quotation unclosed, or seperator after quotation not long enough.
				}
				else{
					if(buffer.toString().length == 0){
						quote = true;
					}
					else throw "String format error: "+buffer.toString(); //has character between start of quotation and seperator.
				}
			}
			else{
				if(!quote && code == seperator.charCodeAt(0)){
					if(sepI == seperator.length - 1){
						pushIntoArray(buffer.toString());
					}
					else sepI++;
				}
				else{
					buffer.addChar(code);
				}
			}
		}
		pushIntoArray(buffer.toString());
		return arrayBuff.iterator();
	}

	//parse all, return an iterator of the iterators of each line. Pointer of data string remains unchanged.
	public function parse(csvString:String):Iterator<Iterator<String>>{
		data = csvString;
		var cachedIndex = i;
		i = 0;
		var arr = new Array<Iterator<String>>();
		while(i < data.length){
			arr.push(parseLine());
		}
		i = cachedIndex;
		return arr.iterator();
	}

	public function create(values:Array<Array<String>>):String{
		if(values.length < 1) throw "Invalid value.";
		for(v in 0...values.length){
			for(j in 0...values[v].length){
				var addQuote = values[v][j].indexOf(seperator.charAt(0)+"") > -1 || values[v][j].indexOf('"') > -1 || values[v][j].indexOf(eol) > -1? true:false;  //add quote if part of the seperator exists in the current string
				if(addQuote) buffer.addChar('"'.code);
				for(k in 0...values[v][j].length){
					var code = values[v][j].charCodeAt(k);
					if(code == '"'.code && addQuote){
						buffer.addChar(code);
					}
					buffer.addChar(code);
				}
				if(addQuote) buffer.addChar('"'.code);
				if(j < values[v].length - 1) buffer.add(seperator);
			}
			if(v < values.length - 1) buffer.add(eol);
		}
		var tmp = buffer.toString();
		buffer = new StringBuf();
		return tmp;
	}

	private inline function pushIntoArray(str:String):Void{
		sepI = 0;
		arrayBuff.push(str);
		buffer = new StringBuf();
	}

	private function validateSep():Bool{
		if(seperator.length == 1) return true;
		if(seperator.length < 1) return false;
		var char = seperator.charCodeAt(0);
		for(v in 1...seperator.length){
			if(char != seperator.charCodeAt(v)) return false;
		}
		return true;
	}
}