# vim: ft=sh
# Forked from: joseph.tingiris@gmail.com
# 2023.08.14 - ducet8@outlook.com

kubectl-events {
    {
        echo $'TIME\tNAMESPACE\tTYPE\tREASON\tOBJECT\tSOURCE\tMESSAGE';
        kubectl get events -o json "$@" \
            | jq -r  '.items | map(. + {t: (.eventTime//.lastTimestamp)}) | sort_by(.t)[] | [.t, .metadata.namespace, .type, .reason, .involvedObject.kind + "/" + .involvedObject.name, .source.component + "," + (.source.host//"-"), .message] | @tsv';
    } \
        | column -s $'\t' -t \
        | less -S
}
