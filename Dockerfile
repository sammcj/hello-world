# This is the first stage, for building things that will be required by the
# final stage (notably the binary)
FROM golang as builder
ENV ARCH=${ARCH:-amd64}
ENV GIN_MODE=${GIN_MODE:-release}

# Create a "nobody" non-root user
RUN echo "nobody:x:65534:65534:Nobody:/:" > /etc_passwd

# Install deps, test and build the binary
RUN make ci

FROM scratch
ENV ARCH=${ARCH:-amd64}
ENV GIN_MODE=${GIN_MODE:-release}

LABEL maintainer "sammcj <sammcj@users.noreply.github.com>"
LABEL \
  vendor="sammcj" \
  description="hello_world" \
  arch="${ARCH}"

# Copy the /etc/passwd file from the builder stage, which contains the "nobody"
COPY --from=builder /etc_passwd /etc/passwd

# Copy any certs from the builder stage
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy the app binary from the builder stage
COPY --chown=nobody:nobody --from=builder /hello_world /hello_world

# Drop privileges
USER nobody

EXPOSE 8080
ENTRYPOINT ["/hello_world"]