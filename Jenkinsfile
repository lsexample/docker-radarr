pipeline {
  agent any
  environment {
    RADARR_RELEASE = sh(
      script: '''curl -s https://api.github.com/repos/Radarr/Radarr/releases | jq -r '.[] | .tag_name' | head -1''',
      returnStdout: true).trim()
    RADARR_RELEASE_NOTES = sh(
      script: '''curl -s https://api.github.com/repos/Radarr/Radarr/releases | jq '.[] | .body' |head -1''',
      returnStdout: true).trim()
  }
  stages {
    stage('Build') {
      steps {
          echo 'Building most current release of Radarr'
          sh "docker build -t qcom/radarr:${RADARR_RELEASE} --build-arg radarr_tag=${RADARR_RELEASE} ."
        }
    }
    stage('Test') {
      steps {
       echo 'CI Tests for future use'
      }
    }
    stage('Compile-and-Push-Release') {
      when { branch "Release" }
      steps {
        echo 'First push the latest tag'
        sh "docker tag qcom/radarr:${RADARR_RELEASE} qcom/radarr:latest"
        sh "docker push qcom/radarr:latest"
        echo 'Pushing by release tag'
        sh "docker push qcom/radarr:${RADARR_RELEASE}"
      }
    }
  }
}
