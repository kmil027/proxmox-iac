pipeline {
    agent any

    environment {
        // Mapeamos los secretos de Jenkins a variables que Terraform entiende
        TF_VAR_proxmox_api_token_id     = credentials('PROXMOX_TOKEN_ID')
        TF_VAR_proxmox_api_token_secret = credentials('PROXMOX_TOKEN_SECRET')
    }

    stages {
        stage('Validar Entorno') {
            steps {
                sh 'terraform version'
                sh 'ansible --version'
            }
        }

        // stage('Limpieza y Checkout') {
        //     steps {
        //         cleanWs() 
        //         checkout scm
        //     }
        // }

        stage('Terraform Apply') {
            steps {
                dir('terraform') { // Cambia a tu carpeta de terraform
                    // sh 'terraform init'
                    // sh 'terraform destroy -auto-approve'
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }

        // stage('Ansible Config') {
        //     steps {
        //         dir('ansible') { // Cambia a tu carpeta de ansible
        //             sshagent(['ssh-proxmox-key']) { // El ID de la credencial que creaste en Jenkins
        //                 // sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible all -i hosts.ini -m ping -e "ansible_python_interpreter=/usr/bin/python3"'
        //                 sh 'ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i hosts.ini setup.yml'
        //             }
        //         }
        //     }
        // }
    }

    post {
        always {
            echo 'Limpiando entorno...'
        }
        success {
            echo '¡Infraestructura desplegada y configurada con éxito!'
        }
    }
}