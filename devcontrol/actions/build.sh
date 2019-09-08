#!/bin/bash

set -euo pipefail

# @description Build the teecke/jenkins-dind docker image
#
# @example
#   build
#
# @arg $1 Task: "brief", "help" or "exec"
#
# @exitcode The exit code of the statements of the action
#
# @stdout "Not implemented" message if the requested task is not implemented
#
function build() {

    # Init
    local briefMessage
    local helpMessage
    briefMessage="Build the teecke/jenkins-dind docker image"
    helpMessage=$(cat <<EOF
Build the Jenkins Dind image.
It is based in a combination of jenkins/jenkins:lts docker image and docker:dind
EOF
)

    # Task choosing
    case $1 in
        brief)
            showBriefMessage "${FUNCNAME[0]}" "$briefMessage"
            ;;
        help)
            showHelpMessage "${FUNCNAME[0]}" "$helpMessage"
            ;;
        exec)
            checkDocker
            # Get jenkins version
            source jenkins-version.ini
            # Prepare build directory
            baseDir="$(pwd)"
            buildDir="$(mktemp -d)"
            cd "${buildDir}"
            git clone --quiet https://github.com/jenkinsci/docker.git .
            rsync -a "${baseDir}/resources/" resources/
            # Make "frankenstein" teecke/jenkins-dind Dockerfile
            echo "FROM docker:dind" > Dockerfile-teecke-jenkins-dind
            cat resources/Dockerfile.teecke-jenkins-dind.partial >> Dockerfile-teecke-jenkins-dind
            grep -v "^FROM\|^ENTRYPOINT" Dockerfile-alpine >> Dockerfile-teecke-jenkins-dind 
            echo "USER root" >> Dockerfile-teecke-jenkins-dind
            # Build the teecke/jenkins-dind docker image
            docker build --pull --build-arg JENKINS_VERSION="${JENKINS_VERSION}" --build-arg JENKINS_SHA="${JENKINS_SHA}" --file Dockerfile-teecke-jenkins-dind -t teecke/jenkins-dind:"${JENKINS_VERSION}" .
            docker build --pull --build-arg JENKINS_VERSION="${JENKINS_VERSION}" --build-arg JENKINS_SHA="${JENKINS_SHA}" --file Dockerfile-teecke-jenkins-dind -t teecke/jenkins-dind:latest .
            # Prune build dir
            cd "${baseDir}" || exit 1
            rm -rf "${buildDir}"
            ;;
        *)
            showNotImplemtedMessage "$1" "${FUNCNAME[0]}"
            return 1
    esac
}

# Main
build "$@"