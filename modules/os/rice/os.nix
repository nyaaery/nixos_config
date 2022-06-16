{ pkgs, themeExpr, ... }@args:

let
    flakeRoot = ../../..;
    dotfiles = flakeRoot + /dotfiles;
    std = args.lib;
    lib = import (flakeRoot + /lib) std;

    inherit (lib)
        fishTerminalColor;
in
{
    services.xserver = {
        enable = true;

        displayManager = {
            session = [{
                manage = "desktop";
                name = "home-manager";
                start = ''
                    ${pkgs.runtimeShell} $HOME/.xsession &
                    waitPID=$!
                '';
            }];

            defaultSession = "home-manager";

            autoLogin = {
                enable = true;
                user = "aery";
            };
        };

        layout = "se";
    };

    environment.systemPackages = with pkgs; [
        git
    ];

    home-manager.users = {
        aery = {
            xsession = {
                enable = true;
                
                # Restore feh wallpaper
                initExtra = ''
                    ${pkgs.runtimeShell} $HOME/.fehbg &
                '';

                windowManager.xmonad = {
                    enable = true;

                    config = dotfiles + /.xmonad/xmonad.hs;
                    libFiles = {
                        "Theme.hs" = pkgs.writeText "Theme.hs" ''
                            module Theme where

                            themeForeground :: String
                            themeForeground = "${themeExpr.foreground}"

                            themeBackground :: String
                            themeBackground = "${themeExpr.background}"

                            themePrimary :: String
                            themePrimary = "${themeExpr.primary}"
                        '';
                    };
                    extraPackages = haskellPackages: with haskellPackages; [
                        xmonad-contrib
                    ];
                };
            };

            home = {
                username = "aery";
                homeDirectory = "/home/aery";

                packages = with pkgs; [
                    firefox
                    tree
                    killall

                    xmobar
                    feh

                    alacritty
                    fish

                    # Rice command line utilities.
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

                file = {
                    ".config/fish/config.fish" = {
                        text = ''
                            # Remove greeting.
                            set -U fish_greeting

                            function fish_prompt
                                printf "%sλ " (set_color ${fishTerminalColor themeExpr.primaryTerminalColor})
                            end
                        '';
                    };

                    ".config/xmobar/xmobarrc" = {
                        text = ''
                            Config {
                                fgColor = "${themeExpr.foreground}",
                                bgColor = "${themeExpr.background}",

                                position = TopSize C 40 32,
                                commands = [
                                    Run XMonadLog,

                                    Run Cpu [ "-t", "<total>%" ] 10,
                                    Run Memory [ "-t", "<used>/<total> MB <usedratio>%" ] 10,
                                    Run Date "%H:%M" "time" 10
                                ],
                                template = "%XMonadLog% }{ cpu: %cpu% mem: %memory% %time%"
                            }
                        '';
                    };

                    ".config/alacritty/alacritty.yml" = {
                        text =
                            let fish = pkgs.fish;
                            in ''
                                colors:
                                    primary:
                                        foreground: "${themeExpr.foreground}"
                                        background: "${themeExpr.background}"
                                    
                                    normal:
                                        black: "${themeExpr.terminalColors.black}"
                                        blue: "${themeExpr.terminalColors.blue}"
                                        green: "${themeExpr.terminalColors.green}"
                                        cyan: "${themeExpr.terminalColors.cyan}"
                                        red: "${themeExpr.terminalColors.red}"
                                        magenta: "${themeExpr.terminalColors.magenta}"
                                        yellow: "${themeExpr.terminalColors.yellow}"
                                        white: "${themeExpr.terminalColors.white}"
                                    
                                    bright:
                                        black: "${themeExpr.terminalColors.brightBlack}"
                                        blue: "${themeExpr.terminalColors.brightBlue}"
                                        green: "${themeExpr.terminalColors.brightGreen}"
                                        cyan: "${themeExpr.terminalColors.brightCyan}"
                                        red: "${themeExpr.terminalColors.brightRed}"
                                        magenta: "${themeExpr.terminalColors.brightMagenta}"
                                        yellow: "${themeExpr.terminalColors.brightYellow}"
                                        white: "${themeExpr.terminalColors.brightWhite}"

                                shell:
                                    program: "${fish}/bin/fish"

                                window:
                                    padding:
                                        x: 8
                                        y: 8

                                    cursor:
                                        style:
                                            blinking: On
                            '';
                    };
                };

                stateVersion = "22.11";
            };
        };
    };
}