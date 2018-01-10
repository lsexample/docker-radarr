pipeline {
  agent any
  environment {
    EXT_RELEASE = sh(
      script: '''curl -s https://api.github.com/repos/Radarr/Radarr/releases | jq -r '.[] | .tag_name' | head -1''',
      returnStdout: true).trim()
    EXT_RELEASE_NOTES = sh(
      script: '''curl -s https://api.github.com/repos/Radarr/Radarr/releases | jq '.[] | .body' |head -1 | sed 's:^.\\(.*\\).$:\\1:' ''',
      returnStdout: true).trim()
    LS_RELEASE = sh(
      script: '''curl -s https://api.github.com/repos/lsexample/docker-radarr/tags | jq -r '.[] | .name' |head -1''',
      returnStdout: true).trim()
    LS_RELEASE_NOTES = sh(
      script: '''git log -1 --pretty=%B | sed 's/$/\\\\n/' | tr -d '\\n' ''',
      returnStdout: true).trim()
    GITHUB_DATE = sh(
      script: '''date '+%Y-%M-%dT%H:%M:%S%:z' ''',
      returnStdout: true).trim()
    COMMIT_SHA = sh(
      script: '''git rev-parse HEAD''',
      returnStdout: true).trim()
    BUILDS_DISCORD = credentials('build_webhook_url')
    DOCKERHUB_PASS = credentials('dockerhub_pass')
    GITHUB_TOKEN = credentials('github_token')
  }
  stages {
    stage('Prep-and-tag'){
      steps {
       script {
          LS_TAG = sh(
            script: '''if [ "$(git describe --exact-match --tags HEAD 2>/dev/null)" == $LS_RELEASE ]; then echo $LS_RELEASE; else echo $(($LS_RELEASE + 1)) ; fi''',
            returnStdout: true).trim()
          NEW_TAG = sh(
            script: '''if [ "$(git describe --exact-match --tags HEAD 2>/dev/null)" == $LS_RELEASE ]; then echo false; else echo true ; fi''',
            returnStdout: true).trim()
        }
        echo "LS Tag for project ${LS_TAG} newtag: ${NEW_TAG}"
      }
    }
    stage('Build') {
      steps {
          echo "Building most current release of Radarr"
          sh "docker build --no-cache -t qcom/radarr:${EXT_RELEASE}-ls${LS_TAG} --build-arg radarr_tag=${EXT_RELEASE} ."
        }
    }
    stage('Test') {
      steps {
       echo 'CI Tests for future use'
      }
    }
    stage('Docker-Push-Release') {
      when { branch "Release" }
      steps {
        sh "echo ${DOCKERHUB_PASS} | docker login -u qcom --password-stdin"
        echo 'First push the latest tag'
        sh "docker tag qcom/radarr:${EXT_RELEASE}-ls${LS_TAG} qcom/radarr:latest"
        sh "docker push qcom/radarr:latest"
        echo 'Pushing by release tag'
        sh "docker push qcom/radarr:${EXT_RELEASE}-ls${LS_TAG}"
      }
    }
    stage('Github-Tag-Push-Release') {
      when { branch "master" }
      steps {
        echo "Pushing New tag for current commit ${EXT_RELEASE}-ls${LS_TAG}"
        sh '''curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST https://api.github.com/repos/lsexample/docker-radarr/git/tags -d '{"tag":"'${EXT_RELEASE}'-ls'${LS_TAG}'","object": "${COMMIT_SHA}","message": "Tagging Release '${EXT_RELEASE}'-ls'${LS_TAG}' to master","type": "commit",  "tagger": {"name": "LinuxServer Jenkins","email": "jenkins@linuxserver.io","date": "'${GITHUB_DATE}'"}}' '''
        echo "Pushing New release for Tag"
        sh ''' curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST https://api.github.com/repos/lsexample/docker-radarr/releases -d '{"tag_name":"'${EXT_RELEASE}'-ls'${LS_TAG}'","target_commitish": "master","name": "'${EXT_RELEASE}'-ls'${LS_TAG}'","body": "**LinuxServer Changes:**\\n\\n'${LS_RELEASE_NOTES}'\\nRadarr Changes:\\n\\n'${EXT_RELEASE_NOTES}'","draft": false,"prerelease": false}' '''
      }
    }
    stage('Docker-Push-Feature') {
      when { 
        not { 
         branch "Release" 
        }
      }
      steps {
        echo "nothing for now"
      }
    }
  }
  post { 
    success {
      echo "Build good send details to discord"
      sh ''' curl -X POST --data '{"avatar_url": "https://wiki.jenkins-ci.org/download/attachments/2916393/headshot.png","embeds": [{"color": 1681177,"description": "**Build:**  '${BUILD_NUMBER}'\\n**Status:**  Success\\n**Job:** '${RUN_DISPLAY_URL}'\\n"}],"username": "Jenkins"}' ${BUILDS_DISCORD} '''
    }
    failure {
      echo "Build Bad sending details to discord"
      sh ''' curl -X POST --data '{"avatar_url": "https://wiki.jenkins-ci.org/download/attachments/2916393/headshot.png","embeds": [{"color": 16711680,"description": "**Build:**  '${BUILD_NUMBER}'\\n**Status:**  failure\\n**Job:** '${RUN_DISPLAY_URL}'\\n"}],"username": "Jenkins"}' ${BUILDS_DISCORD} '''
    }
  }
}
