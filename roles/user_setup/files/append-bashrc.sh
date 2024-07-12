PS1="[\[\033[01;32m\]\u@\h \[\033[01;34m\]\W\[\033[00m\]]$ "

# A socket for sharing the SSH-Agent between Windows and WSL through npiperelay.
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-relay/ssh-agent.sock

# Podman socket. Required for launching Testcontainers from Quarkus.
export DOCKER_HOST=unix://$(podman info --format '{{.Host.RemoteSocket.Path}}')

# Add Rye Shims to Path
. "$HOME/.rye/env"