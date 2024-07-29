#!/bin/bash

# Verifica se o script está sendo executado como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script deve ser executado como root."
    exit 1
fi

# Verifica se o diretório e o arquivo existem
if [ ! -f "./files/siptracer.sh" ]; then
    echo "Arquivo siptracer.sh não encontrado em ./files."
    exit 1
fi

# Verifica se /usr/sbin é acessível e permite escrita
if [ ! -w "/usr/sbin" ]; then
    echo "Sem permissão de escrita em /usr/sbin."
    exit 1
fi

# Move o arquivo
mv "./files/siptracer.sh" "/usr/sbin/siptracer"
if [ $? -ne 0 ]; then
    echo "Falha ao mover o arquivo."
    exit 1
fi

# Define as permissões do arquivo
chmod 755 "/usr/sbin/siptracer"
if [ $? -ne 0 ]; then
    echo "Falha ao definir as permissões do arquivo."
    exit 1
fi

echo "Instalação concluída com sucesso."