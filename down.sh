#!/bin/bash

# Colores para el texto
YELLOW="$(tput setaf 3)"
RED="$(tput setaf 1)"
RESET="$(tput sgr0)"
sudo true
sudo mkdir -p /mnt/server
sudo git clone ${GIT_ADDRESS} .
sudo pip install -U --prefix .local ${PY_PACKAGES}
sudo npm install

# Función para instalar Forge
install_forge() {
    echo "Selecciona la versión de Java para Minecraft Forge:"
    echo "1) Java 8"
    echo "2) Java 11"
    echo "3) Java 16"
    echo "4) Java 17"
    echo "5) Java 18"
    read -p "Ingresa el número de versión de Java: " java_choice

    case $java_choice in
        1) DOCKER_IMAGE="ghcr.io/pterodactyl/yolks:java_8" ;;
        2) DOCKER_IMAGE="ghcr.io/pterodactyl/yolks:java_11" ;;
        3) DOCKER_IMAGE="ghcr.io/pterodactyl/yolks:java_16" ;;
        4) DOCKER_IMAGE="ghcr.io/pterodactyl/yolks:java_17" ;;
        5) DOCKER_IMAGE="ghcr.io/pterodactyl/yolks:java_18" ;;
        *) echo "${RED}Opción inválida. No se realizará ninguna instalación.${RESET}"; exit 1 ;;
    esac

    echo "${YELLOW}Instalando Minecraft Forge con ${DOCKER_IMAGE}...${RESET}"
    local MC_VERSION="1.16.5"
    local FORGE_VERSION="36.2.39"  # Última versión estable para 1.16.5

    apt update
    apt install -y curl jq

    if [[ ! -d /mnt/server ]]; then
        mkdir -p /mnt/server
    fi

    cd /mnt/server

    local FILE_SITE="https://maven.minecraftforge.net/net/minecraftforge/forge/"
    local DOWNLOAD_LINK="${FILE_SITE}${MC_VERSION}-${FORGE_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar"

    echo "${YELLOW}Descargando Forge versión ${FORGE_VERSION}...${RESET}"
    curl -O ${DOWNLOAD_LINK}

    if [[ ! -f "forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar" ]]; then
        echo "${RED}Error al descargar Forge versión ${FORGE_VERSION}!${RESET}"
        exit 1
    fi

    echo "${YELLOW}Instalando Forge...${RESET}"
    java -jar "forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar" --installServer || { 
        echo "${RED}La instalación falló usando la versión de Forge ${FORGE_VERSION} y la versión de Minecraft ${MC_VERSION}.${RESET}"; 
        exit 1; 
    }

    echo "${YELLOW}Configurando el servidor de Forge...${RESET}"
    mv "forge-${MC_VERSION}-${FORGE_VERSION}.jar" "server.jar"

    echo "${YELLOW}Eliminando el archivo del instalador de Forge...${RESET}"
    rm -rf "forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar"

    echo "${YELLOW}Instalación completa.${RESET}"
}

# Función para instalar Paper
install_paper() {
    local MC_VERSION="1.16.5"
    local BUILD="786"  # Última versión estable para 1.16.5

    echo "${YELLOW}Iniciando la descarga de Paper para Minecraft ${MC_VERSION}, por favor espera...${RESET}"
    sleep 2

    apt update
    apt install -y curl

    if [[ ! -d /mnt/server ]]; then
        mkdir -p /mnt/server
    fi

    cd /mnt/server

    local DOWNLOAD_LINK="https://papermc.io/api/v2/projects/paper/versions/${MC_VERSION}/builds/${BUILD}/downloads/paper-${MC_VERSION}-${BUILD}.jar"

    echo "${YELLOW}Descargando Paper versión ${MC_VERSION} build ${BUILD}...${RESET}"
    curl -O ${DOWNLOAD_LINK}

    if [[ ! -f "paper-${MC_VERSION}-${BUILD}.jar" ]]; then
        echo "${RED}Error al descargar Paper versión ${MC_VERSION} build ${BUILD}!${RESET}"
        exit 1
    fi

    echo "${YELLOW}Configurando el servidor de Paper...${RESET}"
    mv "paper-${MC_VERSION}-${BUILD}.jar" "server.jar"

    echo "${YELLOW}Instalación completa.${RESET}"
}

# Función para instalar Vanilla
install_vanilla() {
    local MC_VERSION="1.16.5"
    local DOWNLOAD_LINK="https://launcher.mojang.com/v1/objects/e7e9097a4385d46e93c62ddcc8f1f220b5d8a5e4/server.jar"

    echo "${YELLOW}Iniciando la descarga de Vanilla para Minecraft ${MC_VERSION}, por favor espera...${RESET}"
    sleep 2

    apt update
    apt install -y curl

    if [[ ! -d /mnt/server ]]; then
        mkdir -p /mnt/server
    fi

    cd /mnt/server

    echo "${YELLOW}Descargando Vanilla versión ${MC_VERSION}...${RESET}"
    curl -O ${DOWNLOAD_LINK}

    if [[ ! -f "server.jar" ]]; then
        echo "${RED}Error al descargar Vanilla versión ${MC_VERSION}!${RESET}"
        exit 1
    fi

    echo "${YELLOW}Instalación completa.${RESET}"
}

