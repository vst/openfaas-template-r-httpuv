# OpenFaaS Template using R httpuv Application as Upstream

![](https://img.shields.io/github/v/release/vst/openfaas-template-r-httpuv)

This template provides an R function which uses new style
`watchdog` (`of-watchdog`):

1. Multiple endpoints can be defined for functions using this template.
2. (Almost) all essential Web application functionalities are
   available (various HTTP verbs, full control over HTTP headers etc).

## Background

R is not officially supported by OpenFaaS. I couldn't find any
production-ready community templates around. Therefore, I have created
this OpenFaaS template based on
[httpuv](https://cran.r-project.org/web/packages/httpuv/index.html)
library which is used by frameworks like
[Shiny](https://shiny.rstudio.com/) and
[OpenCPU](https://www.opencpu.org/) under the hood.

## Development Requirements

1. R
2. R packages `httpuv` and `jsonlite`
3. Docker
4. OpenFaaS CLI

## Quickstart

You can create a new OpenFaaS function alongside with your existing
functions (existing stack), or start a new stack, or create a
standalone repository for a single new function.

For the first scenario:

```
cd <existing-stack-directory>
```

... and for the latter two:

```
mkdir <new-directory>
cd <new-directory>
```

Now, we are ready to pull the R-based template and create our
function.

Let's pull the R-based template first:

```
faas-cli template pull "https://github.com/vst/openfaas-template-r-httpuv#0.0.4"
```

... then create our function using the pulled `vst-r-httpuv` template:

```
faas-cli new my-r-function --lang vst-r-httpuv
```

## Testing Locally

You don't need OpenFaaS to develop and test your function. Actually,
you don't even need Docker during development. In this section, we
will test our function both with and without Docker.

### Testing Locally without Docker

This scenario applies to most of your development time span. If you
have required R packages installed, you can run your server locally.

Required R packages are:

1. `jsonlite`
2. `httpuv`

You can install them on Debian/Ubuntu:

```
sudo apt install r-cran-httpuv r-cran-jsonlite
```

... or directly using R:

```
install.packages(c("httpuv", "jsonlite"))
```

> **NOTE:** This template's final OpenFaaS-ready Docker image uses
> Debian and installs most packages using `apt-get`.

You can now run your server which will run on port `5000` by default
(you need to change to `my-r-function` directory first):

```
Rscript run.R
```

... and see endpoints:

1. Hello World: [http://localhost:5000/](http://localhost:5000/)
2. Hello `<something>`: [http://localhost:5000/something](http://localhost:5000/something)
3. Version information: [http://localhost:5000/version](http://localhost:5000/version)

As you should have noted, a single R OpenFaaS Function is capable of
handling dynamic sub-routes and serve multiple functions for each of
them.

### Testing Locally with Docker

Once you are ready for deployment, I advise you to test using Docker,
too, as we want to make sure that all dependencies are satisfied and
we are production ready:

```
faas-cli build -f my-r-function.yml
```

After this, you should have your function build as a Docker image
which you can test locally. We will use port `5001` this time:

```
docker run --rm -p 5001:8080 my-r-function
```

You can see endpoints now:

1. Hello World: [http://localhost:5001/](http://localhost:5001/)
2. Hello `<something>`: [http://localhost:5001/something](http://localhost:5001/something)
3. Version information: [http://localhost:5001/version](http://localhost:5001/version)

## Deploying your function...

... should be as easy as:

```
faas-cli up -a -f my-first-function.yml
```

## Notes about implementing your function

- `./run.R` file is a file you will unlikely need to touch.
- `./framework.R` file is a file you will unlikely need to touch.
- `./library.R` file is where the business logic lives and it should
  always stay agnostic to the platform the application is deployed to,
  ie. definitions in this library ideally should know nothing about
  Web programming.
- `./application.R` file contains HTTP route handlers which map HTTP
  requests to R functions. This is the file where you will bind routes
  to your business logic which is defined under the `./library.R` file.

## Customising the Docker build

Check out `./function/.build` directory. You can define additional
Debian packages to be installed under `packages.apt` and perform
additional setup procedure under `setup.sh` and `setup.R` if required.
