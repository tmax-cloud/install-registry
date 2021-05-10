IP ?= 127.0.0.1
PORT ?= 5000

.PHONY: install load trust run stop clean

install: load trust run

load:
	podman load -i resource/docker-registry.tar

trust:
	echo "Generate certificates for localhost registry"
	openssl req -x509 -newkey rsa:4096 -sha256 -nodes \
	-keyout ./trust/key.pem \
	-out ./trust/cert.pem \
	-subj "/CN=localhost" \
	-addext "subjectAltName = DNS:registry, IP:${IP}" \
	-days 3650
	sudo cp ./trust/cert.pem /etc/pki/ca-trust/source/anchors/localhost-container-registry.pem
	sudo update-ca-trust

run:
	podman run --name registry -t \
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