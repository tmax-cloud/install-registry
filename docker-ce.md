# Image Registry 설치 가이드

## 구성 요소 및 버전
* docker-ce(v18.09.7)

## 폐쇄망 설치 가이드
* image registry는 노드 1개(master)에서만 진행한다.
* 환경 설정
    * run-registry.sh, docker-registry.tar를 Master 환경에 다운로드한다.
        * https://github.com/tmax-cloud/install-registry/manifest
        * git이 설치되어 있는 경우 clone
           ```bash
           $ git clone https://github.com/tmax-cloud/install-registry.git
           $ cd install-registry/resource
           ```

## 설치 가이드
0. [docker 설치](#step-0-docker-%EC%84%A4%EC%B9%98)
1. [registry 실행](#step-1-registry-%EC%8B%A4%ED%96%89)

## Step 0. docker 설치
* 목적 : `docker registry를 구축하기 위해 docker를 설치한다.`
* 생성 순서 :
    * docker 의존성 패키지를 설치와 docker-ce.repo를 등록한다.
    ```bash
    $ yum -y install yum-utils device-mapper-persistent-data lvm2
    $ yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    ```
    * docker를 설치한다.
    ```bash
    $ sudo yum install -y docker-ce
    $ sudo systemctl start docker
    $ sudo systemctl enable docker
    ```
    * docker-ce 설치 시 특정 버전을 설치할 경우 버전을 명시하여 설치한다.
    ```bash
    $ yum list docker-ce.x86-64 --showduplicates
    $ ex) yum install -y docker-ce-18.09.7.ce
    ```
    * docker damon에 insecure-registries를 등록한다.
        * sudo vi /etc/docker/daemon.json
    ```bash
    {
        "insecure-registries": ["{IP}:5000"]
    }
    ```
  ![image](figure/docker_registry.PNG)
    * docker를 재실행하고 status를 확인한다.
    ```bash
    $ sudo systemctl restart docker
    $ sudo systemctl status docker
    ```    
* 비고 :
    * docker-ce 설치 시 runtime confilct 에러가 발생하는 경우 아래와 같이 우회하여 docker 설치를 진행한다.
      *  ex) Error: containerd.io conflicts with 2:runc-1.0.0-377.rc93.el7.8.1.x86_64
	 ```bash
    $ sudo yum list | grep runc
    $ sudo yum remove runc
    $ sudo yum install docker-ce
	 ``` 
## Step 1. registry 실행
* 목적 : `폐쇄망 환경에서 image 사용을 위한 registry를 구축한다.`
* 생성 순서 :
    * run-registry.sh를 실행한다.
        * run-registry.sh, docker-registry.tar 파일이 같은 디렉토리({PWD})에 있어야 한다.
    ```bash
    $ sudo ./run-registry.sh {PWD} {IP}:5000
    ex ) sudo ./run-registry.sh ~/install-registry/resource 172.22.5.2:5000
    ```
  ![image](figure/registry.PNG)

    * 확인
    ```bash
    $ curl {IP}:5000/v2/_catalog
    ```
  ![image](figure/catalog.PNG)

## 삭제 가이드
