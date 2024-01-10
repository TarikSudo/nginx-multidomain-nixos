# Nginx Multi-Domain Configuration (Nix)

This repository contains an `nginx.nix` file for setting up a multi-domain Nginx server. It's tailored for Nix environments and integrates PHP-FPM and MariaDB for a complete web server setup.

## Features
- **Multi-Domain Support:** Easily host multiple websites on a single Nginx instance.
- **PHP-FPM and MariaDB Integration:** Optimized for PHP applications with MariaDB as the database backend.

## Usage
1. Copy `nginx.nix` to your `/etc/nixos/` directory and import it in your `configuration.nix`.
   
2. Set your hosts in `configuration.nix`, for example:
   ```nix
   networking.extraHosts = ''
     127.0.0.1 domain1 domain2
     ::1 domain1 domain2
   '';
   ```

3. Configure PHP in `configuration.nix`, for example:
   ```nix
   environment.systemPackages = with pkgs; [
     # .......
     (pkgs.php.buildEnv {
       extensions = ({ enabled, all }: enabled ++ (with all; [
         mysqli # Enable mysqli Extension
         pdo_mysql # Enable pdo_mysql Extension
       ]));
       extraConfig = ''
         display_errors = On # Display Errors
         date.timezone = Europe/Istanbul # Set Time Zone
         error_log = /srv/logs/php_errors.log # Set PHP error log file directory
         memory_limit = 128M # Set memory limit
       '';
     })
     # ......
   ];
   ```

4. Finally, rebuild your NixOS configuration to apply changes.

## License
This project is licensed under [MIT License](LICENSE). Feel free to use and modify as per your needs.
