<!DOCTYPE html>
<html>


<body class="stackedit">
  <div class="stackedit__html"><h1 id="devops-i.t.-task">DevOps I.T. Task</h1>
<ul>
<li>
<p>Register a free AWS account, the interview task will fit into the 12<br>
month free tier. Create either a GitHub repository or an AWS</p>
</li>
<li>
<p>CodeCommit repository holding your code.</p>
</li>
<li>
<p>Automatize the resource creation steps with Terraform or<br>
CloudFormation and store it in GIT</p>
</li>
<li>
<p>Create a Container Registry to hold container image</p>
</li>
<li>
<p>Create an S3 bucket, which is public to the internet, and capable of<br>
static web hosting</p>
</li>
<li>
<p>Create a HelloWorld style static HTML website and store it in GIT</p>
</li>
<li>
<p>Create a PostgreSQL RDS instance</p>
<pre><code> o Connection credentials should be stored in SSM ParameterStore
</code></pre>
</li>
<li>
<p>Create a Python application which connects to the RDS instance and<br>
print out:</p>
<pre><code> o Connection properties
 o RDS version
 o Credentials should be retrieved from SSM ParameterStore
</code></pre>
</li>
<li>
<p>Create a Dockerfile into GIT which contains the Python application<br>
and set as a starting point</p>
</li>
<li>
<p>Create a CI pipeline with the following tasks:</p>
<pre><code> o Create an EC2, and install Jenkins on it or use AWS CodePipeline
 o Create a source step which clones the given GIT repository
 o Create a build step which build a Docker container and upload it to the
 	Registry
 o Create a deploy step which uploads a static html to the S3 bucket
