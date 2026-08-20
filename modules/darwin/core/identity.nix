# Machine identity, derived from the `hostname` specialArg that mkDarwin threads
# through. Every darwin host gets this, so host files don't repeat themselves —
# adding a Mac means adding a mkDarwin line, not copying networking settings.
{ hostname, lib, ... }:
{
  networking.hostName = hostname;
  networking.computerName = lib.mkDefault hostname;
}
