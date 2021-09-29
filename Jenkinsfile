SECRETS = [
    [env: "GITHUB_OAUTH_TOKEN",     key: "github_token",                 path: "secret/eGA/tools/sonarqube"],
    [env: "GITHUB_URL",             key: "github_url",                   path: "secret/eGA/tools/ios/apple-developer"],
]

pipeline {
  agent {
    label "ios-parallel"
  }
  options {
    skipDefaultCheckout()
    ansiColor("xterm") // needs AnsiColor plugin (https://wiki.jenkins.io/display/JENKINS/AnsiColor+Plugin)
  }
  stages {
    stage("Checkout 📥") {
      steps {
        cleanWs()
        commonCheckout()
      }
    }

    stage("Bundler 💎") {
      steps {
        sh """#!/bin/bash -l
          export LC_ALL=en_US.UTF-8
          export LANG=en_US.UTF-8
          if ! [[ -e `which bundle` ]]; then
            gem install bundler
          fi
          bundle config set --local path "~/ruby"`ruby --version | sed 's/ruby \\([0-9\\.]*\\).*/\\1/'`"gems"
          bundle install
        """
      }
    }

    stage("CovPassCommon 🛠") {
      when {
        not {
          anyOf {
            branch 'master'
            branch 'release/*'
          }
        }
      }
      environment {
        PORT = "200"+"${env.EXECUTOR_NUMBER}"
      }
      steps {
        script {
          withSecrets(SECRETS) {
            sh """#!/bin/bash -l
              export LC_ALL=en_US.UTF-8
              export LANG=en_US.UTF-8
              bundle exec fastlane buildAndTestLane --swift_server_port ${PORT} root_path:Source/CovPassCommon path:Sources,Tests scheme:CovPassCommon coverage:0.0
            """
          }
        }
      }
      post {
        always {
          junit "fastlane/report.xml"
        }
      }
    }

    stage("CovPassUI 🏞") {
      when {
        not {
          anyOf {
            branch 'master'
            branch 'release/*'
          }
        }
      }
      environment {
        PORT = "200"+"${env.EXECUTOR_NUMBER}"
      }
      steps {
        script {
          withSecrets(SECRETS) {
            sh """#!/bin/bash -l
              export LC_ALL=en_US.UTF-8
              export LANG=en_US.UTF-8
              bundle exec fastlane buildAndTestLane --swift_server_port ${PORT} root_path:Source/CovPassUI path:Sources,Tests scheme:CovPassUI coverage:0.0
            """
          }
        }
      }
      post {
        always {
          junit "fastlane/report.xml"
        }
      }
    }

    stage("CovPassCheckApp ✅") {
      when {
        not {
          anyOf {
            branch 'master'
            branch 'release/*'
          }
        }
      }
      environment {
        PORT = "200"+"${env.EXECUTOR_NUMBER}"
      }
      steps {
        script {
          withSecrets(SECRETS) {
            sh """#!/bin/bash -l
              export LC_ALL=en_US.UTF-8
              export LANG=en_US.UTF-8
              bundle exec fastlane buildAndTestLane --swift_server_port ${PORT} root_path:Source/CovPassCheckApp path:Source,Tests scheme:CovPassCheckApp coverage:0.0
            """
          }
        }
      }
      post {
        always {
          junit "fastlane/report.xml"
        }
      }
    }

    stage("CovPassApp 🎫") {
      when {
        not {
          anyOf {
            branch 'master'
            branch 'release/*'
          }
        }
      }
      environment {
        PORT = "200"+"${env.EXECUTOR_NUMBER}"
      }
      steps {
        script {
          withSecrets(SECRETS) {
            sh """#!/bin/bash -l
              export LC_ALL=en_US.UTF-8
              export LANG=en_US.UTF-8
              bundle exec fastlane buildAndTestLane --swift_server_port ${PORT} root_path:Source/CovPassApp path:Source,Tests scheme:CovPassApp coverage:0.0
            """
          }
        }
      }
      post {
        always {
          junit "fastlane/report.xml"
        }
      }
    }
  }
}

// Groovy helper to execute a step with the secrets loaded as environment variales
//
// Would love to use
//
// ```
// environment {
//   ENV_VAR_NAME = credentials("key")
// }
// ```
//
// but the Vault plugin does not support the declarative syntax yet
// (see https://issues.jenkins-ci.org/browse/JENKINS-45685).
// There is also https://github.com/jenkinsci/hashicorp-vault-pipeline-plugin
// but this little helper is not really worth an additional plugin dependency.
//
// Must be called inside a `script` block.
def withSecrets(secrets, closure) {
    def vaultSecrets = secrets.collect { secret ->
        [
            $class: "VaultSecret",
            path: secret.path,
            secretValues: [
              [$class: "VaultSecretValue", vaultKey: secret.key, envVar: secret.env]
            ]
        ]
    }

    wrap([$class: "VaultBuildWrapper", vaultSecrets: vaultSecrets], closure)
}
