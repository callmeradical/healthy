FROM scratch
MAINTAINER lars@callmeradical.com

ADD healthy /

EXPOSE 8080

ENTRYPOINT ["/healthy"]
