FROM redis:8-trixie

LABEL govpf.category="database"
LABEL govpf.fromimage="redis:8-trixie"

COPY docker-entrypoint.sh /usr/local/bin/

VOLUME /data
WORKDIR /data

ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 6379

CMD ["redis-server"]