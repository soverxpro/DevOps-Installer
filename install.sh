#!/bin/bash

# Определение операционной системы
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Не удалось определить операционную систему."
    exit 1
fi

# Функция для установки пакетов (универсальная) с отслеживанием ошибок
install_package() {
    local package_name="$1"
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        sudo apt install -y "$package_name"
        if [ $? -ne 0 ]; then
            echo "Ошибка установки пакета: $package_name"
            FAILED_PACKAGES+=("$package_name")
        fi
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y "$package_name"
        if [ $? -ne 0 ]; then
            echo "Ошибка установки пакета: $package_name"
            FAILED_PACKAGES+=("$package_name")
        fi
    else
        echo "Неподдерживаемая операционная система для установки: $package_name"
        FAILED_PACKAGES+=("$package_name")
    fi
}

# Функция для установки composer (отдельно из-за метода установки) с отслеживанием ошибок
install_composer() {
    curl -sS https://getcomposer.org/installer | php
    if [ $? -ne 0 ]; then
        echo "Ошибка установки composer"
        FAILED_PACKAGES+=("composer")
        return
    fi
    sudo mv composer.phar /usr/local/bin/composer
    if [ $? -ne 0 ]; then
        echo "Ошибка перемещения composer"
        FAILED_PACKAGES+=("composer (move)")
    fi
}

# Массив для хранения имен неудачно установленных пакетов
declare -a FAILED_PACKAGES=()

# Функции установки для специфических случаев или для унификации вызова
install_apache() { install_package apache2; }
install_nginx() { install_package nginx; }
install_mysql() { install_package mysql-server; }
install_postgresql() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        install_package postgresql
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        install_package postgresql-server
    fi
}
install_php() { install_package php; }
install_phpmyadmin() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        install_package phpmyadmin
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        echo "Для CentOS/Fedora установите phpMyAdmin вручную."
        FAILED_PACKAGES+=("phpmyadmin")
    fi
}
install_memcached() { install_package memcached; }
install_redis() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        install_package redis-server
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        install_package redis
    fi
}
install_vsftpd() { install_package vsftpd; }
install_bind() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        install_package bind9
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        install_package bind
    fi
}
install_nodejs() { install_package nodejs; }
install_python() { install_package python3; }
install_ruby() { install_package ruby; }
install_go() { install_package golang; }
install_java() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        install_package default-jdk
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        install_package java-1.8.0-openjdk
    fi
}
install_docker() { install_package docker.io; }
install_git() { install_package git; }
install_certbot() { install_package certbot; }
install_varnish() { install_package varnish; }
install_haproxy() { install_package haproxy; }
install_ufw() { install_package ufw; }
install_postfix() { install_package postfix; }
install_dovecot() { install_package dovecot-core dovecot-imapd; } # Установка базовых пакетов Dovecot
install_nmap() { install_package nmap; }
install_traceroute() { install_package traceroute; }
install_wget() { install_package wget; }
install_zsh() { install_package zsh; }
install_vim() { install_package vim; }
install_kubectl() { install_package kubectl; }
install_docker_compose() { install_package docker-compose-plugin; } # Для современных версий Docker
install_prometheus() { install_package prometheus; }
install_grafana() { install_package grafana; }
install_mongodb() { install_package mongodb; }
install_ansible() { install_package ansible; }
install_terraform() {
    if [[ "$ID" == "ubuntu" || "$ID" == "debian" ]]; then
        wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
        if [ $? -ne 0 ]; then FAILED_PACKAGES+=("terraform (gpg)"); return; fi
        echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
        if [ $? -ne 0 ]; then FAILED_PACKAGES+=("terraform (repo)"); return; fi
        sudo apt update
        if [ $? -ne 0 ]; then FAILED_PACKAGES+=("terraform (update)"); return; fi
        install_package terraform
    elif [[ "$ID" == "centos" || "$ID" == "fedora" ]]; then
        sudo yum install -y yum-utils
        if [ $? -ne 0 ]; then FAILED_PACKAGES+=("terraform (yum-utils)"); return; fi
        sudo yum config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo
        if [ $? -ne 0 ]; then FAILED_PACKAGES+=("terraform (repo)"); return; fi
        install_package terraform
    fi
}

# Ассоциативный массив для категорий с описаниями
declare -A categories
categories["C1"]="Мониторинг и Логирование (Prometheus, Grafana)"
categories["C2"]="DevOps инструменты (Docker, Docker Compose, Kubernetes (kubectl), Ansible, Terraform)"
categories["C3"]="Базовые инструменты разработчика (Git, Wget)"
categories["C4"]="Веб-сервер LEMP (Nginx, PHP, MySQL, phpMyAdmin)"
categories["C5"]="Стек MEAN (MongoDB, Node.js)"
categories["C6"]="Среды выполнения (Node.js, Python, Ruby, Go, Java)"
categories["C7"]="Серверные инструменты (Docker, Docker Compose, Certbot, Varnish Cache, HAProxy, FTP, DNS)"
categories["C8"]="Прочее (Zsh, Vim)"
categories["C9"]="Сервер электронной почты (Postfix, Dovecot)"
categories["C10"]="Инструменты для работы с сетью (Nmap, iputils-ping, traceroute)"
categories["C11"]="Стек MERN (MongoDB, Node.js)"
categories["C12"]="Базы данных (MySQL, PostgreSQL, Redis, Memcached)"
categories["C13"]="Веб-сервер LAMP (Apache, PHP, MySQL, phpMyAdmin)"

