FROM xxx/aipaas/cuda:10.1-runtime-centos7-catch
ENV PATH $PATH:/usr/local/python3/bin/
ENV PYTHONIOENCODING utf-8
RUN set -ex \
	# 替换yum源
	&& mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
	&& curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo \
	&& sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo \
	# 安装python依赖库
	&& yum makecache \
	&& yum -y install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make wget \
	&& yum clean all \
	&& rm -rf /var/cache/yum \
	# 下载安装python3
 	&& wget https://www.python.org/ftp/python/3.6.4/Python-3.6.4.tgz \
#    && wget http://mirrors.sohu.com/python/3.6.4/Python-3.6.4.tgz \
	&& mkdir -p /usr/local/python3 \
	&& tar -zxvf Python-3.6.4.tgz \
	&& cd Python-3.6.4 \
	&& ./configure --prefix=/usr/local/python3 \
	&& make && make install && make clean \
	# 修改pip默认镜像源
	&& mkdir -p ~/.pip \
	&& echo '[global]' > ~/.pip/pip.conf \
	&& echo 'index-url = https://pypi.tuna.tsinghua.edu.cn/simple' >> ~/.pip/pip.conf \
	&& echo 'trusted-host = pypi.tuna.tsinghua.edu.cn' >> ~/.pip/pip.conf \
	&& echo 'timeout = 120' >> ~/.pip/pip.conf \
	# 更新pip
	&& pip3 install --upgrade pip \
	# 安装wheel
	&& pip3 install wheel \
	# 删除安装包
	&& cd .. \
	&& rm -rf /Python* \
	&& find / -name "*.py[co]" -exec rm '{}' ';' \
	# 设置系统时区
	&& rm -rf /etc/localtime \
	&& ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

COPY . /baseinfo_metrics

WORKDIR /baseinfo_metrics

RUN pip install -r requirements.txt

CMD ["python3", "./metrics/main.py"]