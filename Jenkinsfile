pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('docker_hub_login')  // Ensure this matches the actual credentials ID in Jenkins
        BACKEND_IMAGE = "deeeye2/mohamed.cv"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out the code from GitHub repository'
                git url: 'https://github.com/deeeye2/mohmed-cv.git', branch: 'master'
                script {
                    echo 'Listing files in the workspace after checkout:'
                    sh 'ls -al'
                }
            }
        }
        
        stage('Build Backend Image') {
            steps {
                script {
                    echo 'Building backend Docker image'
                    echo 'Listing files in the root directory:'
                    sh 'ls -al'
                    sh 'docker build -t $BACKEND_IMAGE:v1.0.8 .'
                }
            }
        }
        
        stage('Push Backend Image') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                script {
                    echo 'Pushing backend Docker image to DockerHub'
                    docker.withRegistry('https://index.docker.io/v1/', 'docker_hub_login') {
                        sh 'docker push $BACKEND_IMAGE:v1.0.8'
                    }
                }
            }
        }
    }
    
    post {
        always {
            script {
                echo 'Cleaning up Docker images'
                sh 'docker rmi $BACKEND_IMAGE:v1.0.8 || true'
            }
        }
        success {
            echo 'Docker images built and pushed successfully.'
        }
        failure {
            echo 'Failed to build or push Docker images.'
        }
    }
}
