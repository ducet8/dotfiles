# Copyright (c) 2022 Joseph Tingiris
# https://github.com/bash-d/bd/blob/main/LICENSE.md

# *-bd-autopath.sh: set PATH & MANPATH automatically

#
# metadata
#

# bash.d: exports PATH MANPATH
# bash.d-changelog: 20221218, joseph.tingiris@gmail.com, evolved from my path.sh
# vim:ts=4:sw=4

#
# 1. build PATH
#

# subdirectories to search for executables
BD_SEARCH_PATHS="bin .bin sbin .sbin" # scripts? tools?

# set the default filename that contains additional paths to include in the search for executables (autopaths)
[ -r "${HOME}/.Auto_Path" ] && BD_AUTO_PATHS=".Auto_Path" # deprecated
[ -r "${HOME}/.bash_autopath" ] && BD_AUTO_PATHS=".bash_autopath" # preferred
[ -z ${BD_AUTO_PATHS} ] && BD_AUTO_PATHS=".bash_autopath"

# prepare the BD_ADD_PATHS array (to aggregate many possibilities in a specific order, regardless of existence or duplication)
BD_ADD_PATHS=()

BD_ADD_PATHS+=("/apex")
BD_ADD_PATHS+=("/base")

# first, add the contents of BD_AUTO_PATHS to the BD_ADD_PATHS array
if [ -r "${HOME}/${BD_AUTO_PATHS}" ]; then
    while read BD_AUTO_PATHS_LINE; do
        BD_ADD_PATHS+=("${BD_AUTO_PATHS_LINE}")
    done < "${HOME}/${BD_AUTO_PATHS}"
    unset BD_AUTO_PATHS_LINE
fi

# second, use the value of HOME to initialize the BD_ADD_PATHS array
BD_ADD_PATHS+=("${HOME}")

# third, add common HOME subdirectories to the BD_ADD_PATHS array
BD_ADD_PATHS+=("${HOME}/opt/static/${Uname_I}")
BD_ADD_PATHS+=("${HOME}/opt/${Os_Variant}/${Uname_I}")
BD_ADD_PATHS+=("${HOME}/opt")
BD_ADD_PATHS+=("${HOME}/src")

# fourth, if BD_HOME is set then add these paths to the BD_ADD_PATHS array
if [ -n ${BD_HOME} ] && [ -r ${BD_HOME}/${BD_AUTO_PATHS} ]; then
    if [ "${BD_HOME}" != "${HOME}" ]; then
        # if BD_HOME isn't HOME then mimic the first step (i.e. when sudo su -)
        while read BD_AUTO_PATHS_LINE; do
            BD_ADD_PATHS+=("${BD_AUTO_PATHS_LINE}")
        done < "${BD_HOME}/${BD_AUTO_PATHS}"
        unset BD_AUTO_PATHS_LINE

        # if BD_HOME isn't HOME then mimic the second step
        BD_ADD_PATHS+=("${BD_HOME}")
    fi

    # if BD_HOME isn't HOME then mimic the third step
    BD_ADD_PATHS+=("${BD_HOME}/opt/static/${Uname_I}")
    BD_ADD_PATHS+=("${BD_HOME}/opt/${Os_Variant}/${Uname_I}")
    BD_ADD_PATHS+=("${BD_HOME}/opt")
    BD_ADD_PATHS+=("${BD_HOME}/src")
fi

# fifth, add common system directories to the BD_ADD_PATHS array
BD_ADD_PATHS+=("/opt/rh")
BD_ADD_PATHS+=("/opt")
BD_ADD_PATHS+=("/usr/local")
BD_ADD_PATHS+=("/usr")
BD_ADD_PATHS+=("/")

# sixth, add existing PATH to the BD_ADD_PATHS array (last)
BD_DEFAULT_PATHS=()
OIFS="${IFS}"
IFS=':' BD_DEFAULT_PATHS=(${PATH})
IFS="${OIFS}"
for BD_DEFAULT_PATH in "${BD_DEFAULT_PATHS[@]}"; do
    BD_ADD_PATHS+=("${BD_DEFAULT_PATH}")
done
unset BD_DEFAULT_PATH BD_DEFAULT_PATHS

