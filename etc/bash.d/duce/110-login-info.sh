# 2022.11.09 - ducet8@outlook.com

# Display some useful information

# Notify of missing utilities
required_utils=(bat git jq lsd nvim tmux vim wget)
missing_utils=""
for tool in $required_utils; do
    if ! type -P ${tool} &>/dev/null; then
        if [[ ${tool} == "nvim" ]]; then tool="neovim"; fi  # nvim is available as neovim
        if [[ ${tool} == "bat" ]]; then
	    if [[ ${Os_Id,,} == "rocky" ]] || [[ ${Os_Id,,} =~ "centos" ]]; then 
	        continue  # bat is not available on rocky or centose
	    elif [[ ${Os_Id,,} == "debian" ]] && (type -P batcat &>/dev/null); then
	    	continue  # batcat is used on debian
	    fi
	fi
        missing_utils+="${tool} "
    fi
done
if [[ ${missing_utils} != "" ]]; then
    missing_util_msg="Missing Utilities: ${missing_utils}\n"
    if [[ ${Os_Id,,} == "darwin" ]]; then
        missing_util_msg+="\tYou most likely need to run: brew install ${missing_utils}"
    elif [[ ${Os_Id,,} == "rocky" ]] || [[ ${Os_Id,,} =~ "centos" ]]; then
        missing_util_msg+="\tYou most likely need to run: sudo dnf install ${missing_utils}"
    fi
    bd_ansi reset; bd_ansi fg_yellow5
    echo "${missing_util_msg}"
    bd_ansi reset
    unset missing_util_msg
fi
unset missing_utils
unset required_utils

# Display OS Info
echo ""
bd_ansi reset; bd_ansi fg_yellow4
if [[ ${#Os_Pretty_Name} -gt 0 ]]; then
    echo "${Os_Pretty_Name^^}"
else
    if [[ -r /etc/redhat-release ]]; then
        cat /etc/redhat-release
        echo ""
    fi
fi

# Display Profile Version
bd_ansi reset; bd_ansi fg_yellow4
echo "${DOT_LOCATION}/.bash_profile: ${Bash_Profile_Version}"

# Display DISPLAY if set
[ ! -z "${DISPLAY}" ] && bd_ansi reset && bd_ansi fg_magenta3 && echo "" && echo "DISPLAY = ${DISPLAY}"

# Dsiplay any tmux info
if [ "${TMUX}" ]; then
    bd_ansi reset; bd_ansi fg_magenta1
    echo "${Tmux_Info} [${TMUX}]"
fi