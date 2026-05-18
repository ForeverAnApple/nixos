{
  flake.modules.nixos.laptop = {
    powerManagement.powertop.enable = true;
    services.upower.enable = true;
    services.tlp.enable = true;

    services.logind.settings.Login = {
      HandleLidSwitch = "suspend-then-hibernate";
      HandleLidSwitchDocked = "ignore";
      HandlePowerKey = "suspend-then-hibernate";
      HandlePowerKeyLongPress = "poweroff";
    };

    systemd.sleep.settings.Sleep.HibernateDelaySec = "4h";
  };
}
