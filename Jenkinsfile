pipeline {
  agent any
  stages {
    stage('Radarr-Release') {
      steps {
        script {
          RADARR_RELEASE = sh(
            script: '''curl -s https://api.github.com/repos/Radarr/Radarr/releases | jq -r '.[] | .tag_name' | head -1''', 
            returnStdout: true).trim()
        }
      }
    }
    stage('Build') {
      steps {
          echo 'Building last 10 releases of Radarr'
          sh "docker build -t qcom/radarr:${RADARR_RELEASE} --build-arg radarr_tag=${RADARR_RELEASE} ."
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
        sh 'docker tag qcom/radarr:${RADARR_RELEASE} qcom/radarr:latest'
        sh 'docker push qcom/radarr:latest'
        echo 'Pushing by release tag'
        sh "docker push qcom/radarr:${RADARR_RELEASE}"
      }
    }
  }
}
