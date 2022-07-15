{
    pkgs,
    flakeRoot,
    hostOptions,
    ...
}@args:

let
    std = args.lib;
    lib = import (flakeRoot + /lib) std;

    inherit (builtins)
        elem
        toString
        readFile;

    inherit (lib)
        fishTerminalColor
        id
        replace;
    
    font = "Fira Code";
in
{
    imports = [
        ./xmonad.nix
        ./theme.nix

        # Roles.
        ./laptop.nix
        ./bluetooth.nix
    ];

    console.keyMap = "sv-latin1";

    security = {
        sudo.enable = false;
        doas.enable = true;
    };

    services = {
        xserver = {
            enable = true;
            
            layout = "se";

            windowManager._xmonad = {
                enable = true;
            };
        };

        pipewire = {
            enable = true;
            alsa.enable = true;
            pulse.enable = true;
        };
    };

    environment.systemPackages = with pkgs; [
        git
        gcc
        tree
        killall
        bat
        firefox
        feh
        alacritty
        fish
        pavucontrol
        unzip
        xclip

        imagemagick

        (neovim { bin = with pkgs; [
            # nvim-tresitter dependencies
            coreutils
            gnutar
            gzip
            curl
            git
            gcc
        ]; })
    ];

    fonts.fonts = with pkgs; [
        font-awesome
        (fira-code-with-features { features = [
            "cv01"
            "cv02"
            "cv06"
            "cv11"
            "ss05"
            "ss03"
        ]; })
    ];

    programs = {
        ssh = {
            startAgent = true;
        };
    };

    users.users = {
        aery = {
            isNormalUser = true;

            # Explicitly define home.
            createHome = true;
            home = "/home/aery";

            packages = with pkgs; [
                neofetch
                figlet
                tty-clock
                fortune
                cowsay
                lolcat
                cbonsai
                cmatrix
                pipes
            ];

            extraGroups = [
                "wheel"
                "networkmanager"
            ];
        };
    };

    theme.dotfilesFn =
        pkgs.dotfiles
        {
            inherit lib;
            src = flakeRoot + /dotfiles;
            files = {
                ".config/alacritty/alacritty.yml".subs = theme:
                    let
                        size =
                            if (elem "laptop" hostOptions.roles)
                            then 6
                            else 11;
                    in
                        theme //
                        {
                            inherit font; 
                            fish = toString pkgs.fish;
                            size = toString size;
                        };

                ".config/fish/config.fish".subs = theme:
                    { primary = fishTerminalColor theme.primaryTerminalColor; };

                ".xmonad/lib/Theme.hs".subs = theme:
                    theme //
                    { inherit font; };

                ".config/xmobar/.xmobarrc".subs = theme:
                    theme //
                    { inherit font; };

                ".config/nvim/init.lua".subs = _:
                    let
                        neovim-pack =
                            pkgs.neovim-pack
                            {
                                start = with pkgs.vimPlugins; [
                                    nvim-treesitter
                                    nvim-ts-rainbow
                                    nvim-autopairs
                                    indent-blankline-nvim
                                ];
                            };
                    in
                    { packpath = toString neovim-pack; };
            };
        };

    # Installing Nix flakes system-wide.
    # https://nixos.wiki/wiki/Flakes
    nix = {
        package = pkgs.nixFlakes;
        extraOptions = ''
            experimental-features = nix-command flakes
        '';
    };
}
