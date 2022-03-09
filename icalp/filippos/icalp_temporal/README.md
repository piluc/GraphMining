1. Clone repository: `https://gitlab.com/tgpublic/twc.`
2. Download Eigen3 library: `git clone https://gitlab.com/libeigen/eigen.git`
3. Set the environment variable EIGEN3_INCLUDE_DIR to the Eigen3 folder.
For example: `export EIGEN3_INCLUDE_DIR=/home/user/Downloads/eigen-3.3.7`
4. In the folder source/twc run:
```
mkdir cmake-build-release
cd cmake-build-release
cmake -DCMAKE_BUILD_TYPE=Release ..
make
```
5. Run: `./twc $PATH/twc-main/datasets/icalp.txt 0 -u=0 -k=10 -c=0 -a=0.1`
