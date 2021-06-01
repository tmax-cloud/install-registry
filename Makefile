IP ?= 127.0.0.1
PORT ?= 5000

.PHONY: install load trust run stop clean ca cert

install: load run

trust: ca cert

load:
	podman load -i resource/docker-registry.tar

ca:
	openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
            -keyout ./trust/ca.key -out ./trust/ca.crt \
            -subj "/C=KR/ST=Seoul/L=Seoul/O=Tmax"

cert:
	openssl genrsa -aes256 -passout pass:will_be_removed -out ./trust/key.pem 2048
	openssl rsa -in ./trust/key.pem -passin pass:will_be_removed -out ./trust/key.pem
	openssl req -new -key ./trust/key.pem -out ./trust/registry.csr -config ./trust/cert.conf
	openssl x509 -req -days 1825 -extensions v3_user -in ./trust/registry.csr \
    -CA ./trust/ca.crt -CAcreateserial \
    -CAkey ./trust/ca.key \
    -out  ./trust/cert.pem -extfile ./trust/cert.conf

run:
	podman run --name registry -t -d \
	--privileged \
	-p ${PORT}:5000 \
	-e REGISTRY_HTTP_TLS_CERTIFICATE=/trust/cert.pem \
	-e REGISTRY_HTTP_TLS_KEY=/trust/key.pem \
	-v ./trust:/trust \
	localhost/registry

stop:
	podman stop registry

clean: stop
	-podman rm registry
	-podman rmi localhost/registry
	rm -rf ./trust/*
	sudo rm -rf /etc/pki/ca-trust/source/anchors/localhost-container-registry.pem
	sudo update-ca-trust
