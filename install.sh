username=`whoami`
set -e

installDocker() {
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo useradd $username -a -G docker
    echo "docker installed, you may need reboot to use it."
}

installDependencies() {
    sudo apt-get update
    sudo apt-get upgrade -y

    # first, docker
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
    command -v docker >/dev/null 2>&1 || installDocker

    # then dotnet
    wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt-get -y install apt-transport-https
    sudo apt-get update
    sudo apt-get -y install dotnet-sdk-2.1

    sudo apt-get install -y nodejs npm git # in case ...
}

installServer() {
    echo "::::installing iDECenter..."

    if [[ -d iDECenter ]]; then
        rm -rf iDECenter
    fi

    git clone git://github.com/iDECenter/iDECenter.git
    cd iDECenter
    npm install
    node dbcreator.js
    cd ..
}

makeDockerImage() {
    echo "::::downloading iDockerCenter..."

    if [[ -d iDockerCenter ]]; then
        rm -rf iDockerCenter
    fi

    git clone git://github.com/iDECenter/iDockerCenter.git

    cd iDockerCenter
    chmod +x ./build_image.sh
    echo "::::building docker image..."
    ./build_image.sh
    cd ..
}

installDaemon() {
    echo "::::installing iDaemonCenter"

    if [[ -d iDaemonCenter ]]; then
        rm -rf iDaemonCenter
    fi

    git clone git://github.com/iDECenter/iDaemonCenter.git
    dotnet build iDaemonCenter/iDaemonCenter/iDaemonCenter.csproj -o ../..
}

makeTemplates() {
    echo "::::making templates"

    cd template
    chmod +x get_mbed_wb.sh
    ./get_mbed_wb.sh
    cd ..
}

echo "::::WARNING: this script works on ubuntu only (now)"
installDependencies
installServer
cd iDECenter

while true; do
    read -p "::::build docker image now(Y) or use pre-built image(N, default)?" c

    if [[ $c == "Y" || $c == "y" ]]; then
        makeDockerImage
        break
    fi

    if [[ $c == "N" || $c == "n" || $c == "" ]]; then
        echo "::::use pre-built image"
        break
    fi
done

installDaemon
makeTemplates
