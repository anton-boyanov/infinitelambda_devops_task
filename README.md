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
<pre class=" language-bash"><code class="prism  language-bash"><span class="token shebang important">#!/bin/bash</span>  
yum -y update  
yum -y <span class="token function">install</span> docker  
systemctl start docker  
systemctl <span class="token function">enable</span> docker  
systemctl status docker  
yum -y <span class="token function">install</span> java-1.8.0-openjdk <span class="token function">git</span>  
<span class="token function">wget</span> -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo  
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key  
yum -y <span class="token function">install</span> jenkins  
<span class="token function">usermod</span> -aG docker jenkins  
systemctl start jenkins  
systemctl status jenkins  
</code></pre>
<h4 id="for-docker-container">For Docker container</h4>
<ul>
<li>Base Image with python from docker hub</li>
</ul>
<pre class=" language-dockerfile"><code class="prism  language-dockerfile"><span class="token keyword">FROM</span> tedder42/python3<span class="token punctuation">-</span>psycopg2  
<span class="token keyword">COPY</span> python/app.py .  
<span class="token keyword">COPY</span> entrypoint.sh .  
<span class="token keyword">RUN</span> chmod 777 app.py &amp;&amp; \  
    chmod 777 entrypoint.sh &amp;&amp; \  
    apt <span class="token punctuation">-</span>y update &amp;&amp; \  
    pip install boto3 &amp;&amp; \  
    pip install psycopg2<span class="token punctuation">-</span>binary  
