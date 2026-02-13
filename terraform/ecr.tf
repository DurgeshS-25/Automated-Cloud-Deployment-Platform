# ============================================
# ECR Repository for Docker Images
# ============================================

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-app-${var.environment}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "${var.project_name}-ecr-${var.environment}"
    Environment = var.environment
  }
}

# ECR Lifecycle Policy (delete old images to save costs)
resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

output "ecr_repo_url" {
  description = "ECR Repository URL"
  value       = aws_ecr_repository.app.repository_url
}
