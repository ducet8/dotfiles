#!/usr/bin/env bash
# Set the OS variant environment variables

Os_Id=""
Os_Version_Id=""
Os_Version_Major=""
Os_Wsl=0

# Identify Windows Subsystem for Linux kernel
if uname -r | grep -q Microsoft; then Os_Wsl=1; fi

# Identify Linux Standard Base distributions
if [ -r /etc/os-release ]; then
    if [ ${#Os_Id} -eq 0 ]; then
        Os_Id=$(sed -nEe 's#"##g;s#^ID=(.*)$#\1#p' /etc/os-release)
    fi
    if [ ${#Os_Name} -eq 0 ]; then
        Os_Name=$(sed -nEe 's#"##g;s#^NAME=(.*)$#\1#p' /etc/os-release)
    fi
    if [ ${#Os_Pretty_Name} -eq 0 ]; then
        Os_Pretty_Name=$(sed -nEe 's#"##g;s#^PRETTY_NAME=(.*)$#\1#p' /etc/os-release)
        if [ ${Os_Wsl} -eq 1 ]; then
            Os_Pretty_Name+=" (WSL)"
        fi
    fi
    if [ ${#Os_Version_Id} -eq 0 ]; then
        Os_Version_Id=$(sed -nEe 's#"##g;s#^VERSION_ID=(.*)$#\1#p' /etc/os-release)
    fi
fi

# Identify older, non-lsb RHEL variants
if [ ${#Os_Id} -eq 0 ]; then
    if [ -r /etc/redhat-release ]; then
        Os_Id=rhel
        Os_Version_Id=$(sed 's/[^.0-9][^.0-9]*//g' /etc/redhat-release)
    fi
fi

# Identify Apple Darwin distributions
if [ ${#Os_Id} -eq 0 ]; then
    if uname -s | grep -q Darwin; then
        Os_Id=Darwin
        Os_Version_Id=$(/usr/bin/sw_vers -productVersion 2> /dev/null)
        if [ ${#Os_Pretty_Name} -eq 0 ]; then
            Os_Pretty_Name="${Os_Id} ${Os_Version_Id}"
        fi
    fi
fi

# Identify OS major version
Os_Version_Major=${Os_Version_Id%.*}
if [ "${Os_Version_Id}" == "${Os_Version_Id}" ]; then
    Os_Version_Major=""
fi

##
# Set Os_ variables
##
export Os_Id Os_Version_Id Os_Version_Major Os_Wsl Os_Pretty_Name

if [ ${#Os_Id} -gt 0 ]; then
    if [ ${#Os_Version_Major} -gt 0 ]; then
        export Os_Variant="${Os_Id}/${Os_Version_Major}"
    else
        export Os_Variant="${Os_Id}"
    fi
fi
