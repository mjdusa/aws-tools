# aws-tools






# python-sandbox


## Setup

### PIP Setup ~/.pip/pip.conf
```bash
[global]
index-url = https://[USERNAME]@godaddy.com:[PyPI-TOKEN]@gdartifactory1.jfrog.io/artifactory/api/pypi/python-virt/simple
```

### Poetry Setup
```bash
# verify you are on the expected version of Python, currently 3.13
python --version

# update pip
python -m pip install --upgrade pip

# verify pip version
pip --version

# install poetry
pip install poetry --verbose

# setup poetry
poetry install

# verify poetry version
poetry --version

# show current poetry config
poetry config --list

# add private repository
poetry config repositories.gdartifactory https://gdartifactory1.jfrog.io/artifactory/api/pypi/python-virt/simple
poetry config http-basic.gdartifactory ${USER}@godaddy.com [PyPI Token secret from Artifactory]

# add private publishing repository
poetry config repositories.overwatch-library https://gdartifactory1.jfrog.io/artifactory/api/pypi/pypi-overwatch-plc-library-local

poetry config http-basic.overwatch-library [...parameters...]

# show current poetry config
poetry config --list
```

### Example of adding dependancies to Poetry
```bash
# Add dependancies
poetry add python gd-auth-sso gd-auth

# Add dev dependancies
poetry add --group dev  black flake8 pylint pytest pytest-spec pytest-cov

# Update poetry lock file
poetry update

# poetry.lock
poetry lock

# Update app minor version
poetry version minor

# Update app major version
poetry version major
```

### Using make to check your code changes before you check it in GitHub
```bash
# Linting
make clean

# Linting
make lint

# Checking format with black
make format-check

# Reformatting with black (not called by anything else)
make format

# Testing (calls clean, format-check & lint)
make tests

# Coverage (calls clean, format-check, lint & tests)
make cover
```

### .pypirc setup
```bash
vi ~/.pypirc

[pypi]
username = __token__
password = pypi-[TOKEN]

```

### Updating Library and Deploying
- Using the normal PR process.  Create a branch and PR for your changes.
- Make sure you update the version number of the libary in the pyproject.toml
```bash
[tool.poetry]
...
version = "0.2.0"
...
```
- Make your change(s) and have them reviewed and approved via normal PR process.
- When your changes pass all of the gates, tests, and reviews, then merge your changes into the main branch.
- Launch the Publish workflow
- Done!