# Массив для упорядочивания категорий
declare -a category_order=("C1" "C2" "C3" "C4" "C5" "C6" "C7" "C8" "C9" "C10" "C11" "C12" "C13")

# Ассоциативный массив для отдельных пакетов с описаниями
declare -A individual_packages
individual_packages["P01"]="Ansible"
individual_packages["P02"]="Certbot"
individual_packages["P03"]="Docker Compose"
individual_packages["P04"]="Kubernetes (kubectl)"
individual_packages["P05"]="Memcached"
individual_packages["P06"]="Prometheus"
individual_packages["P07"]="Git"
individual_packages["P08"]="Grafana"
individual_packages["P09"]="MySQL"
individual_packages["P10"]="PostgreSQL"
individual_packages["P11"]="HAProxy"
individual_packages["P12"]="Postfix"
individual_packages["P13"]="UFW"
individual_packages["P14"]="Node.js"
individual_packages["P15"]="traceroute"
individual_packages["P16"]="Composer"
individual_packages["P17"]="Ruby"
individual_packages["P18"]="Terraform"
individual_packages["P19"]="phpMyAdmin"
individual_packages["P20"]="Nginx"
individual_packages["P21"]="Java"
individual_packages["P22"]="FTP (vsftpd)"
individual_packages["P23"]="Vim"
individual_packages["P24"]="PHP"
individual_packages["P25"]="iputils-ping"
individual_packages["P26"]="Dovecot"
individual_packages["P27"]="Nmap"
individual_packages["P28"]="Apache2"
individual_packages["P29"]="Wget"
individual_packages["P30"]="Varnish Cache"
individual_packages["P31"]="Zsh"
individual_packages["P32"]="Python"
individual_packages["P33"]="Redis"
individual_packages["P34"]="MongoDB"
individual_packages["P35"]="DNS (BIND)"
individual_packages["P36"]="Docker"
individual_packages["P37"]="Go"

# Массив для упорядочивания отдельных пакетов
declare -a package_order=("P01" "P02" "P03" "P04" "P05" "P06" "P07" "P08" "P09" "P10" "P11" "P12" "P13" "P14" "P15" "P16" "P17" "P18" "P19" "P20" "P21" "P22" "P23" "P24" "P25" "P26" "P27" "P28" "P29" "P30" "P31" "P32" "P33" "P34" "P35" "P36" "P37")

# Ассоциативный массив для сопоставления категорий и пакетов
declare -A categories_to_packages
categories_to_packages["C1"]="prometheus grafana"
categories_to_packages["C2"]="docker.io docker-compose-plugin kubectl ansible terraform"
categories_to_packages["C3"]="git wget"
categories_to_packages["C4"]="nginx php mysql-server phpmyadmin"
categories_to_packages["C5"]="mongodb nodejs"
categories_to_packages["C6"]="nodejs python3 ruby golang java-1.8.0-openjdk"
categories_to_packages["C7"]="docker.io docker-compose-plugin certbot varnish haproxy vsftpd bind9"
categories_to_packages["C8"]="zsh vim"
categories_to_packages["C9"]="postfix dovecot-core dovecot-imapd"
categories_to_packages["C10"]="nmap iputils-ping traceroute"
categories_to_packages["C11"]="mongodb nodejs"
categories_to_packages["C12"]="mysql-server postgresql redis memcached"
categories_to_packages["C13"]="apache2 php mysql-server phpmyadmin"

# Ассоциативный массив для сопоставления отдельных пакетов и их имен
declare -A selection_to_package
selection_to_package["P01"]="ansible"
selection_to_package["P02"]="certbot"
selection_to_package["P03"]="docker-compose-plugin"
selection_to_package["P04"]="kubectl"
selection_to_package["P05"]="memcached"
selection_to_package["P06"]="prometheus"
selection_to_package["P07"]="git"
selection_to_package["P08"]="grafana"
selection_to_package["P09"]="mysql-server"
selection_to_package["P10"]="postgresql"
selection_to_package["P11"]="haproxy"
selection_to_package["P12"]="postfix"
selection_to_package["P13"]="ufw"
selection_to_package["P14"]="nodejs"
selection_to_package["P15"]="traceroute"
selection_to_package["P16"]="composer"
selection_to_package["P17"]="ruby"
selection_to_package["P18"]="terraform"
selection_to_package["P19"]="phpmyadmin"
selection_to_package["P20"]="nginx"
selection_to_package["P21"]="java-1.8.0-openjdk"
selection_to_package["P22"]="vsftpd"
selection_to_package["P23"]="vim"
selection_to_package["P24"]="php"
selection_to_package["P25"]="iputils-ping"
selection_to_package["P26"]="dovecot-core"
selection_to_package["P27"]="nmap"
selection_to_package["P28"]="apache2"
selection_to_package["P29"]="wget"
selection_to_package["P30"]="varnish"
selection_to_package["P31"]="zsh"
selection_to_package["P32"]="python3"
selection_to_package["P33"]="redis"
selection_to_package["P34"]="mongodb"
selection_to_package["P35"]="bind9"
selection_to_package["P36"]="docker.io"
selection_to_package["P37"]="golang"

