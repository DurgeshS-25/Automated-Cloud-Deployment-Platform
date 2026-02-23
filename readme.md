# ☁️ Cloud Deployment Platform

> Automated AWS infrastructure deployment with Terraform, Docker, and CI/CD for zero-downtime deployments.

[![Terraform](https://img.shields.io/badge/Terraform-1.6+-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![Docker](https://img.shields.io/badge/Docker-Multi--Stage-2496ED?logo=docker)](https://www.docker.com/)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.2-6DB33F?logo=spring-boot)](https://spring.io/)

---

## 🎯 Overview

Production-grade deployment platform demonstrating enterprise DevOps practices: Infrastructure as Code with Terraform, containerization with Docker, automated CI/CD with GitHub Actions, and blue-green deployments for zero downtime.

**Key Achievement:** Automates deployment from code commit to production in AWS with instant rollback capability.

---

## 🏗️ Architecture
```
GitHub → CI/CD Pipeline → AWS (VPC → ALB → Blue/Green EC2 → CloudWatch)
```

**Infrastructure:**
- Multi-AZ VPC with public/private subnets
- Application Load Balancer with health checks
- Blue-Green Auto Scaling Groups (EC2 t3.micro)
- CloudWatch monitoring and alarms
- ECR for Docker image storage

**Deployment Flow:**
1. Code pushed to GitHub
2. GitHub Actions: Build → Test → Docker Build → Push to ECR
3. EC2 instances auto-pull new image
4. Health checks validate deployment
5. ALB switches traffic (zero downtime)

---

## ✨ Features

- ✅ **Infrastructure as Code** - Modular Terraform design
- ✅ **Zero-Downtime Deployments** - Blue-green strategy
- ✅ **Containerization** - Multi-stage Docker builds (~250MB)
- ✅ **CI/CD Automation** - GitHub Actions pipelines
- ✅ **Auto-Scaling** - Handles traffic spikes (1-3 instances)
- ✅ **Health Monitoring** - Automated checks and rollback
- ✅ **Cost Optimized** - Free tier resources, ~$2 for 48-hour test

---

## 🛠️ Tech Stack

**Infrastructure:** Terraform, AWS (VPC, EC2, ALB, ASG, CloudWatch, ECR, IAM)  
**Application:** Spring Boot 3.2.2, Java 17, Maven  
**Containerization:** Docker (multi-stage), Alpine Linux  
**CI/CD:** GitHub Actions  
**Monitoring:** CloudWatch, Spring Actuator

---

## 🚀 Quick Start
```bash
# 1. Clone and setup
git clone https://github.com/DurgeshS-25/Automated-Cloud-Deployment-Platform.git
cd Automated-Cloud-Deployment-Platform

# 2. Configure AWS
aws configure  # Use IAM user (not root!)

# 3. Deploy infrastructure
cd terraform
terraform init
terraform apply  # Review plan, type 'yes'

# 4. Push Docker image
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [ECR_URL]
docker build -t cloud-platform-demo:latest -f docker/Dockerfile .
docker tag cloud-platform-demo:latest [ECR_URL]:latest
docker push [ECR_URL]:latest

# 5. Access application
# Visit ALB URL from terraform outputs

# 6. Cleanup (IMPORTANT - Avoid charges!)
terraform destroy
```

---

## 💰 Cost Breakdown

**48-Hour Test Deployment:** ~$2-5 total  
**Monthly (if left running):** ~$16

**Optimization:**
- Free tier EC2 (t3.micro) ✅
- NAT Gateway disabled (saves $32/month) ✅
- Minimal log retention ✅

---

## 📊 Key Metrics

- **Deployment Time:** 5-10 minutes
- **Container Startup:** 2.3 seconds
- **Docker Image Size:** 250MB (multi-stage optimized)
- **Zero Downtime:** Blue-green switching
- **Auto-Rollback:** On health check failure

---

## 🎓 Learning Outcomes

Built to demonstrate:
1. **Terraform** - Modular IaC, state management, AWS provider
2. **AWS Architecture** - Multi-AZ, load balancing, auto-scaling
3. **Docker** - Multi-stage builds, security, optimization
4. **CI/CD** - Automated pipelines, testing, deployment
5. **Zero-Downtime** - Blue-green deployment strategy
6. **Monitoring** - CloudWatch integration, health checks
7. **Security** - IAM roles, security groups, least privilege

---

## 👨‍💻 Author

**Durgesh**  
MS Information Systems @ Northeastern University  
AWS Certified Cloud Practitioner

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?logo=linkedin&logoColor=white)](https://linkedin.com/in/your-profile)
[![GitHub](https://img.shields.io/badge/GitHub-100000?logo=github&logoColor=white)](https://github.com/DurgeshS-25)
[![Email](https://img.shields.io/badge/Email-D14836?logo=gmail&logoColor=white)](mailto:durgeshss25@gmail.com)

---

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details.

---

**Built with ❤️ to demonstrate production-ready DevOps practices**