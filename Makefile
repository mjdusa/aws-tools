# Use bash syntax
SHELL=/bin/bash

BUILD_TS:=$(shell date -u +"%Y-%m-%d_%H%M%S%Z")
DIST_DIR:=./dist/
SRC_DIR:=./src/
TESTS_DIR:=./tests/

# Git parameters
GIT_BRANCH:=$(shell git rev-parse --abbrev-ref HEAD)
GIT_COMMIT:=$(shell git rev-parse HEAD)

REPO_NAME:="todo"
REPO_UID:="${ARTIFACTORY_USERNAME}"
REPO_PWD:="${ARTIFACTORY_PASSWORD}"

FILES_TO_CHECK = *.py

.PHONY: default
default: usage

.PHONY: init
init:
	poetry self update

.PHONY: clean
clean:
	rm *.log || true
	rm -rf MANIFEST
	rm -rf report.xml
	rm -rf coverage.xml
	rm -rf .coverage
	rm -rf .pytest*
	rm -rf cdk.out
	rm -rf ${DIST_DIR} || true
	find . -name .DS_Store -exec rm -rf {} \; || true
	find . -name __pycache__ -exec rm -rf {} \; || true
	find ${SRC_DIR} -name "*.pyc" -exec rm -rf {} \; || true
	find ${TESTS_DIR} -name "*.pyc" -exec rm -rf {} \; || true

.PHONY: clear-cache
clear-cache:
	poetry cache clear PyPI --all --no-interaction

.PHONY: update-requirements
update-requirements:
	poetry self add poetry-plugin-export
	poetry export --without-hashes -f requirements.txt --output requirements.txt

.PHONY: format
format:
	poetry run black ${SRC_DIR} ${TESTS_DIR}

.PHONY: ruff
ruff:
	poetry run ruff check ${SRC_DIR} ${TESTS_DIR}

.PHONY: flake8
flake8:
	poetry run flake8 ${SRC_DIR} ${TESTS_DIR}

.PHONY: black
black:
	poetry run black --check --diff ${SRC_DIR} ${TESTS_DIR}

.PHONY: pylint
pylint:
	poetry run pylint ${SRC_DIR} ${TESTS_DIR} --rcfile=./.github/linters/.python-lint

.PHONY: lint
lint: ruff flake8 black pylint

.PHONY: unit-tests
unit-tests:
	poetry run py.test \
 	  -vvv \
 	  --cov-config .coveragerc \
 	  --cov-report xml:coverage.xml \
	  --cov=${SRC_DIR} \
 	  ${TESTS_DIR}/unit

.PHONY: int-tests
int-tests:
	poetry run py.test \
 	  -vvv \
 	  --cov-config .coveragerc \
 	  --cov-report xml:coverage.xml \
	  --cov=${SRC_DIR} \
 	  ${TESTS_DIR}/integration

.PHONY: tests
tests: clean lint unit-tests int-tests

.PHONY: cover
cover: clean lint
	poetry run coverage run -m pytest -vv --runslow
	poetry run coverage xml

.PHONY: publish
publish: clean
	poetry publish --build -vvv --repository="${REPO_NAME}" --username="${REPO_UID}" --password="${REPO_PWD}"

.PHONY: ldaper
ldaper: clean init clear-cache update-requirements lint tests cover
	python ./src/ldaper/ldaper.py

.PHONY: get_password
get_password: clean init clear-cache update-requirements lint tests cover
	python ./src/auth/get_password.py

.PHONY: all
all: clean init clear-cache update-requirements lint tests cover

.PHONY: usage
usage:
	@echo "usage:"
	@echo "  make [command]"
	@echo "available commands:"
	@echo "  all - clean init clear-cache update-requirements lint tests cover"	
	@echo "  clean - clean up build artifacts"
	@echo "  cover - generate coverage report"
	@echo "  format - format code"
	@echo "  help - show usage"
	@echo "  install - install latest build app dependancies (ie: golangci-lint, gcov2lcov)"
	@echo "  lint - run all linter checks"
	@echo "  publish - publish the lib"
	@echo "  tests - run all tests"
	@echo "  usage - show this information"

.PHONY: help
help: usage
