{ config, pkgs, ... }:

{
  imports = [
    # Include hardware configuration for RockPro64 (generated during installation)
    # ./hardware-configuration.nix
  ];

  # Bootloader (U-Boot is handled during installation on RockPro64)
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Recommended for ARM boards like RockPro64
  hardware.opengl.enable = true;
  hardware.opengl.extraPackages = with pkgs; [
    mesa.panfrost  # For Mali GPU on RK3399
  ];

  # Use GBM backend for Kodi (best for standalone on ARM)
  environment.systemPackages = with pkgs; [
    (kodi-gbm.withPackages (kodiPkgs: with kodiPkgs; [
      # IPTV viewer: PVR IPTV Simple Client
      pvr-iptvsimple

      # Netflix addon (requires Widevine DRM and InputStream Adaptive)
      netflix

      # Disney+ addon (similar requirements)
      # Note: If disneyplus addon exists in kodiPackages, add it here.
      # As of current nixpkgs, netflix is available; check for disneyplus.

      # Free and open source YouTube viewer
      youtube

      # Essential for streaming addons (Netflix, Disney+, YouTube DASH)
      inputstream-adaptive

      # Optional: A modern skin similar to Google TV / Android TV
      # Arctic Horizon 2 or similar modern skins may be available; fallback to a clean one
      # Example: arctic-horizon or aeon-nox-silvo if packaged
      # If not, install manually in Kodi later.
    ]))
  ];

  # Create a dedicated kodi user for autologin and standalone mode
  users.users.kodi = {
    isNormalUser = true;
    extraGroups = [ "video" "input" "audio" ];
    initialPassword = "kodi";  # Change this!
  };

  # Autologin and start Kodi standalone
  services.getty.autologinUser = "kodi";

  # Use greetd for lightweight login manager
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "${pkgs.kodi-gbm}/bin/kodi-standalone";
        user = "kodi";
      };
    };
  };

  # Enable Sway (required for some Wayland sessions, but GBM works standalone)
  programs.sway.enable = true;

  # Audio: Use ALSA for HDMI passthrough (common for TV setups)
  sound.enable = true;
  hardware.pulseaudio.enable = false;  # Disable PulseAudio

  # Networking
  networking.networkmanager.enable = true;  # Or use wireless if needed

  # Firewall: Allow Kodi remote control if desired
  networking.firewall.allowedTCPPorts = [ 8080 ];
  networking.firewall.allowedUDPPorts = [ 8080 ];

  # Notes:
  # - First install NixOS on RockPro64 using aarch64 image and proper U-Boot (see NixOS wiki: https://nixos.wiki/wiki/NixOS_on_ARM/PINE64_ROCKPro64)
  # - Netflix/Disney+ require Widevine DRM. On aarch64 Linux, extract from Chromium or use inputstream helper addon in Kodi to fetch it.
  # - For a Google TV-like UI: After boot, in Kodi go to System > Interface > Skin > Get more... and search for "Arctic Horizon 2", "Aeon Nox Silvo", or "Unity" (modern Android TV feel).
  # - Configure IPTV in Kodi via PVR IPTV Simple Client addon (add your M3U playlist).
  # - YouTube addon is fully FOSS and works without API key for basic use.

  system.stateVersion = "24.11";  # Adjust to your NixOS version
}