# Функция для установки набора пакетов
install_packages_from_list() {
    local packages_to_install=("$@")
    for package_code in "${packages_to_install[@]}"; do
        case "$package_code" in
            "apache2") install_apache ;;
            "nginx") install_nginx ;;
            "mysql-server") install_mysql ;;
            "postgresql") install_postgresql ;;
            "php") install_php ;;
            "phpmyadmin") install_phpmyadmin ;;
            "memcached") install_memcached ;;
            "redis") install_redis ;;
            "vsftpd") install_vsftpd ;;
            "bind9") install_bind ;;
            "composer") install_composer ;;
            "nodejs") install_nodejs ;;
            "python3") install_python ;;
            "ruby") install_ruby ;;
            "golang") install_go ;;
            "java-1.8.0-openjdk") install_java ;;
            "docker.io") install_docker ;;
            "git") install_git ;;
            "certbot") install_certbot ;;
            "varnish") install_varnish ;;
            "haproxy") install_haproxy ;;
            "ufw") install_ufw ;;
            "postfix") install_postfix ;;
            "dovecot-core"|"dovecot-imapd") install_dovecot ;; # Обработка базовых пакетов Dovecot
            "nmap") install_nmap ;;
            "traceroute") install_traceroute ;;
            "wget") install_wget ;;
            "zsh") install_zsh ;;
            "vim") install_vim ;;
            "kubectl") install_kubectl ;;
            "docker-compose-plugin") install_docker_compose ;;
            "prometheus") install_prometheus ;;
            "grafana") install_grafana ;;
            "mongodb") install_mongodb ;;
            "ansible") install_ansible ;;
            "terraform") install_terraform ;;
            *) echo "Неизвестный пакет для установки: $package_code" ;;
        esac
    done
}

# Вывод меню
echo "Выберите, что установить:"
echo "Категории:"
for category_code in "${category_order[@]}"; do
    echo "$category_code) ${categories[$category_code]}"
done
echo ""
echo "Отдельные пакеты:"
for package_code in "${package_order[@]}"; do
    echo "$package_code) ${individual_packages[$package_code]}"
done
echo ""
echo "Дополнительно:"
echo "ALL) Установить все"
echo ""

# Чтение ввода пользователя
read -p "Выберите категории (например: C1 C3), отдельные пакеты (например: P07 P20) или ALL, разделенные пробелом: " selections

# Разбор ввода пользователя
selected_packages=()
install_all=false
for selection in $selections; do
    if [[ "$selection" == "ALL" ]]; then
        install_all=true
    elif [[ "${categories_to_packages[$selection]}" ]]; then
        IFS=' ' read -ra category_packages <<< "${categories_to_packages[$selection]}"
        selected_packages+=( "${category_packages[@]}" )
    elif [[ "${selection_to_package[$selection]}" ]]; then
        selected_packages+=("${selection_to_package[$selection]}")
    else
        echo "Неверный выбор: $selection"
    fi
done

# Установка всех пакетов
if $install_all; then
    echo "Установка всех доступных программ..."
    # Собираем все пакеты из категорий и отдельных пакетов, удаляя дубликаты
    declare -A all_packages_map
    for category_code in "${!categories_to_packages[@]}"; do
        IFS=' ' read -ra pkgs <<< "${categories_to_packages[$category_code]}"
        for pkg in "${pkgs[@]}"; do
            all_packages_map["$pkg"]=1
        done
    done
    for package_code in "${!selection_to_package[@]}"; do
        all_packages_map["${selection_to_package[$package_code]}"]=1
    done
    install_packages_from_list "${!all_packages_map[@]}"
    echo "Установка завершена!"
elif [[ ${#selected_packages[@]} -gt 0 ]]; then
    echo "Установка выбранных программ..."
    install_packages_from_list "${selected_packages[@]}"
    echo "Установка завершена!"
else
    echo "Не выбрано ни одной программы для установки."
fi

# Вывод информации о неудачах установки
if [[ ${#FAILED_PACKAGES[@]} -gt 0 ]]; then
    echo ""
    echo "Следующие пакеты не были установлены или были установлены с ошибками:"
    for failed_package in "${FAILED_PACKAGES[@]}"; do
        echo "- $failed_package"
    done
fi
