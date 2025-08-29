pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
        IMAGE_NAME = "bovasgabriel/trend-app:latest"
        KUBECONFIG_PATH = "/var/lib/jenkins/workspace/trend-ci-cd/kubeconfig"
    }

    stages {
        stage('Checkout') {
            steps {
                echo "Checking out code from GitHub..."
                git branch: 'main', url: 'https://github.com/bovasgabriel/Trend-App.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                sh "docker build -t ${IMAGE_NAME} ."
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo "Pushing Docker image to DockerHub..."
                withDockerRegistry([ credentialsId: 'dockerhub-creds', url: '' ]) {
                    sh "docker push ${IMAGE_NAME}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                echo "Deploying application to EKS..."
                sh """
                    kubectl --kubeconfig ${KUBECONFIG_PATH} set image deployment/trend-app trend-app=${IMAGE_NAME} -n default
                    kubectl --kubeconfig ${KUBECONFIG_PATH} rollout status deployment/trend-app -n default --timeout=120s || true
                    kubectl --kubeconfig ${KUBECONFIG_PATH} get pods -n default
                """
            }
        }
    }

    post {
        always {
            echo "Pipeline finished."
        }
    }
}

