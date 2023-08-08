package main

import (
	"encoding/json"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/sqs"
	"log"
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
	userID := "1" // バッチ処理の対象となるキーを固定値で指定

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
		errorMessage := fmt.Sprintf("Error getting item from DynamoDB: %v", err)
		log.Println(errorMessage)
		return "", fmt.Errorf(errorMessage)
	}

	user := User{}
	err = dynamodbattribute.UnmarshalMap(result.Item, &user)
	if err != nil {
		errorMessage := fmt.Sprintf("Error unmarshalling result from DynamoDB: %v", err)
		log.Println(errorMessage)
		return "", fmt.Errorf(errorMessage)
	}

	messageBody, err := json.Marshal(map[string]string{
		"email": user.MailAddress,
		"name":  user.Name,
	})
	if err != nil {
		errorMessage := fmt.Sprintf("Error marshalling message body: %v", err)
		log.Println(errorMessage)
		return "", fmt.Errorf(errorMessage)
	}

	sqsQueueURL := os.Getenv("SQS_QUEUE_URL")
	sqsParams := &sqs.SendMessageInput{
		QueueUrl:    aws.String(sqsQueueURL),
		MessageBody: aws.String(string(messageBody)),
	}

	_, err = sqsSvc.SendMessage(sqsParams)
	if err != nil {
		errorMessage := fmt.Sprintf("Error sending message to SQS: %v", err)
		log.Println(errorMessage)
		return "", fmt.Errorf(errorMessage)
	}

	return "Success", nil
}

func main() {
	lambda.Start(HandleRequest)
}
