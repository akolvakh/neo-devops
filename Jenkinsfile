pipeline {
  agent {
    kubernetes {
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: jenkins-kaniko
spec:
  serviceAccountName: jenkins-sa
  containers:
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.16.0-debug
      tty: true
      command:
        - cat
      volumeMounts:
        - name: workspace-volume
          mountPath: /workspace
    - name: git
      image: alpine/git:2.40.1
      tty: true
      command:
        - cat
      volumeMounts:
        - name: workspace-volume
          mountPath: /workspace
  volumes:
    - name: workspace-volume
      emptyDir: {}
"""
    }
  }

  environment {
    ECR_REGISTRY = "190403256762.dkr.ecr.us-east-1.amazonaws.com"
    IMAGE_NAME   = "lesson-5-dev-ecr"
    IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"
    COMMIT_EMAIL = "ci_akolvakh@localhost"
    COMMIT_NAME  = "ci_akolvakh"
  }
  stages {
    stage('Build & Push Docker Image') {
  steps {
    container('git') {
      withCredentials([usernamePassword(
          credentialsId: 'github-token',
          usernameVariable: 'GITHUB_USER',
          passwordVariable: 'GITHUB_PAT'
      )]) {
        sh '''
          git clone https://$GITHUB_USER:$GITHUB_PAT@github.com/$GITHUB_USER/neo-devops.git
          cd neo-devops
          git checkout lesson-8-9
          cd django
          cp -r . /workspace/
        '''
      }
    }
    container('kaniko') {
      sh '''
        /kaniko/executor \
          --context /workspace \
          --dockerfile /workspace/Dockerfile \
          --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \
          --cache=true
      '''
    }
  }
}

stage('Update Chart Tag in Git') {
  steps {
    container('git') {
      withCredentials([usernamePassword(
          credentialsId: 'github-token',
          usernameVariable: 'GITHUB_USER',
          passwordVariable: 'GITHUB_PAT'
      )]) {
        sh '''
          cd neo-devops
          git checkout lesson-8-9
          cd charts/django-app
          sed -i "s/tag: .*/tag: $IMAGE_TAG/" values.yaml
          git config user.email "$COMMIT_EMAIL"
          git config user.name "$COMMIT_NAME"
          git add values.yaml
          git commit -m "Update image tag to $IMAGE_TAG"
          git push origin lesson-8-9
        '''
      }
    }
  }
}


  }
}