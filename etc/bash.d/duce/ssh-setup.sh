# 2022.11.08 - ducet8@outlook.com

if [[ ${Os_Id,,} != "darwin" ]]; then
    return 0
fi

function ssh_setup() {
   cat ~/.ssh/id_rsa.pub | ssh ${1} 'cat - >> ~/.ssh/authorized_keys'
}
