std:

{
    inherit (import ./lib.nix std)
        attrsetFromEachThemeEachHost
        fishTerminalColor
        optionalPath;

    inherit (import ./escape.nix std)
        bashEscape
        bashString
        breEscape
        escapeBREScript
        escapeSEDScript
        fishEscape
        fishString
        sedEscape;

    inherit (import ./template.nix std)
        replace
        sedScript;
}