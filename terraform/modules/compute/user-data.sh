#!/bin/bash
# EC2 User Data Script - Runs on instance launch

set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=========================================="
echo "Starting EC2 Instance Configuration"
echo "Environment: ${environment}"
echo "=========================================="

# Update system packages
echo "[1/6] Updating system packages..."
yum update -y

# Install Docker
echo "[2/6] Installing Docker..."
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install AWS CLI v2
echo "[3/6] Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/aws /tmp/awscliv2.zip

# Install CloudWatch Agent
echo "[4/6] Installing CloudWatch Agent..."
wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm -O /tmp/cloudwatch-agent.rpm
rpm -U /tmp/cloudwatch-agent.rpm
rm /tmp/cloudwatch-agent.rpm

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json << 'CWCONFIG'
{
  "metrics": {
    "namespace": "CloudPlatform",
    "metrics_collected": {
      "mem": {
        "measurement": [
          {"name": "mem_used_percent", "rename": "MemoryUsedPercent"}
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          {"name": "used_percent", "rename": "DiskUsedPercent"}
        ],
        "metrics_collection_interval": 60,
        "resources": ["/"]
      }
    }
  }
}
CWCONFIG

# Start CloudWatch Agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config \
  -m ec2 \
  -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

# Login to ECR and pull Docker image
echo "[5/6] Logging into ECR and pulling application..."
aws ecr get-login-password --region ${aws_region} | docker login --username AWS --password-stdin ${ecr_repo}

# Try to pull image, but don't fail if it doesn't exist yet
docker pull ${ecr_repo}:latest || echo "No image in ECR yet - this is normal on first deployment"

# Run the application (if image exists)
if docker image inspect ${ecr_repo}:latest >/dev/null 2>&1; then
  echo "[6/6] Starting application container..."
  docker run -d \
    --name app \
    --restart unless-stopped \
    -p ${app_port}:${app_port} \
    -e ENVIRONMENT=${environment} \
    -e AWS_REGION=${aws_region} \
    ${ecr_repo}:latest
  
  echo "? Application started successfully!"
else
  echo "? No Docker image available yet. Instance is ready for deployment."
  
  # Create a simple health check endpoint for testing
  docker run -d \
    --name placeholder \
    --restart unless-stopped \
    -p ${app_port}:80 \
    nginxdemos/hello:plain-text
  
  echo "? Placeholder service running for health checks"
fi

# Create health check monitoring script
cat > /usr/local/bin/health-check.sh << 'HEALTHEOF'
#!/bin/bash
response=$$(curl -s -o /dev/null -w "%%{http_code}" http://localhost:${app_port}/actuator/health)
if [ "$$response" = "200" ]; then
  exit 0
else
  echo "Health check failed with status: $$response"
  exit 1
fi
HEALTHEOF

chmod +x /usr/local/bin/health-check.sh

# Add health check to cron (restart app if unhealthy)
echo "*/2 * * * * /usr/local/bin/health-check.sh || docker restart app" | crontab -

echo "=========================================="
echo "EC2 Instance Configuration Complete!"
echo "Environment: ${environment}"
echo "App Port: ${app_port}"
echo "=========================================="
