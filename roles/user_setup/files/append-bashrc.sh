PS1="[\[\033[01;32m\]\u@\h \[\033[01;34m\]\W\[\033[00m\]]$ "

# A socket for sharing the SSH-Agent between Windows and WSL through npiperelay.
export SSH_AUTH_SOCK=$XDG_RUNTIME_DIR/ssh-relay/ssh-agent.sock

# Podman Socket
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/podman/podman.sock

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
