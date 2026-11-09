# Suporte do Personal hShop

[English](SUPPORT.md) · [Deutsch](SUPPORT-de.md) · [Español](SUPPORT-es.md) · [Français](SUPPORT-fr.md) · [Italiano](SUPPORT-it.md) · **Português (Brasil)**

_Esta tradução é fornecida apenas para sua conveniência. Em caso de divergência com a [versão em inglês](SUPPORT.md), prevalece a versão em inglês._

## Contato

E-mail: [personalhshop@icloud.com](mailto:personalhshop@icloud.com)

## Primeiros passos

1. Escolha **Personal hShop › Ajustes…**, clique em **Escolher pasta…** e selecione a pasta que contém os seus arquivos .cia.
2. Escolha **Arquivo › Iniciar servidor**.
3. Abra http://localhost:1234 (ou a porta definida nos ajustes) em um navegador no seu Mac, ou ative **Abrir a página automaticamente após iniciar o servidor** nos ajustes. Quando a pasta tiver arquivos .cia, a página mostrará o endereço que o console e outros dispositivos podem usar.
4. No console, abra o FBI, escolha **Remote Install › Scan QR Code** e escaneie o código do arquivo que você quer instalar.

## Requisitos

- Um Mac com macOS 27 ou posterior.
- Um Nintendo 3DS com um gerenciador de títulos homebrew que consiga instalar a partir de um código QR, como o FBI, na mesma rede local que o Mac.
- Arquivos .cia que você tenha o direito de instalar. O Personal hShop não inclui, não baixa e não indica links para nenhum jogo.

## Solução de problemas

**O console não consegue se conectar.**

- Verifique se o console e o Mac estão na mesma rede. O console só consegue entrar em redes Wi-Fi de 2,4 GHz que usem IPv4 e segurança WPA2 ou anterior; ele não consegue entrar em uma rede somente WPA3.
- Redes de convidados e roteadores com o “isolamento de AP” ou o “isolamento de clientes” ativado impedem que os dispositivos se comuniquem. Use a rede principal ou desative essa opção.
- Escaneie os códigos da página ou use o endereço que ela mostra: “localhost” só funciona no próprio Mac.
- Se o Mac estiver conectado a mais de uma rede (por exemplo, Ethernet e Wi-Fi), o endereço da página pode ser o da rede errada. Nesse caso, abra a página em http://<o endereço do Mac na rede do console>:1234; os códigos passarão a usar esse endereço.
- Se o firewall do Mac estiver ativado, abra **Ajustes do Sistema › Rede › Firewall › Opções…** e verifique se **Bloquear todas as conexões de entrada** está desativado e se o Personal hShop está definido como **Permitir conexões de entrada**.
- Uma VPN em execução no Mac pode impedir que o console chegue até ele.

**“A porta … já está em uso.”**
Outro app está usando essa porta. Escolha outra nos ajustes e inicie o servidor novamente.

**Um arquivo não aparece na página.**
Só aparecem os arquivos terminados em .cia que estão diretamente na pasta escolhida, não os das subpastas.

**A página diz “Nenhum arquivo .cia encontrado”, mas a pasta tem arquivos.**
O Personal hShop não conseguiu abrir a pasta, ou os arquivos estão em uma subpasta. Escolha **Arquivo › Parar servidor**, abra os ajustes, clique em **Escolher pasta…**, selecione a pasta novamente e depois inicie o servidor. Se a pasta estiver em um disco externo ou de rede, conecte o disco primeiro.

**Um título aparece diferente do nome do arquivo.**
Os títulos vêm do título em inglês gravado dentro do arquivo. Quando o arquivo não tem um, como muitos arquivos criptografados, o título vem do nome do arquivo, sem o ID de título de 16 dígitos do início e sem os detalhes entre parênteses depois do nome, como o código do produto, a versão e a região. Títulos escritos inteiramente em maiúsculas aparecem com a inicial de cada palavra em maiúscula, mantendo os algarismos romanos como estão.

**Uma instalação parou no meio.**
O Mac fica acordado enquanto um arquivo está sendo enviado, mas fechar a tampa de um MacBook ainda o coloca em repouso. O FBI desiste quando nenhum dado chega por 15 segundos; inicie a instalação novamente.

**Jogos grandes demoram muito.**
O Wi-Fi do console é lento: conte com cerca de 0,5 MB/s em um 3DS original e cerca de 1,3 MB/s em um New 3DS, então um jogo de 1 GB leva cerca de 15 minutos em um New 3DS e mais de meia hora em um 3DS original.

## Desinstalação

Encerre o Personal hShop e mova o app para o Lixo. Para remover também os ajustes dele, escolha **Ir › Ir para Pasta…** no Finder, digite `~/Library/Containers` e mova para o Lixo a pasta chamada “Personal hShop” (o nome real dela é `com.github.cesarse.Personal-hShop`).

## Privacidade

O Personal hShop não coleta nenhum dado. Consulte a [política de privacidade](PRIVACY-pt-BR.md).
