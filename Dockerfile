FROM tedder42/python3-psycopg2
COPY app.py .
RUN chmod 700 app.py && \
    apt -y update && \
    pip install boto3 && \
    pip install psycopg2-binary

ENTRYPOINT [python app.py]