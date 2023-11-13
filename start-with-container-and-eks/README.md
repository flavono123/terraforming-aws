# [AWS Builders Korea - Docker and EKS 시작하기](https://catalog.us-east-1.prod.workshops.aws/workshops/46236689-b414-4db8-b5fc-8d2954f2d94a/ko-KR)

**🔊 Notice**
- 다음 두 개 섹션 건너 뜀
  - [Cloud9 IDE 환경 구성](https://catalog.us-east-1.prod.workshops.aws/workshops/46236689-b414-4db8-b5fc-8d2954f2d94a/ko-KR/install); 로컬 터미널/IDE에서 실습
  - [Docker](https://catalog.us-east-1.prod.workshops.aws/workshops/46236689-b414-4db8-b5fc-8d2954f2d94a/ko-KR/docker)
    - community 초과 등급의 테라폼 프로바이더가 없음
    - 테라폼으로 IaC 구성 학습할 필요성이 적음

## [EKS](https://catalog.us-east-1.prod.workshops.aws/workshops/46236689-b414-4db8-b5fc-8d2954f2d94a/ko-KR/eks)

### [EKS 설치](https://catalog.us-east-1.prod.workshops.aws/workshops/46236689-b414-4db8-b5fc-8d2954f2d94a/ko-KR/eks/10-install)

![eks-plural](./img/eks-plural.png)

```sh
❯ k get no
NAME                                             STATUS   ROLES    AGE   VERSION
ip-10-0-23-182.ap-northeast-2.compute.internal   Ready    <none>   21m   v1.28.3-eks-4f4795d
ip-10-0-30-110.ap-northeast-2.compute.internal   Ready    <none>   19m   v1.28.3-eks-4f4795d
```

### [Pod 기본 명령어](https://catalog.us-east-1.prod.workshops.aws/workshops/46236689-b414-4db8-b5fc-8d2954f2d94a/ko-KR/eks/20-pod)

![pod-basic-plural](./img/pod-basic-plural.png)

```sh
❯ k get po -owide
NAME           READY   STATUS    RESTARTS   AGE   IP           NODE                                             NOMINATED NODE   READINESS GATES
nginx-orange   1/1     Running   0          72s   10.0.1.250   ip-10-0-30-110.ap-northeast-2.compute.internal   <none>           <none>
```
