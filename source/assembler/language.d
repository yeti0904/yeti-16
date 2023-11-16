module yeti16.assembler.language;

class Language {
	static const string[] registers = [
		"a", "b", "c", "d", "e", "f", "h", "i"
	];

	static const string[] registerPairs = [
		"ab", "cd", "ef", "ds", "sr", "bs", "sp", "ip", "hi"
	];
}
