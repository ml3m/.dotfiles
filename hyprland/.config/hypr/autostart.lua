-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Bar auto-hide daemon: hides the bar and reveals it on top-edge hover
o.exec_on_start("bash $HOME/.config/omarchy/bar-autohide.sh &")
