pipeline {
    agent any

    environment {
        ACCOUNT_ID = "976300215862"
        AWS_REGION = "us-east-1"
        IMAGE_NAME = "java25-demo-app"
        ECR_REPO = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"
    }

    stages {

        stage('1. Checkout Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/vbkumar508-afk/java-example-kumar-jar.git'
            }
        }

        stage('2. Build Docker Image') {
            steps {
                sh '''
                    docker build -t $IMAGE_NAME:$BUILD_NUMBER .
                '''
            }
        }

        stage('Trivy Image Scan') {
    steps {
        sh '''
            set -e

            echo "Workspace: $(pwd)"
            ls -lah

            mkdir -p $HOME/trivy-cache
            mkdir -p $HOME/trivy-tmp
            export TMPDIR=$HOME/trivy-tmp

            IMAGE="java25-demo-app:$BUILD_NUMBER"

            echo "Scanning image: $IMAGE"

            docker images | grep java25-demo-app || true

            trivy image \
                --scanners vuln \
                --cache-dir $HOME/trivy-cache \
                --no-progress \
                -o trivy-image-report.html \
                $IMAGE

            echo "Checking report file..."
            ls -lah trivy-image-report.html || true
        '''
    }
}
            
        

        stage('4. AWS ECR Login') {
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

        stage('5. Tag Docker Image') {
            steps {
                sh '''
                    docker tag $IMAGE_NAME:$BUILD_NUMBER $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }

        stage('6. Push Image to ECR') {
            steps {
                sh '''
                    docker push $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }

        stage('7. Pull Image from ECR') {
            steps {
                sh '''
                    docker pull $ECR_REPO:$BUILD_NUMBER
                '''
            }
        }

        stage('8. Deploy Container') {
            steps {
                sh '''
                    docker stop java25-container || true
                    docker rm java25-container || true

                    docker run -d \
                    --name java25-container \
                    -p 8085:8085 \
                    $ECR_REPO:$BUILD_NUMBER \
                    java -jar target/java-example-demo-1.0.0.jar
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'trivy-image-report.html', allowEmptyArchive: true
        }
    }
}
