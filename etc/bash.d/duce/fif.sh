# Forked from: joseph.tingiris@gmail.com
# 2023.01.17 - ducet8@outlook.com

# fif
# find file (ff) or find in file (fif)

function fif_aborting() {
    printf "\naborting ... $@\n\n"A && return 1
}

function fif_usage() {
    printf "\nusage: $0 <start from|string to find> [string to find] [find flags]\n\n"
}

function fif() {
    if [ ! "${1}" ];then
        fif_usage
        return 1
    fi

    if [ "${BD_OS}" == 'darwin' ]; then
        Readlink='greadlink'
        Xargs_Args='-0 -r'
    else
        Readlink='readlink'
        Xargs_Args='-0 -r --max-args=64 --max-procs=16'
    fi

    Depends=()
    Depends+=('find') # GNU
    Depends+=('grep') # GNU
    Depends+=("${Readlink}") # GNU
    Depends+=('xargs') # GNU

    for Depend in ${Depends[@]}; do
        if ! type -P ${Depend} &> /dev/null; then fif_aborting "${Depend} file not found executable"; fi
    done

    if [ -d "${1}" ]; then
        From="${1}"
        String="${2}"
        Find_Flags="${3}"
    else
        From='.'
        String="${1}"
        Find_Flags="${2}"
    fi

    set -o noglob

    Find_Excludes=()
    Find_Excludes+=('.git')
    Find_Excludes+=('.svn')

    Basename=${0##*/}

    Find_Exclude_Files=(.${Basename}-exclude .find-exclude)
    for Find_Exclude_File in "${Find_Exclude_Files[@]}"; do
        if [ -r "${Find_Exclude_File}" ]; then
            Find_Excludes+=($(cat ${Find_Exclude_File} | grep -v '^#'))
        fi
    done

    let Find_Exclude_Count=0
    Find_Exclude_Args=''
    for Find_Exclude in "${Find_Excludes[@]}"; do
        if [ ${Find_Exclude_Count} -gt 0 ]; then
            Find_Exclude_Args+=' -and'
        fi
        Find_Exclude_Args+=" -not -iwholename */${Find_Exclude}/*"
        let Find_Exclude_Count=${Find_Exclude_Count}+1
    done

    if [ "${Basename}" == 'ff' ] || [ "${Basename}" == 'tff' ]; then
        Find_File=0 # true
    else
        Find_File=1 # false
    fi

    if [ ${Find_File} -eq 0 ]; then
        LC_ALL=C find ${Find_Flags} "$(${Readlink} -e "${From}")"/ ${Find_Exclude_Args} -and -name "*${String}*" 2> /dev/null
    else
        LC_ALL=C find ${Find_Flags} "$(${Readlink} -e "${From}")"/ ${Find_Exclude_Args} -type f -print0  2> /dev/null | xargs ${Xargs_Args} grep -Fl "${String}" 2> /dev/null
    fi
}

function ff() {
    fif "$@"
}
