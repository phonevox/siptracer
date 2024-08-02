# Siptracer

**pt-BR**: Aplicação para geração de arquivos .pcap em segundo plano.<br>
**en-US**: Application to generate .pcap files in the background.

# Descrição

A aplicação "*siptracer*" serve para gerar arquivos .pcap em segundo plano, para consulta posterior em outra aplicação (sngrep).

O script de instalação que acompanha no repositório é para a adição do `siptracer.sh` como "siptracer" em seu PATH.

**NOTA**: *Técnicamente falando, esta aplicação é só um "handler" para formatação de um comando **tcpdump**. Pode analisar o comando gerado com a flag "--debug"*

# Instalação

```sh
git clone https://github.com/phonevox/siptracer.git
cd siptracer
chmod +x install.sh
./install.sh # Instala o siptracer em seu PATH. Relogue sua sessão para utilizar.
siptracer --help
```
**NOTA**: *O instalador precisa ser executado como root.*<br>

# Uso

Execute `./install.sh` para instalar o siptracer.

Execute `siptracer --help` para obter mais informações de uso.

Exemplos de uso:
```
siptracer
siptracer --interface eth1 --output /var/log/siptracer_output.pcap
siptracer -i ens0 -p 5060,50007,5061 --debug
```
Irá monitorar *eth0*, e registrar todo fluxo das portas 5060 e 50007 em *output.pcap* no diretório atual.
