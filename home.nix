{
  # TODO: uncomment the next line if you want to reference your GitHub/GitLab access tokens and other secrets
  # secrets,
  pkgs,
  lib,
  username,
  nix-index-database,
  inputs,
  config,
  ...
}: let
  unstable-packages = with pkgs.unstable; [
    # TODO: select your core binaries that you always want on the bleeding-edge
    coreutils
    curl
    du-dust
    fd
    ffmpeg
    findutils
    git
    git-crypt
    jq
    killall
    mosh
    neovim
    nodejs_20
    nodePackages.pnpm
    procs
    ripgrep
    sd
    tmux
    vim
    wget
    (pkgs.nerdfonts.override { fonts = [ "Monaspace" ]; })
  ];

  stable-packages = with pkgs; [
    # TODO: customize these stable packages to your liking for the languages that you use

    # TODO: you can add plugins, change keymaps etc using (jeezyvim.nixvimExtend {})
    # https://github.com/LGUG2Z/JeezyVim#extending
    # jeezyvim
    # lunarvim
    
    # key tools
    # gh # for bootstrapping
    just

    # core languages
    # rustup
    
    # to fix error in neovim
    gcc
    cargo

    # rust stuff
    cargo-cache
    cargo-expand

    # local dev stuf
    mkcert
    httpie

    # treesitter
    tree-sitter

    # language servers
    nodePackages.vscode-langservers-extracted # html, css, json, eslint
    nodePackages.yaml-language-server
    nil # nix

    # formatters and linters
    alejandra # nix
    # nixfmt-rfc-style
    deadnix # nix
    nodePackages.prettier
    shellcheck
    shfmt
    statix # nix
  ];
