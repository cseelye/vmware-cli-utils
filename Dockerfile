FROM ubuntu:16.04
LABEL maintainer=cseelye@gmail.com

ARG OVFTOOL=VMware-ovftool*
ARG PERL_AUTO_SDK=VMware-vSphere-Automation-SDK-Perl-*
ARG PERL_SDK=VMware-vSphere-Perl-SDK-*
ARG PYTHON_AUTO_SDK=VMware-vSphere-Automation-SDK-Python-*
ARG BASE_DIR=/root

# Install ovftool
COPY [ "$OVFTOOL", "/tmp" ]
RUN echo "ovftool: Installing prerequisites" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        ca-certificates \
        openssl && \
    echo "ovftool: Installing ovftool" && \
    /bin/bash "$(find /tmp -name "$OVFTOOL" -print -quit)" --eulas-agreed --console --required && \
    echo "ovftool: Cleaning up" && \
    apt-get autoremove --assume-yes && \
    apt-get clean && \
    rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install PERL_SDK / Perl SDK and Perl Automation SDK
COPY [ "$PERL_SDK", "$PERL_AUTO_SDK", "/tmp/" ]
ENV VMWARE_PERL_AUTO_SDK_HOME=$BASE_DIR/VMware-vSphere-Automation-SDK-Perl ftp_proxy= http_proxy=
RUN echo "PERL_SDK and Perl SDKs: Installing prerequisites" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        build-essential \
        cpanminus \
        curl \
        e2fsprogs \
        expect \
        gcc \
        gcc-multilib \
        kmod \
        inetutils-ping \
        libxml-libxml-perl \
        libssl-dev \
        libcurl3 \
        libunwind8 \
        libicu55 \
        libarchive-zip-perl \
        libcrypt-ssleay-perl \
        libclass-methodmaker-perl \
        libdevel-stacktrace-perl \
        libclass-data-inheritable-perl \
        libconvert-asn1-perl \
        libcrypt-openssl-rsa-perl \
        libcrypt-x509-perl \
        libexception-class-perl \
        libpath-class-perl \
        libuuid-perl \
        libsocket6-perl \
        libio-socket-inet6-perl \
        libdata-dump-perl \
        libsoap-lite-perl \
        libmodule-build-perl \
        perl \
        perl-doc \
        unzip \
        uuid \
        uuid-dev && \
    cpanm ExtUtils::MakeMaker@6.96 Module::Build@0.4205 Net::FTP@2.77 LWP::Protocol::https@6.04 UUID::Random Try::Tiny Net::INET6Glue && \
    echo "PERL_SDK and Perl SDKs: Configuring CPAN for VMware installer" && \
    (echo y; echo o conf prerequisites_policy follow; echo o conf build_cache 50; echo o conf commit;) | cpan && \
    echo "PERL_SDK and Perl SDKs: Installing vSphere PERL_SDK and Perl SDK" && \
    tar xzf /tmp/$PERL_SDK -C /tmp && \
    sed -e "s|get_answer('Do you want to continue? (yes/no)', 'yesno', '')|get_answer('Do you want to continue? (yes/no)', 'yesno', 'yes')|g" -i /tmp/vmware-vsphere-cli-distrib/vmware-install.pl && \
    /tmp/vmware-vsphere-cli-distrib/vmware-install.pl -d EULA_AGREED=yes && \
    rm --force --recursive /tmp/vmware-vsphere-cli-distrib/ && \
    echo "PERL_SDK and Perl SDKs: Installing vSphere Perl Automation SDK" && \
    unzip -q /tmp/"$PERL_AUTO_SDK" -d $BASE_DIR && \
    ln --symbolic $(find $BASE_DIR -type d -name "$PERL_AUTO_SDK" -print -quit) $VMWARE_PERL_AUTO_SDK_HOME && \
    rm --force --recursive /tmp/"$PERL_AUTO_SDK" && \
    echo "PERL_SDK and Perl SDKs: Cleaning up" && \
    apt-get autoremove --assume-yes && \
    apt-get clean && \
    rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*
ENV PERL5LIB=$PERL5LIB:$VMWARE_PERL_AUTO_SDK_HOME/client/lib/sdk:$VMWARE_PERL_AUTO_SDK_HOME/client/lib/runtime:$VMWARE_PERL_AUTO_SDK_HOME/client/samples


