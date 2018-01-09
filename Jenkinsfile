#!/usr/bin/env groovy

def RADARR_RELEASE = sh (
    script: '''curl -s https://api.github.com/repos/Radarr/Radarr/releases | jq -r '.[] | .tag_name' | head -1''',
    returnStdout: true
    ).trim()
def TAG_NAME = binding.variables.get("TAG_NAME")

pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building latest releases of Radarr'
                sh "docker build -t qcom/radarr:${RADARR_RELEASE} --build-arg radarr_tag=${RADARR_RELEASE} ."
            }
        }
        stage('Test') {
            steps {
                echo 'CI Tests for future use'
            }
        }
        stage('Push-Release') {
            when { branch "Release" }
            steps {
                if (TAG_NAME != null) {
                  echo 'First push the latest tag' 
                  sh "docker tag qcom/radarr:${RADARR_RELEASE} qcom/radarr:latest"
                  sh "docker push qcom/radarr:latest"
                  echo 'Now pushing the last 10 release tags for the remote project'
                  sh "docker push qcom/radarr:${RADARR_RELEASE}"
                } else {
                  error("Anything commited to the release branch must have a version tag")
                }
            }
        }
    }
}