in {
  imports = [
    nix-index-database.hmModules.nix-index
    inputs.tokyonight.homeManagerModules.default
  ];
  tokyonight.enable = true;
  tokyonight.style = "night";
  home.stateVersion = "22.11";

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";

    sessionVariables.EDITOR = "nvim";
    # TODO: set your preferred $SHELL
    sessionVariables.SHELL = "/etc/profiles/per-user/${username}/bin/fish";
  };

  home.packages =
    stable-packages
    ++ unstable-packages
    ++
    # TODO: you can add anything else that doesn't fit into the above two lists in here
    [
      # pkgs.some-package
      # pkgs.unstable.some-other-package
    ];

  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "/tmp/configuration/nvim";
    recursive = true;
  };

  programs = {
    home-manager.enable = true;
    nix-index.enable = true;
    nix-index.enableFishIntegration = true;
    nix-index-database.comma.enable = true;

    starship.enable = true;
    starship.settings = {
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = false;
      git_branch.style = "242";
      directory.style = "blue";
      directory.truncate_to_repo = false;
      directory.truncation_length = 8;
      python.disabled = true;
      ruby.disabled = true;
      hostname.ssh_only = false;
      hostname.style = "bold green";
    };

    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      defaultOptions = ["--height 40%" "--layout=reverse" "--border"];
      fileWidgetCommand = "fd --hidden --strip-cwd-prefix --exclude .git";
      fileWidgetOptions = [
        "--preview 'if test -d {}; eza --tree --all --level=3 --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end'"
      ];
      changeDirWidgetCommand = "fd --type d --hidden --strip-cwd-prefix --exclude .git";
      changeDirWidgetOptions = ["--preview 'eza --tree --color=always {} | head -200'"];
    };

    bat.enable = true;

    eza = {
      enable = true;
      git = true;
      icons = true;
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = ["--cmd cd"];
    };

    # direnv.enable = true;
    # direnv.nix-direnv.enable = true;

    helix = {
      enable = true;
      settings.theme = "tokyonight";
      settings.editor.true-color = true;
      settings.editor.mouse = true;
      settings.editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "block";
      };
    };

    git = {
      enable = true;
      package = pkgs.unstable.git;
      delta.enable = true;
      delta.options = {
        line-numbers = true;
        side-by-side = true;
        navigate = true;
      };
      userEmail = "bassim101@gmail.com"; # TODO: set your git email
      userName = "Bassim Shahidy"; #TODO: set your git username
      signing = { 
        key = "~/.ssh/id_ed25519";
        signByDefault = true;
      };
      extraConfig = {
        # TODO: uncomment the next lines if you want to be able to clone private https repos
        # url = {
        #   "https://oauth2:${secrets.github_token}@github.com" = {
        #     insteadOf = "https://github.com";
        #   };
        #   "https://oauth2:${secrets.gitlab_token}@gitlab.com" = {
        #     insteadOf = "https://gitlab.com";
        #   };
        # };
        gpg.format = "ssh";
        rebase.autoStash = true;
        rerere.enabled = true;
        pull.rebase = true;
        push = {
          default = "current";
          autoSetupRemote = true;
        };
        merge = {
          conflictstyle = "diff3";
        };
        diff = {
          colorMoved = "default";
        };
      };
    };

    gh = {
      enable = true;
      gitCredentialHelper = {
        enable = true;
        hosts = ["https://github.com" "https://gist.github.com"];
      };
    };

    ssh = {
      enable = true;
      # includes = [
      #   (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
      #     "/home/${username}/.ssh/config_external"
      #   )
      #   (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
      #     "/Users/${username}/.ssh/config_external"
      #   )
      # ];
      matchBlocks = {
        "github.com" = {
          identitiesOnly = true;
          identityFile = [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
              "/home/${username}/.ssh/id_ed25519"
            )
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
              "/Users/${username}/.ssh/id_ed25519"
            )
          ];
        };
      };
      addKeysToAgent = "yes";
    };


    lazygit = {
      enable = true;
      settings = {
        os.editPreset = "nvim";
        git.paging.pager = "delta --dark --paging=never";
      };
    };

    yazi = {
      enable = true;
      enableFishIntegration = true;
      # enableZshIntegration = true;
      settings = {
        manager = {
          show_hidden = true;
          ratio = [1 3 4];
        };
      };
    };

    fish = {
      enable = true;
      # Run 'scoop install win32yank' on Windows, then add this line with your Windows username to the bottom of interactiveShellInit
      # fish_add_path --append /mnt/c/Users/<Your Windows Username>/scoop/apps/win32yank/0.1.1
      #
      # If scoop doesn't work, use chocolatey: run 'choco install win32yank' on Windows, then add this line to the bottom of interactiveShellInit:
      # fish_add_path --append /mnt/c/ProgramData/chocolatey/bin

      interactiveShellInit = ''
        ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

        ${pkgs.lib.strings.fileContents (pkgs.fetchFromGitHub {
            owner = "rebelot";
            repo = "kanagawa.nvim";
            rev = "de7fb5f5de25ab45ec6039e33c80aeecc891dd92";
            sha256 = "sha256-f/CUR0vhMJ1sZgztmVTPvmsAgp0kjFov843Mabdzvqo=";
          }
          + "/extras/kanagawa.fish")}

        set -U fish_greeting

        fish_add_path --append /mnt/c/Users/IT-Support/scoop/apps/win32yank/current
        fish_add_path --append /mnt/c/ProgramData/chocolatey/bin

        set show_file_or_dir_preview 'if test -d {}; eza --tree --all --level=3 --color=always {} | head -200; else; bat -n --color=always --line-range :500 {}; end'
      '';
      functions = {
        refresh = "source $HOME/.config/fish/config.fish";
        take = ''mkdir -p -- "$1" && cd -- "$1"'';
        ttake = "cd $(mktemp -d)";
        show_path = "echo $PATH | tr ' ' '\n'";
        posix-source = ''
          for i in (cat $argv)
            set arr (echo $i |tr = \n)
            set -gx $arr[1] $arr[2]
          end
        '';
      };
      shellAbbrs =
        {
          gc = "nix-collect-garbage --d";
        }
        // {
          ".." = "cd ..";
          "..." = "cd ../../";
          "...." = "cd ../../../";
          "....." = "cd ../../../../";
        }
        // {
          g = "git";
          gs = "git status";
          gss = "git status -s";
          gp = "git push";
          gpl = "git pull";
          gcam = "git commit -a --amend --no-edit";
          gpf = "git push --force-with-lease";
        }
        // {
          yz = "yazi";
          lg = "lazygit";
        }
        // {
          ls = "eza --git --icons=always --color=always --long --no-user --no-permissions --no-filesize --no-time";
          lsa = "eza --git --icons=always --color=always --long --no-user --no-permissions --no-filesize --no-time --all";
          lsl = "eza --git --icons=always --color=always --long --no-user";
          ll = "eza --git --icons=always --color=always --long --no-user -all";
          lt = "eza --git --icons=always --color=always --long --no-user -all --tree --level=2";
          lt2 = "eza --git --icons=always --color=always --long --no-user -all --tree --level=3";
          lt3 = "eza --git --icons=always --color=always --long --no-user -all --tree --level=4";
          ltg = "eza --git --icons=always --color=always --long --no-user --tree --git-ignore";
        }
        // {
          ns = "git add . && sudo nixos-rebuild switch --flake /tmp/configuration";
          nss = "git add . && sudo nixos-rebuild switch --flake /tmp/configuration && sudo shutdown -h now";
        };
      shellAliases = {
        lspe = "fzf --preview '$show_file_or_dir_preview'";
        lsp = "fd --max-depth 1 --hidden --follow --exclude .git | fzf --preview '$show_file_or_dir_preview'";
        pbcopy = "/mnt/c/Windows/System32/clip.exe";
        pbpaste = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -command 'Get-Clipboard'";
        explorer = "/mnt/c/Windows/explorer.exe";
      };
      plugins = [
        {
          inherit (pkgs.fishPlugins.autopair) src;
          name = "autopair";
        }
        {
          inherit (pkgs.fishPlugins.done) src;
          name = "done";
        }
        {
          inherit (pkgs.fishPlugins.sponge) src;
          name = "sponge";
        }
      ];
    };
  };
}
