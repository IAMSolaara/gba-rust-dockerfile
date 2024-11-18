ARG DEBIAN_VERSION
FROM buildpack-deps:${DEBIAN_VERSION}

ENV RUSTUP_HOME=/usr/local/rustup \
	CARGO_HOME=/usr/local/cargo \
	PATH=/usr/local/cargo/bin:$PATH

RUN set -eux; \ 
	export DEBIAN_FRONTEND=noninteractive; \ 
	apt-get -y update && \ 
	apt-get -y install gcc-arm-none-eabi && \ 
	apt-get -y clean && \ 
	rm -rf /var/lib/apt/lists/*


RUN set -eux; \
	dpkgArch="$(dpkg --print-architecture)"; \
	case "${dpkgArch##*-}" in \
	amd64) rustArch='x86_64-unknown-linux-gnu' ;; \
	arm64) rustArch='aarch64-unknown-linux-gnu' ;; \
	*) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
	esac; \
	\
	url="https://static.rust-lang.org/rustup/dist/${rustArch}/rustup-init"; \
	wget "$url"; \
	chmod +x rustup-init; \
	./rustup-init -y --no-modify-path --default-toolchain nightly; \
	rm rustup-init; \
	chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
	rustup --version; \
	cargo --version; \
	rustc --version; \
	rustup component add rust-src; 

