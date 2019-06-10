## `srv/` ##

This subdirectory contains all of the configuration necessary to run
`dot.cyphar.com`, minus any credentials and tedious installation steps.

* `lxd/` contains the `yaml` configuration files used to set up all of the
  containers required to run `dot.cyphar.com`. Because LXD doesn't (currently)
  have a way to automatically set up the rootfs, these configurations are
  fairly minimal and include all of the important paths to be set up.

* `overlay/` contains "overlays" of the rootfs for the host and containers. It
  includes configuration files, scripts, and various other bits which are used
  for the every-day running of services.

* `overlay/install.sh` is a basic helper script which can help you install the
  various bits into both the host and containers automatically (it also fixes
  up the owners for you, and also runs scripts before and after to try to
  automate as much setup as possible).