<span class="token keyword">ENTRYPOINT</span> <span class="token punctuation">[</span><span class="token string">"/app.py"</span><span class="token punctuation">]</span>
</code></pre>
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
<pre class=" language-bash"><code class="prism  language-bash"><span class="token shebang important">#!/bin/bash</span>
<span class="token function">export</span> AWS_DEFAULT_REGION<span class="token operator">=</span>eu-west-1
<span class="token keyword">echo</span> <span class="token string">""</span>
<span class="token keyword">echo</span> <span class="token string">"===================== LOGIN TO ECR ====================
aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 408636776942.dkr.ecr.eu-west-1.amazonaws.com
echo "</span><span class="token string">"
echo "</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span> DOCKER BUILD AND TAG <span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span>
docker build -t 408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest <span class="token keyword">.</span>
<span class="token keyword">echo</span> <span class="token string">""</span>
<span class="token keyword">echo</span> <span class="token string">"===================== DOCKER PUSH =====================
docker push 408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest
echo "</span><span class="token string">"
echo "</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span> DOCKER RUN <span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span>
docker run --name latest -itd 408636776942.dkr.ecr.eu-west-1.amazonaws.com/aboyanov-hello-image:latest
<span class="token function">sleep</span> 5
<span class="token keyword">echo</span> <span class="token string">""</span>
<span class="token keyword">echo</span> <span class="token string">"===================== DOCKER LOGS =====================
docker logs latest &gt; web/python_output.json
echo "</span><span class="token string">"
echo "</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span> UPLOAD TO S3 <span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span>
aws s3 <span class="token function">cp</span> web s3://406296236709-devops-s3-website.hashicorp.com/ --recursive
<span class="token keyword">echo</span> <span class="token string">""</span>
<span class="token keyword">echo</span> <span class="token string">"===================== REMOVE ALL STOPPED CONTAINERS =====================
docker rm -f <span class="token variable"><span class="token variable">$(</span>docker <span class="token function">ps</span> -aq<span class="token variable">)</span></span>
sleep 1
docker ps -a
echo "</span><span class="token string">"
echo "</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span> REMOVE ALL NOT TAGGED IMAGES <span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span>
docker rmi <span class="token punctuation">$(</span>docker images -q --filter <span class="token string">"dangling=true"</span><span class="token punctuation">)</span>
<span class="token function">sleep</span> 1
docker images
<span class="token keyword">echo</span> <span class="token string">""</span>
<span class="token keyword">echo</span> "<span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span> DONE <span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">==</span><span class="token operator">=</span> 
</code></pre>
<h4 id="for-python-app">For Python app</h4>
<ul>
<li>using boto3 and psycopg2 libraries</li>
</ul>
<pre class=" language-python"><code class="prism  language-python"><span class="token keyword">import</span> boto3  
<span class="token keyword">import</span> psycopg2  
client <span class="token operator">=</span> boto3<span class="token punctuation">.</span>client<span class="token punctuation">(</span><span class="token string">'ssm'</span><span class="token punctuation">,</span> region_name<span class="token operator">=</span><span class="token string">'eu-west-1'</span><span class="token punctuation">)</span>  
username <span class="token operator">=</span> client<span class="token punctuation">.</span>get_parameter<span class="token punctuation">(</span>  
    Name<span class="token operator">=</span><span class="token string">'/aboyanov/database/username/master'</span><span class="token punctuation">,</span>  
  WithDecryption<span class="token operator">=</span><span class="token boolean">True</span>  
<span class="token punctuation">)</span>  
password <span class="token operator">=</span> client<span class="token punctuation">.</span>get_parameter<span class="token punctuation">(</span>  
    Name<span class="token operator">=</span><span class="token string">'/aboyanov/database/password/master'</span><span class="token punctuation">,</span>  
  WithDecryption<span class="token operator">=</span><span class="token boolean">True</span>  
<span class="token punctuation">)</span>  
source <span class="token operator">=</span> boto3<span class="token punctuation">.</span>client<span class="token punctuation">(</span><span class="token string">'rds'</span><span class="token punctuation">,</span> region_name<span class="token operator">=</span><span class="token string">'eu-west-1'</span><span class="token punctuation">)</span>  
instances <span class="token operator">=</span> source<span class="token punctuation">.</span>describe_db_instances<span class="token punctuation">(</span>DBInstanceIdentifier<span class="token operator">=</span><span class="token string">'aboyanov'</span><span class="token punctuation">)</span>  
rds_host <span class="token operator">=</span> instances<span class="token punctuation">.</span>get<span class="token punctuation">(</span><span class="token string">'DBInstances'</span><span class="token punctuation">)</span><span class="token punctuation">[</span><span class="token number">0</span><span class="token punctuation">]</span><span class="token punctuation">.</span>get<span class="token punctuation">(</span><span class="token string">'Endpoint'</span><span class="token punctuation">)</span><span class="token punctuation">.</span>get<span class="token punctuation">(</span><span class="token string">'Address'</span><span class="token punctuation">)</span>  
<span class="token keyword">try</span><span class="token punctuation">:</span>  
    connection <span class="token operator">=</span> psycopg2<span class="token punctuation">.</span>connect<span class="token punctuation">(</span>  
        database<span class="token operator">=</span><span class="token string">"postgres"</span><span class="token punctuation">,</span>  
  user<span class="token operator">=</span>username<span class="token punctuation">.</span>get<span class="token punctuation">(</span><span class="token string">"Parameter"</span><span class="token punctuation">)</span><span class="token punctuation">.</span>get<span class="token punctuation">(</span><span class="token string">"Value"</span><span class="token punctuation">)</span><span class="token punctuation">,</span>  
  password<span class="token operator">=</span>password<span class="token punctuation">.</span>get<span class="token punctuation">(</span><span class="token string">"Parameter"</span><span class="token punctuation">)</span><span class="token punctuation">.</span>get<span class="token punctuation">(</span><span class="token string">"Value"</span><span class="token punctuation">)</span><span class="token punctuation">,</span>  
  host<span class="token operator">=</span>rds_host<span class="token punctuation">,</span>  
  port<span class="token operator">=</span><span class="token string">'5432'</span>  
  <span class="token punctuation">)</span>  
    cursor <span class="token operator">=</span> connection<span class="token punctuation">.</span>cursor<span class="token punctuation">(</span><span class="token punctuation">)</span>  
    <span class="token comment"># Print PostgreSQL Connection properties  </span>
  <span class="token keyword">print</span><span class="token punctuation">(</span><span class="token string">"\n"</span><span class="token punctuation">,</span> <span class="token string">"Connection --properties: "</span><span class="token punctuation">,</span> <span class="token string">"\n"</span><span class="token punctuation">,</span> <span class="token string">"\n"</span><span class="token punctuation">,</span> connection<span class="token punctuation">.</span>get_dsn_parameters<span class="token punctuation">(</span><span class="token punctuation">)</span><span class="token punctuation">,</span><span class="token string">"\n"</span><span class="token punctuation">)</span>  
    <span class="token comment"># Print PostgreSQL version  </span>
  cursor<span class="token punctuation">.</span>execute<span class="token punctuation">(</span><span class="token string">"SELECT version();"</span><span class="token punctuation">)</span>  
    record <span class="token operator">=</span> cursor<span class="token punctuation">.</span>fetchone<span class="token punctuation">(</span><span class="token punctuation">)</span>  
    <span class="token keyword">print</span><span class="token punctuation">(</span><span class="token string">"RDS --version: "</span><span class="token punctuation">,</span> <span class="token string">"\n"</span><span class="token punctuation">,</span> <span class="token string">"\n"</span><span class="token punctuation">,</span> record<span class="token punctuation">,</span> <span class="token string">"\n"</span><span class="token punctuation">)</span>  