</code></pre>
</li>
<li>
<p>Give READ access to the GIT repository and to the created resources.</p>
</li>
</ul>
<h2 id="time-box">Time Box</h2>
<p>The task should be completed within 7 days.</p>
<h2 id="prerequisite">Prerequisite</h2>
<p>To commlete the task, I’m using <strong>sandbox AWS account</strong> and my own <strong>GitHub repo</strong>, so the first step is skipped.<br>
For (IaC) I’m using <strong>Terragrunt</strong> on the top of a <strong>Terraform</strong>.<br>
For Container Registry I’m using <strong>AWS ECR</strong><br>
For CI automation I’m usinh <strong>Jenkins</strong>.<br>
For IDE I’m using <strong>InteliJ IDEA</strong>.<br>
All the resources including EC2 and Jenkins instalation are provisioned by Terraform script.<br>
The secrets in SSM Parameter Store are created from Amazon AWS Console, and the values do not exist in the code.</p>
<h4 id="git-repo-httpsgithub.comanton-boyanovinfinitelambda_devops_task.git">Git Repo: <a href="https://github.com/anton-boyanov/infinitelambda_devops_task.git">https://github.com/anton-boyanov/infinitelambda_devops_task.git</a></h4>
<h4 id="helloworld-http406296236709-devops-s3-hello-website.s3-website-eu-west-1.amazonaws.com">HelloWorld: <a href="http://406296236709-devops-s3-hello-website.s3-website-eu-west-1.amazonaws.com/">http://406296236709-devops-s3-hello-website.s3-website-eu-west-1.amazonaws.com/</a></h4>
<h4 id="jenkins-httpec2-54-216-33-251.eu-west-1.compute.amazonaws.com8080jobpython_app">Jenkins: <a href="http://ec2-54-216-33-251.eu-west-1.compute.amazonaws.com:8080/job/python_app/">http://ec2-54-216-33-251.eu-west-1.compute.amazonaws.com:8080/job/python_app/</a></h4>
<ul>
<li><strong>user</strong>: <em>aboyanov</em></li>
<li><strong>pass</strong>: <em>infinite</em></li>
</ul>
<h2 id="solution">Solution</h2>
<p>The IaC script includes Terragrunt infrastructure part, yaml configurations files and Terraform modules.</p>
<h2 id="folder-structure">Folder structure</h2>
<p>The folder structure controlled by Terragrunt is nested, with strict dependency tree.<br>
The configuration files pass configurations on level base.</p>
<blockquote>
<p>(for example: configuration on account level, on VPC level, on Environment level…)</p>
</blockquote>
<h2 id="implementation">Implementation</h2>
<h4 id="networking">Networking:</h4>
<ul>
<li>VPC</li>
<li>IGW</li>
<li>Private RT (no internet connected)</li>
<li>Public RT (conncted to IGW)</li>
<li>2 x Private Subnets (in different az) for RDS</li>
<li>2 x Public Subnets (in different az) for webservers</li>
<li>2 x Security groups for EC2, RDS</li>
<li>DHCP Option set</li>
</ul>
<h4 id="for-rds">For RDS:</h4>
<ul>
<li>Amazon PostgreSQL RDS service</li>
<li>engine_version: “12.3”</li>
<li>instance_class: “db.t2.micro”</li>
</ul>
<h4 id="for-iam">For IAM</h4>
<ul>
<li>1 role and 1 custom policy for EC2</li>
</ul>
<h4 id="for-ec2">For EC2</h4>
<ul>
<li>instance_type = “t2.micro”</li>
<li>AMI ID: ami-014ce76919b528bff</li>
<li>docker, OpenJDK, Jenkins, git are installed from user_data:</li>
</ul>
<blockquote>
<p>#!/bin/bash<br>
yum -y update<br>
yum -y install docker<br>
systemctl start docker<br>
systemctl enable docker<br>
systemctl status docker<br>
yum -y install java-1.8.0-openjdk git<br>
wget -O /etc/yum.repos.d/jenkins.repo <a href="https://pkg.jenkins.io/redhat-stable/jenkins.repo">https://pkg.jenkins.io/redhat-stable/jenkins.repo</a><br>
rpm --import <a href="https://pkg.jenkins.io/redhat-stable/jenkins.io.key">https://pkg.jenkins.io/redhat-stable/jenkins.io.key</a><br>
yum -y install jenkins<br>
usermod -aG docker jenkins<br>
systemctl start jenkins<br>
systemctl status jenkins</p>
</blockquote>
<h4 id="for-docker-container">For Docker container</h4>
<ul>
<li>Base Image with python from docker hub</li>
</ul>
<blockquote>
<p><strong>FROM</strong> tedder42/python3-psycopg2<br>
<strong>COPY</strong> python/app.py .<br>
<strong>COPY</strong> <a href="http://entrypoint.sh">entrypoint.sh</a> .<br>
<strong>RUN</strong> chmod 777 <a href="http://app.py">app.py</a> &amp;&amp; \<br>
chmod 777 <a href="http://entrypoint.sh">entrypoint.sh</a> &amp;&amp; \<br>
apt -y update &amp;&amp; \<br>
pip install boto3 &amp;&amp; \<br>
pip install psycopg2-binary<br>
<strong>ENTRYPOINT</strong> ["/app.py"]</p>
</blockquote>
<h4 id="for-jenkins">For Jenkins</h4>
<ul>
<li>using AWS Credentials stored in Jenkins credentials manager</li>
<li>pulling repo from GitHub using SCM manager</li>
<li>Building, tagging, pushing to ECR</li>
<li>Running docker container</li>
<li>Getting output from python app and add it as a link in the HelloWorld index.thml</li>
<li>upload HelloWorld to s3</li>
<li>remove old stopped containers and untagged docker images</li>
</ul>
<blockquote>
<p>#!/bin/bash<br>
export AWS_DEFAULT_REGION=eu-west-1<br>
echo “”<br>
echo "===================== LOGIN TO ECR ====================<br>
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin <a href="http://408636776942.dkr.ecr.eu-west-1.amazonaws.com">408636776942.dkr.ecr.eu-west-1.amazonaws.com</a><br>
echo “”<br>
echo "===================== DOCKER BUILD AND TAG =====================<br>
docker build -t <a href="http://408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest">408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest</a> .<br>
echo “”<br>
echo "===================== DOCKER PUSH =====================<br>
docker push <a href="http://408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest">408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest</a><br>
echo “”<br>
echo "===================== DOCKER RUN =====================<br>
docker run --name latest -itd <a href="http://408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest">408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest</a><br>
sleep 5<br>
echo “”<br>
echo "===================== DOCKER LOGS =====================<br>
docker logs latest &gt; web/python_output.json<br>
echo “”<br>
echo "===================== UPLOAD TO S3 =====================<br>
aws s3 cp web s3://406296236709-devops-s3-website.hashicorp.com/ --recursive<br>
echo “”<br>
echo "===================== REMOVE ALL STOPPED CONTAINERS =====================<br>
docker rm -f $(docker ps -aq)<br>
sleep 1<br>
docker ps -a<br>
echo “”<br>
echo "===================== REMOVE ALL NOT TAGGED IMAGES =====================<br>
docker rmi $(docker images -q --filter “dangling=true”)<br>
sleep 1<br>
docker images<br>
echo “”<br>
echo "===================== DONE =====================</p>
</blockquote>
<h4 id="for-python-app">For Python app</h4>
<ul>
<li>using boto3 and psycopg2 libraries</li>
</ul>
<blockquote>
<p>#!/usr/local/bin/python3.7<br>
import boto3<br>
import psycopg2<br>
client = boto3.client(‘ssm’, region_name=‘eu-west-1’)<br>
username = client.get_parameter(<br>
Name=’/aboyanov/database/username/master’,<br>
WithDecryption=True<br>
)<br>
password = client.get_parameter(<br>
Name=’/aboyanov/database/password/master’,<br>
WithDecryption=True<br>
)<br>
source = boto3.client(‘rds’, region_name=‘eu-west-1’)<br>
instances = source.describe_db_instances(DBInstanceIdentifier=‘aboyanov’)<br>
rds_host = instances.get(‘DBInstances’)[0].get(‘Endpoint’).get(‘Address’)<br>
try:<br>
connection = psycopg2.connect(<br>
database=“postgres”,<br>
user=username.get(“Parameter”).get(“Value”),<br>
password=password.get(“Parameter”).get(“Value”),<br>
host=rds_host,<br>
port=‘5432’<br>
)<br>
cursor = connection.cursor()<br>
# Print PostgreSQL Connection properties<br>
print("\n", “Connection --properties: “, “\n”, “\n”, connection.get_dsn_parameters(),”\n”)<br>
# Print PostgreSQL version<br>
cursor.execute(“SELECT version();”)<br>
record = cursor.fetchone()<br>
print("RDS --version: ", “\n”, “\n”, record, “\n”)<br>
except (Exception, psycopg2.Error) as error :<br>
print (“Error while connecting to PostgreSQL”, error)<br>
finally:<br>
#closing database connection.<br>
if(connection):<br>
cursor.close()<br>
connection.close()<br>
print(“PostgreSQL connection is closed”)<br>
</blockquote>

</div>
</body>

</html>
