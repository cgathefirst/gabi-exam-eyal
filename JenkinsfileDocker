@Library('my-shared-library') _ 


pipeline {
    agent any
    stages {
        stage('SCM pull') {
            steps {
                echo 'Building application...'
            }
        }
        stage('Parallel Tests') {
            parallel {
                stage('Docker build') {
                    steps {
                        script {
                        dockerImage.dockerBuild()
                        }
                    }
                }

                stage('trivy scan') {
                    steps {
                        script {
                        trivyImage.trivyScan()
                        }
                    }
                }
                stage('bandit scan') {
                    steps {
                        script {
                        banditImage.banditScan()
                        }
                    }
                }
                stage('sonarqube scan') {
                    steps {
                        script {
                        sonarqubeImage.sonarqubeScan()
                        }
                    }
                }
            }
        }
        stage('docker push') {
            parallel {
                stage('Docker push') {
                    steps {
                        script {
                        dockerImage.dockerPush()
                        }
                    }
                }

                stage('Unit test') {
                    steps {
                        script {
                        dockerImage.dockerUnit()
                        }
                    }
                }
            }
        }
        stage('Deploy'){
            steps{
                script {
                        dockerImage.dockerDeploy()
                }
            }
        }
        stage('test'){
            steps{
                script {
                        dockerImage.dockerTest()
                }
            }
        }
        stage('Post install'){
            steps{
                script {
                        sh "echo 'Deploy' >> b.txt "
                }
            }
        }
        stage('sqscanner'){
            steps{
                script{
                    codeQuality.sonarCreateProject('gabi')
                    codeQuality.sonarLocalScan()
                }
            }
        }
    }
}
