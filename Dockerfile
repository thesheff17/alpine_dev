FROM alpine

MAINTAINER Dan Sheffner <Dan@Sheffner.com>

# This script will create a basic dev env

RUN apk add --update \
    bash \
    build-base \
    curl \
    cyrus-sasl-dev \
    git \
    go \
    jpeg-dev \
    libc-dev \
    libffi-dev \
    libmemcached-dev \
    musl \
    postgresql-dev \
    py-pip \
    python \
    python-dev \
    python3 \
    python3-dev \
    tmux \
    vim \
    wget \
    zlib-dev \
    && rm -rf /var/cache/apk/*

# pip upgrades
RUN pip3 install --upgrade pip && pip2 install --upgrade pip

# virtualenv
RUN pip2 install virtualenvwrapper virtualenv && \
    cd /root/ && \
    /bin/bash -c "source /usr/bin/virtualenvwrapper.sh && \
    mkvirtualenv --python=/usr/bin/python3 venv3 && \
    mkvirtualenv venv2" && \
    echo "source /usr/bin/virtualenvwrapper.sh" >> /root/.bashrc

# these files get messed up for some reason venv3
RUN \
    echo "#!/bin/bash" > /root/.virtualenvs/preactivate && \
    echo "# This hook is run before every virtualenv is activated." >> /root/.virtualenvs/preactivate && \
    echo "# argument: environment name " >> /root/.virtualenvs/preactivate && \
    echo "#!/bin/bash" > /root/.virtualenvs/venv3/bin/preactivate && \
    echo "# This hook is run before this virtualenv is activated." >> /root/.virtualenvs/venv3/bin/preactivate

# these files get messed up for some reason venv2
RUN \
    echo "#!/bin/bash" > /root/.virtualenvs/preactivate && \
    echo "# This hook is run before every virtualenv is activated." >> /root/.virtualenvs/preactivate && \
    echo "# argument: environment name " >> /root/.virtualenvs/preactivate && \
    echo "#!/bin/bash" > /root/.virtualenvs/venv2/bin/preactivate && \
    echo "# This hook is run before this virtualenv is activated." >> /root/.virtualenvs/venv2/bin/preactivate

# python3 pip
RUN \
   /bin/bash -c " source /root/.virtualenvs/venv3/bin/activate && \
   pip3 install boto3 django django-environ django-secure whitenoise \
    django-braces django-crispy-forms django-floppyforms django-model-utils \
    pillow django-allauth psycopg2 unicode-slugify django-autoslug pytz django-redis \
    redis pymysql libsass django-compressor django-sass-processor django-debug-toolbar \
    django_extensions django-nose django-axes python-dateutil pyflakes coverage sphinx \
    werkzeug django-test-plus factory_boy ipdb sqlalchemy bpython pylibmc jupyter"

# python3 flask
RUN /bin/bash -c " source /root/.virtualenvs/venv3/bin/activate && \
    pip3 install flask flask-bcrypt flask-login flask-migrate flask-sqlalchemy flask-script \
    flask-testing flask-wtf mako markupsafe wtforms alembic gunicorn itsdangerous py-bcrypt "

# python2 pip
RUN \
   /bin/bash -c " source /root/.virtualenvs/venv2/bin/activate && \
   pip install boto3 django django-environ django-secure whitenoise \
    django-braces django-crispy-forms django-floppyforms django-model-utils \
    pillow django-allauth psycopg2 unicode-slugify django-autoslug pytz django-redis \
    redis pymysql libsass django-compressor django-sass-processor django-debug-toolbar \
    django_extensions django-nose django-axes python-dateutil pyflakes coverage sphinx \
    werkzeug django-test-plus factory_boy ipdb sqlalchemy bpython pylibmc jupyter "

# python2 flask
RUN /bin/bash -c " source /root/.virtualenvs/venv2/bin/activate && \
    pip install flask flask-bcrypt flask-login flask-migrate flask-sqlalchemy flask-script \
    flask-testing flask-wtf mako markupsafe wtforms alembic gunicorn itsdangerous py-bcrypt "

# vim modules
RUN mkdir -p /root/.vim/autoload /root/.vim/bundle /root/.vim/colors/ /root/.vim/ftplugin/
RUN curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
WORKDIR /root/.vim/bundle/
RUN git clone https://github.com/tpope/vim-sensible.git
RUN git clone https://github.com/ctrlpvim/ctrlp.vim.git

# project died
# RUN git clone https://github.com/kien/ctrlp.vim.git
RUN git clone https://github.com/scrooloose/nerdtree
RUN git clone https://github.com/Lokaltog/vim-powerline.git
RUN git clone https://github.com/jistr/vim-nerdtree-tabs.git
RUN git clone https://github.com/python-mode/python-mode.git
# RUN git clone --recursive https://github.com/davidhalter/jedi-vim.git
RUN git clone https://github.com/fatih/vim-go.git
RUN git clone https://github.com/vim-syntastic/syntastic.git

WORKDIR /root/.vim/colors/
RUN wget https://raw.githubusercontent.com/thesheff17/youtube/master/vim/wombat256mod.vim
WORKDIR /root/.vim/ftplugin/
RUN wget https://raw.githubusercontent.com/thesheff17/youtube/master/vim/python_editing.vim
WORKDIR /root/
RUN wget https://raw.githubusercontent.com/thesheff17/youtube/master/vim/vimrc2
RUN mv vimrc2 .vimrc

# go packages
RUN export PATH=$PATH:/usr/local/go/bin && \
    export GOPATH=/root/go/bin && \
    export GOBIN=/root/go/bin && \
    go get github.com/nsf/gocode && \
    go get github.com/alecthomas/gometalinter && \
    go get golang.org/x/tools/cmd/goimports && \
    go get golang.org/x/tools/cmd/guru && \
    go get golang.org/x/tools/cmd/gorename && \
    go get github.com/golang/lint/golint && \
    go get github.com/rogpeppe/godef && \
    go get github.com/kisielk/errcheck && \
    go get github.com/jstemmer/gotags && \
    go get github.com/klauspost/asmfmt/cmd/asmfmt && \
    go get github.com/fatih/motion && \
    go get github.com/zmb3/gogetdoc && \
    go get github.com/josharian/impl

# make share location
RUN mkdir -p /root/git/

# Copy over samples
COPY ./webserver.go /root/bin/
COPY ./webserver.py /root/bin/

# tmux setup
# ADD tmuxinator /root/.tmuxinator
RUN echo 'set-option -g default-shell /bin/bash' > /root/.tmux.conf

WORKDIR /root/
CMD ["/bin/bash"]
