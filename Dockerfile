FROM debian:bookworm-slim

ARG VERSION=1.31.2

# Install runtime dependencies for downloading, extracting, and patching binaries
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    xz-utils \
    patchelf \
    && rm -rf /var/lib/apt/lists/*

ENV DIST="https://codeberg.org/jbruchon/jdupes/releases/download/v${VERSION}/jdupes-${VERSION}-linux-x86_64.pkg.tar.xz"
# Download the specified version release package from Codeberg
RUN echo "Dowloading from $DIST"
RUN curl -sSL $DIST | tar -C / -xJf -

# Patch the dynamic linker interpreter to match Debian's glibc path
RUN patchelf --set-interpreter /lib/ld-linux-x86-64.so.2 /jdupes*-linux-*/jdupes*

RUN find /jdupes*-linux-* -name 'jdupes*' -type f -exec patchelf --set-interpreter /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 \{\} \;
RUN find /jdupes*-linux-* -name 'jdupes*' -type f -exec ln -s \{\} /usr/local/bin/ \;


# Verify binary execution capability
RUN /usr/local/bin/jdupes --version

ENTRYPOINT ["/usr/local/bin/jdupes"]
CMD ["--help"]
