<p align="center"><img src="docs/icon.png" width="128" alt="Ícone do Tampa Fechada"></p>

<h1 align="center">Tampa Fechada</h1>

<p align="center">Deixa o MacBook funcionando com a tampa fechada, sem precisar de monitor externo.<br>
<b>Abriu o app → o Mac continua ligado com a tela abaixada. Fechou o app → volta ao normal.</b></p>

---

## Por quê

Por padrão, o macOS coloca o MacBook pra dormir quando a tampa fecha (a menos que ele esteja ligado num monitor externo). Só que às vezes você quer deixar algo rodando, como um download, um render ou uma automação, sem deixar o notebook aberto chamando atenção (num hostel, por exemplo).

## Como instalar

1. Baixe o **`TampaFechada.zip`** na [página de releases](https://github.com/morgsdoti/tampa-fechada/releases/latest) e abra o zip.
2. Arraste o **Tampa Fechada** pra pasta **Aplicativos**.
3. Abra o app. **Na primeira vez, o macOS vai bloquear** com uma mensagem do tipo *"A Apple não pôde verificar se o app está livre de malware"*. Isso acontece porque o app não tem a assinatura paga da Apple (US$ 99/ano), não porque tem algo de errado. Pra liberar:
   - Vá em **Ajustes do Sistema → Privacidade e Segurança**, role até o fim e clique em **Abrir Mesmo Assim**.
   - Confirme. Só precisa fazer isso uma vez.

Funciona em Mac com chip Apple ou Intel, no **macOS 13 (Ventura) ou mais novo**.

## Como usar

- **Abra o app.** Ele pede sua senha (na janela do próprio macOS) e ativa. Pode abaixar a tela.
- **Feche o app** (bolinha vermelha, botão "Desligar e fechar" ou ⌘Q). Ele pede a senha de novo e volta tudo ao normal.
- **Tirou o carregador com ele aberto?** Aparece um aviso perguntando se você quer desligar, pra não guardar o notebook ligado na mochila.

> Dica: com o app aberto, clique com o botão direito no ícone dele no Dock → **Opções → Manter no Dock**. Aí vira um botão de um clique.

## ⚠️ Cuidados

- **Não guarde o Mac na mochila com o app aberto.** Ele continua ligado e esquenta num lugar fechado.
- Deixe numa **superfície dura** (mesa, chão). Cama e cobertor abafam a ventilação.
- Com o app aberto, o Mac não dorme nem na bateria. Deixe no carregador.
- Se o app travar ou for encerrado à força, a configuração pode continuar ativa. Pra voltar ao normal, é só abrir e fechar o app de novo, ou rodar no Terminal:
  ```bash
  sudo pmset -a disablesleep 0
  ```

## Como funciona

O app só liga e desliga uma configuração que já existe no macOS:

```bash
sudo pmset -a disablesleep 1   # ao abrir o app
sudo pmset -a disablesleep 0   # ao fechar o app
```

A senha é pedida pela janela padrão do macOS. O app nunca vê nem guarda a sua senha. A cada 5 segundos ele confere se o Mac está na tomada ou na bateria, pra mostrar o aviso. Ele não acessa a internet nem coleta nada. O código inteiro está em [`main.swift`](main.swift) e dá pra ler em poucos minutos.

## Compilar você mesmo

Precisa do Xcode ou das Command Line Tools (`xcode-select --install`):

```bash
git clone https://github.com/morgsdoti/tampa-fechada
cd tampa-fechada
./build.sh
```

O app é compilado e instalado em `/Applications`. Use `./build.sh --no-install` pra só gerar o `build/TampaFechada.zip`.

## Licença

[MIT](LICENSE)
