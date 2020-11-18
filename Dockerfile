FROM tedder42/python3-psycopg2
COPY python/app.py .
RUN chmod 777 app.py && \
    apt -y update && \
    pip install boto3 && \
    pip install psycopg2-binary

ENTRYPOINT [/app.py]