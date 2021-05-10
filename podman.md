# Image Registry 설치 가이드

## 구성 요소 및 버전
* podman (v2.2.1 이상)
* openssl (v1.1.1 이상)

## 설치
1. 패키지 설치
   ```bash
   sudo yum install -y git make podman
   ```
   
2. git repo clone
   ```bash
   git clone https://github.com/tmax-cloud/install-registry.git
   cd install-registry
   ```
   
3. 설치
   ```bash
   IP=<내부망IP(default:127.0.0.1)> PORT=<port:default:5000> make install 
   ```

## 이미지 푸시하기
1. (외부망 환경에서) 설치하고자하는 이미지를 pull 및 tar 파일로 저장
   ```bash
   podman pull <image>
   podman save -o <image_archive>.tar <image> # podman save -o redis.tar redis
   ```

2. tar 이미지 파일을 (레지스트리를 띄운) 내부 환경으로 복사

3. 이미지 로드 및 푸시
   ```bash
   podman load -i <image_archive>.tar
   podman tag <내부망IP>:<PORT>/<image> <image> # podman tag 172.22.0.5:5000/redis redis
   podman push <내부망IP>:<PORT>/<image> # podman push 172.22.0.5:5000/redis
   ```

## 이미지 풀하기
1. (내부망의 다른 노드에서 pull할 경우) /etc/containers/registries.conf에 insecure registry 등록
   ```text
   [registires.insecure]
   registries = ["<내부망IP>:<PORT>"]
   ```

2. 이미지 풀
   ```bash
   podman pull <내부망IP>:<PORT>/<image>
   ```

## 제거
   ```bash
   make clean
   ```