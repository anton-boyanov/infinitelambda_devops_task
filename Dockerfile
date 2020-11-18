FROM tedder42/python3-psycopg2
COPY python/app.py .
COPY entrypoint.sh .
RUN chmod 777 app.py && \
    chmod 777 entrypoint.sh && \
    apt -y update && \
    pip install boto3 && \
    pip install psycopg2-binary

ENTRYPOINT ["/entrypoint.sh"]