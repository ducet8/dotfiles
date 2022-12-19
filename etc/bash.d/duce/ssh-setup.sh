# 2022.12.19 - ducet8@outlook.com

if [[ ${BD_OS,,} != "darwin" ]]; then
    return 0
fi

function ssh_setup() {
   cat ~/.ssh/id_rsa.pub | ssh ${1} 'cat - >> ~/.ssh/authorized_keys'
}
