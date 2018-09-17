username=`whoami`
set -e

installDocker() {
    sudo apt-get install apt-transport-https ca-certificates curl gnupg2 software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install docker-ce
    sudo useradd $username -G docker
    echo "docker installed, you may need reboot to use it."
}

installDependencies() {
    # first, docker
    command -v docker >/dev/null 2>&1 || installDocker
}

installServer() {
    echo "installing iDECenter..."

    if [[ -d iDECenter ]]; then
        rm -rf iDECenter
    fi

    git clone git@github.com:iDECenter/iDECenter.git
}

makeDockerImage() {
    echo "downloading iDockerCenter..."

    if [[ -d iDockerCenter ]]; then
        rm -rf iDockerCenter
    fi

    git clone git@github.com:iDECenter/iDockerCenter.git

    cd iDockerCenter
    chmod +x ./build_image.sh
    ./build_image.sh
    cd ..
}

echo "WARNING: this script works on ubuntu only (now)"
installDependencies
installServer

