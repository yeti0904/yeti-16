module yeti16.assembler.parser;

import std.conv;
import std.stdio;
import std.format;
import yeti16.assembler.error;
import yeti16.assembler.lexer;

enum NodeType {
	Null,
	Instruction,
	Label,
	Macro,
	Identifier,
	Register,
	RegisterPair,
	Integer,
	String
}

class Node {
	NodeType  type;
	ErrorInfo error;
}

class InstructionNode : Node {
	string name;
	Node[] params;

	this(string pname, ErrorInfo perror) {
		type  = NodeType.Instruction;
		name  = pname;
		error = perror;
	}

	override string toString() {
		string ret = "    " ~ name;

		foreach (ref param ; params) {
			ret ~= ' ' ~ param.toString();
		}

		return ret;
	}
}

class LabelNode : Node {
	string name;

	this(string pname, ErrorInfo perror) {
		type  = NodeType.Label;
		name  = pname;
		error = perror;
	}

	override string toString() {
		return format("%s:", name);
	}
}

class MacroNode : Node {
	string name;
	Node   value;

	this(string pname, ErrorInfo perror) {
		type  = NodeType.Macro;
		name  = pname;
		error = perror;
	}

	override string toString() {
		return format("%s:", name);
	}
}

class IdentifierNode : Node {
	string name;

	this(string pname, ErrorInfo perror) {
		type  = NodeType.Identifier;
		name  = pname;
		error = perror;
	}

	override string toString() {
		return name;
	}
}

class RegisterNode : Node {
	string name;

	this(string pname, ErrorInfo perror) {
		type  = NodeType.Register;
		name  = pname;
		error = perror;
	}

	override string toString() {
		return name;
	}
}

class RegisterPairNode : Node {
	string name;

	this(string pname, ErrorInfo perror) {
		type  = NodeType.RegisterPair;
		name  = pname;
		error = perror;
	}

	override string toString() {
		return name;
	}
}

class IntegerNode : Node {
	int value;

	this(int pvalue, ErrorInfo perror) {
		type  = NodeType.Integer;
		value = pvalue;
		error = perror;
	}

	override string toString() {
		return text(value);
	}
}

class StringNode : Node {
	string value;

	this(string pvalue, ErrorInfo perror) {
		type  = NodeType.String;
		value = pvalue;
		error = perror;
	}

	override string toString() {
		return format("\"%s\"", value);
	}
}

class ParserFail : Exception {
	this(string msg = "", string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

class Parser {
	size_t  i;
	Node[]  nodes;
	Token[] tokens;
	bool    success;

	this() {

	}

	ErrorInfo CurrentError() {
		return ErrorInfo(tokens[i].file, tokens[i].line);
	}

	void Next() {
		++ i;

		if (i >= tokens.length) {
			assert(0);
		}
	}

	void Error(string str) {
		ErrorBegin(CurrentError());
		stderr.writeln(str);
	}

	Node ParseParameter() {
		switch (tokens[i].type) {
			case TokenType.Identifier: {
				return new IdentifierNode(tokens[i].contents, CurrentError());
			}
			case TokenType.Register: {
				return new RegisterNode(tokens[i].contents, CurrentError());
			}
			case TokenType.RegisterPair: {
				return new RegisterPairNode(tokens[i].contents, CurrentError());
			}
			case TokenType.Integer: {
				return new IntegerNode(parse!int(tokens[i].contents), CurrentError());
			}
			case TokenType.String: {
				return new StringNode(tokens[i].contents, CurrentError());
			}
			case TokenType.Hex: {
				return new IntegerNode(
					to!int(tokens[i].contents[2 .. $], 16), CurrentError()
				);
			}
			case TokenType.Binary: {
				return new IntegerNode(
					to!int(tokens[i].contents[2 .. $], 2), CurrentError()
				);
			}
			case TokenType.Label: {
				Error("Cannot use label statement as parameter");
				throw new ParserFail();
			}
			default: assert(0);
		}
	}

	Node ParseStatement() {
		switch (tokens[i].type) {
			case TokenType.Label: {
				return new LabelNode(tokens[i].contents, CurrentError());
			}
			case TokenType.Identifier: {
				auto ret = new InstructionNode(tokens[i].contents, CurrentError());

				Next();

				while (tokens[i].type != TokenType.End) {
					ret.params ~= ParseParameter();
					Next();
				}
				return ret;
			}
			case TokenType.Macro: {
				Next();

				auto ret = new MacroNode(tokens[i].contents, CurrentError());

				Next();

				ret.value = ParseParameter();
				Next();

				if (tokens[i].type != TokenType.End) {
					assert(0); // TODO: Error
				}
				return ret;
			}
			case TokenType.End: return null;
			default: {
				stderr.writefln("ParseStatement: Unexpected type %s", tokens[i].type);
				assert(0);
			}
		}
	}

	void Parse() {
		success = true;
		
		for (i = 0; i < tokens.length; ++ i) {
			Node node;

			try {
				node = ParseStatement();
			}
			catch (ParserFail) {
				success = false;
				return;
			}

			if (node !is null) {
				nodes ~= node;
			}
		}
	}

	void PrintNodes() {
		foreach (ref node ; nodes) {
			writeln(node);
		}
	}
}
