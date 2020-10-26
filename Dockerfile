FROM alpine
WORKDIR /srv/streamlink-service
ENV COLUMNS=116
ENV PORT=8000
EXPOSE $PORT
ADD main.py .
RUN apk update &&                                                                     \
    apk add python3 py-pip uwsgi-python uwsgi-http py-flask gcc musl-dev ffmpeg curl zip; \
    pip3 install https://github.com/mysterio21/streamlink/archive/pluto.zip;         \
    apk del gcc musl-dev;                                                             \
    rm -vfr /root/.cache /var/cache/apk/*;                                            \
    mkdir -p /var/log/uwsgi

RUN DIR=/opt/ffmpeg-patch && mkdir -p ${DIR} && cd ${DIR} && \
    curl -sLO https://github.com/mysterio21/ffmpeg-hls-pts-discontinuity-reclock/releases/download/1.4/ffmpeg-patch-static-1.4.zip && \
    unzip -j ffmpeg-patch-static-1.4.zip && \
    rm ffmpeg-patch-static-1.4.zip
    
CMD uwsgi --http-socket 0.0.0.0:$PORT \
          --plugin python,http        \
          --wsgi-file main.py         \
          --lock-engine ipcsem        \
          --callable app              \
          --workers 4                 \
          --threads 4                 \
          --uid uwsgi                 \
          --master                    \
          --logto /var/log/uwsgi/log.log