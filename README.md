[日本語のREADME](./README_ja.md)

Here is a machine translation of the above Japanese text. Apologies for any mistakes. 

---

# Fedora WSL Setup Playbook

This is an Ansible playbook for setting up Fedora as a WSL distribution. It handles the setup within the distribution after importing a container-based rootfs with `wsl --import ...`.

This playbook performs the following major configurations:

1. Initial Setup (Role: initial_setup)
    1. Configure `man`
    1. Install packages
    1. Enable systemd for WSL
1. General User Setup (Role: user_setup)
    1. Create and register the user as the default for WSL
    1. Mount Box Drive
    1. Customize `bashrc` and `.gitconfig` (including Windows SSH Agent integration)
    1. Install tools outside of DNF
1. Post-Systemd Startup Setup (Role: after_started_systemd)
    1. Configure locale and timezone
    1. Enable services

For details, refer to the `main.yml` of each role.

## How to Play

1. Import the rootfs of Fedora using `wsl --import xxx yyy`.
1. Install the packages required to execute the playbook:

    ```sh
    dnf install git ansible python3-passlib  python3-libdnf5
    ```

1. Clone this repository:

    ```sh
    git clone https://github.com/peter-777/fedora-wsl-setup-playbook.git && \
    cd ./fedora-wsl-setup-playbook
    ```

1. Execute the playbook. Details of the command parameters are provided below.

    ```sh
    ansible-playbook -l <environment> playbook.yml -e @private.yml --ask-vault-pass
    ```

1. Shut down WSL using `wsl --shutdown`, restart the distribution, and then execute the following as the root user:

    ```sh
    ansible-playbook -l fedora playbook.yml --tags after-started-systemd -e @private.yml --ask-vault-pass
    ```

## Parameters

| Parameter | Description |
| - | - |
| -l <environment> | `fedora` or `testcontainer`<br><li>`fedora`: Execute the playbook on the running WSL distribution.</li><li>`testcontainer`: Start a Fedora container with Podman and execute the playbook.</li> |
| -e @private.yml | Load parameters from the Vault file (`private.yml`). Details are provided below.<br>While not mandatory, it is recommended. |
| --ask-vault-pass | Prompts for the Vault password.<br>Use this if the Vault is encrypted. |

### Destroy Playground

When specifying `-l testcontainer`, Podman automatically starts a Fedora container, but if a container named `testcontainer` already exists, it will be reused.

To test in a fresh environment or remove the playground, use the following commands to delete the container:

```sh
podman stop testcontainer
podman rm testcontainer
```

### Run with Vault

When running the playbook, some parameters (such as the username and password to create) need to be provided at runtime. It is convenient to use `ansible-vault` to save these parameters in a file.

Create the following YAML file, replacing the username and password with your own:

```yaml
user_name: user
user_password: password
user_salt: saltstring
user_git_name: User Name
user_git_email: user@example.com
box_drive_path: C:/Users/UserName/Box
```

Optionally, encrypt the Vault file. The example below assumes the Vault file is named `private.yml`:

```sh
ansible-vault encrypt private.yml
```

## Customize Playbook

### Default User .bashrc

To customize the default user's `.bashrc`, edit the `roles/user_setup/files/append-bashrc.sh` file.

### Add or Remove Installed Packages

To modify the packages that are installed, edit the `roles/initial_setup/vars/main.yml` file.

### SSH Agent Relay

Running this playbook allows you to use the SSH Agent from Windows within WSL, which is especially beneficial for users who manage their private keys with tools like 1Password.

Previously, this was achieved using `Npiperelay` and a socket service, but it is now done by invoking Windows executables directly from WSL.

However, this method does not use the distribution's native SSH command, which has its pros and cons. Therefore, the tasks for installing `Npiperelay` are left as comments.

### Further Customizations

Feel free to customize any other aspects as you prefer:

- Install additional tools besides the Quarkus CLI
- Exclude the Box Drive mount task if you are not a Box Drive user
- And so on...
