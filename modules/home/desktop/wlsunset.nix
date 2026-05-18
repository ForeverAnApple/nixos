# Wayland blue light filter — warms the screen toward 3500K at local sundown.
# Defaults to SF Bay Area; override per host with lib.mkForce on latitude/longitude.
{
  flake.modules.homeManager.wlsunset = {
    services.wlsunset = {
      enable = true;
      latitude = 37.77;
      longitude = -122.42;
      temperature.night = 3500;
    };
  };
}
