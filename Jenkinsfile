pipeline {
    agent any

    environment {
        ACCOUNT_ID = "976300215862"
        AWS_REGION = "us-east-1"
        IMAGE_NAME = "java25-demo-app"
        ECR_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/vbkumar508-afk/java-example-kumar-jar.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME:$BUILD_NUMBER .
                '''
            }
        }

        stage('AWS ECR Login') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-ecr'
                ]]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | \
                        docker login \
                        --username AWS \
                        --password-stdin \
                        $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                sh '''
                    docker tag $IMAGE_NAME:$BUILD_NUMBER $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                    docker push $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }

        stage('Pull Image from ECR') {
            steps {
                sh '''
                    docker pull $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }

        stage('Deploy Container') {
            steps {
                sh '''
                    docker stop new_image-container || true
                    docker rm new_image-container || true

                    docker run -d \
                    --name new_image-container \
                    -p 8083:8085 \
                    $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }
}
}
