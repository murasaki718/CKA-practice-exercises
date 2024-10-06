let
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-24.05";
  pkgs = import nixpkgs { config = {}; overlays = []; };
in

pkgs.mkShellNoCC {
  packages = with pkgs; [
    cowsay
    lolcat
    fzf
    fd
    awscli2
    ssm-session-manager-plugin
    tfswitch
  ];
  GREETING = "Hello, K8s Student!";
  shellHook = ''
    echo $GREETING | cowsay | lolcat
    terraform -version
    aws --version
    '';
}
