import std.stdio;
import std.string;
import yeti16.computer;
import yeti16.diskUtils;
import yeti16.assembler.assembler;

const string appHelp = "
YETI-16 beta 1.4.0

Usage: %s {operation} [args]

Operations:
	asm {file} [-o {file}]
		Compiles an assembly file to machine code

		Flags:
		    -o : Sets output binary file
		    -t : Show lexer output
		    -a : parser output
		    -l : Show label addresses

	run {file}
		Runs the given file in the emulator

		Flags:
		    -d {file} : Adds a disk

	new_disk {file} {size}
		Creates a disk of {size} sectors and saves it in {file}
";

int main(string[] args) {
	assert(args.length > 0);

	if (args.length == 1) {
		writefln(appHelp.strip(), args[0]);
		return 0;
	}

	switch (args[1]) {
		case "asm": {
			return AssemblerCLI(args[2 .. $]);
		}
		case "run": {
			return ComputerCLI(args[2 .. $]);
		}
		case "new_disk": {
			return CreateDiskCLI(args[2 .. $]);
		}
		case "version":
		case "--version":
		case "help":
		case "--help": {
			writefln(appHelp.strip(), args[0]);
			return 0;
		}
		default: {
			stderr.writefln("Unknown operation '%s'", args[1]);
			return 1;
		}
	}
}
