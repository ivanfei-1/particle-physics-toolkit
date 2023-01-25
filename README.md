# particle-physics-toolkit
 Dockerfile to create the particle physics simulation env
 
本镜像**使用 Ubuntu 22.04 作为基础镜像**。

拉取镜像

    $ docker pull ivanfei/particle-physics-pack

运行镜像：

    $ docker run -it ivanfei/particle-physics-pack bash

默认情况下，容器已经安装好了 MadGraph 以及其他东西需要的一切准备工作，默认使用 root 账户，如果你希望使用其他非 root 账户，可以自己创建账户并将 `\root` 中的 MadGraph 目录复制到新账户的目录下。

### 安装 Pythia8

在容器中，进入你安装 MadGraph 的目录（默认在 `/root` 中），执行

    $ ./MG5_aMC_v3_4_1/bin/mg5_aMC

进入 MadGraph 的命令行界面，执行

    > install pythia8

中途会让你另开一个终端输入命令，在 **你的电脑（而不是容器中）** 新开一个终端窗口，执行

    $ docker container ls

找到你的容器 CONTAINER ID（记作 <container_id>）之后，执行

    $ docker exec -it <container_id> bash

以新开一个容器窗口，之后在其中执行

    $ tail -f /root/MG5_aMC_v3_4_1/HEPTools/MG5aMC_PY8_interface/mg5amc_py8_interface_install.log

以继续安装 Pythia
等着个窗口出现 `Finished PYTHIA8 installation`，回到之前的窗口，看到出现绿色字 `mg5amc_py8_interface successfully installed in /root/MG5_aMC_v3_4_1/HEPTools.` 即为安装成功。

### 安装 Delphes

好消息！困难的部分过去了，现在只需要在 MadGraph 中执行

    > install Delphes

等待安装完毕即可。

至此，三件套已经安装完毕，你可以开始快乐粒子了。
