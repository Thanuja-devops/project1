pipeline {
    agent any

    tools {
        maven '3.9.11'
        jdk 'java17'
    }

    environment {
        APP_NAME = 'country-chicken-backend'
        NEXUS_DOCKER_URL = '172.31.15.25:8083'
        VERSION = ''
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Thanuja-devops/project1.git'
            }
        }

        stage('Read Version') {
            steps {
                script {
                    VERSION = sh(
                        script: "mvn help:evaluate -Dexpression=project.version -q -DforceStdout",
                        returnStdout: true
                    ).trim()

                    if (!VERSION) {
                        error "Version not found in pom.xml"
                    }

                    echo "Building version: ${VERSION}"
                }
            }
        }

        stage('Build & Deploy JAR to Nexus') {
            steps {
                sh 'mvn clean deploy -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build \
                  -t ${NEXUS_DOCKER_URL}/${APP_NAME}:${VERSION} .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus-docker-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login ${NEXUS_DOCKER_URL} -u "$DOCKER_USER" --password-stdin
                    docker push ${NEXUS_DOCKER_URL}/${APP_NAME}:${VERSION}
                    docker logout ${NEXUS_DOCKER_URL}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Build, Nexus deploy & Docker push successful"
        }
        always {
            sh 'docker system prune -f'
            cleanWs()
        }
    }
}
