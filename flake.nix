{
  outputs =
    { self }:
    {
      packages.default = import ./nix/tgt.nix;
      homeManagerModules.default = import ./nix/home/default.nix;
      lib = import ./nix/lib.nix;
    };
}
