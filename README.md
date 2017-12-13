# vmware-cli-utils
Container for hosting VMware command line management tools and SDKs. This was inspired by https://github.com/lamw/vmware-utils but a smaller version and designed to be easier to customize/update to different versions of VMware utilities.

This container includes PowerShell Core/PowerCLI Core, ovftool, esxcli, the Perl SDK and Perl Automation SDK, the Python SDK/Python Automation SDK, and the VMware community samples repo for PowerCLI and the Python SDK. If you prefer other languages they are easy to add.

## Building
* VMware's license wall prevents the build from automatically downloading the installers for most of these tools, so you'll need to do it yourself. See below for links.
* SDKs and samples are installed under the base directory `/root` by default. You can change this with the build arg `BASE_DIR`.
* The Dockerfile defaults to filenames like `VMware-ovftool*` as the name of the installer(s). If you have more than one version of a particular installer in the working directory, the first one will be installed. If your filename does not match this, or for some other reason you want to explicitly set the installer to use, then use a build arg to set the name of the file. See the Dockerfile for a list of all the supported build args. For example, the Perl SDK build arg would look like this:

```--build-arg PERL_SDK=VMware-vSphere-Perl-SDK-X.Y.Z-1234567.x86_64.tar.gz```

* Build the container in the standard way, optionally using the build-args if you need:

```docker build -t vmware-cli-utils .```

## Usage
The default CMD of the container is a Bash shell so you can use it interactively.  You will probably find it convenient to mount your home directory into the container so you have access to your files.

Example:
```docker run -it --rm -v /home/cseelye:/root/myhome vmware-cli-utils```

## Sources for VMware installers
These are links to the most recent vSphere 6.5 versions of these tools, at the time this README was written. You may need to find more recent builds for your purposes.
* ovftool https://my.vmware.com/group/vmware/details?downloadGroup=OVFTOOL420&productId=614
* vCLI and the Perl SDK https://my.vmware.com/group/vmware/details?downloadGroup=VS-PERL-SDK65&productId=614
* Perl Automation SDK https://my.vmware.com/group/vmware/details?downloadGroup=VS-AUTOMATIONSDK-PERL65&productId=614
* Python Automation SDK https://my.vmware.com/group/vmware/details?downloadGroup=VS-AUTOMATIONSDK-PYTHON65&productId=614
