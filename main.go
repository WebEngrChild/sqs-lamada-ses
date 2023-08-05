package main

import (
	"encoding/json"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/sqs"
	"os"
)

type User struct {
	UserID      string `json:"user_id"`
	Timestamp   string `json:"timestamp"`
	Status      string `json:"status"`
	MailAddress string `json:"mailAddress"`
	Name        string `json:"name"`
}

func HandleRequest() (string, error) {
	sess := session.Must(session.NewSession(&aws.Config{
		Region: aws.String("ap-northeast-1"),
	}))

	db := dynamodb.New(sess)
	sqsSvc := sqs.New(sess)

	tableName := "users"
	userID := "1"

	params := &dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"user_id": {
				S: aws.String(userID),
			},
		},
	}

	result, err := db.GetItem(params)
	if err != nil {
		return "", err
	}

	user := User{}
	err = dynamodbattribute.UnmarshalMap(result.Item, &user)
	if err != nil {
		return "", err
	}

	messageBody, err := json.Marshal(map[string]string{
		"mailAddress": user.MailAddress,
		"name":        user.Name,
	})
	if err != nil {
		return "", err
	}

	sqsQueueURL := os.Getenv("SQS_QUEUE_URL")
	sqsParams := &sqs.SendMessageInput{
		QueueUrl:    aws.String(sqsQueueURL),
		MessageBody: aws.String(string(messageBody)),
	}

	_, err = sqsSvc.SendMessage(sqsParams)
	if err != nil {
		return "", err
	}

	return "Success", nil
}

func main() {
	lambda.Start(HandleRequest)
}
