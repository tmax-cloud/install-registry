# Image Registry 설치 가이드

## 구성 요소 및 버전
* podman (v2.2.1 이상)
* openssl (v1.0.2k 이상)

## 설치
1. 패키지 설치
   ```bash
   sudo yum install -y git make podman
   ```
   
2. git repo clone
   ```bash
   git clone -b 5.0 https://github.com/tmax-cloud/install-registry.git
   cd install-registry
   ```
   
3. CSR(./trust/cert.conf) 수정 
   ```text
   [ alt_names ]
   DNS.1 = <enter_your_registry_domain>
   IP.1 = <enter_your_registry_ip>
   ```

4. 인증서 생성
   ```bash
   make trust
   ...
   Country Name (2 letter code) [KR]: <enter_your_country>
   Organization Name (eg, company) [TmaxCloud]: <enter_your_origanization_name>
   Organizational Unit Name (eg, section) [DevOps]: <enter_your_origanization_unit_name>
   Common Name (eg, hostname) [registry]: <enter_hostname>
   ...
   ```
   

5. 설치
   ```bash
   IP=<내부망IP(default:127.0.0.1)> PORT=<port:default:5000> make install 
   ```
   
### 트러블슈팅
   * Podman run error in non-root mode: "user namespaces are not enabled in /proc/sys/user/max_user_namespaces" 
      ```bash
     sudo su 
     echo 'user.max_user_namespaces=10000' > /etc/sysctl.d/42-rootless.conf && sysctl --system   
      ```

## 신뢰하는 레지스트리로 등록
1. /etc/containers/registries.conf에 insecure registry 등록
   ```text
   [registires.insecure]
   registries = ["<내부망IP>:<PORT>"]
   ```
   
## 이미지 푸시하기
1. (외부망 환경에서) 설치하고자하는 이미지를 pull 및 tar 파일로 저장
   ```bash
   podman pull <image>
   podman save -o <image_archive>.tar <image> # podman save -o redis.tar redis
   ```

2. tar 이미지 파일을 (레지스트리를 띄운) 내부 환경으로 복사

3. 대상 레지스트리를 [신뢰하는 레지스트리로 등록](https://github.com/tmax-cloud/install-registry/blob/5.0/podman.md#%EC%8B%A0%EB%A2%B0%ED%95%98%EB%8A%94-%EB%A0%88%EC%A7%80%EC%8A%A4%ED%8A%B8%EB%A6%AC%EB%A1%9C-%EB%93%B1%EB%A1%9D)
4. 이미지 로드 및 푸시
   ```bash
   podman load -i <image_archive>.tar
   podman tag <image> <내부망IP>:<PORT>/<image> # podman tag redis 172.22.0.5:5000/redis
   podman push <내부망IP>:<PORT>/<image> # podman push 172.22.0.5:5000/redis
   ```

## 이미지 풀하기
1. 대상 레지스트리를 [신뢰하는 레지스트리로 등록](https://github.com/tmax-cloud/install-registry/blob/5.0/podman.md#%EC%8B%A0%EB%A2%B0%ED%95%98%EB%8A%94-%EB%A0%88%EC%A7%80%EC%8A%A4%ED%8A%B8%EB%A6%AC%EB%A1%9C-%EB%93%B1%EB%A1%9D)
2. 이미지 풀
   ```bash
   podman pull <내부망IP>:<PORT>/<image>
   ```

## 제거
   ```bash
   make clean
   ```