# Install Python SDK (pyvmomi) and Python Automation SDK
ARG REQUIRED_PYTHON_MODULES="lxml pyOpenSSL requests simplejson urllib3 virtualenv werkzeug"
ARG VMWARE_PYTHON_AUTO_SDK_HOME=$BASE_DIR/VMware-vSphere-Automation-SDK-Python
COPY [ "$PYTHON_AUTO_SDK", "/tmp" ]
RUN echo "Python SDK: Installing prerequisites" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        ca-certificates \
        curl \
        libffi-dev \
        libssl-dev \
        python \
        python-dev \
        python3 \
        python3-dev \
        unzip && \
    echo "Python SDK: Setting up python3 and installing prerequisites" && \
    curl https://bootstrap.pypa.io/get-pip.py | python3 && \
    pip3 install --upgrade six && \
    pip3 install --upgrade $REQUIRED_PYTHON_MODULES suds-py3 suds-jurko && \
    echo "Python SDK: Setting up python2 and installing prerequisites" && \
    curl https://bootstrap.pypa.io/get-pip.py | python && \
    pip2 install --upgrade six && \
    pip2 install --upgrade $REQUIRED_PYTHON_MODULES suds && \
    echo "Python SDK: Extracting vSphere Python Automation SDK" && \
    unzip /tmp/"$PYTHON_AUTO_SDK" -d $BASE_DIR && \
    ln --symbolic $(find $BASE_DIR -type d -name "$PYTHON_AUTO_SDK" -print -quit) $VMWARE_PYTHON_AUTO_SDK_HOME && \
    echo "Python SDK: Installing vSphere Python SDK/Automation SDK for python2" && \
    pip2 install pyvmomi && \
    pip2 install $VMWARE_PYTHON_AUTO_SDK_HOME/client/lib/vapi_runtime-2.5.0.zip && \
    pip2 install $VMWARE_PYTHON_AUTO_SDK_HOME/client/lib/vapi_common_client-2.5.0.zip && \
    pip2 install $VMWARE_PYTHON_AUTO_SDK_HOME/client/lib/vapi_client_bindings-2.5.0.zip && \
    echo "Python SDK: Installing vSphere Python SDK/Automation SDK for python3" && \
    pip3 install pyvmomi && \
    pip3 install $VMWARE_PYTHON_AUTO_SDK_HOME/client/lib/vapi_runtime-2.5.0.zip && \
    pip3 install $VMWARE_PYTHON_AUTO_SDK_HOME/client/lib/vapi_common_client-2.5.0.zip && \
    pip3 install $VMWARE_PYTHON_AUTO_SDK_HOME/client/lib/vapi_client_bindings-2.5.0.zip && \
    echo "Python SDK: Cleaning up" && \
    apt-get autoremove --assume-yes && \
    apt-get clean && \
    rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Install PowerCLI
# As of this writing (12/11/2017) the linux version of PowerCLI (PowerCLI Core) only works on the alpha versions of PowerShell Core, not the beta or RC
RUN echo "PowerCLI: Installing prerequisites" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        jq \
        libcurl3 \
        libicu55 \
        liblttng-ust0 \
        libunwind8 \
        unzip && \
    echo "PowerCLI: Installing Powershell alpha18" && \
    curl --location https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.18/powershell_6.0.0-alpha.18-1ubuntu1.16.04.1_amd64.deb -o /tmp/powershell.deb && \
    dpkg-deb --info /tmp/powershell.deb && \
    dpkg --install /tmp/powershell.deb; \
    apt-get install --fix-broken && \
    echo "PowerCLI: Installing vSphere PowerCLI" && \
    curl --location https://download3.vmware.com/software/vmw-tools/powerclicore/PowerCLI_Core.zip -o /tmp/powercli.zip && \
    unzip -q /tmp/powercli.zip -d /tmp/powercli && \
    mkdir --parents /root/.local/share/powershell/Modules && \
    mv /tmp/powercli/PowerCLI* /root/.local/share/powershell/Modules/ && \
    cd /root/.local/share/powershell/Modules && \
    unzip -q PowerCLI.ViCore.zip && \
    unzip -q PowerCLI.Vds.zip && \
    mkdir --parents /root/.config/powershell/ && \
    cp /tmp/powercli/Start-PowerCLI.ps1 /root/.config/powershell/Microsoft.PowerShell_profile.ps1 && \
    echo "PowerCLI: Cleaning up" && \
    apt-get autoremove --assume-yes && \
    apt-get clean && \
    rm --force --recursive /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Community samples
RUN echo "Community Samples: installing" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --assume-yes --no-install-recommends \
        ca-certificates \
        git && \
    mkdir --parents $BASE_DIR/samples && \
    git clone https://github.com/vmware/PowerCLI-Example-Scripts.git $BASE_DIR/samples/PowerCLI-Example-Scripts  && \
    git clone https://github.com/vmware/pyvmomi-community-samples.git $BASE_DIR/samples/pyvmomi-community-samples && \
    pip2 install --upgrade --requirement $BASE_DIR/samples/pyvmomi-community-samples/requirements.txt && \
    pip2 install --upgrade pyOpenSSL && \
    pip3 install --upgrade --requirement $BASE_DIR/samples/pyvmomi-community-samples/requirements.txt && \
    pip3 install --upgrade pyOpenSSL


WORKDIR /root
CMD [ "/bin/bash" ]