<span class="token keyword">except</span> <span class="token punctuation">(</span>Exception<span class="token punctuation">,</span> psycopg2<span class="token punctuation">.</span>Error<span class="token punctuation">)</span> <span class="token keyword">as</span> error <span class="token punctuation">:</span>  
    <span class="token keyword">print</span> <span class="token punctuation">(</span><span class="token string">"Error while connecting to PostgreSQL"</span><span class="token punctuation">,</span> error<span class="token punctuation">)</span>  
<span class="token keyword">finally</span><span class="token punctuation">:</span>  
    <span class="token comment">#closing database connection.  </span>
  <span class="token keyword">if</span><span class="token punctuation">(</span>connection<span class="token punctuation">)</span><span class="token punctuation">:</span>  
        cursor<span class="token punctuation">.</span>close<span class="token punctuation">(</span><span class="token punctuation">)</span>  
        connection<span class="token punctuation">.</span>close<span class="token punctuation">(</span><span class="token punctuation">)</span>  
        <span class="token keyword">print</span><span class="token punctuation">(</span><span class="token string">"PostgreSQL connection is closed"</span><span class="token punctuation">)</span>
</code></pre>
<h2 id="links">Links:</h2>
<h4 id="git-repo-httpsgithub.comanton-boyanovinfinitelambda_devops_task.git">Git Repo: <a href="https://github.com/anton-boyanov/infinitelambda_devops_task.git">https://github.com/anton-boyanov/infinitelambda_devops_task.git</a></h4>
<h4 id="helloworld-http406296236709-devops-s3-hello-website.s3-website-eu-west-1.amazonaws.com">HelloWorld: <a href="http://406296236709-devops-s3-hello-website.s3-website-eu-west-1.amazonaws.com/">http://406296236709-devops-s3-hello-website.s3-website-eu-west-1.amazonaws.com/</a></h4>
<h4 id="jenkins-httpec2-54-216-33-251.eu-west-1.compute.amazonaws.com8080jobpython_app">Jenkins: <a href="http://ec2-54-216-33-251.eu-west-1.compute.amazonaws.com:8080/job/python_app/">http://ec2-54-216-33-251.eu-west-1.compute.amazonaws.com:8080/job/python_app/</a></h4>
<ul>
<li><strong>user</strong>: <em>aboyanov</em></li>
<li><strong>pass</strong>: <em>infinite</em></li>
</ul>
</div>
</body>

</html>