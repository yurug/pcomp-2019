#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

readonly data=$1; shift
readonly user=$1; shift
readonly view=$1; shift
readonly changes=$1; shift

docker run\
       aquamen\
       /home/docker/pcomp-2019/defis/1/aquamen/scripts/run.sh\
       ${data}\
       ${user}\
       ${view}\
       ${changes}
