#!/bin/bash

# Определение операционной системы
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Не удалось определить операционную систему."
    exit 1
fi

# Функции для установки пакетов
install_apache() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y apache2
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y httpd
    fi
}

install_nginx() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y nginx
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y nginx
    fi
}

install_mysql() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y mysql-server
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y mysql-server
    fi
}

install_postgresql() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y postgresql
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y postgresql-server
    fi
}

install_php() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y php
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y php
    fi
}

install_phpmyadmin() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y phpmyadmin
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        echo "Для CentOS/Fedora установите phpMyAdmin вручную."
    fi
}

install_memcached() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y memcached
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y memcached
    fi
}

install_redis() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y redis-server
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y redis
    fi
}

install_vsftpd() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y vsftpd
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y vsftpd
    fi
}

install_bind() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y bind9
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y bind
    fi
}

install_composer() {
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
}

install_nodejs() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y nodejs
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y nodejs
    fi
}

install_python() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y python3
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y python3
    fi
}

install_ruby() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y ruby
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y ruby
    fi
}

install_go() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y golang
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y golang
    fi
}

install_java() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y default-jdk
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y java-1.8.0-openjdk
    fi
}

install_docker() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y docker.io
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y docker
    fi
}

install_git() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y git
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y git
    fi
}

install_certbot() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y certbot
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y certbot
    fi
}

install_varnish() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y varnish
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y varnish
    fi
}

install_haproxy() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y haproxy
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y haproxy
    fi
}

# Список пакетов
options=("Apache2" "Nginx" "MySQL" "PostgreSQL" "PHP" "phpMyAdmin" "Memcached" "Redis" "FTP (vsftpd)" "DNS (BIND)" "Composer" "Node.js" "Python" "Ruby" "Go" "Java" "Docker" "Git" "Certbot" "Varnish Cache" "HAProxy")

# Выбор пакетов для установки
echo "Выберите программы для установки (например: 1 3 5):"
for i in "${!options[@]}"; do
    printf "%d) %s\n" $((i+1)) "${options[i]}"
done

read -p "Ваш выбор: " -a selections

# Установка выбранных пакетов
for selection in "${selections[@]}"; do
    case $selection in
        1) install_apache ;;
        2) install_nginx ;;
        3) install_mysql ;;
        4) install_postgresql ;;
        5) install_php ;;
        6) install_phpmyadmin ;;
        7) install_memcached ;;
        8) install_redis ;;
        9) install_vsftpd ;;
        10) install_bind ;;
        11) install_composer ;;
        12) install_nodejs ;;
        13) install_python ;;
        14) install_ruby ;;
        15) install_go ;;
        16) install_java ;;
        17) install_docker ;;
        18) install_git ;;
        19) install_certbot ;;
        20) install_varnish ;;
        21) install_haproxy ;;
        *) echo "Неверный выбор: $selection" ;;
    esac
done

echo "Выбранные программы установлены!"
