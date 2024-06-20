_: {
  # Project root
  projectRootFile = "flake.nix";
  # Terraform formatter
  programs = {
    yamlfmt.enable = true;
    nixfmt-rfc-style.enable = true;
    deno.enable = true;
    deadnix = {
      enable = true;
      # Can break callPackage if this is set to false
      no-lambda-pattern-names = true;
    };
    statix.enable = true;
    rustfmt.enable = true;
    beautysh.enable = true;
    mdformat.enable = true;
  };
  settings.formatter = {
    deadnix.excludes = [ "npins/default.nix" ];
    nixfmt-rfc-style.excludes = [ "npins/default.nix" ];
    deno.excludes = [ "npins/default.nix" ];
    statix.excludes = [ "npins/default.nix" ];
    yamlfmt.excludes = [ "npins/sources.json" ];
  };
}
