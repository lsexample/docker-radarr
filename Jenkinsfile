pipeline {
    agent any
    stages {
        stage('ReleaseInfo') {
            steps {
                sh '''curl -s https://api.github.com/repos/Radarr/Radarr/releases | jq -r '.[] | .tag_name' | head -10 > releases.txt'''
            }
        }
        stage('Build') {
            steps {
                echo 'Building last 10 releases of Radarr'
                sh '''for version in $(cat releases.txt); do 
                        docker build -t qcom/radarr:$version --build-arg radarr_tag=$version . 
                      done'''
            }
        }
        stage('Test') {
            steps {
                echo 'CI Tests for future use'
            }
        }
        stage('Push') {
            steps {
                echo 'First push the latest tag'
                sh 'docker tag qcom/radarr:$(cat releases.txt |head -1) qcom/radarr:latest'
                sh 'docker push qcom/radarr:latest'
                echo 'Now pushing the last 10 release tags for the remote project'
                sh '''for version in $(cat releases.txt); do 
                        docker push qcom/radarr:$version
                      done'''
            }
        }
    }
}
