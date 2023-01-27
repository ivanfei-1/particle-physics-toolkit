# particle-physics-toolkit
 Dockerfile to create the particle physics simulation env.
 Based on Ubuntu 22.04 and MG5 3.4.2, also includes Anaconda3.
 
本镜像使用 **Ubuntu 22.04** 作为基础镜像, MadGraph 版本 3.4.2, 同时包含 Anaconda3 作为 python 环境。

拉取镜像

    $ docker pull ivanfei/particle-physics-pack

运行镜像：

    $ docker run -it ivanfei/particle-physics-pack bash

默认情况下，容器已经安装好了 MadGraph 以及其他东西需要的一切准备工作，默认使用 root 账户，如果你希望使用其他非 root 账户，可以自己创建账户并将 `\root` 中的 MadGraph 目录复制到新账户的目录下。

至此，三件套已经安装完毕，你可以开始快乐粒子了。
