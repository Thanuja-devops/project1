pipeline {
    agent any

    tools {
        maven '3.9.11'
        jdk   'java17'
    }

    environment {
        NEXUS_URL = "http://NEXUS_SERVER_IP:8081"
        NEXUS_MAVEN_REPO = "maven-releases"
        NEXUS_DOCKER_REGISTRY = "NEXUS_SERVER_IP:8083"

        APP_NAME = "country-chicken-backend"
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'YOUR_GIT_REPO_URL'
            }
        }

        stage('Maven Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Publish JAR to Nexus') {
            steps {
                sh """
                mvn deploy -DskipTests \
                -DaltDeploymentRepository=nexus::default::${NEXUS_URL}/repository/${NEXUS_MAVEN_REPO}
                """
            }
        }

        stage('Docker Build') {
            steps {
                sh """
                docker build -t ${NEXUS_DOCKER_REGISTRY}/${APP_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage('Docker Push to Nexus') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'nexus-docker-creds',
                    usernameVariable: 'NEXUS_USER',
                    passwordVariable: 'NEXUS_PASS'
                )]) {
                    sh """
                    docker login ${NEXUS_DOCKER_REGISTRY} -u ${NEXUS_USER} -p ${NEXUS_PASS}
                    docker push ${NEXUS_DOCKER_REGISTRY}/${APP_NAME}:${IMAGE_TAG}
                    """
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -f'
        }
    }
}
