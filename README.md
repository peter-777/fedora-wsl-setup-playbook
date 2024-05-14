# How to Play.

1. Activate the distribution by loading the fedora-rootfs using `wsl --import`.
1. Log into the distribution and install the packages listed in Requirements.
1. Check out repository.

    ```sh
    git clone https://github.com/peter-777/fedora-wsl-setup-playbook.git && \
    cd ./fedora-wsl-setup-playbook
    ```

1. Execute the following command.

    `ansible-playbook -i inventories/hosts.ini -l fedora playbook.yml`

1. After executing `wsl --shutdown`, log in again to the distribution as root and execute the following command.

    `ansible-playbook -i inventories/hosts.ini -l fedora playbook.yml --tags after-started-systemd`

## Requirements

- git
- ansible
- pathon3-passlib

`dnf install git ansible python3-passlib`

## Test play in container

`ansible-playbook -i inventories/hosts.ini -l testcontainer playbook.yml`

destory playground
```sh
podman stop testcontainer
podman rm testcontainer
```

## Run with vault

create private.yml
```yml
user_name: user
user_password: password
user_salt: saltstring
user_git_name: User Name
user_git_email: user@example.com
box_drive_path: C:/Users/UserName/Box
```

encrypt

`ansible-vault encrypt private.yml`


ansible-vault encrypt private.yml

`ansible-playbook -i inventories/hosts.ini -l testcontainer playbook.yml -e @private.yml --ask-vault-pass`

## Customize user .bashrc

Edit `roles/user_setup/files/append-bashrc.sh` as you like.

It will be written to the default user's .bashrc.

## Add or Remove install packages

Edit `roles/initial_setup/vars/main.yml`

## Feel free to customize various other aspects as you prefer.

- Add CLI tools other than Quarkus CLI
- Drop the mounting task for Box Drive
- and so on.
