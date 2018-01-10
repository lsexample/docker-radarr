pipeline {
  agent any
  environment {
    EXT_USER = 'Radarr'
    EXT_REPO = 'Radarr'
    LS_USER = 'lsexample'
    LS_REPO = 'docker-radarr'
    DOCKERHUB_IMAGE = 'qcom/radarr'
    DOCKERHUB_USER = 'qcom'
    BUILDS_DISCORD = credentials('build_webhook_url')
    DOCKERHUB_PASS = credentials('dockerhub_pass')
    GITHUB_TOKEN = credentials('github_token')
  }
  stages {
    stage("Set ENV Variables"){
      steps{
        script{
          env.EXT_RELEASE = sh(
            script: '''curl -s https://api.github.com/repos/${EXT_USER}/${EXT_REPO}/releases | jq -r '.[] | .tag_name' | head -1''',
            returnStdout: true).trim()
          env.EXT_RELEASE_NOTES = sh(
            script: '''curl -s https://api.github.com/repos/${EXT_USER}/${EXT_REPO}/releases | jq '. | .[0].body' | sed 's:^.\\(.*\\).$:\\1:' | sed 's/[][`~!@#$%^&*()-_=+{}\\|;:",<.>/?'"'"']/\\\\&/g' ''',
            returnStdout: true).trim()
          env.LS_RELEASE = sh(
            script: '''curl -s https://api.github.com/repos/${LS_USER}/${LS_REPO}/tags | jq -r '.[] | .name' |head -1''',
            returnStdout: true).trim()
          env.LS_RELEASE_NOTES = sh(
            script: '''git log -1 --pretty=%B | sed 's/$/\\\\\\n/' | tr -d '\\\\n' ''',
            returnStdout: true).trim()
          env.GITHUB_DATE = sh(
            script: '''date '+%Y-%m-%dT%H:%M:%S%:z' ''',
            returnStdout: true).trim()
          env.COMMIT_SHA = sh(
            script: '''git rev-parse HEAD''',
            returnStdout: true).trim()
        }
        script{
          env.LS_TAG = sh(
            script: '''if [ "$(git describe --exact-match --tags HEAD 2>/dev/null)" == ${LS_RELEASE} ]; then echo ${LS_RELEASE}; else echo $((${LS_RELEASE} + 1)) ; fi''',
            returnStdout: true).trim()
          env.NEW_TAG = sh(
            script: '''if [ "$(git describe --exact-match --tags HEAD 2>/dev/null)" == ${LS_RELEASE} ]; then echo false; else echo true ; fi''',
            returnStdout: true).trim()
        }
      }
    }
    stage('Build') {
      steps {
          echo "Building most current release of ${EXT_REPO}"
          sh "docker build --no-cache -t ${DOCKERHUB_IMAGE}:${EXT_RELEASE}-ls${LS_TAG} --build-arg radarr_tag=${EXT_RELEASE} ."
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
        sh "echo ${DOCKERHUB_PASS} | docker login -u ${DOCKERHUB_USER} --password-stdin"
        echo 'First push the latest tag'
        sh "docker tag ${DOCKERHUB_IMAGE}:${EXT_RELEASE}-ls${LS_TAG} ${DOCKERHUB_IMAGE}:latest"
        sh "docker push ${DOCKERHUB_IMAGE}:latest"
        echo 'Pushing by release tag'
        sh "docker push ${DOCKERHUB_IMAGE}:${EXT_RELEASE}-ls${LS_TAG}"
      }
    }
    stage('Github-Tag-Push-Release') {
      when { branch "master" }
      steps {
        echo "Pushing New tag for current commit ${EXT_RELEASE}-ls${LS_TAG}"
        sh '''curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST https://api.github.com/repos/${LS_USER}/${LS_REPO}/git/tags -d '{"tag":"'${EXT_RELEASE}'-ls'${LS_TAG}'","object": "'${COMMIT_SHA}'","message": "Tagging Release '${EXT_RELEASE}'-ls'${LS_TAG}' to master","type": "commit",  "tagger": {"name": "LinuxServer Jenkins","email": "jenkins@linuxserver.io","date": "'${GITHUB_DATE}'"}}' '''
        echo "Pushing New release for Tag"
        sh ''' curl -H "Authorization: token ${GITHUB_TOKEN}" -X POST https://api.github.com/repos/${LS_USER}/${LS_REPO}/releases -d '{"tag_name":"'${EXT_RELEASE}'-ls'${LS_TAG}'","target_commitish": "master","name": "'${EXT_RELEASE}'-ls'${LS_TAG}'","body": "**LinuxServer Changes:**\\n\\n'${LS_RELEASE_NOTES}'\\n'${EXT_REPO}' Changes:\\n\\n'${EXT_RELEASE_NOTES}'","draft": false,"prerelease": false}' '''
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
}
