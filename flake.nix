{
  description = "My nixos system flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    agents.url = "github:numtide/llm-agents.nix";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    agents,
    ...
  } @ inputs: let
    unstableOverlay = final: prev: let
    in {
      opencode = agents.packages.${final.stdenv.hostPlatform.system}.opencode;
      claude-code = agents.packages.${final.stdenv.hostPlatform.system}.claude-code;
    };

    commonModules = [
      ./base.nix
      {
        nixpkgs.overlays = [unstableOverlay];
      }
    ];
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
        };
        modules =
          commonModules
          ++ [
            {nixpkgs.hostPlatform = "x86_64-linux";}
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.alauxui = import ./hosts/nixos/home.nix;
            }
            ./hosts/nixos/configuration.nix
          ];
      };
    };

    devShells."x86_64-linux".default = let
      pkgs = import nixpkgs {system = "x86_64-linux";};
    in
      pkgs.mkShell {
        nativeBuildInputs = [pkgs.zsh];

        packages = with pkgs; [
          go-task
          stow
          pre-commit
          copier
        ];

        shellHook = ''
          echo "Welcome to the dev shell"
        '';
      };
  };
}
