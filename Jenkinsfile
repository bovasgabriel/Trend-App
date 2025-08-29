pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/bovasgabriel/Trend-App.git'
            }
        }

      }
    }
    stage('Configure kubeconfig') {
      steps {
        sh 'aws eks update-kubeconfig --name $EKS_CLUSTER --region $AWS_REGION --kubeconfig $KUBECONFIG'
      }
    }
    stage('Deploy to EKS') {
    steps {
        script {
            sh """
                echo "Deploying to Kubernetes..."
                kubectl --kubeconfig kubeconfig apply -f deployment.yaml
                kubectl --kubeconfig kubeconfig apply -f service.yaml

                echo "Checking rollout status..."
                kubectl --kubeconfig kubeconfig rollout status deployment/trend-app -n default --timeout=120s || true

                echo "Current Pods status:"
                kubectl --kubeconfig kubeconfig get pods -n default -o wide
            """
        }
    }
}


        stage('Build Docker Image') {
            steps {
                sh 'docker build -t bovasgabriel/trend-app:latest .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withDockerRegistry([ credentialsId: 'dockerhub-creds', url: '' ]) {
                    sh 'docker push bovasgabriel/trend-app:latest'
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                  echo "Deploying updated image to EKS..."
                  kubectl --kubeconfig /var/lib/jenkins/workspace/trend-ci-cd/kubeconfig set image deployment/trend-app trend-app=bovasgabriel/trend-app:latest -n default
                  kubectl --kubeconfig /var/lib/jenkins/workspace/trend-ci-cd/kubeconfig rollout status deployment/trend-app -n default --timeout=120s || true
                  kubectl --kubeconfig /var/lib/jenkins/workspace/trend-ci-cd/kubeconfig get pods -n default
                '''
            }
        }
    }  

}

