pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "your-dockerhub-username/your-app:${BUILD_NUMBER}"
        SONARQUBE_ENV = 'SonarQubeServer'      // Jenkins SonarQube name
        DOCKER_CREDENTIALS_ID = 'docker-creds' // Jenkins DockerHub creds
        GIT_CREDENTIALS_ID = 'git-creds'       // For pushing to GitOps repo
    }

    stages {

        stage('Checkout') {
            steps {
                git credentialsId: "${GIT_CREDENTIALS_ID}", url: 'https://github.com/your-repo/your-app.git'
            }
        }

        stage('SonarQube Code Analysis') {
            steps {
                withSonarQubeEnv("${SONARQUBE_ENV}") {
                    sh 'sonar-scanner'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Scan with Trivy') {
            steps {
                sh "trivy image --exit-code 1 --severity HIGH,CRITICAL ${DOCKER_IMAGE} || exit 1"
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_CREDENTIALS_ID}", usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Update K8s Manifest (GitOps)') {
            steps {
                script {
                    def manifestFile = "manifests/deployment.yaml"
                    sh """
                        sed -i 's|image: .*|image: ${DOCKER_IMAGE}|' ${manifestFile}
                        git config user.email "jenkins@example.com"
                        git config user.name "Jenkins CI"
                        git add ${manifestFile}
                        git commit -m "Update image to ${DOCKER_IMAGE}"
                        git push origin main
                    """
                }
            }
        }

        stage('Sync ArgoCD') {
            steps {
                sh "argocd app sync your-argocd-app-name"
            }
        }
    }

    post {
        success {
            echo "Deployment pipeline executed successfully."
        }
        failure {
            echo "Deployment failed. Check the logs."
        }
    }
}
