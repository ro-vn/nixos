# Declarative disk layout for the N100: GPT with a 512M ESP and an ext4 root.
# No ZFS / impermanence in the base setup — kept intentionally simple.
#
# Confirm the target device before installing:
#   lsblk        # NVMe is usually /dev/nvme0n1, SATA/USB is /dev/sda
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1"; # TODO: confirm on the real machine
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
