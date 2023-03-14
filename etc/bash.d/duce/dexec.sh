# vim: ft=sh
# 2023.03.14 - ducet8@outlook.com

function dexec() {
    local container_shell

    container_shell=$(sudo docker exec nginx sh -c "which bash")
    [ -z ${container_shell} ] && container_shell=$(sudo docker exec nginx sh -c "which sh")
    [ -z ${container_shell} ] && bd_ansi fg_red && echo "ERROR: Could not determine the shell for container: ${1}" && bd_ansi reset && return 1

    sudo docker cp $BD_HOME/dotfiles/container_profile "${1}":/tmp/duce
    sudo docker exec -it "${1}" "${container_shell}"
    sudo docker exec "${1}" "${container_shell}" -c "[[ -f /tmp/duce ]] && rm duce"
}
