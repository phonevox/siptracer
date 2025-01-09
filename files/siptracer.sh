#!/bin/bash

# Valores padrão
INTERFACE="eth0"
OUTPUT_FILE="$(pwd)/output.pcap"
RESET_INTERVAL=0  # Valor padrão
PORTS="5060,50007"
DEBUG=false

show_help() {
    echo "Uso: $0 [OPÇÕES]"
    echo "Para rodar em background, utilize '& disown' no final."
    echo "Lembre-se de finalizar o processo para não consumir recursos desnecessários quando não for mais necessário."
    # obs: você pode rodar "<chamar script> & disown" pra rodar o script em background
    # só lembre de encerrá-lo depois, conferindo no "ps aux" (ex: ps aux | grep tracer)
    echo ""
    echo "Capture pacotes SIP com tcpdump."
    echo ""
    echo "Opções:"
    echo "  -i, --interface   Interface de rede (padrão: eth0)"
    echo "  -O, --output      Caminho do arquivo de saída (padrão: [DIRETORIO_ATUAL]/output.pcap)"
    echo "  -r, --reset       Intervalo de reset em segundos (padrão: 0 (indefinido))"
    echo "  -p, --ports       Portas para captura, separadas por vírgula caso >1 (padrão: 5060,50007)"
    echo "  -h, --help        Exibir esta mensagem de ajuda"
    echo "  --debug           Ativa opções de debugging"
    exit 1
}

# Processa os argumentos da linha de comando
while [[ $# -gt 0 ]]; do
    case "$1" in
        --interface | -i)
            INTERFACE="$2"
            shift
            shift
            ;;
        --output | -O)
            OUTPUT_FILE="$2"
            shift
            shift
            ;;
        --reset | -r)
            RESET_INTERVAL="$2"
            shift
            shift
            ;;
        --port | -p)
            PORTS="$2"
            shift
            shift
            ;;
        --debug)
            DEBUG=true
            shift
            shift
            ;;
        --help | -h)
            show_help
            ;;
        *)
            echo "Argumento desconhecido: $1"
            echo ""
            show_help
            ;; 
    esac
done

# Detecta o sistema operacional
if [ -f /etc/os-release ]; then
    source /etc/os-release
    OS=$ID
else
    echo "Sistema operacional não suportado."
    exit 1
fi

# Função para checar se o tcpdump está instalado no Debian
check_tcpdump_debian() {
    if ! dpkg -l | grep -q tcpdump; then
        echo "tcpdump não está instalado."
        exit 1
    fi
}

# Função para checar se o tcpdump está instalado no CentOS/Rocky
check_tcpdump_centos() {
    if ! yum list installed tcpdump &> /dev/null; then
        echo "tcpdump não está instalado."
        exit 1
    fi
}

# Verifica e executa a checagem conforme o sistema operacional
case "$OS" in
    debian|ubuntu)
        check_tcpdump_debian
        ;;
    centos|rocky)
        check_tcpdump_centos
        ;;
    *)
        echo "Sistema operacional não suportado."
        exit 1
        ;;
esac

# Adiciona o timestamp ao nome do arquivo, se RESET_INTERVAL não for 0
if [ "$RESET_INTERVAL" -ne 0 ]; then
    OUTPUT_FILE=$(basename "$OUTPUT_FILE" | cut -d. -f1)
    OUTPUT_FILE="$OUTPUT_FILE-%Y%m%d-%H%M%S.pcap"
else
    OUTPUT_FILE=$(basename "$OUTPUT_FILE" | cut -d. -f1).pcap
fi

# Construção do comando tcpdump
TCPDUMP_CMD="sudo tcpdump -i '$INTERFACE' -w '$OUTPUT_FILE' -s 0 -nn -q -A -p"

# Adiciona a opção -G apenas se RESET_INTERVAL for maior que zero
if [ "$RESET_INTERVAL" -gt 0 ]; then
    TCPDUMP_CMD="$TCPDUMP_CMD -G $RESET_INTERVAL"
fi

# Adicionando as ports ao comando tcpdump
IFS=',' read -ra PORT_ARRAY <<< "$PORTS"
if [ "${#PORT_ARRAY[@]}" -eq 1 ]; then
    TCPDUMP_CMD="$TCPDUMP_CMD 'port ${PORT_ARRAY[0]}'"
else
    PORT_EXPRESSION=""
    for port in "${PORT_ARRAY[@]}"; do
        PORT_EXPRESSION+="port $port or "
    done
    PORT_EXPRESSION="${PORT_EXPRESSION% or }" # Remove o último "or"
    TCPDUMP_CMD="$TCPDUMP_CMD '$PORT_EXPRESSION'"
fi

if $DEBUG; then
        # DEBUGGING
        echo "Interface   : $INTERFACE"
        echo "Output      : $OUTPUT_FILE"
        echo "Reset       : $RESET_INTERVAL"
        echo "Ports       : $PORTS"
        echo "tcpdump cmd : $TCPDUMP_CMD"
fi

# Executa o comando tcpdump
eval $TCPDUMP_CMD
