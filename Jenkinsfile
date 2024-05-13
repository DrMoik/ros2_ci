pipeline {
    agent any

    stages {
        stage('Prepare Workspace') {
            steps {
                script {
                    dir('/home/user/ros2_ws/src') {
                        echo "Will check if we need to clone or just pull"
                        if (!fileExists('ros2_ci')) {
                            sh 'git clone https://github.com/DrMoik/ros2_ci.git'
                        } else {
                            dir('ros2_ci') {
                                sh 'git pull origin main'
                            }
                        }
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('/home/user/ros2_ws/src/') {
                    sh 'sudo docker build -f ros2_ci/Dockerfile -t ros2_ci_image .'
                }
            }
        }

        stage('Manage Docker Container') {
            steps {
                script {
                    if (sh(script: "sudo docker ps --filter 'name=ros2_jen' --filter 'status=running' | grep -q ros2_jen", returnStatus: true) == 0) {
                        echo "Container ros2_jen is running. Stopping container..."
                        sh 'sudo docker stop ros2_jen'
                    } else {
                        echo "Container ros2_jen is not running."
                    }
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                sh 'sudo docker run -d --rm --name ros2_jen --net=host -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix ros2_ci_image'
                sleep(10) 
                sh 'sudo docker exec ros2_jen /bin/bash -c "source /opt/ros/galactic/setup.bash && source /ros2_ws/install/setup.bash && colcon test --packages-select tortoisebot_waypoints --event-handler=console_direct+ && colcon test-result --all"'
            }
        }
    }
    
    post {
        always {
            echo 'Finish.'
        }
    }
}
