variable "project" {
  description = "Kurzname, geht in Ressourcennamen und Tags ein."
  type        = string
  default     = "kiratio"
}

variable "domain" {
  description = "Wurzeldomain der Seite, ohne www."
  type        = string
  default     = "kiratio.de"
}

variable "region" {
  description = "Region des S3-Buckets."
  type        = string
  default     = "eu-central-1"
}

variable "github_repository" {
  description = "Repository, das deployen darf, als owner/name."
  type        = string
  default     = "themmerich/kiratio"
}

variable "deploy_branch" {
  description = "Branch, von dem aus deployt werden darf. Andere Branches bekommen keine Rolle."
  type        = string
  default     = "main"
}

# Die numerischen IDs stehen in `gh api repos/<owner>/<name> --jq '.id, .owner.id'`.
variable "github_owner_id" {
  description = "Numerische ID des GitHub-Kontos, für die ID-basierte Form des sub-Claims."
  type        = string
  default     = "3725151"
}

variable "github_repository_id" {
  description = "Numerische ID des Repositorys, für die ID-basierte Form des sub-Claims."
  type        = string
  default     = "1375811331"
}

variable "create_oidc_provider" {
  description = "Auf false setzen, wenn der GitHub-OIDC-Provider im Konto schon existiert."
  type        = bool
  default     = true
}

variable "rate_limit_per_5min" {
  description = "Anfragen je IP in fünf Minuten, ab denen die WAF blockt."
  type        = number
  default     = 2000
}
