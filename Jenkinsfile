#!groovy

@Library('github.com/red-panda-ci/jenkins-pipeline-library@v3.1.6') _

// Initialize global config
cfg = jplConfig('jenkins-dind', 'docker', '', [slack: '', email:'pedroamador.rodriguez+teecke@gmail.com'])
String jenkinsVersion

def publishDocumentation() {
    sh """
    git checkout ${cfg.BRANCH_NAME}
    make
    git add README.md
    git diff-files --quiet || git commit -m "Docs: Update README.md with Red Panda JPL"
    """
}
def publishDockerImage(String jenkinsVersion) {
    docker.withRegistry("https://registry.hub.docker.com", 'teeckebot-docker-credentials') {
        docker.build("teecke/jenkins-dind:latest").push()
        docker.build("teecke/jenkins-dind:${jenkinsVersion}").push()
    }
}

pipeline {
    agent { label 'docker' }

    stages {
        stage ('Initialize') {
            steps  {
                jplStart(cfg)
                script {
                    jenkinsVersion = sh (script: 'cat jenkins-version.ini|grep JENKINS_VERSION|cut -f 2 -d "="', returnStdout: true).trim()
                }
            }
        }
        stage ('Build') {
            steps {
                script {
                    sh """devcontrol build
                    docker tag teecke/jenkins-dind:$jenkinsVersion teecke/jenkins-dind:latest
                    """
                }
            }
        }
        stage('Make release') {
            when { expression { cfg.BRANCH_NAME.startsWith('release/new') } }
            steps {
                // publishDocumentation(jenkinsVersion)
                publishDockerImage(jenkinsVersion)
                jplMakeRelease(cfg, true)
                jplCloseRelease(cfg)
            }
        }
    }

    post {
        always {
            jplPostBuild(cfg)
        }
    }

    options {
        timestamps()
        ansiColor('xterm')
        buildDiscarder(logRotator(artifactNumToKeepStr: '20',artifactDaysToKeepStr: '30'))
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
    }
}
