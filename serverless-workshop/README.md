# [Serverless Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR)

## [시작 전 준비 사항](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/start)

- [사전 환경 구성(IAM Role)](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/start/cloudformation)
  - CloudFormation -> HCL

## [간단한 배달 주문 서비스 만들기](a://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/simple-api-service)

![간단한배달주문서비스만들기](img/1st-archi.png)

### [API Gateway 생성하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/simple-api-service/create-apigw)

![api-gateway-post-order-50a3c28](img/50a3c28.png)

### [주문 처리 Lambda 함수 작성하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/simple-api-service/create-lambda)

![lambda-function-order-function-f7a7545](img/f7a7545.png)

### [API Gateway를 Lambda 함수에 연결하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/simple-api-service/integ-apigw-lambda#api-gateway)

![apigw-lambda-integrate-0563184](img/0563184.png)

## [비동기 처리 모델로 변경하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/api-async)

![비동기처리모델로변경하기](img/2nd-archi.png)

### [SQS 구성하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/api-async/create-sqs)

![a000639](img/a000639.png)

### [API Gateway, Lambda를 SQS에 연결하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/api-async/integration)

![8bada3d](img/8bada3d.png)

### [Dead-letter queue 적용하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/api-async/dead-letter-queue)

![a4665ea](img/a4665ea.png)

## [EventBridge를 사용한 Event-driven 모델 적용하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/eventbridge)

![EDA](img/3rd-archi.png)

### [EventBridge를 구성하고 SQS에 연결하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/eventbridge/create-eventbridge)

![17ca8bf](img/17ca8bf.png)

### [API Gateway를 EventBridge에 연결하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/eventbridge/apigw-eb)

![102d450](img/102d450.png)

### [픽업 주문 메시지 처리 구성](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/eventbridge/pickup-order)

![709bd94](img/709bd94.png)

### [EventBridge를 SNS에 연결하기](https://catalog.us-east-1.prod.workshops.aws/workshops/4923c0ff-6470-46e1-9884-7c6ee63e7136/ko-KR/eventbridge/pickup-eb-sns)

![ec0aed1](img/ec0aed1.png)

## 리소스 정리하기

```bash
terraform destroy
```
