# [IAM Workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US)

![overview](./img/overview.png)

## [IAM 사용자 및 사용자 그룹](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-user-and-user-group)

### [IAM 사용자(User)](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-user-and-user-group/iam-user)


![iam-user](./img/iam-user.png)

![iam-user-plural](./img/iam-user-plural.png)

### [IAM 사용자 그룹(User Group)](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-user-and-user-group/iam-user-group)

![iam-user-group](./img/iam-user-group.png)

![iam-user-group-plural](./img/iam-user-group-plural.png)

## [IAM 정책(Policy)](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-policies)

![iam-policies.png](./img/iam-policies.png)

권한을 제한하는 정책 (Guardrail)

1. 조직 SCP 정책 (Organization SCPs)
2. 권한 경계 정책 (Permissions boundaries)
3. 세션 정책 (Session policies)

권한을 부여하는 정책 (Grant)

1. 자격증명 기반 정책 (Identity-based policies)
   1. AWS 관리형 정책 (AWS Managed policies): AWS에서 제공하는 글로벌 적용 가능 정책
   2. 고객 관리형 정책 (Customer Managed policies): 고객이 직접 생성하여 고객 계정에서만 사용 가능한 정책
   3. 인라인 정책 (In-line policies): 단일 사용자 그룹 역할에 직접 추가하는 정책 (재활용 불가)
2. 리소스 기반 정책 (Resource-based policies)
3. 액세스 제어 리스트 (Access Control Lists, ACLs)

### [자격증명 기반 정책(Identity-based policies)](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-policies/identity-based-policies)

[**사용자 권한 추가 (AWS 관리형 정책)**](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-policies/identity-based-policies#(aws-))

![aws-managed-policies](./img/aws-managed-policies.png)

Super-Pro : AmazonEC2ReadOnlyAccess

![aws-managed-policies-plural](./img/aws-managed-policies-plural.png)

[**인라인 정책 (In-line policies)**](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-policies/identity-based-policies#(in-line-policies))

![inline-policy](./img/inline-policy.png)

![inline-policy-plural](./img/inline-policy-plural.png)

[**권한 경계(Permissions boundaries)**](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-policies/permissions-boundaries)

![permission-boundaries](./img/permission-boundaries.png)


![permission-boundaries-plural](./img/permission-boundaries-plural.png)

[**리소스 기반 정책(Resource-based policies)**](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-policies/resource-based-policies)

![resource-based-policies](./img/resource-based-policies.png)

![resource-based-policies-plural](./img/resource-based-policies-plural.png)

## [IAM 역할(Role)](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-roles)

주체(Principals):

- 동일한 AWS 계정의 IAM 사용자
- 역할과 다른 AWS 계정의 IAM 사용자
- Amazon Elastic Compute Cloud(Amazon EC2)와 같은 AWS가 제공하는 웹 - 서비스
- SAML 2.0, OpenID Connect 또는 사용자 지정 구축 자격 증명 브로커와 호환되는 외부 자격 증명 공급자(IdP) 서비스에 의해 인증된 외부 사용자

### [역할 전환(Role Switch)](https://catalog.us-east-1.prod.workshops.aws/workshops/dd23d392-bea4-483c-aefd-f62ed73f936d/en-US/iam-roles/role-switch)

![role-switch](img/role-switch.png)

![role-switch-plural](img/role-switch-plural.png)
