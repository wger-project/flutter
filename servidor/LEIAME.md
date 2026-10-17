# Servidor do CT da Vila

O app conversa com um servidor wger. Este é o passo a passo para subir o servidor
próprio da academia no plano gratuito do Oracle Cloud.

## 1. Criar a máquina

No painel do Oracle Cloud: **Compute > Instances > Create instance**.

- **Image:** Canonical Ubuntu 24.04
- **Shape:** Ampere `VM.Standard.A1.Flex`, 2 OCPUs e 12 GB de memória (dentro do "Always Free")
- **SSH keys:** "Generate a key pair for me" e baixe a chave privada
- Se aparecer "Out of capacity", tente outro "Availability domain" ou tente mais tarde

## 2. Abrir as portas 80 e 443

Na página da instância: clique na **subnet** > **Security Lists** > **Default Security List** >
**Add Ingress Rules**, com Source CIDR `0.0.0.0/0`, protocolo TCP e porta de destino `80,443`.

## 3. Rodar o instalador

Abra o **Cloud Shell** (ícone `>_` no topo do painel), envie a chave baixada pelo menu do
Cloud Shell e conecte na máquina (troque o IP pelo "Public IP" da instância):

```bash
chmod 600 ssh-key-*.key
ssh -i ssh-key-*.key ubuntu@IP_DA_MAQUINA
```

Já dentro da máquina:

```bash
curl -fsSL https://raw.githubusercontent.com/PatrickAgs/gym-app/master/servidor/instalar-servidor.sh | bash -s -- seu@email.com
```

No final ele mostra o endereço do servidor, no formato `https://IP-COM-TRACOS.sslip.io`.

## 4. Primeiro acesso

Entre no endereço com o usuário `admin` e a senha `adminadmin`, e troque a senha na hora.
Depois cadastre a academia, os professores e os alunos pelo menu de academias.
