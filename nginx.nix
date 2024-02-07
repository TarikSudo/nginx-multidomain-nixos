{ pkgs, lib, config, ... }:
let
  # Configuration for domain1
  web1 = "domain1";
  domain1 = "domain1.com";
  dataDir1 = "/srv/domain1/public";  # Directory for domain1's public files

  # Configuration for domain2
  web2 = "domain2";
  domain2 = "domain2.com";
  dataDir2 = "/srv/domain2/public";  # Directory for domain2's public files

  # Repeat the above configuration for more domains

in {
  services.phpfpm = {
    # PHP-FPM pool configurations
    pools = {

      "${web1}" = {
        user = "you";  # The user running the PHP-FPM process for domain1
        group = "users";  # The group running the PHP-FPM process for domain1
        settings = {
          "listen.owner" = config.services.nginx.user;  # Owner of the listen socket
          "pm" = "dynamic";  # Process manager configuration
          "pm.max_children" = 32;  # Maximum number of child processes
          "pm.max_requests" = 500;  # Maximum number of requests a child process should execute before respawning
          "pm.start_servers" = 2;  # Number of child processes to start
          "pm.min_spare_servers" = 2;  # Minimum number of idle child processes
          "pm.max_spare_servers" = 5;  # Maximum number of idle child processes
          "php_admin_value[error_log]" = "stderr";  # Error log path
          "php_admin_flag[log_errors]" = true;  # Enable error logging
          "catch_workers_output" = true;  # Redirect worker stdout and stderr into main error log
        };
        phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];  # Setting PATH for PHP environment
      };

      "${web2}" = {
        user = "you";
        group = "users";
        settings = {
            "listen.owner" = config.services.nginx.user;
            "pm" = "dynamic";
            "pm.max_children" = 32;
            "pm.max_requests" = 500;
            "pm.start_servers" = 2;
            "pm.min_spare_servers" = 2;
            "pm.max_spare_servers" = 5;
            "php_admin_value[error_log]" = "stderr";
            "php_admin_flag[log_errors]" = true;
            "catch_workers_output" = true;
        };
        phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
      };

      # Repeat the above configuration for web3 and web4 with respective variables

    };
  };

  services.nginx = {
    enable = true;
    # Nginx virtual host configurations
    virtualHosts = {

      "${domain1}" = {
      index index.php;

        location / {
          try_files $uri $uri/ /index.php;
        }

        location ~ \.php$ {
          try_files $uri $uri/ /index.php;
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_index  index.php;
          fastcgi_pass unix:${config.services.phpfpm.pools.${web1}.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        }
      '';
    };

    "${domain2}" = {
      root = dataDir2;
      extraConfig = ''
        index index.php;

        location / {
          try_files $uri $uri/ /index.php;
        }

        location ~ \.php$ {
          try_files $uri $uri/ /index.php;
          fastcgi_split_path_info ^(.+\.php)(/.+)$;
          fastcgi_index  index.php;
          fastcgi_pass unix:${config.services.phpfpm.pools.${web2}.socket};
          include ${pkgs.nginx}/conf/fastcgi_params;
          include ${pkgs.nginx}/conf/fastcgi.conf;
        }
      '';
    };

      # Repeat the above configuration for more domains with respective variables

    };
  };

  services.mysql = {
    enable = true;  # Enabling MySQL service
    package = pkgs.mariadb;  # Specifying MariaDB as the MySQL implementation
  };
}
