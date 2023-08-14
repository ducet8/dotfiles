# vim: ft=sh
# 2023.08.14 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

ssh_setup() {
   cat ~/.ssh/id_rsa.pub | ssh ${1} 'cat - >> ~/.ssh/authorized_keys'
}
