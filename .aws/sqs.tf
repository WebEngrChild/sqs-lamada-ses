resource "aws_sqs_queue" "queue" {
  name = "my-queue"
}

output "sqs_queue_url" {
  value = aws_sqs_queue.queue.url
}