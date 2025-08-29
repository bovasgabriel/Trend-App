pipeline {
  agent any
  environment {
    DOCKERHUB_USER = 'bovasgabriel'
    DOCKERHUB_REPO = 'trend'
    IMAGE          = "${DOCKERHUB_USER}/${DOCKERHUB_REPO}:${env.BUILD_NUMBER}"

    AWS_REGION   = 'ap-south-1'
    EKS_CLUSTER  = 'trend-cluster'
    KUBE_NS      = 'default'
    KUBECONFIG   = "${WORKSPACE}/kubeconfig"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build Docker image') {
      steps { sh 'docker build -t $IMAGE .' }
    }
    stage('Push to DockerHub') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DH_USER', passwordVariable: 'DH_PASS')]) {
          sh 'echo $DH_PASS | docker login -u $DH_USER --password-stdin'
          sh 'docker push $IMAGE'
          sh 'docker tag $IMAGE $DOCKERHUB_USER/$DOCKERHUB_REPO:latest'
          sh 'docker push $DOCKERHUB_USER/$DOCKERHUB_REPO:latest'
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
        sh '''
          kubectl --kubeconfig $KUBECONFIG get deploy trend-web -n $KUBE_NS >/dev/null 2>&1 \
          && kubectl --kubeconfig $KUBECONFIG set image deploy/trend-web trend-web=$IMAGE -n $KUBE_NS \
          || kubectl --kubeconfig $KUBECONFIG apply -f k8s/
        '''
        sh 'kubectl --kubeconfig $KUBECONFIG rollout status deployment/trend-web -n $KUBE_NS'
      }
    }
  }
  post {
    always { sh 'docker logout || true' }
  }
}
