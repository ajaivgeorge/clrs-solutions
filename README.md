# cpp_starter_project
[![CMake](https://github.com/ajaivgeorge/cpp_starter_project/actions/workflows/build_cmake.yml/badge.svg)](https://github.com/ajaivgeorge/cpp_starter_project/actions/workflows/build_cmake.yml)
[![codecov](https://codecov.io/gh/ajaivgeorge/cpp_starter_project/branch/main/graph/badge.svg?token=TOLC1XFLHQ)](https://codecov.io/gh/ajaivgeorge/cpp_starter_project)

## Getting Started

### Use the Github template
First, click the green `Use this template` button near the top of this page.
This will take you to Github's ['Generate Repository'](https://github.com/cpp-best-practices/cpp_starter_project/generate) page.
Fill in a repository name and short description, and click 'Create repository from template'.
This will allow you to create a new repository in your Github account,
prepopulated with the contents of this project.
Now you can clone the project locally and get to work!

    git clone https://github.com/<user>/<your_new_repo>.git

## Dependencies

Note about install commands:
- In case of an error in cmake, make sure that the dependencies are on the PATH.


### Too Long, Didn't Install

This is a really long list of dependencies, and it's easy to mess up.
That's why we have a Docker image that's already set up for you.
See the [Docker instructions](#docker-instructions) below.


### Necessary Dependencies
1. A C++ compiler that supports C++17.
See [cppreference.com](https://en.cppreference.com/w/cpp/compiler_support)
to see which features are supported by each compiler.
The following compilers should work:

  * [gcc 7+](https://gcc.gnu.org/)
	<details>
	<summary>Install command</summary>

	- Debian/Ubuntu:

			sudo apt install build-essential

	- Windows:

			choco install mingw -y

	- MacOS:

			brew install gcc
	</details>

  * [clang 6+](https://clang.llvm.org/)
	<details>
	<summary>Install command</summary>

	- Debian/Ubuntu:

			bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

	- Windows:

		Visual Studio 2019 ships with LLVM (see the Visual Studio section). However, to install LLVM separately:

			choco install llvm -y

		llvm-utils for using external LLVM with Visual Studio generator:

			git clone https://github.com/zufuliu/llvm-utils.git
			cd llvm-utils/VS2017
			.\install.bat

	- MacOS:

			brew install llvm
	</details>


2. [Conan](https://conan.io/)
	<details>
	<summary>Install Command</summary>

	- Via pip - https://docs.conan.io/en/latest/installation.html#install-with-pip-recommended

			pip install --user conan

	</details>

3. [CMake 3.15+](https://cmake.org/)
	<details>
	<summary>Install Command</summary>

	- Debian/Ubuntu:

			sudo apt-get install cmake

	</details>

### Optional Dependencies
#### C++ Tools
  * [Doxygen](http://doxygen.nl/)
	<details>
	<summary>Install Command</summary>

	- Debian/Ubuntu:

			sudo apt-get install doxygen
			sudo apt-get install graphviz

	</details>


  * [ccache](https://ccache.dev/)
	<details>
	<summary>Install Command</summary>

	- Debian/Ubuntu:

			sudo apt-get install ccache

	</details>


  * [Cppcheck](http://cppcheck.sourceforge.net/)
	<details>
	<summary>Install Command</summary>

	- Debian/Ubuntu:

			sudo apt-get install cppcheck

	</details>


  * [include-what-you-use](https://include-what-you-use.org/)
	<details>
	<summary>Install Command</summary>

	Follow instructions here:
	https://github.com/include-what-you-use/include-what-you-use#how-to-install
	</details>

## Build Instructions

A full build has different steps:
1) Specifying the compiler using environment variables
2) Configuring the project
3) Building the project

For the subsequent builds, in case you change the source code, you only need to repeat the last step.

### (1) Specify the compiler using environment variables

By default (if you don't set environment variables `CC` and `CXX`), the system default compiler will be used.

Conan and CMake use the environment variables CC and CXX to decide which compiler to use. So to avoid the conflict issues only specify the compilers using these variables.

CMake will detect which compiler was used to build each of the Conan targets. If you build all of your Conan targets with one compiler, and then build your CMake targets with a different compiler, the project may fail to build.

<details>
<summary>Commands for setting the compilers </summary>

- Debian/Ubuntu:

	Set your desired compiler (`clang`, `gcc`, etc):

	- Temporarily (only for the current shell)

		Run one of the followings in the terminal:

		- clang

				CC=clang CXX=clang++

		- gcc

				CC=gcc CXX=g++

	- Permanent:

		Open `~/.bashrc` using your text editor:

			gedit ~/.bashrc

		Add `CC` and `CXX` to point to the compilers:

			export CC=clang
			export CXX=clang++

		Save and close the file.

</details>

### (2) Configure your build

To configure the project, you could use `cmake`, or `ccmake` or `cmake-gui`. Each of them are explained in the following:

#### (2.a) Configuring via cmake:
With Cmake directly:

    cmake -S . -B ./build

Cmake will automatically create the `./build` folder if it does not exist, and it wil configure the project.

#### (2.b) Configuring via ccmake:

With the Cmake Curses Dialog Command Line tool:

    ccmake -S . -B ./build

Once `ccmake` has finished setting up, press 'c' to configure the project,
press 'g' to generate, and 'q' to quit.

#### (2.c) Configuring via cmake-gui:

To use the GUI of the cmake:

2.c.1) Open cmake-gui from the project directory:
```
cmake-gui .
```
2.c.2) Set the build directory:

![build_dir](https://user-images.githubusercontent.com/16418197/82524586-fa48e380-9af4-11ea-8514-4e18a063d8eb.jpg)

2.c.3) Configure the generator:

In cmake-gui, from the upper menu select `Tools/Configure`.

**Warning**: if you have set `CC` and `CXX` always choose the `use default native compilers` option. This picks `CC` and `CXX`. Don't change the compiler at this stage!

2.c.4) Choose the Cmake options and then generate:

![generate](https://user-images.githubusercontent.com/16418197/82781591-c97feb80-9e1f-11ea-86c8-f2748b96f516.png)

### (3) Build the project
Once you have selected all the options you would like to use, you can build the
project (all targets):

    cmake --build ./build


### Running the tests

You can use the `ctest` command run the tests.

```shell
cd ./build
ctest -C Debug
cd ../
```

## Troubleshooting

### Update Conan
Many problems that users have can be resolved by updating Conan, so if you are
having any trouble with this project, you should start by doing that.

To update conan:

    pip install --user --upgrade conan

You may need to use `pip3` instead of `pip` in this command, depending on your
platform.

### Clear Conan cache
If you continue to have trouble with your Conan dependencies, you can try
clearing your Conan cache:

    conan remove -f '*'

The next time you run `cmake` or `cmake --build`, your Conan dependencies will
be rebuilt. If you aren't using your system's default compiler, don't forget to
set the CC, CXX, CMAKE_C_COMPILER, and CMAKE_CXX_COMPILER variables, as
described in the 'Build using an alternate compiler' section above.

### Identifying misconfiguration of Conan dependencies

If you have a dependency 'A' that requires a specific version of another
dependency 'B', and your project is trying to use the wrong version of
dependency 'B', Conan will produce warnings about this configuration error
when you run CMake. These warnings can easily get lost between a couple
hundred or thousand lines of output, depending on the size of your project.

If your project has a Conan configuration error, you can use `conan info` to
find it. `conan info` displays information about the dependency graph of your
project, with colorized output in some terminals.

    cd build
    conan info .

In my terminal, the first couple lines of `conan info`'s output show all of the
project's configuration warnings in a bright yellow font.

For example, the package `spdlog/1.5.0` depends on the package `fmt/6.1.2`.
If you were to modify the file `conanfile.py` so that it requires an
earlier version of `fmt`, such as `fmt/6.0.0`, and then run:

```bash
conan remove -f '*'       # clear Conan cache
rm -rf build              # clear previous CMake build
cmake -S . -B ./build     # rebuild Conan dependencies
conan info ./build
```

...the first line of output would be a warning that `spdlog` needs a more recent
version of `fmt`.

## Testing
See [gtest](https://google.github.io/googletest/)

## Docker Instructions

If you have [Docker](https://www.docker.com/) installed, you can run this
in your terminal, when the Dockerfile is in your working directory:

```bash
docker build --tag=my_project:latest .
docker run -it -v /path/to/code:/home/dev/work my_project:latest
```

This command will put you in a `bash` session in a Ubuntu 18.04 Docker container,
with all of the tools listed in the [Dependencies](#dependencies) section already installed.
Additionally, you will have `g++-10` and `clang++-11` installed as the default
versions of `g++` and `clang++`.

If you want to build this container using some other versions of gcc and clang,
you may do so with the `gcc_version` and `llvm_version` arguments:

```bash
docker build --tag=myproject:latest --build-arg gcc_version=9 --build-arg llvm_version=10 .
```

The CC and CXX environment variables are set to GCC version 10 by default.
If you wish to use clang as your default CC and CXX environment variables, you
may do so like this:

```bash
docker build --tag=my_project:latest --build-arg use_clang=1 .
```

You will be logged in as dev, so you will see the `#` symbol as your prompt.
You will be in the home directory that contains a copy of the `cpp_starter_project`;
any changes you make to your local copy will be updated in the Docker image.
You need to mount your local copy directly in the Docker image, see
[Docker volumes docs](https://docs.docker.com/storage/volumes/).
TLDR:

```bash
docker run -it \
	-v absolute_path_on_host_machine:absolute_path_in_guest_container \
	my_project:latest
```

You can configure and build [as directed above](#build) using these commands:

```bash
/starter_project# mkdir build
/starter_project# cmake -S . -B ./build
/starter_project# cmake --build ./build
```

You can configure and build using `clang-12`, without rebuilding the container,
with these commands:

```bash
/starter_project# mkdir build
/starter_project# CC=clang CXX=clang++ cmake -S . -B ./build
/starter_project# cmake --build ./build
```

The `ccmake` tool is also installed; you can substitute `ccmake` for `cmake` to
configure the project interactively.
All of the tools this project supports are installed in the Docker image;
enabling them is as simple as flipping a switch using the `ccmake` interface.
Be aware that some of the sanitizers conflict with each other, so be sure to
run them separately.
