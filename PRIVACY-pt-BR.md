# Política de privacidade

[English](PRIVACY.md) · [Deutsch](PRIVACY-de.md) · [Español](PRIVACY-es.md) · [Français](PRIVACY-fr.md) · [Italiano](PRIVACY-it.md) · **Português (Brasil)**

_Esta tradução é fornecida apenas para sua conveniência. Em caso de divergência com a [versão em inglês](PRIVACY.md), prevalece a versão em inglês._

_Última atualização: 9 de novembro de 2026_

O Personal hShop é um app para Mac. Ele não coleta nenhum dado pessoal.

## O que o app não faz

- Não coleta nem compartilha nenhuma informação pessoal. O pouco que ele salva fica no seu Mac (veja abaixo).
- Nunca se conecta à internet nem a qualquer serviço online. A sandbox dele nem sequer permite conexões de saída.
- Não tem contas, análises, publicidade nem rastreamento, e não contém código de terceiros que faça isso.
- Não guarda nenhum registro de quais arquivos são baixados, nem por qual dispositivo.

## O que fica no seu Mac

O próprio app salva três ajustes, somente no seu Mac, dentro da própria sandbox:

- a porta do servidor;
- se a página abre automaticamente quando o servidor é iniciado;
- um marcador para a pasta que você escolheu, para que o app possa lê-la novamente na próxima vez que for aberto.

O macOS também pode guardar ali detalhes comuns das janelas, como a posição da janela de ajustes. Nada disso sai do seu Mac. Os títulos dos jogos lidos dos seus arquivos ficam na memória enquanto o app está aberto e somem quando ele é encerrado.

## Seus arquivos e sua rede

- O app só lê a pasta que você escolher. Ele nunca altera, move nem apaga os seus arquivos.
- Enquanto o servidor está em execução, qualquer dispositivo que consiga alcançar o seu Mac pela rede, normalmente os dispositivos da sua rede local, pode abrir a página e baixar os arquivos listados nela. A página e os arquivos são enviados por HTTP simples, sem criptografia, e a página mostra os nomes dos seus jogos e o endereço local do seu Mac. O servidor para quando você o para ou encerra o app, e nunca inicia sozinho. Só o inicie em redes de confiança.

## Retenção e exclusão dos seus dados

Os ajustes acima ficam guardados até que você os apague. Nada é guardado em nenhum outro lugar e quem desenvolve o app não recebe nenhum dado, então não há nada a pedir para apagar.

Para que o app pare de ler a sua pasta, escolha outra pasta nos ajustes ou apague os ajustes do app como descrito abaixo.

Para apagar os ajustes do app, encerre o app, escolha **Ir › Ir para Pasta…** no Finder, digite `~/Library/Containers` e mova para o Lixo a pasta chamada “Personal hShop”. O nome real dela é `com.github.cesarse.Personal-hShop`. Se o macOS pedir permissão, permita.

Mover só o app para o Lixo não apaga essa pasta.

## Relatórios de falhas

Se você escolheu no macOS compartilhar análises com os desenvolvedores de apps, a Apple pode fornecer relatórios anônimos de falhas deste app a quem o desenvolve. A Apple trata esses relatórios de acordo com a própria política de privacidade.

## Crianças

O app não coleta dados de ninguém, inclusive de crianças.

## Alterações nesta política

Se esta política mudar, a nova versão será publicada aqui com uma nova data.

## Contato

Para qualquer dúvida sobre esta política, envie um e-mail para [personalhshop@icloud.com](mailto:personalhshop@icloud.com). Veja também a página de [suporte](SUPPORT-pt-BR.md).
