# Fedora WSL setup playbook

FedoraをWSLのディストリビューション使う人向けのセットアップ用のAnsibleプレイブックです。
コンテナベースのrootfsを`wsl --import ...`したあとのディストリビューション内のセットアップを行います。

このプレイブックは大きく以下の設定を行います。

1. 初期設定(Role: initial_setup)
    1. manの設定
    1. パッケージのインストール
    1. WSLのsystemd有効化
1. 一般ユーザーの設定(Role: user_setup)
    1. ユーザーの作成とWSLのデフォルトへの登録
    1. Box Driveのマウント
    1. bashrc,.gitconfigのカスタマイズ(WindowsのSSH Agentとの連携設定)
    1. DNF外のtoolのインストール
1. Systemd起動後の設定(Role: after_started_systemd)
    1. ロケール、およびタイムゾーンの設定
    1. Serviceの有効化

詳細は各ロールの`main.yml`を参照してください。

## How to Play.

1. Fedoraのrootfsをインポートします。 `wsl --import xxx yyy`.
1. プレイブックの実行に必要なパッケージをインストールします。

    ```sh
    dnf install git ansible python3-passlib python3-libdnf5
    ```

1. このリポジトリをクローンします、

    ```sh
    git clone https://github.com/peter-777/fedora-wsl-setup-playbook.git && \
    cd ./fedora-wsl-setup-playbook
    ```

1. プレイブックを実行します。コマンドのパラメーターの詳細は後述。

    ```sh
    ansible-playbook -l <環境> playbook.yml -e @private.yml --ask-vault-pass
    ```

1. WSLを`wsl --shutdown`で終了させ, 再度ディストリビューションを起動します。その後rootユーザーで以下を実行してください。

    ```sh
    ansible-playbook -l fedora playbook.yml --tags after-started-systemd -e @private.yml --ask-vault-pass
    ```

## Parameters

| param | value |
| - | - |
| -l <環境> | `fedora` or `testcontainer`<br><li>`fedora`: 実行しているWSLディストリビューションにプレイブックを実行します。</li><li>`testcontainer`: PodmanでFedoraコンテナを起動し、プレイブックを実行します。</li> |
| -e @private.yml | Vaultファイル(private.yml)からパラメーターを読み込みます。詳細は後述。<br>指定せずとも実行可能ですが利用を推奨します。 |
| --ask-vault-pass | Vaultのパスワードを確認するプロンプトが表示されます。<br>Vaultを暗号化している場合に使用します。 |

### Destory playground

`-l testcontainer`指定時、Podmanが自動的にFedoraコンテナを起動しますが、既に`testcontainer`という名称のコンテナが存在している場合はそのコンテナが再利用されます。

フレッシュな環境でテストする場合やプレいグラウンドが不要になった場合は、以下のコマンドでコンテナを削除してください。


```sh
podman stop testcontainer
podman rm testcontainer
```

### Run with vault

プレイブック実行時に一部のパラメーター(作成するユーザー名やパスワードなど)は、実行時に与える必要があります。
`ansible-vault`でパラメーターをファイル化しておくと便利です。

以下のYAMLファイルを作成します。ユーザー名やパスワードなどはご自身の内容に合わせてください。

```yml
user_name: user
user_password: password
user_salt: saltstring
user_git_name: User Name
user_git_email: user@example.com
box_drive_path: C:/Users/UserName/Box
```

任意でVaultを暗号化します。以下の例ではVaultはprivate.ymlです。

```sh
ansible-vault encrypt private.yml
```

## Customize playbook

### Default user .bashrc

デフォルトユーザーの.bashrcをカスタマイズしたい場合は、`roles/user_setup/files/append-bashrc.sh`を編集してください。

### Add or Remove install packages

導入するパッケージを変更したい場合は、`roles/initial_setup/vars/main.yml`を編集してください。

### SSH Agent Relay

このプレイブックを実行するとWindows上のSSH-AgentがWSLで利用できるようになります。1password等で秘密鍵を管理している人などは大いに恩恵を受けることができます。

以前は`Npiperelay`とSocketサービスを使って実現していましたが、現在はWSLからWindowsのexeを呼び出すことによって実現しています。

しかし、この方法ではディストリビューションの本来のSSHコマンドを使わないため、一長一短があると感じています。
そのため、以前の`Npiperelay`導入用のtaskはコメントアウトとして残しています。

### Further Customizations

上記以外にも色々カスタマイズしたい箇所はあるかと思います。お好きにどうぞ。

- Quarkus CLI以外にも好きなツールを導入する
- Boxドライブユーザーじゃないのでマウントタスクを除外する
- などなど
