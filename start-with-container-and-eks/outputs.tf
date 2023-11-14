output "game_2048_endpoint" {
  value       = kubernetes_service.game_2048.status[0].load_balancer[0].ingress[0].hostname
  description = "The enpoint should render game 2048 in a browser"
}