# Función para instalar Web Hosting
install_web_hosting() {
    echo "Selecciona la versión de PHP para Web hosting:"
    echo "1) PHP 8.0"
    echo "2) PHP 8.1"
    read -p "Ingresa el número de versión de PHP: " php_choice

    case $php_choice in
        1) DOCKER_IMAGE="ghcr.io/sigma-production/nginx-ptero:8.0" ;;
        2) DOCKER_IMAGE="ghcr.io/sigma-production/nginx-ptero:8.1" ;;
        *) echo "${RED}Opción inválida. No se realizará ninguna instalación.${RESET}"; exit 1 ;;
    esac

    echo "${YELLOW}Instalando Web hosting con ${DOCKER_IMAGE}...${RESET}"
    
    apt update
    apt install -y git
    
    git clone https://github.com/Sigma-Production/ptero-eggs ./temp
    cp -r ./temp/nginx /mnt/server/
    cp -r ./temp/php-fpm /mnt/server/
    cp -r ./temp/webroot /mnt/server/
    cp ./temp/start.sh /mnt/server/
    chmod +x /mnt/server/start.sh
    rm -rf ./temp
    mkdir /mnt/server/tmp
    mkdir /mnt/server/logs

    echo "${YELLOW}Instalación completa.${RESET}"
}

# Función para instalar Python
install_python() {
    echo "Selecciona la versión de Python:"
    echo "1) Python 3.12"
    echo "2) Python 3.11"
    echo "3) Python 3.10"
    echo "4) Python 3.9"
    echo "5) Python 3.8"
    echo "6) Python 3.7"
    echo "7) Python 2.7"
    read -p "Ingresa el número de versión de Python: " python_choice

    case $python_choice in
        1) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:python_3.12" ;;
        2) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:python_3.11" ;;
        3) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:python_3.10" ;;
        4) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:python_3.9" ;;
        5) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:python_3.8" ;;
        6) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:python_3.7" ;;
        7) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:python_2.7" ;;
        *) echo "${RED}Opción inválida. No se realizará ninguna instalación.${RESET}"; exit 1 ;;
    esac

    echo "${YELLOW}Instalando Python con ${DOCKER_IMAGE}...${RESET}"
    
    apt update
    apt install -y git python3 python3-pip
    
    if [[ ! -d /mnt/server ]]; then
        mkdir -p /mnt/server
    fi
    
    cd /mnt/server

    git clone ${GIT_ADDRESS} .

    if [[ ! -z ${PY_PACKAGES} ]]; then
        pip install -U --prefix .local ${PY_PACKAGES}
    fi

    if [ -f /mnt/server/${REQUIREMENTS_FILE} ]; then
        pip install -U --prefix .local -r ${REQUIREMENTS_FILE}
    fi

    echo "${YELLOW}Instalación completa.${RESET}"
}

# Función para instalar Node.js
install_nodejs() {
    echo "Selecciona la versión de Node.js:"
    echo "1) Node.js 21"
    echo "2) Node.js 20"
    echo "3) Node.js 19"
    echo "4) Node.js 18"
    echo "5) Node.js 17"
    echo "6) Node.js 16"
    echo "7) Node.js 14"
    echo "8) Node.js 12"
    read -p "Ingresa el número de versión de Node.js: " node_choice

    case $node_choice in
        1) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:nodejs_21" ;;
        2) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:nodejs_20" ;;
        3) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:nodejs_19" ;;
        4) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:nodejs_18" ;;
        5) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:nodejs_17" ;;
        6) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:nodejs_16" ;;
        7) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:nodejs_14" ;;
        8) DOCKER_IMAGE="ghcr.io/parkervcp/yolks:nodejs_12" ;;
        *) echo "${RED}Opción inválida. No se realizará ninguna instalación.${RESET}"; exit 1 ;;
    esac

    echo "${YELLOW}Instalando Node.js con ${DOCKER_IMAGE}...${RESET}"
    
    apt update
    apt install -y curl git
    
    if [[ ! -d /mnt/server ]]; then
        mkdir -p /mnt/server
    fi
    
    cd /mnt/server

    git clone ${GIT_ADDRESS} .

    if [[ -f /mnt/server/package.json ]]; then
        npm install
    fi

    if [[ -f /mnt/server/${NODE_PACKAGES_FILE} ]]; then
        npm install $(cat ${NODE_PACKAGES_FILE})
    fi

    echo "${YELLOW}Instalación completa.${RESET}"
}

# Menú principal
echo "Elige una opción para instalar:"
echo "1) Minecraft"
echo "   - Forge"
echo "   - Paper"
echo "   - Vanilla"
echo "2) Web hosting"
echo "3) Programación"
echo "   - Python"
echo "   - Node.js"
read -p "Ingresa el número de opción: " choice

case $choice in
    1)
        echo "Selecciona la versión de Minecraft:"
        echo "1) Forge"
        echo "2) Paper"
        echo "3) Vanilla"
        read -p "Ingresa el número de versión: " mc_choice

        case $mc_choice in
            1)
                # Instalación de Minecraft Forge
                install_forge
                ;;
            2)
                # Instalación de Paper
                install_paper
                ;;
            3)
                # Instalación de Vanilla
                install_vanilla
                ;;
            *)
                echo "${RED}Opción inválida. No se realizará ninguna instalación.${RESET}"
                exit 1
                ;;
        esac
        ;;
    2)
        # Instalación de Web hosting
        install_web_hosting
        ;;
    3)
        echo "Selecciona el lenguaje de programación:"
        echo "1) Python"
        echo "2) Node.js"
        read -p "Ingresa el número de opción: " prog_choice

        case $prog_choice in
            1)
                # Instalación de Python
                install_python
                ;;
            2)
                # Instalación de Node.js
                install_nodejs
                ;;
            *)
                echo "${RED}Opción inválida. No se realizará ninguna instalación.${RESET}"
                exit 1
                ;;
        esac
        ;;
    *)
        echo "${RED}Opción inválida. No se realizará ninguna instalación.${RESET}"
        exit 1
        ;;
esac