# prepare the BD_BIN_PATHS array (a refined version of BD_ADD_PATHS that's cleaned & without duplicates)
BD_BIN_PATHS=()

# seventh, iterate through BD_ADD_PATHS & more intelligently add only qualifying elements to the BD_BIN_PATHS array
for BD_ADD_PATH in "${BD_ADD_PATHS[@]}"; do
    # strip comments from lines
    BD_ADD_PATH="${BD_ADD_PATH%#*}"

    # don't add these to the BD_BIN_PATHS array
    [ "${BD_ADD_PATH}" == "" ] && continue
    [ "${BD_ADD_PATH}" == "./" ] && continue
    [ "${BD_ADD_PATH:0:1}" == "#" ] && continue # no comments

    # check if this BD_ADD_PATH element is in the existing PATH
    if [[ "${PATH}" == "${BD_ADD_PATH}:"* ]] || [[ "${PATH}" == *":${BD_ADD_PATH}:"* ]] || [[ "${PATH}" == *":${BD_ADD_PATH}" ]]; then
        # add existing PATH element to BD_BIN_PATHS array
        if [ -r  "${BD_ADD_PATH}" ]; then
            # bypass duplicates; if it's already in the BD_BIN_PATHS array then don't add it again
            let BD_IN_PATH=0
            for BD_BIN_PATH in "${BD_BIN_PATHS[@]}"; do
                [ "${BD_ADD_PATH}" == "${BD_BIN_PATH}" ] && BD_IN_PATH=1 && break
            done
            unset BD_BIN_PATH
            [ ${BD_IN_PATH} -eq 0 ] && BD_BIN_PATHS+=("${BD_ADD_PATH}")
            unset BD_IN_PATH
        fi

        # don't continue (to add existing PATH element BD_SEARCH_PATHS)
        continue # maybe revisit this logic ... why not? performance.
    else
        # if the non-PATH BD_ADD_PATH element ends in a BD_SEARCH_PATHS value, then use its dirname (i.e. strip */bin)
        for BD_SEARCH_PATH in ${BD_SEARCH_PATHS}; do
            if [[ "${BD_ADD_PATH}" == *"/${BD_SEARCH_PATH}" ]]; then
                BD_ADD_PATH=${BD_ADD_PATH%/*}
            fi

            # don't let empty values go forward; root paths, e.g. /bin & /sbin, may get emptied by the above logic, so fix it
            [ -z "${BD_ADD_PATH}" ] && BD_ADD_PATH="${BD_SEARCH_PATH}"
        done
        unset BD_SEARCH_PATH
    fi

    # add existing & non-duplicate BD_SEARCH_PATHS to the BD_BIN_PATHS array
    for BD_SEARCH_PATH in ${BD_SEARCH_PATHS}; do
        if [ -r  "${BD_ADD_PATH}/${BD_SEARCH_PATH}" ]; then
            BD_ADD_BIN="${BD_ADD_PATH}/${BD_SEARCH_PATH}"
            BD_ADD_BIN="${BD_ADD_BIN//\/\//\/}" # compress // into /

            # bypass duplicates; if it's already in the BD_BIN_PATHS array then don't add it again
            let BD_IN_PATH=0
            for BD_SEARCH_PATH in "${BD_BIN_PATHS[@]}"; do
                [ "${BD_ADD_BIN}" == "${BD_SEARCH_PATH}" ] && BD_IN_PATH=1 && break
            done
            unset BD_SEARCH_PATH
            [ ${BD_IN_PATH} -eq 0 ] && BD_BIN_PATHS+=("${BD_ADD_BIN}")
            unset BD_IN_PATH BD_ADD_BIN
        fi
    done
    unset BD_SEARCH_PATH

    # if it's not / then look for BD_SEARCH_PATHS subdirectories & add them to the BD_BIN_PATHS array
    if [ "${BD_ADD_PATH}" != "/" ]; then
        for BD_SEARCH_PATH in ${BD_SEARCH_PATHS}; do
            for BD_SEARCH_BIN in "${BD_ADD_PATH}/"*"/${BD_SEARCH_PATH}"; do
                if [ -r  "${BD_SEARCH_BIN}" ]; then
                    BD_ADD_BIN="${BD_SEARCH_BIN}"
                    BD_ADD_BIN="${BD_ADD_BIN//\/\//\/}" # compress // into /

                    let BD_IN_PATH=0
                    for BD_SEARCH_PATH in "${BD_BIN_PATHS[@]}"; do
                        [ "${BD_ADD_BIN}" == "${BD_SEARCH_PATH}" ] && BD_IN_PATH=1 && break
                    done
                    unset BD_SEARCH_PATH

                    [ ${BD_IN_PATH} -eq 0 ] && BD_BIN_PATHS+=("${BD_ADD_BIN}") && unset BD_IN_PATH && unset BD_ADD_BIN
                fi
            done
            unset BD_SEARCH_BIN
        done
        unset BD_SEARCH_PATH
    fi
done
unset BD_ADD_PATH

# BD_ADD_PATHS isn't used anymore, so unset it
unset BD_ADD_PATHS

# build & export the new PATH
PATH="./"
for BD_BIN_PATH in "${BD_BIN_PATHS[@]}"; do
    PATH+=":${BD_BIN_PATH}"
done
unset BD_BIN_PATH

export PATH

# BD_BIN_PATHS isn't used anymore, so unset it
unset BD_BIN_PATHS

bd_debug "PATH=${PATH}" 13

#
# 2. build MANPATH
#

# prepare the BD_ADD_MANPATHS array
BD_ADD_MANPATHS=()

# first, add common system directories to the BD_ADD_MANPATHS array
BD_ADD_MANPATHS+=("/usr/local/share/man")
BD_ADD_MANPATHS+=("/usr/share/man")

# second, add existing MANPATH to the BD_ADD_MANPATHS array (last)
BD_DEFAULT_MANPATHS=()
OIFS="${IFS}"
IFS=':' BD_DEFAULT_MANPATHS=(${MANPATH})
IFS="${OIFS}"
for BD_DEFAULT_MANPATH in "${BD_DEFAULT_MANPATHS[@]}"; do
    BD_ADD_MANPATHS+=("${BD_DEFAULT_MANPATH}")
done
unset BD_DEFAULT_MANPATH BD_DEFAULT_MANPATHS

# prepare the BD_MAN_PATHS array
BD_MAN_PATHS=()

# third, iterate through BD_ADD_MANPATHS & more intelligently add only qualifying elements to the BD_MAN_PATHS array
for BD_ADD_MANPATH in "${BD_ADD_MANPATHS[@]}"; do
    [ "${BD_ADD_MANPATH}" == "" ] && continue
    [ "${BD_ADD_MANPATH}" == "./" ] && continue
    [ "${BD_ADD_MANPATH:0:1}" == "#" ] && continue # no comments

    # check if this BD_ADD_MANPATH element is in the existing MANPATH
    if [ -r  "${BD_ADD_MANPATH}" ]; then
        let BD_IN_MANPATH=0
        for BD_MAN_PATH in "${BD_MAN_PATHS[@]}"; do
            # bypass duplicates; if it's already in the BD_MAN_PATHS array then don't add it again
            let BD_IN_MANPATH=0
            [ "${BD_ADD_MANPATH}" == "${BD_MAN_PATH}" ] && BD_IN_MANPATH=1 && break
        done
        [ ${BD_IN_MANPATH} -eq 0 ] && BD_MAN_PATHS+=("${BD_ADD_MANPATH}")
        unset BD_IN_MANPATH
    fi
done
unset BD_MAN_PATH

# BD_ADD_MANPATHS isn't used anymore, so unset it
unset BD_ADD_MANPATHS

# build & export the new MANPATH
MANPATH=""
for BD_MAN_PATH in "${BD_MAN_PATHS[@]}"; do
    MANPATH+="${BD_MAN_PATH}:"
done
unset BD_MAN_PATH

MANPATH=${MANPATH%:*} # remove trailing :

export MANPATH

# BD_MAN_PATHS isn't used anymore, so unset it
unset BD_MAN_PATHS

bd_debug "MANPATH=${MANPATH}" 13

# bill cipher, we win again! aybabtu! 51923621 16189 6416 1961217

