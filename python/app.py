#!/usr/local/bin/python3.7

import boto3
import psycopg2

client = boto3.client('ssm', region_name='eu-west-1')
username = client.get_parameter(
    Name='/aboyanov/database/username/master',
    WithDecryption=True
)
password = client.get_parameter(
    Name='/aboyanov/database/password/master',
    WithDecryption=True
)
source = boto3.client('rds', region_name='eu-west-1')
instances = source.describe_db_instances(DBInstanceIdentifier='aboyanov')
rds_host = instances.get('DBInstances')[0].get('Endpoint').get('Address')
print(rds_host)
try:
    connection = psycopg2.connect(
        database="postgres",
        user=username.get("Parameter").get("Value"),
        password=password.get("Parameter").get("Value"),
        host="aboyanov.chnffzayndnb.eu-west-1.rds.amazonaws.com",
        port='5432'
    )
    cursor = connection.cursor()
    # Print PostgreSQL Connection properties
    print("\n", "Connection --properties: ", "\n", "\n", connection.get_dsn_parameters(),"\n")

    # Print PostgreSQL version
    cursor.execute("SELECT version();")
    record = cursor.fetchone()
    print("RDS --version: ", "\n", "\n", record, "\n")

except (Exception, psycopg2.Error) as error :
    print ("Error while connecting to PostgreSQL", error)
finally:
    #closing database connection.
    if(connection):
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")