#!groovy

@Library('github.com/teecke/jenkins-pipeline-library@v3.3.0') _

// Initialize global config
cfg = jplConfig('jenkins-dind', 'docker', '', [email:'pedroamador.rodriguez+teecke@gmail.com'])
String jenkinsVersion

def publishDockerImage(String jenkinsVersion) {
    docker.withRegistry("https://registry.hub.docker.com", 'teeckebot-docker-credentials') {
        docker.image("teecke/jenkins-dind:latest").push()
        docker.image("teecke/jenkins-dind:${jenkinsVersion}").push()
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
        stage ('Bash linter') {
            steps {
                script {
                    sh "devcontrol run-bash-linter"
                }
            }
        }
        stage ('Build') {
            steps {
                script {
                    sh "devcontrol build"
                }
            }
        }
        stage('Make release') {
            when { expression { cfg.BRANCH_NAME.startsWith('release/new') } }
            steps {
                publishDockerImage(jenkinsVersion)
                jplMakeRelease(cfg, true)
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
