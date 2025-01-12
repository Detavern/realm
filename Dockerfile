FROM debian:bullseye-slim

COPY target/x86_64-unknown-linux-musl/release/realm /usr/local/bin
COPY entrypoint.sh /usr/local/bin

RUN chmod +x /usr/local/bin/realm

ENTRYPOINT ["entrypoint.sh"]
CMD ["realm"]
