pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = "976300215862"
        AWS_REGION = "us-east-1"

        IMAGE_NAME = "kumar-java-app"
        IMAGE_TAG = "v1"

        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"   
    }

    stages {
        stage('Checkout'){
            steps{
		cleanWs()
                git branch: 'main', url: 'https://github.com/vbkumar508-afk/java-example-kumar-jar.git'
            }
        }

       

        stage('Build Docker Image'){
            steps{
                sh 'docker build -t $IMAGE_NAME:$IMAGE_TAG .'
            }
        }

      stage('Trivy Scan') {
    steps {
        sh '''
        mkdir -p /var/tmp/trivy

        export TMPDIR=/var/tmp/trivy

        wget -O html.tpl \
        https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/html.tpl

        trivy image \
        --scanners vuln \
        --format template \
        --template "@html.tpl" \
        -o trivy-image-report.html \
        kumar-java-app:v1
        '''
    }
}

        stage('Login to AWS ECR') {
    steps {
        // 'aws-ecr-creds' is the ID of your credentials in Jenkins
        withAWS(credentials: 'aws-ecr-creds', region: "${AWS_REGION}") {
            sh '''
            aws ecr get-login-password --region $AWS_REGION | \
            docker login --username AWS --password-stdin \
            $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
            '''
        }
    }
}
        

        stage('Tag Docker Image'){
            steps{
                sh '''
                docker tag $IMAGE_NAME:$IMAGE_TAG \
                $ECR_REPO:$IMAGE_TAG
                '''
            }
        }

        stage('Push to ECR'){
            steps{
                sh 'docker push $ECR_REPO:$IMAGE_TAG'
            }
        }

        stage('Pull from ECR'){
            steps{
                sh 'docker pull $ECR_REPO:$IMAGE_TAG'
            }
        }

        stage('Deploy Container'){
            steps {
                sh '''
                docker run -d \
                --name java-app \
                -p 8085:8085 \
                $ECR_REPO:$IMAGE_TAG
                '''
            }
        }
    }

}
