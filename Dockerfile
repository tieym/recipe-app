FROM python:3.9-alpine3.13
LABEL maintainer="me"

# makes python print messages, usefull for development
ENV PYTHONUNBUFFERED 1

#copys the dependencies
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
# directory where the commands will be made from
WORKDIR /app
EXPOSE 8000


ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

#adds /py/bin to the path
ENV PATH="/py/bin:$PATH"

USER django-user

