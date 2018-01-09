pipeline {
  agent any
  environment {
    EXT_REPO_URL = 'https://api.github.com/repos/Radarr/Radarr/releases'
    LS_REPO_URL = 'https://api.github.com/repos/lsexample/docker-radarr/tags'
    EXT_RELEASE = sh(
      script: '''curl -s ${EXT_REPO_URL} | jq -r '.[] | .tag_name' | head -1''',
      returnStdout: true).trim()
    EXT_RELEASE_NOTES = sh(
      script: '''curl -s ${EXT_REPO_URL} | jq '.[] | .body' |head -1 | sed 's:^.\(.*\).$:\1:' ''',
      returnStdout: true).trim()
    LS_RELEASE = sh(
      script: '''curl -s ${LS_REPO_URL} | jq '.[] | .name' |head -1''',
      returnStdout: true).trim()
  }
  stages {
    stage('Build') {
      steps {
          echo 'Building most current release of Radarr'
          sh "docker build --no-cache -t qcom/radarr:${EXT_RELEASE} --build-arg radarr_tag=${EXT_RELEASE} ."
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
        sh "docker tag qcom/radarr:${EXT_RELEASE} qcom/radarr:latest"
        sh "docker push qcom/radarr:latest"
        echo 'Pushing by release tag'
        sh "docker push qcom/radarr:${EXT_RELEASE}"
      }
    }
  }
}
