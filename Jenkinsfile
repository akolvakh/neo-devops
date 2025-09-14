/* 
  ===============================
  CI/CD PIPELINE ДЛЯ DJANGO APP
  ===============================
  
  Цей Jenkins pipeline виконує наступні завдання:
  1. Клонує код з GitHub репозиторію
  2. Збирає Docker образ за допомогою Kaniko
  3. Завантажує образ в Amazon ECR
  4. Оновлює Helm chart з новим тегом образу
  5. Відправляє зміни назад в Git репозиторій
*/

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

  // Змінні середовища для pipeline
  environment {
    ECR_REGISTRY = "190403256762.dkr.ecr.us-east-1.amazonaws.com"  // Адреса ECR реєстру
    IMAGE_NAME   = "lesson-5-dev-ecr"                              // Назва образу
    IMAGE_TAG    = "v1.0.${BUILD_NUMBER}"                          // Тег образу з номером збірки
    COMMIT_EMAIL = "ci_akolvakh@localhost"                          // Email для Git commit
    COMMIT_NAME  = "ci_akolvakh"                                   // Ім'я для Git commit
  }
  
  stages {
    // Етап 1: Збірка та завантаження Docker образу
    stage('Збірка та завантаження Docker образу') {
      steps {
        // Клонування коду з GitHub
        container('git') {
          withCredentials([usernamePassword(
              credentialsId: 'github-token',
              usernameVariable: 'GITHUB_USER',
              passwordVariable: 'GITHUB_PAT'
          )]) {
            sh '''
              echo "🔄 Клонування репозиторію..."
              git clone https://$GITHUB_USER:$GITHUB_PAT@github.com/$GITHUB_USER/neo-devops.git
              cd neo-devops
              git checkout lesson-8-9
              echo "📁 Копіювання Django коду..."
              cd django
              cp -r . /workspace/
              echo "✅ Код успішно підготовлено"
            '''
          }
        }
        
        // Збірка образу за допомогою Kaniko
        container('kaniko') {
          sh '''
            echo "🐳 Початок збірки Docker образу..."
            echo "📦 Образ: $ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
            /kaniko/executor \
              --context /workspace \
              --dockerfile /workspace/Dockerfile \
              --destination=$ECR_REGISTRY/$IMAGE_NAME:$IMAGE_TAG \
              --cache=true
            echo "✅ Образ успішно зібрано та завантажено в ECR"
          '''
        }
      }
    }

    // Етап 2: Оновлення тегу в Git репозиторії
    stage('Оновлення тегу в Git репозиторії') {
      steps {
        container('git') {
          withCredentials([usernamePassword(
              credentialsId: 'github-token',
              usernameVariable: 'GITHUB_USER',
              passwordVariable: 'GITHUB_PAT'
          )]) {
            sh '''
              echo "🔄 Оновлення Helm chart з новим тегом..."
              cd neo-devops
              git checkout lesson-8-9
              cd charts/django-app
              
              echo "📝 Поточний values.yaml:"
              cat values.yaml | grep -A5 -B5 tag
              
              echo "🔧 Оновлення тегу на: $IMAGE_TAG"
              sed -i "s/tag: .*/tag: $IMAGE_TAG/" values.yaml
              
              echo "📝 Оновлений values.yaml:"
              cat values.yaml | grep -A5 -B5 tag
              
              echo "💾 Збереження змін в Git..."
              git config user.email "$COMMIT_EMAIL"
              git config user.name "$COMMIT_NAME"
              git add values.yaml
              git commit -m "🚀 Оновлення тегу образу до $IMAGE_TAG [skip ci]"
              git push origin lesson-8-9
              
              echo "✅ Зміни успішно відправлені в репозиторій"
              echo "🎯 ArgoCD автоматично виявить зміни та оновить деплоймент"
            '''
          }
        }
      }
    }
  }
  
  // Пост-обробка pipeline
  post {
    success {
      echo """
        🎉 Pipeline успішно завершено!
        📦 Образ: ${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
        🚀 ArgoCD почне синхронізацію через декілька хвилин
      """
    }
    failure {
      echo """
        ❌ Pipeline завершився з помилкою!
        🔍 Перевірте логи вище для деталей
        💡 Можливі причини:
           - Проблеми з GitHub доступом
           - Помилки збірки Docker образу
           - Проблеми з ECR доступом
      """
    }
    cleanup {
      echo "🧹 Очищення workspace..."
    }
  }
}