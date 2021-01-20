import Config

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :nerves_pack],
  app: Mix.Project.config()[:app]

# Nerves Runtime can enumerate hardware devices and send notifications via
# SystemRegistry. This slows down startup and not many programs make use of
# this feature.

config :nerves_runtime, :kernel, use_system_registry: false

# Erlinit can be configured without a rootfs_overlay. See
# https://github.com/nerves-project/erlinit/ for more information on
# configuring erlinit.

config :nerves,
  erlinit: [
    hostname_pattern: "nerves-%s"
  ]

# Configure the device for SSH IEx prompt access and firmware updates
#
# * See https://hexdocs.pm/nerves_ssh/readme.html for general SSH configuration
# * See https://hexdocs.pm/ssh_subsystem_fwup/readme.html for firmware updates

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

# Configure the network using vintage_net
config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"wlan0",
     %{
       ipv4: %{method: :dhcp},
       type: VintageNetWiFi,
       vintage_net_wifi: %{
         networks: [
           %{
             key_mgmt: :wpa_psk,
             psk: System.get_env("WPA_PSK"),
             ssid: System.get_env("WPA_SSID")
           }
         ]
       }
     }}
  ]

config :mdns_lite,
  # The `host` key specifies what hostnames mdns_lite advertises.  `:hostname`
  # advertises the device's hostname.local. For the official Nerves systems, this
  # is "nerves-<4 digit serial#>.local".  mdns_lite also advertises
  # "nerves.local" for convenience. If more than one Nerves device is on the
  # network, delete "nerves" from the list.

  host: [:hostname, "nerves"],
  ttl: 120,

  # Advertise the following services over mDNS.
  services: [
    %{
      name: "SSH Remote Login Protocol",
      protocol: "ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Secure File Transfer Protocol over SSH",
      protocol: "sftp-ssh",
      transport: "tcp",
      port: 22
    },
    %{
      name: "Erlang Port Mapper Daemon",
      protocol: "epmd",
      transport: "tcp",
      port: 4369
    }
  ]

gamma = [
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  2,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  4,
  4,
  4,
  4,
  4,
  5,
  5,
  5,
  5,
  6,
  6,
  6,
  6,
  7,
  7,
  7,
  7,
  8,
  8,
  8,
  9,
  9,
  9,
  10,
  10,
  10,
  11,
  11,
  11,
  12,
  12,
  13,
  13,
  13,
  14,
  14,
  15,
  15,
  16,
  16,
  17,
  17,
  18,
  18,
  19,
  19,
  20,
  20,
  21,
  21,
  22,
  22,
  23,
  24,
  24,
  25,
  25,
  26,
  27,
  27,
  28,
  29,
  29,
  30,
  31,
  32,
  32,
  33,
  34,
  35,
  35,
  36,
  37,
  38,
  39,
  39,
  40,
  41,
  42,
  43,
  44,
  45,
  46,
  47,
  48,
  49,
  50,
  50,
  51,
  52,
  54,
  55,
  56,
  57,
  58,
  59,
  60,
  61,
  62,
  63,
  64,
  66,
  67,
  68,
  69,
  70,
  72,
  73,
  74,
  75,
  77,
  78,
  79,
  81,
  82,
  83,
  85,
  86,
  87,
  89,
  90,
  92,
  93,
  95,
  96,
  98,
  99,
  101,
  102,
  104,
  105,
  107,
  109,
  110,
  112,
  114,
  115,
  117,
  119,
  120,
  122,
  124,
  126,
  127,
  129,
  131,
  133,
  135,
  137,
  138,
  140,
  142,
  144,
  146,
  148,
  150,
  152,
  154,
  156,
  158,
  160,
  162,
  164,
  167,
  169,
  171,
  173,
  175,
  177,
  180,
  182,
  184,
  186,
  189,
  191,
  193,
  196,
  198,
  200,
  203,
  205,
  208,
  210,
  213,
  215,
  218,
  220,
  223,
  225,
  228,
  231,
  233,
  236,
  239,
  241,
  244,
  247,
  249,
  252,
  255
]

config :blinkchain,
  canvas: {8, 1}

config :blinkchain, :channel0,
  pin: 12,
  number: 0,
  type: :grbw,
  brightness: 32,
  gamma: gamma,
  arrangement: [
    %{
      type: :strip,
      origin: {0, 0},
      count: 8,
      direction: :right
    }
  ]

config :power_control,
  cpu_governor: :powersave,
  disable_hdmi: false,
  disable_leds: true

config :mix_tasks_upload_hotswap,
  app_name: :natural_waker,
  nodes: [:"naturalwaker@nerves.local"],
  cookie: :"secret token shared between nodes"

config :nerves_time, :servers, [
  "0.pool.ntp.org",
  "1.pool.ntp.org",
  "2.pool.ntp.org",
  "3.pool.ntp.org"
]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
